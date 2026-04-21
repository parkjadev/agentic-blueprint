#!/usr/bin/env bash
# UserPromptSubmit hook — append a one-line beat hint to the user prompt
# so the assistant always knows where in the v4 three-beat lifecycle we are.
# Stdout is appended as additional context to the user's message.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT" 2>/dev/null || exit 0

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[[ -z "$branch" ]] && exit 0

# Strip type/<issue>- prefix to derive the slug.
slug=$(echo "$branch" | sed -E 's#^[a-z]+/[0-9]+-##; s#^[a-z]+/##')

beat="?"
hint=""

# Branch-age warning (>7 days old).
age_warning=""
if [[ "$branch" != "main" && "$branch" != "master" ]]; then
  head_ts=$(git log -1 --format=%ct "$branch" 2>/dev/null || echo "")
  if [[ -n "$head_ts" ]]; then
    now=$(date +%s)
    age_days=$(( (now - head_ts) / 86400 ))
    if (( age_days > 7 )); then
      age_warning=" · branch age: ${age_days}d (>7d — consider finishing)"
    fi
  fi
fi

# Classify by branch state and on-disk artefacts.
if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  beat="Signal"
  hint="On main. Use /signal sync after merges, /signal audit for periodic review, or /spec feature <slug> to start the next feature."
elif [[ -d "docs/specs/$slug" || -f "docs/specs/$slug.md" ]]; then
  beat="Ship"
  hint="Spec exists. Use /ship to implement and open the PR; /ship is idempotent and resumable."
elif [[ -f "docs/research/${slug}-brief.md" ]]; then
  beat="Spec (mid)"
  hint="Research brief present. Use /spec feature $slug to draft the specs (or /spec epic / /spec idea as appropriate)."
else
  beat="Spec (start)"
  hint="No brief or spec yet. Use /spec feature $slug, or /spec idea <product> for a greenfield product, or /spec fix <issue> for a bug."
fi

cat <<EOF
[beat-hint] branch=$branch · beat=$beat${age_warning}
$hint
EOF
