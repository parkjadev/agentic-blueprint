#!/usr/bin/env bash
# Hard Rules compliance check (v5 — 4 rules + 3 meta-principles).
# Exits 0 if all rules pass, non-zero with a short failure summary otherwise.
# Each check runs independently; all are evaluated so we report every failure.
#
# v5 ruleset:
#   1. Australian spelling                   (content gate)
#   3. Spec-before-Ship                      (merged v3 #5 + #6)
#   4. Templates + contracts versioned       (covers docs/templates/ and docs/contracts/)
#   5. Descriptive profiles, not prescriptive (merged v3 #8 + #9)
#   6–8. Meta-principles (progressive disclosure, context economy, gates over
#        guidance) — not hook-gated; read by skill authors.
#
# Retired in v5.0: Rule 2 (starters generic and boot clean) — archived at
#   docs/principles/_archive/02-starters-generic-boot-clean.md. Reinstate if
#   plugin packs land in v5.x. Numbering preserved so downstream references to
#   Rules 3/4/5 don't silently shift.
#
# Tagged-exception commit-subject prefixes:
#   [release]  skips Rule 4 (sacred paths)     — per-commit or full range
#   [infra]    skips Rule 3 (Spec-before-Ship) on the tagged commit
#   [docs]     skips Rule 3 on the tagged commit
#   [bulk]     skips the >50-file runaway guard (wired in pre-commit-gate.sh)
# Rules 1 and 5 are never skippable.

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

header "Rule 4: Templates + contracts versioned, not edited in flight"
sacred_changes=$(git diff --name-only "$base_ref"...HEAD 2>/dev/null \
  | grep -E '^docs/(templates|contracts)/' \
  | grep -vE '^docs/(templates|contracts)/_archive/' || true)

if [[ -n "$sacred_changes" ]]; then
  branch_r4="$branch"
  if [[ "${AGENTIC_BLUEPRINT_RELEASE:-0}" == "1" ]]; then
    pass "docs/templates/ or docs/contracts/ edited with AGENTIC_BLUEPRINT_RELEASE=1 (release-mode escape)"
  else
    # Per-commit check: every commit in range that touches a non-archive
    # sacred path must carry a [release] subject.
    #
    # When pre-commit-gate.sh is running the check with PENDING_AMEND=1,
    # the HEAD commit is about to be rewritten — treat its effective
    # subject as PENDING_COMMIT_SUBJECT, not the still-on-disk value.
    head_sha="$(git rev-parse HEAD 2>/dev/null || echo "")"
    bad_commit=""
    while read -r sha; do
      [[ -z "$sha" ]] && continue
      touches_active=$(git show --name-only --format= "$sha" 2>/dev/null \
        | grep -E '^docs/(templates|contracts)/' \
        | grep -vE '^docs/(templates|contracts)/_archive/' || true)
      if [[ -n "$touches_active" ]]; then
        if [[ "$sha" == "$head_sha" && "${PENDING_AMEND:-0}" == "1" && -n "${PENDING_COMMIT_SUBJECT:-}" ]]; then
          subject="$PENDING_COMMIT_SUBJECT"
        else
          subject=$(git log -1 --format=%s "$sha" 2>/dev/null || echo "")
        fi
        if [[ "$subject" != \[release\]* ]]; then
          bad_commit="$sha — $subject"
          break
        fi
      fi
    done < <(git log --format=%H "$base_ref"..HEAD -- 'docs/templates/' 'docs/contracts/' 2>/dev/null)

    if [[ -z "$bad_commit" ]]; then
      pass "docs/templates/ or docs/contracts/ edited with [release]-tagged commit(s)"
    else
      case "$branch_r4" in
        docs/*|templates/*|contracts/*)
          pass "sacred paths edited on dedicated '$branch_r4' (reviewer approval required at merge)"
          ;;
        *)
          fail "Rule 4" "branch '$branch_r4' has untagged sacred-path-touching commit: $bad_commit — use a [release]-prefixed subject, AGENTIC_BLUEPRINT_RELEASE=1, or a 'docs/*'/'templates/*'/'contracts/*' branch"
          ;;
      esac
    fi
  fi
else
  pass "docs/templates/ and docs/contracts/ untouched (or only _archive/ moves)"
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
  echo "All 4 Hard Rules (1, 3, 4, 5) pass. Rule 2 retired in v5.0. Meta-principles 6–8 are not hook-gated."
  exit 0
else
  echo "$fails rule(s) failed."
  exit 1
fi
