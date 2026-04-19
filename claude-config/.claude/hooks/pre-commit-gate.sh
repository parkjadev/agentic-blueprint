#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash) — gate `git commit` and `git push` calls
# behind the Hard Rules check. Non-commit Bash invocations pass through.

set -uo pipefail

payload="$(cat || true)"
[[ -z "$payload" ]] && exit 0

cmd=$(printf '%s' "$payload" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = data.get("tool_input", {}) or {}
print(ti.get("command", ""))
' 2>/dev/null || true)

[[ -z "$cmd" ]] && exit 0

# Only act on git commit / git push commands.
case "$cmd" in
  *"git commit"*|*"git push"*) ;;
  *) exit 0;;
esac

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCRIPT="$REPO_ROOT/.claude/skills/hard-rules-check/scripts/check-all.sh"

if [[ ! -x "$SCRIPT" && ! -f "$SCRIPT" ]]; then
  # No check script available — let the commit through with a warning.
  echo "warn: hard-rules-check script missing; commit proceeding without gate" >&2
  exit 0
fi

# Run the rules check; on failure block the commit/push.
if ! bash "$SCRIPT" >/tmp/hard-rules.out 2>&1; then
  cat <<EOF >&2
Blocked: Hard Rules check failed.

$(tail -n 40 /tmp/hard-rules.out)

Fix the violations above and try again. To bypass legitimately (rare),
discuss with the user first — never use --no-verify silently.
EOF
  exit 2
fi

exit 0
