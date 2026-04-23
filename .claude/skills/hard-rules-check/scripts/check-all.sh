#!/usr/bin/env bash
# Hard Rules compliance check (v4 — 8 rules).
# Exits 0 if all rules pass, non-zero with a short failure summary otherwise.
# Each check runs independently; all are evaluated so we report every failure.
#
# v4 ruleset:
#   1. Australian spelling                   (content gate)
#   2. Starters generic and boot clean       (merged v3 #2 + #3)
#   3. Spec-before-Ship                      (merged v3 #5 + #6)
#   4. Templates versioned, not edited       (v3 #7 with [release]/env escapes)
#   5. Descriptive profiles, not prescriptive (merged v3 #8 + #9)
#   6–8. Meta-principles (progressive disclosure, context economy, gates over
#        guidance) — not hook-gated; read by skill authors.
#
# Dropped in v4: v3 #4 (Zod optional services) — moved to starters/nextjs/CLAUDE.md
# as a starter-local convention.
#
# Tagged-exception commit-subject prefixes (v4):
#   [release]  skips Rule 4 (templates)       — per-commit or full range
#   [infra]    skips Rule 3 (Spec-before-Ship) on the tagged commit
#   [docs]     skips Rule 3 on the tagged commit
#   [bulk]     skips the >50-file runaway guard (wired in PR 3's pre-commit-gate)
# Rules 1, 2, 5 are never skippable.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

fails=0
pass()    { printf "  ✓ %s\n" "$1"; }
fail()    {
  printf "  ✗ %s — %s\n" "$1" "$2"
  # Emit a GitHub Actions annotation when running in CI so the failure
  # surfaces on the annotations API even when the full log is auth-gated.
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    local escaped="${2//$'\n'/%0A}"
    printf "::error title=%s::%s\n" "$1" "$escaped"
  fi
  fails=$((fails+1))
}
header()  { printf "\n== %s ==\n" "$1"; }

# Detect current branch. On GitHub Actions PR events, HEAD is detached so
# `git rev-parse --abbrev-ref HEAD` returns 'HEAD'; prefer env vars.
if [[ -n "${GITHUB_HEAD_REF:-}" ]]; then
  branch="$GITHUB_HEAD_REF"
elif [[ -n "${GITHUB_REF_NAME:-}" ]]; then
  branch="$GITHUB_REF_NAME"
else
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
fi
slug=$(echo "$branch" | sed -E 's#^[a-z]+/[0-9]+-##' | sed -E 's#^[a-z]+/##')

# Determine the base ref to diff against.
if git rev-parse --verify main >/dev/null 2>&1; then
  base_ref="main"
elif git rev-parse --verify origin/main >/dev/null 2>&1; then
  base_ref="origin/main"
else
  base_ref=""
fi

# Collect every commit subject in base_ref..HEAD once (for tagged-exception
# scans). If no base_ref, default to empty.
if [[ -n "$base_ref" ]]; then
  commit_subjects=$(git log --format=%s "$base_ref"..HEAD 2>/dev/null || echo "")
else
  commit_subjects=""
fi

# Pre-commit hooks can export PENDING_COMMIT_SUBJECT so the very first commit
# on a branch can still carry an [infra]/[docs]/[release] exception — git log
# alone only sees already-landed commits. See .claude/hooks/pre-commit-gate.sh.
if [[ -n "${PENDING_COMMIT_SUBJECT:-}" ]]; then
  commit_subjects=$(printf '%s\n%s' "$PENDING_COMMIT_SUBJECT" "$commit_subjects")
fi

# Helper: does any commit in range (or the pending commit) carry the given bracketed prefix?
range_has_prefix() {
  local prefix="$1"
  echo "$commit_subjects" | grep -qE "^\[${prefix}\]" 2>/dev/null
}

header "Rule 1: Australian spelling"
if bash .claude/skills/australian-spelling/scripts/check.sh docs CLAUDE.md README.md >/dev/null 2>&1; then
  pass "no US-English variants in docs/ or root markdown"
else
  fail "Rule 1" "US-English variants present — run the australian-spelling script for detail"
fi

header "Rule 2: Starters generic and boot clean"
rule2_fail=0
if [[ ! -d starters ]]; then
  pass "starters/ retired pending v5 agnostic redesign — rule vacuously passes"
else
  # 2a: brand/domain strings
  if grep -rniE '\b(acme|blueprint-inc|customer-x|mycompany)\b' starters/ >/dev/null 2>&1; then
    fail "Rule 2" "domain/brand strings found in starters/"
    rule2_fail=1
  fi
  # 2b: smoke-test script present
  if [[ -f claude-config/scripts/smoke-test.sh || -f claude-config/scripts/bootstrap-smoke-test.sh ]]; then
    :
  elif [[ ! -d claude-config/scripts ]]; then
    :
  else
    fail "Rule 2" "claude-config/scripts/{smoke-test,bootstrap-smoke-test}.sh missing"
    rule2_fail=1
  fi
  if [[ $rule2_fail -eq 0 ]]; then
    pass "starters/ generic; smoke-test script present (run via /ship — not invoked here for speed)"
  fi
