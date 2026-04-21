#!/usr/bin/env bash
# signal-sync: post-merge housekeeping. Merged from v3 memory-sync.
# Idempotent — safe to rerun.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

echo "== signal-sync =="

# 1. Plan-status updater (claude-config helper, if present).
if [[ -x claude-config/scripts/update-plan-status.sh ]]; then
  echo "running claude-config/scripts/update-plan-status.sh"
  bash claude-config/scripts/update-plan-status.sh || {
    echo "update-plan-status.sh exited non-zero (continuing)" >&2
  }
else
  echo "claude-config/scripts/update-plan-status.sh not present; skipping"
fi

# 2. Archive stale research briefs (older than 180 days).
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

# 3. Cross-reference sanity: every plan file should mention its specs path.
if [[ -d docs/plans ]]; then
  for plan in docs/plans/*.md; do
    [[ -f "$plan" ]] || continue
    slug=$(basename "$plan" .md)
    if [[ (-d "docs/specs/$slug" || -f "docs/specs/$slug.md") ]] && ! grep -q "docs/specs/$slug" "$plan"; then
      echo "warn: $plan does not reference docs/specs/$slug"
    fi
  done
fi

echo "signal-sync complete."
