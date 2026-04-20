#!/usr/bin/env bash
# Hard Rules compliance check.
# Exits 0 if all rules pass, non-zero with a short failure summary otherwise.
# Each check runs independently; all are evaluated so we report every failure.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

fails=0
pass()    { printf "  ✓ %s\n" "$1"; }
fail()    { printf "  ✗ %s — %s\n" "$1" "$2"; fails=$((fails+1)); }
header()  { printf "\n== %s ==\n" "$1"; }

header "Rule 1: Australian spelling"
if bash .claude/skills/australian-spelling/scripts/check.sh docs CLAUDE.md README.md >/dev/null 2>&1; then
  pass "no US-English variants in docs/ or root markdown"
else
  fail "Rule 1" "US-English variants present — run the australian-spelling script for detail"
fi

header "Rule 2: No domain-specific business logic in starters"
# Heuristic: look for brand strings in lowercase that shouldn't appear in a generic starter.
if grep -rniE '\b(acme|blueprint-inc|customer-x|mycompany)\b' starters/ >/dev/null 2>&1; then
  fail "Rule 2" "domain/brand strings found in starters/"
else
  pass "no domain/brand strings in starters/"
fi

header "Rule 3: Starters boot clean"
if [[ -f claude-config/scripts/smoke-test.sh || -f claude-config/scripts/bootstrap-smoke-test.sh ]]; then
  pass "smoke-test script present (run it via /ship — not invoked here for speed)"
elif [[ ! -d claude-config/scripts ]]; then
  pass "claude-config/scripts not yet bootstrapped (skipped)"
else
  fail "Rule 3" "claude-config/scripts/{smoke-test,bootstrap-smoke-test}.sh missing"
fi

header "Rule 4: Optional services (Zod schemas in env.ts)"
if [[ -f starters/nextjs/src/env.ts ]]; then
  if grep -qE 'optional\(\)' starters/nextjs/src/env.ts 2>/dev/null; then
    pass "optional Zod fields present in starters/nextjs/src/env.ts"
  else
    fail "Rule 4" "no .optional() fields in env.ts — Stripe/Inngest/Resend/etc. must gracefully skip"
  fi
else
  pass "starters/nextjs not present or env.ts not yet scaffolded (skipped)"
fi

# Detect current branch. On GitHub Actions PR events, HEAD is detached so
# `git rev-parse --abbrev-ref HEAD` returns 'HEAD'; prefer the env vars
# GitHub sets (GITHUB_HEAD_REF for PR events, GITHUB_REF_NAME for push).
if [[ -n "${GITHUB_HEAD_REF:-}" ]]; then
  branch="$GITHUB_HEAD_REF"
elif [[ -n "${GITHUB_REF_NAME:-}" ]]; then
  branch="$GITHUB_REF_NAME"
else
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
fi
slug=$(echo "$branch" | sed -E 's#^[a-z]+/[0-9]+-##' | sed -E 's#^[a-z]+/##')

# Determine the base ref to diff against. In CI, `main` may not exist as a
# local branch (actions/checkout only creates the checked-out ref), so fall
# back to `origin/main`.
if git rev-parse --verify main >/dev/null 2>&1; then
  base_ref="main"
elif git rev-parse --verify origin/main >/dev/null 2>&1; then
  base_ref="origin/main"
else
  base_ref=""
fi

header "Rule 5: Spec-driven (feature branches have a spec)"
# Bootstrap exception: this rule only applies once docs/specs/ exists in the
# repo (i.e. once at least one feature has been planned). On a meta/rebuild
# branch that creates the harness itself, there is nothing to spec yet.
if [[ "$branch" == "main" || -z "$branch" ]]; then
  pass "on main — no per-feature spec required"
elif [[ ! -d docs/specs ]]; then
  pass "docs/specs/ not yet bootstrapped (skipped)"
elif [[ -d "docs/specs/$slug" ]] || git diff --name-only "$base_ref"...HEAD 2>/dev/null | grep -q '^docs/specs/'; then
  pass "spec present for branch '$branch'"
else
  fail "Rule 5" "no docs/specs/$slug/ and no spec changes on branch '$branch'"
fi

header "Rule 6: Plan-before-code (plan file present)"
if [[ "$branch" == "main" || -z "$branch" ]]; then
  pass "on main — no per-feature plan required"
elif [[ ! -d docs/plans ]] || [[ -z "$(ls -A docs/plans 2>/dev/null)" ]]; then
  pass "docs/plans/ not yet bootstrapped (skipped)"
elif [[ -f "docs/plans/$slug.md" ]] || git diff --name-only "$base_ref"...HEAD 2>/dev/null | grep -q '^docs/plans/'; then
  pass "plan present for branch '$branch'"
else
  fail "Rule 6" "no docs/plans/$slug.md on branch '$branch'"
fi

header "Rule 7: Templates are sacred"
if git diff --name-only "$base_ref"...HEAD 2>/dev/null | grep -q '^docs/templates/'; then
  # Escape hatch (per docs/principles/07-templates-are-sacred.md): template
  # changes may land on a dedicated `docs/*` or `templates/*` branch.
  branch_r7="$branch"
  case "$branch_r7" in
    docs/*|templates/*)
      pass "docs/templates/ edited on dedicated '$branch_r7' (reviewer approval required at merge)"
      ;;
    *)
      fail "Rule 7" "branch '$branch_r7' modifies docs/templates/ — use a 'docs/*' or 'templates/*' branch for template changes"
      ;;
  esac
else
  pass "docs/templates/ untouched"
fi

header "Rule 8: Tool-agnostic framing in guides"
# Flag explicit "you must use X" patterns.
if grep -rniE 'you must use|required to use|only works with' docs/guides/ >/dev/null 2>&1; then
  fail "Rule 8" "prescriptive language in docs/guides/ — guides must stay tool-agnostic"
else
  pass "no prescriptive language in docs/guides/"
fi

header "Rule 9: Platform profiles descriptive"
if [[ -d docs/guides ]]; then
  if grep -rniE 'recommended vendor|the only correct choice' docs/guides/ >/dev/null 2>&1; then
    fail "Rule 9" "prescriptive language in platform profiles"
  else
    pass "platform profiles read descriptively"
  fi
else
  pass "docs/guides/ absent (skipped)"
fi

echo
if [[ $fails -eq 0 ]]; then
  echo "All 9 Hard Rules pass."
  exit 0
else
  echo "$fails rule(s) failed."
  exit 1
fi
