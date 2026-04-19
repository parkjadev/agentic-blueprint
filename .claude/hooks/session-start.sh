#!/usr/bin/env bash
# SessionStart hook — emit the lifecycle orientation map and current stage hint.
# Stdout is injected as system context for the session.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT" 2>/dev/null || exit 0

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

cat <<EOF
Agentic Blueprint — five-stage lifecycle

Stage 1 Research & Think → /research <topic>    → docs/research/<slug>-brief.md
Stage 2 Plan             → /plan <slug>         → docs/specs/<slug>/*, docs/plans/<slug>.md
Stage 3 Build            → /build               → implementation, hard-rules-check
Stage 4 Ship             → /ship                → starter-verifier, changelog-entry, PR
Stage 5 Run              → /run <task>          → memory-sync, docs-inspector

Current branch: $branch
Run /stage for a status snapshot.
EOF
