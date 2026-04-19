#!/usr/bin/env bash
# UserPromptSubmit hook — append a one-line stage hint to the user prompt
# so the assistant always knows where in the lifecycle the team currently is.
# Stdout is appended as additional context to the user's message.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT" 2>/dev/null || exit 0

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[[ -z "$branch" ]] && exit 0

# Strip the type/<issue>- prefix to derive the slug.
slug=$(echo "$branch" | sed -E 's#^[a-z]+/[0-9]+-##; s#^[a-z]+/##')

stage="?"
hint=""

if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  stage="5 (Run)"
  hint="On main. Use /run for post-merge tasks; /new-feature to start the next feature."
elif [[ -d "docs/specs/$slug" && -f "docs/plans/$slug.md" ]]; then
  stage="3 (Build) or 4 (Ship)"
  hint="Specs and plan exist. Use /build to implement; /ship when ready for PR."
elif [[ -f "docs/research/${slug}-brief.md" ]]; then
  stage="2 (Plan)"
  hint="Research brief present. Use /plan $slug to draft specs."
else
  stage="1 (Research & Think)"
  hint="No brief yet. Use /research $slug to start."
fi

cat <<EOF
[stage-hint] branch=$branch · stage=$stage
$hint
EOF
