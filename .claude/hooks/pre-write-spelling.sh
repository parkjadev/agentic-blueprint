#!/usr/bin/env bash
# PreToolUse hook — warn (non-blocking) on US-English variants in markdown being written.
# Stdin: Claude Code tool-call JSON. We only inspect Write/Edit on .md files.

set -uo pipefail

payload="$(cat || true)"
[[ -z "$payload" ]] && exit 0

read -r path content < <(printf '%s' "$payload" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = data.get("tool_input", {}) or {}
path = ti.get("file_path", "")
# "content" (Write) or "new_string" (Edit); take whichever is present.
body = ti.get("content") or ti.get("new_string") or ""
# Flatten newlines so the whole body is one shell arg.
print(path, repr(body))
' 2>/dev/null || true)

[[ -z "$path" ]] && exit 0

case "$path" in
  *.md|*.txt|*.mdx) ;;
  *) exit 0;;
esac

WORDLIST="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/.claude/skills/australian-spelling/references/wordlist.md"
[[ -f "$WORDLIST" ]] || exit 0

# Extract US variants from the wordlist.
mapfile -t patterns < <(
  awk -F' → ' '/^[a-zA-Z]+ → [a-zA-Z]+/ { print $1 }' "$WORDLIST" | sort -u
)
[[ ${#patterns[@]} -eq 0 ]] && exit 0

regex="\\b($(IFS='|'; echo "${patterns[*]}"))\\b"

# Echo to stderr as a warning; do not block (exit 0).
if printf '%s' "$content" | grep -iE "$regex" >/dev/null 2>&1; then
  cat <<EOF >&2
note: content about to be written to $path contains US-English variants.
Consider running:

  bash .claude/skills/australian-spelling/scripts/check.sh $path

after the write to see the specific lines. (Non-blocking — Hard Rule #1 reminder.)
EOF
fi

exit 0
