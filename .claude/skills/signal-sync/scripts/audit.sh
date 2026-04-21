#!/usr/bin/env bash
# signal-sync: cross-reference audit. Merged from v3 docs-inspector agent logic.
# Reports broken internal links, stale TODOs, plan↔spec drift.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

mkdir -p docs/signal
OUT="docs/signal/audit-$(date +%F).md"

{
  echo "# signal-sync audit — $(date +%FT%T%z)"
  echo
  echo "## Broken internal markdown links"
  # Crude pass: [text](relative/path) — check existence.
  broken=0
  while IFS= read -r file; do
    while IFS= read -r target; do
      [[ -z "$target" ]] && continue
      # Skip external + anchors-only.
      [[ "$target" == http* ]] && continue
      [[ "$target" == "#"* ]] && continue
      # Strip anchor fragments.
      path="${target%%#*}"
      [[ -z "$path" ]] && continue
      # Resolve relative to the file's directory.
      dir=$(dirname "$file")
      resolved=$(readlink -f "$dir/$path" 2>/dev/null || echo "$dir/$path")
      if [[ ! -e "$resolved" ]]; then
        echo "- $file → $target (missing)"
        broken=$((broken+1))
      fi
    done < <(grep -oE '\]\([^)]+\)' "$file" 2>/dev/null | sed -E 's/\]\(([^)]+)\)/\1/')
  done < <(find docs/ README.md CLAUDE.md CHANGELOG.md -type f -name '*.md' 2>/dev/null)
  echo
  echo "(broken links: $broken)"
  echo
  echo "## Stale TODO markers (older than 30 days by git blame)"
  threshold=$(date -d "30 days ago" +%s 2>/dev/null || date -v-30d +%s)
  stale=0
  while IFS= read -r hit; do
    file="${hit%%:*}"
    line="${hit#*:}"
    line="${line%%:*}"
    ts=$(git log -1 --format=%ct -L"$line,$line:$file" 2>/dev/null | head -1)
    if [[ -n "$ts" ]] && (( ts < threshold )); then
      echo "- $file:$line"
      stale=$((stale+1))
    fi
  done < <(grep -rniE 'TODO[:(]' docs/ 2>/dev/null | head -50)
  echo
  echo "(stale TODOs: $stale)"
  echo
  echo "## Plan ↔ spec cross-reference drift"
  drift=0
  if [[ -d docs/plans ]]; then
    for plan in docs/plans/*.md; do
      [[ -f "$plan" ]] || continue
      slug=$(basename "$plan" .md)
      if [[ (-d "docs/specs/$slug" || -f "docs/specs/$slug.md") ]] && ! grep -q "docs/specs/$slug" "$plan"; then
        echo "- $plan does not reference docs/specs/$slug"
        drift=$((drift+1))
      fi
    done
  fi
  echo
  echo "(drift items: $drift)"
} > "$OUT"

echo "audit report written to $OUT"
head -40 "$OUT"
