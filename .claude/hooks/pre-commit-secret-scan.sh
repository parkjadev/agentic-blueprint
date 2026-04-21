#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash) — fast regex scan of staged git diff for
# obvious API keys, JWTs, and private keys. Fires on `git commit` / `git push`.
# Target: <500ms. Unconditional — [bulk] / [release] / etc. do NOT skip this.

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

# Only act on git commit / git push / git add commands that might stage secrets.
case "$cmd" in
  *"git commit"*|*"git push"*) ;;
  *) exit 0;;
esac

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

# Collect staged diff (for commit) or last commit diff (for push).
case "$cmd" in
  *"git commit"*) diff_output=$(git diff --cached --unified=0 2>/dev/null || true);;
  *"git push"*)   diff_output=$(git log -p --unified=0 "origin/main..HEAD" 2>/dev/null \
                               || git log -p --unified=0 -n 5 2>/dev/null || true);;
esac

[[ -z "$diff_output" ]] && exit 0

# Fast regex patterns — tuned for signal, not exhaustive.
# Only scan added lines (start with '+' but not '+++').
added=$(echo "$diff_output" | grep -E '^\+[^+]' || true)
[[ -z "$added" ]] && exit 0

violations=""

# OpenAI / Anthropic style API keys.
if echo "$added" | grep -qE '(sk-|sk_live_|sk_test_)[a-zA-Z0-9_-]{20,}'; then
  violations="${violations}\n- sk-/sk_live/sk_test API key pattern"
fi

# AWS access keys.
if echo "$added" | grep -qE 'AKIA[0-9A-Z]{16}'; then
  violations="${violations}\n- AWS access key (AKIA…)"
fi

# GitHub personal access tokens.
if echo "$added" | grep -qE 'gh[pousr]_[A-Za-z0-9]{30,}'; then
  violations="${violations}\n- GitHub token (ghp_/gho_/ghu_/ghs_/ghr_)"
fi

# Generic private keys.
if echo "$added" | grep -qE -- '-----BEGIN (RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY-----'; then
  violations="${violations}\n- Private key block (-----BEGIN … PRIVATE KEY-----)"
fi

# JWT-like tokens (three base64 segments).
if echo "$added" | grep -qE 'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'; then
  violations="${violations}\n- JWT-like token (eyJ…\.eyJ…\.…)"
fi

if [[ -n "$violations" ]]; then
  cat <<EOF >&2
Blocked: pre-commit-secret-scan detected potential secrets in staged diff.
$(printf "%b" "$violations")

This scan is unconditional — [bulk]/[release]/[infra] prefixes do NOT skip it.
Review the diff, move secrets to your platform secret store, and retry.
EOF
  exit 2
fi

exit 0
