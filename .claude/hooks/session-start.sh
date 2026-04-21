#!/usr/bin/env bash
# SessionStart hook — emit the v4 three-beat orientation map and current beat hint.
# Stdout is injected as system context for the session.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT" 2>/dev/null || exit 0

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

cat <<EOF
Agentic Blueprint v4 — three-beat lifecycle

Spec   → /spec <idea|epic|feature|fix|chore> <slug>  → docs/specs/<slug>.md
Ship   → /ship                                         → PR + CI + deploy + verify (idempotent)
Signal → /signal <init|sync|audit|status>              → post-ship sync, scheduled tasks, learnings

Status → /beat                                         → current beat + next-best command
Install/Update → /beat install | /beat update          → adopt-in-place or pull updates

Tagged-exception commit prefixes: [release] [infra] [docs] [bulk]
See docs/principles/README.md for the 5 Hard Rules + 3 meta-principles.

Current branch: $branch
Run /beat for a status snapshot.
EOF
