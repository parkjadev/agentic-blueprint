#!/usr/bin/env bash
# PreToolUse hook — block Write/Edit into docs/templates/ (Hard Rule #7).
# Reads the tool-call JSON from stdin; exits non-zero to block.

set -uo pipefail

payload="$(cat || true)"
if [[ -z "$payload" ]]; then
  exit 0
fi

path=$(printf '%s' "$payload" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = data.get("tool_input", {}) or {}
print(ti.get("file_path", ""))
' 2>/dev/null || true)

if [[ -z "$path" ]]; then
  exit 0
fi

# Normalise to repo-relative.
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
case "$path" in
  /*) rel="${path#$REPO_ROOT/}";;
  *)  rel="$path";;
esac

if [[ "$rel" == docs/templates/* ]]; then
  # Escape hatch (per docs/principles/07-templates-are-sacred.md): template
  # changes may land on a dedicated `docs/*` or `templates/*` branch. Any
  # other branch trying to edit docs/templates/ is blocked.
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  case "$branch" in
    docs/*|templates/*) exit 0;;
  esac

  cat <<EOF >&2
Blocked: $rel is in docs/templates/, which is sacred (Hard Rule #7).

Templates define the spec contract. Edit for clarity in a dedicated docs: PR,
never bundled into a feature change. Move to a branch named \`docs/<slug>\`
or \`templates/<slug>\` and retry — that branch is the documented escape.
EOF
  exit 2
fi

exit 0
