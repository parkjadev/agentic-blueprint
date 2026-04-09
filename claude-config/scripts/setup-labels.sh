#!/usr/bin/env bash
#
# setup-labels.sh
#
# Bootstrap the label taxonomy on a fresh repo so the issue templates and
# branch naming convention work out of the box.
#
# Creates:
#   type:*    — what kind of change it is
#   scope:*   — which area of the codebase
#   status    — triage helpers (urgent, blocked, needs-triage)
#
# It does NOT create vertical:* labels — those are project-specific. Add them
# yourself once you know your verticals.
#
# Usage:
#   ./setup-labels.sh                  # uses gh's current repo
#   ./setup-labels.sh owner/repo       # explicit repo
#
# Requirements:
#   - gh CLI authenticated with write scope on the target repo

set -euo pipefail

REPO_ARG=()
if [[ $# -ge 1 ]]; then
  REPO_ARG=(--repo "$1")
fi

# Each entry: name|colour|description
labels=(
  # type:* — one per issue/PR
  "type:feature|0e8a16|New user-facing capability"
  "type:fix|d73a4a|Bug fix or regression"
  "type:chore|c5def5|Maintenance, refactor, deps, tooling"
  "type:docs|0075ca|Documentation only"

  # scope:* — area of the codebase
  "scope:api|fbca04|src/app/api/** route handlers"
  "scope:dashboard|fbca04|Web dashboard / admin UI"
  "scope:mobile|fbca04|Flutter mobile companion"
  "scope:schema|fbca04|Database schema, migrations, Drizzle"
  "scope:auth|fbca04|Clerk, JWT, middleware, roles"
  "scope:workflow|fbca04|CI, hooks, build, scripts, repo plumbing"

  # status — triage state
  "needs-triage|ededed|Awaiting triage"
  "blocked|b60205|Blocked on something else"
  "urgent|d93f0b|Production-impacting, ship now"
)

for entry in "${labels[@]}"; do
  IFS='|' read -r name colour description <<<"${entry}"
  echo "→ ${name}"
  # --force makes this idempotent: creates if missing, updates colour/description if it exists.
  # The "${REPO_ARG[@]+"${REPO_ARG[@]}"}" expansion is the bash-strict-mode safe way to splice
  # in an optional array — without the +"..." form, an empty array trips `set -u` (nounset).
  gh label create "${name}" \
    --color "${colour}" \
    --description "${description}" \
    --force \
    ${REPO_ARG[@]+"${REPO_ARG[@]}"} \
    > /dev/null
done

echo
echo "Created/updated ${#labels[@]} labels."
echo
echo "Next:"
echo "  - Add any vertical:* labels for your project's distinct areas (optional)"
echo "  - Run claude-config/scripts/setup-branch-protection.sh to lock down main"
