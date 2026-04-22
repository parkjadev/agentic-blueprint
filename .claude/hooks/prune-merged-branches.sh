#!/usr/bin/env bash
# SessionStart hook: prune locally-merged branches (including squash-merges).
#
# Safety:
# - Only runs inside a git repository.
# - Never touches the current branch, 'main', or 'master'.
# - Only deletes branches whose every commit is already in mainline, detected
#   via `git cherry` — which handles squash-merges. Each line starts with `-`
#   when the patch is already present in mainline; `+` marks unique commits.
#
# Idempotent. Silent when nothing to delete; one line per deletion otherwise.

set -uo pipefail

# Bail early if not a git repo.
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Prefer 'main', fall back to 'master'. Bail if neither exists locally.
if git rev-parse --verify --quiet main >/dev/null; then
  mainline="main"
elif git rev-parse --verify --quiet master >/dev/null; then
  mainline="master"
else
  exit 0
fi

current="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

# Refresh remote-tracking refs; never fail the hook on network trouble.
first_remote="$(git remote | head -n1)"
[[ -n "$first_remote" ]] && git fetch --prune "$first_remote" 2>/dev/null || true

deleted=()
while IFS= read -r branch; do
  [[ -z "$branch" ]] && continue
  [[ "$branch" == "$mainline" || "$branch" == "main" || "$branch" == "master" ]] && continue
  [[ "$branch" == "$current" ]] && continue

  # `git cherry mainline branch` lists one line per commit on the branch:
  #   `+ <sha>` — commit is NOT in mainline (unique to this branch)
  #   `- <sha>` — commit IS in mainline (even via squash-merge)
  # No `+` lines means the branch is fully absorbed and safe to delete.
  if ! git cherry "$mainline" "$branch" 2>/dev/null | grep -q '^+'; then
    if git branch -D "$branch" >/dev/null 2>&1; then
      deleted+=("$branch")
    fi
  fi
done < <(git for-each-ref --format='%(refname:short)' refs/heads/)

if (( ${#deleted[@]} > 0 )); then
  printf 'prune-merged-branches: removed %d branch(es): %s\n' \
    "${#deleted[@]}" "${deleted[*]}"
fi

exit 0
