#!/usr/bin/env bash
# starter-verify: run the canonical smoke-test for a starter in isolation.
# Captures only the first 10 lines of error output on failure.

set -uo pipefail

target="${1:-all}"
case "$target" in
  nextjs|flutter|dotnet|all) ;;
  *) echo "Usage: $0 <nextjs|flutter|dotnet|all>" >&2; exit 2;;
esac

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

# The dotnet target runs in-tree (not via the bootstrap smoke-test tmpdir,
# which only copies the Node and Flutter starters). Skip with a warning if
# the .NET SDK is not installed — matches how Flutter is handled when its
# CLI is missing.
run_dotnet() {
  if ! command -v dotnet >/dev/null 2>&1; then
    echo "SKIP — dotnet — .NET SDK not installed (install .NET 9 to enable)"
    return 0
  fi
  local starter="$REPO_ROOT/starters/dotnet-azure"
  if [[ ! -d "$starter" ]]; then
    echo "SKIP — dotnet — starters/dotnet-azure/ not present"
    return 0
  fi
  local tmp
  tmp=$(mktemp)
  if (
    cd "$starter" \
      && dotnet build --nologo --verbosity minimal \
      && dotnet test  --nologo --verbosity minimal --filter "Category!=Integration" \
      && dotnet format --verify-no-changes
  ) >"$tmp" 2>&1; then
    echo "PASS — dotnet (dotnet build, test, format --verify-no-changes) ✓"
    rm -f "$tmp"
    return 0
  else
    local code=$?
    echo "FAIL — dotnet — exited with $code"
    echo
    echo "---- first 10 lines of output ----"
    head -n 10 "$tmp"
    rm -f "$tmp"
    return 1
  fi
}

if [[ "$target" == "dotnet" ]]; then
  run_dotnet
  exit $?
fi

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
else
  code=$?
  echo "FAIL — $target — smoke-test exited with $code"
  echo
  echo "---- first 10 lines of output ----"
  head -n 10 "$tmp"
  rm -f "$tmp"
  exit 1
fi

# `all` also runs the dotnet target in-tree. Failure bubbles up; skip does not.
if [[ "$target" == "all" ]]; then
  run_dotnet || exit 1
fi

exit 0
