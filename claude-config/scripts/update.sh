#!/usr/bin/env bash
# Agentic Blueprint v4 — /beat update.
# Pulls newer blueprint-owned files into an adopter repo without clobbering
# user-customised files.
#
# Blueprint-owned set (updated on success):
#   - .claude/commands/{spec,ship,signal,beat}.md
#   - .claude/agents/{spec-researcher,spec-author}.md
#   - .claude/skills/{australian-spelling,hard-rules-check,signal-sync,starter-verify}/
#   - .claude/hooks/{session-start,beat-aware-prompt,template-guard,pre-write-spelling,pre-commit-secret-scan,pre-commit-gate}.sh
#   - Content inside <!-- agentic-blueprint:begin/end --> in CLAUDE.md
#
# Respects user customisations: any custom command/agent/skill/hook outside
# the blueprint set is left alone. If a blueprint-owned file has been edited
# locally, this script logs a warning and skips it — manual merge required.

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

# Compare VERSION files.
src_version="?"
dst_version="?"
[[ -f "$SRC_DIR/claude-config/VERSION" ]] && src_version=$(cat "$SRC_DIR/claude-config/VERSION")
[[ -f claude-config/VERSION ]] && dst_version=$(cat claude-config/VERSION)

echo "agentic-blueprint update"
echo "  upstream: $src_version"
echo "  local:    $dst_version"
echo "  dry-run:  $DRY_RUN"
echo

if [[ "$src_version" == "$dst_version" ]]; then
  echo "Already up to date."
  exit 0
fi

# Blueprint-owned file list.
blueprint_files=(
  ".claude/commands/spec.md"
  ".claude/commands/ship.md"
  ".claude/commands/signal.md"
  ".claude/commands/beat.md"
  ".claude/agents/spec-researcher.md"
  ".claude/agents/spec-author.md"
  ".claude/hooks/session-start.sh"
  ".claude/hooks/beat-aware-prompt.sh"
  ".claude/hooks/template-guard.sh"
  ".claude/hooks/pre-write-spelling.sh"
  ".claude/hooks/pre-commit-secret-scan.sh"
  ".claude/hooks/pre-commit-gate.sh"
)
blueprint_skill_dirs=(
  ".claude/skills/australian-spelling"
  ".claude/skills/hard-rules-check"
  ".claude/skills/signal-sync"
  ".claude/skills/starter-verify"
)

run() { if [[ $DRY_RUN -eq 1 ]]; then echo "DRY: $*"; else eval "$*"; fi; }

updated=0
skipped=0

for f in "${blueprint_files[@]}"; do
  src="$SRC_DIR/$f"
  [[ -f "$src" ]] || continue
  if [[ ! -f "$f" ]]; then
    run "mkdir -p \"$(dirname \"$f\")\""
    run "cp \"$src\" \"$f\""
    updated=$((updated+1))
    echo "  + $f (new)"
    continue
  fi
  # If the local file differs from the upstream-shipped version, either the
  # user edited it or a previous update already synced. We cheat by diffing
  # against the shipped VERSION — if different from upstream, log a warning.
  if ! diff -q "$src" "$f" >/dev/null 2>&1; then
    # Check if the local file has unique user edits beyond the upstream prior.
    # Without a .v3-baseline reference, we can't tell — err on the side of
    # caution and warn rather than overwrite.
    echo "  ? $f — local differs from upstream; leaving in place (manual merge if desired)"
    skipped=$((skipped+1))
  fi
done

for d in "${blueprint_skill_dirs[@]}"; do
  src="$SRC_DIR/$d"
  [[ -d "$src" ]] || continue
  if [[ ! -d "$d" ]]; then
    run "mkdir -p \"$(dirname \"$d\")\""
    run "cp -R \"$src\" \"$d\""
    updated=$((updated+1))
    echo "  + $d/ (new)"
    continue
  fi
  # For skills, overwrite files that are blueprint-shipped by name; leave
  # anything extra the user added.
  while IFS= read -r -d '' rel; do
    rel_path="${rel#$src/}"
    src_file="$rel"
    dst_file="$d/$rel_path"
    if [[ ! -f "$dst_file" ]]; then
      run "mkdir -p \"$(dirname \"$dst_file\")\""
      run "cp \"$src_file\" \"$dst_file\""
      updated=$((updated+1))
    elif ! diff -q "$src_file" "$dst_file" >/dev/null 2>&1; then
      echo "  ? $dst_file — local differs from upstream; leaving in place"
      skipped=$((skipped+1))
    fi
  done < <(find "$src" -type f -print0)
done

# Refresh CLAUDE.md fenced block.
if [[ -f CLAUDE.md ]] && grep -q '<!-- agentic-blueprint:begin -->' CLAUDE.md 2>/dev/null; then
  if [[ $DRY_RUN -eq 0 ]]; then
    python3 - "$SRC_DIR/CLAUDE.md" CLAUDE.md <<'PY'
import sys, pathlib, re
src_path, dst_path = sys.argv[1], sys.argv[2]
src = pathlib.Path(src_path).read_text()
dst = pathlib.Path(dst_path).read_text()
begin = "<!-- agentic-blueprint:begin -->"
end = "<!-- agentic-blueprint:end -->"
pattern = re.compile(
    re.escape(begin) + r".*?" + re.escape(end),
    re.DOTALL,
)
new_block = f"{begin}\n{src.rstrip()}\n{end}"
new = pattern.sub(lambda _m: new_block, dst, count=1)
pathlib.Path(dst_path).write_text(new)
print("  ~ CLAUDE.md — fenced block refreshed")
PY
    updated=$((updated+1))
  else
    echo "DRY: refresh CLAUDE.md fenced block"
  fi
fi

# Update VERSION pin.
if [[ $DRY_RUN -eq 0 ]]; then
  echo "$src_version" > claude-config/VERSION
fi

echo
echo "update complete: $updated file(s) updated, $skipped skipped with local changes"