fi

header "Rule 3: Spec-before-Ship"
# Tagged-exception: [infra] or [docs] commit anywhere in range skips Rule 3.
# chore/* branches remain exempt on trust for small cleanups.
if [[ "$branch" == "main" || -z "$branch" ]]; then
  pass "on main — no per-feature spec required"
elif [[ "$branch" == release/* ]]; then
  pass "release branch '$branch' — no per-feature spec required"
elif [[ "$branch" == chore/* ]]; then
  pass "chore branch '$branch' — no per-feature spec required"
elif range_has_prefix "infra"; then
  pass "[infra]-tagged commit in range — Rule 3 skipped (harness/CI/deps change)"
elif range_has_prefix "docs"; then
  pass "[docs]-tagged commit in range — Rule 3 skipped (documentation change)"
elif [[ ! -d docs/specs ]]; then
  pass "docs/specs/ not yet bootstrapped (skipped)"
elif [[ -d "docs/specs/$slug" ]] || [[ -f "docs/specs/$slug.md" ]] || git diff --name-only "$base_ref"...HEAD 2>/dev/null | grep -q '^docs/specs/'; then
  pass "spec present for branch '$branch'"
else
  fail "Rule 3" "no docs/specs/$slug (folder or .md file) and no spec changes on branch '$branch' — use [infra]/[docs] prefix for harness changes, or create a spec"
fi

header "Rule 4: Templates versioned, not edited in flight"
template_changes=$(git diff --name-only "$base_ref"...HEAD 2>/dev/null \
  | grep '^docs/templates/' \
  | grep -v '^docs/templates/_archive/' || true)

if [[ -n "$template_changes" ]]; then
  branch_r4="$branch"
  if [[ "${AGENTIC_BLUEPRINT_RELEASE:-0}" == "1" ]]; then
    pass "docs/templates/ edited with AGENTIC_BLUEPRINT_RELEASE=1 (release-mode escape)"
  else
    # Per-commit check: every commit in range that touches a non-archive
    # template path must carry a [release] subject.
    bad_commit=""
    while read -r sha; do
      [[ -z "$sha" ]] && continue
      touches_active=$(git show --name-only --format= "$sha" 2>/dev/null \
        | grep '^docs/templates/' \
        | grep -v '^docs/templates/_archive/' || true)
      if [[ -n "$touches_active" ]]; then
        subject=$(git log -1 --format=%s "$sha" 2>/dev/null || echo "")
        if [[ "$subject" != \[release\]* ]]; then
          bad_commit="$sha — $subject"
          break
        fi
      fi
    done < <(git log --format=%H "$base_ref"..HEAD -- 'docs/templates/' 2>/dev/null)

    if [[ -z "$bad_commit" ]]; then
      pass "docs/templates/ edited with [release]-tagged commit(s)"
    else
      case "$branch_r4" in
        docs/*|templates/*)
          pass "docs/templates/ edited on dedicated '$branch_r4' (reviewer approval required at merge)"
          ;;
        *)
          fail "Rule 4" "branch '$branch_r4' has untagged template-touching commit: $bad_commit — use a [release]-prefixed subject, AGENTIC_BLUEPRINT_RELEASE=1, or a 'docs/*'/'templates/*' branch"
          ;;
      esac
    fi
  fi
else
  pass "docs/templates/ untouched (or only _archive/ moves)"
fi

header "Rule 5: Descriptive profiles, not prescriptive"
rule5_fail=0
if [[ -d docs/guides ]]; then
  if grep -rniE 'you must use|required to use|only works with' docs/guides/ >/dev/null 2>&1; then
    fail "Rule 5" "prescriptive language in docs/guides/ — guides must stay tool-agnostic"
    rule5_fail=1
  fi
  if grep -rniE 'recommended vendor|the only correct choice' docs/guides/ >/dev/null 2>&1; then
    fail "Rule 5" "endorsement language in platform profiles — describe, don't prescribe"
    rule5_fail=1
  fi
fi
if [[ $rule5_fail -eq 0 ]]; then
  pass "docs/guides/ reads descriptively (no prescriptive or endorsement phrasing)"
fi

echo
if [[ $fails -eq 0 ]]; then
  echo "All 5 Hard Rules (1–5) pass. Meta-principles 6–8 are not hook-gated."
  exit 0
else
  echo "$fails rule(s) failed."
  exit 1
fi
