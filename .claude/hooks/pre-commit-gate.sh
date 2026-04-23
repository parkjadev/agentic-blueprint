#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash) — gate `git commit` and `git push` calls
# behind the v4 Hard Rules check and the runaway-commit guard.
# Non-commit Bash invocations pass through.

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
cd "$REPO_ROOT"

# -----------------------------------------------------------------------------
# Parse the pending commit subject from the command line so both the bulk
# guard below and the Hard Rules gate can honour tagged-exception prefixes on
# the very first commit of a branch. (check-all.sh otherwise only sees
# already-landed commits via `git log base_ref..HEAD`.) Supports `-m "..."`,
# `-m '...'`, and `-F <file>` forms.
#
# Also detect `--amend` so Rule 4 can treat the HEAD commit's effective
# subject as the pending one (amends rewrite HEAD; the subject the gate
# needs to evaluate against is the new one, not the one still on disk).
# -----------------------------------------------------------------------------
pending_commit_subject=""
pending_amend=0
case "$cmd" in
  *"git commit"*)
    pending_commit_subject=$(printf '%s' "$cmd" | python3 -c '
import re, sys, pathlib
cmd = sys.stdin.read()
m = re.search(r"-m\s+(?:\"([^\"]*)\"|\x27([^\x27]*)\x27)", cmd)
if m:
    print(m.group(1) or m.group(2) or "")
    sys.exit(0)
f = re.search(r"-F\s+(\S+)", cmd)
if f:
    try:
        print(pathlib.Path(f.group(1)).read_text().splitlines()[0])
    except Exception:
        pass
' 2>/dev/null || echo "")
    case "$cmd" in
      *" --amend"*|*" --amend "*) pending_amend=1;;
    esac
    ;;
esac

# -----------------------------------------------------------------------------
# Runaway-commit guard: staged diff of >50 files requires [bulk] prefix.
# Agents that go off-rails and rewrite half the repo get stopped here.
# -----------------------------------------------------------------------------
case "$cmd" in
  *"git commit"*)
    staged_files=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    if [[ -n "$staged_files" && "$staged_files" -gt 50 ]]; then
      if [[ "$pending_commit_subject" != \[bulk\]* ]]; then
        cat <<EOF >&2
Blocked: this commit stages $staged_files files (>50).

Large commits obscure review and are a common signature of an agent that
has gone off-rails. If this is a genuine bulk change (mass rename, sweep),
re-run with a \`[bulk]\` prefix on the commit subject:

  git commit -m "[bulk] <description>"

The \`[bulk]\` prefix is recorded in the git log audit trail.
EOF
        exit 2
      fi
    fi
    ;;
esac

# -----------------------------------------------------------------------------
# Hard Rules gate (delegates to check-all.sh which honours tagged exceptions).
# -----------------------------------------------------------------------------
SCRIPT="$REPO_ROOT/.claude/skills/hard-rules-check/scripts/check-all.sh"

if [[ ! -x "$SCRIPT" && ! -f "$SCRIPT" ]]; then
  echo "warn: hard-rules-check script missing; commit proceeding without gate" >&2
  exit 0
fi

if ! PENDING_COMMIT_SUBJECT="$pending_commit_subject" PENDING_AMEND="$pending_amend" bash "$SCRIPT" >/tmp/hard-rules.out 2>&1; then
  cat <<EOF >&2
Blocked: Hard Rules check failed.

$(tail -n 40 /tmp/hard-rules.out)

Tagged-exception prefixes available on the commit message:
  [release]  skips Rule 4 (templates versioned)
  [infra]    skips Rule 3 (Spec-before-Ship) — CI/hooks/deps work
  [docs]     skips Rule 3 — doc-only commits
  [bulk]     skips the >50-file runaway guard

Rules 1, 2, 5 are never skippable. Fix the violations above or use a
named prefix if the exception is legitimate.
EOF
  exit 2
fi

exit 0
