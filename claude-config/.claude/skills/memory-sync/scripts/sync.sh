#!/usr/bin/env bash
# Memory sync — post-merge housekeeping.
# Wraps claude-config/scripts/update-plan-status.sh and runs additional cross-reference checks.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

echo "== memory-sync =="

# 1. Run the plan-status updater if present.
if [[ -x claude-config/scripts/update-plan-status.sh ]]; then
  echo "running claude-config/scripts/update-plan-status.sh"
  bash claude-config/scripts/update-plan-status.sh || {
    echo "update-plan-status.sh exited non-zero (continuing)" >&2
  }
else
  echo "claude-config/scripts/update-plan-status.sh not present; skipping"
fi

# 2. Archive stale research briefs (older than 180 days, no recent git log reference).
if [[ -d docs/research ]]; then
  mkdir -p docs/research/_archive
  threshold=$(date -d "180 days ago" +%s 2>/dev/null || date -v-180d +%s)
  while IFS= read -r -d '' brief; do
    [[ "$brief" == *"/_archive/"* ]] && continue
    [[ "$brief" == *".gitkeep" ]] && continue
    mtime=$(stat -c %Y "$brief" 2>/dev/null || stat -f %m "$brief")
    if (( mtime < threshold )); then
      echo "archiving stale brief: $brief"
      mv "$brief" docs/research/_archive/
    fi
  done < <(find docs/research -type f -name '*.md' -print0)
fi

# 3. Quick cross-reference sanity: every plan file should mention its specs folder.
if [[ -d docs/plans ]]; then
  for plan in docs/plans/*.md; do
    [[ -f "$plan" ]] || continue
    slug=$(basename "$plan" .md)
    if [[ -d "docs/specs/$slug" ]] && ! grep -q "docs/specs/$slug" "$plan"; then
      echo "warn: $plan does not reference docs/specs/$slug"
    fi
  done
fi

echo "memory-sync complete."
