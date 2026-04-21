#!/usr/bin/env bash
# Agentic Blueprint v4 — list or revert AI-authored commits as a group.
# Identifies commits with a "Co-Authored-By: Claude" trailer and offers a
# single cohesive revert.
#
# Usage:
#   bash claude-config/scripts/revert-ai-commits.sh --since <ref>  # list only
#   bash claude-config/scripts/revert-ai-commits.sh --since <ref> --apply  # revert

set -euo pipefail

SINCE=""
APPLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --since)  SINCE="$2"; shift 2;;
    --apply)  APPLY=1;    shift;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

if [[ -z "$SINCE" ]]; then
  echo "Usage: $0 --since <ref> [--apply]" >&2
  echo "Example: $0 --since HEAD~10 --apply" >&2
  exit 2
fi

# Collect commits with a Claude co-author trailer.
commits=$(git log --format='%H %s' "$SINCE..HEAD" 2>/dev/null | while read -r sha subj; do
  if git show -s --format=%B "$sha" 2>/dev/null | grep -q 'Co-Authored-By: Claude'; then
    echo "$sha $subj"
  fi
done)

if [[ -z "$commits" ]]; then
  echo "No AI-authored commits found in $SINCE..HEAD."
  exit 0
fi

echo "AI-authored commits in $SINCE..HEAD:"
echo "$commits" | awk '{print "  " substr($1,1,7) " " substr($0, index($0,$2))}'
echo

if [[ $APPLY -eq 0 ]]; then
  echo "Pass --apply to revert these as a single cohesive revert commit."
  exit 0
fi

# Revert in reverse order into one cohesive commit.
shas=$(echo "$commits" | awk '{print $1}' | tac)
temp_branch="revert-ai-commits-$(date +%s)"
echo "Creating revert commit on branch: $temp_branch"
git checkout -b "$temp_branch"
for sha in $shas; do
  git revert --no-commit "$sha"
done
git commit -m "[infra] Revert AI-authored commits in $SINCE..HEAD

Reverted commits (in reverse order):
$(echo "$commits" | awk '{print "  " substr($1,1,7) " " substr($0, index($0,$2))}')

Triggered via claude-config/scripts/revert-ai-commits.sh.
"
echo
echo "Revert commit landed on $temp_branch. Review with 'git show HEAD', then merge or push as usual."
