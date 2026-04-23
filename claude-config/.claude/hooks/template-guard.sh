#!/usr/bin/env bash
# PreToolUse hook — block Write/Edit into docs/templates/ or docs/contracts/
# (Hard Rule 4 — sacred specification artefacts).
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

# Protected directories — edits require a dedicated branch name, a release
# environment escape, or live in an _archive/ subfolder.
protected=""
case "$rel" in
  docs/templates/*) protected="docs/templates";;
  docs/contracts/*) protected="docs/contracts";;
esac

if [[ -n "$protected" ]]; then
  # Always-allowed: the _archive/ subfolder is where retired content lives.
  if [[ "$rel" == "$protected"/_archive/* ]]; then
    exit 0
  fi

  # Session-level escape: AGENTIC_BLUEPRINT_RELEASE=1 signals an explicit
  # release rebuild where edits to sacred paths are expected.
  if [[ "${AGENTIC_BLUEPRINT_RELEASE:-0}" == "1" ]]; then
    exit 0
  fi

  # Branch-name escape: edits may land on a dedicated `docs/*`,
  # `templates/*`, or `contracts/*` branch. Any other branch is blocked.
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  case "$branch" in
    docs/*|templates/*|contracts/*) exit 0;;
  esac

  cat <<EOF >&2
Blocked: $rel is in $protected/, which is sacred (Hard Rule 4).

Sacred paths define the spec contract. Edit for clarity in a dedicated PR,
never bundled into a feature change. Either:
  - Move to a branch named \`docs/<slug>\`, \`templates/<slug>\`, or \`contracts/<slug>\`, or
  - Set AGENTIC_BLUEPRINT_RELEASE=1 for an explicit release rebuild, or
  - Edit under $protected/_archive/ (always allowed).
EOF
  exit 2
fi

exit 0
