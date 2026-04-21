#!/usr/bin/env bash
# starter-verify: run the canonical smoke-test for a starter in isolation.
# Captures only the first 10 lines of error output on failure.

set -uo pipefail

target="${1:-all}"
case "$target" in
  nextjs|flutter|all) ;;
  *) echo "Usage: $0 <nextjs|flutter|all>" >&2; exit 2;;
esac

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

SMOKE="claude-config/scripts/smoke-test.sh"
if [[ ! -f "$SMOKE" ]]; then
  SMOKE="claude-config/scripts/bootstrap-smoke-test.sh"
fi

if [[ ! -f "$SMOKE" ]]; then
  echo "starter-verify: no smoke-test script found in claude-config/scripts/" >&2
  exit 2
fi

tmp=$(mktemp)
if bash "$SMOKE" "$target" >"$tmp" 2>&1; then
  case "$target" in
    nextjs)  echo "PASS — nextjs (pnpm type-check, lint, test:ci) ✓";;
    flutter) echo "PASS — flutter (flutter analysis + tests) ✓";;
    all)     echo "PASS — nextjs + flutter ✓";;
  esac
  rm -f "$tmp"
  exit 0
else
  code=$?
  echo "FAIL — $target — smoke-test exited with $code"
  echo
  echo "---- first 10 lines of output ----"
  head -n 10 "$tmp"
  rm -f "$tmp"
  exit 1
fi
