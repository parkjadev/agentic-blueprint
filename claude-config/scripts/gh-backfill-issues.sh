#!/usr/bin/env bash
#
# gh-backfill-issues.sh
#
# Create retroactive (closed) GitHub issues from a manifest file. Useful when:
#   - You bootstrapped a new project but forgot Hard Rule #2 ("issue before
#     branch") for the first N commits.
#   - You're adopting agentic-blueprint on an existing repo that already has
#     history and you want to back-fill issues to satisfy the audit trail.
#   - A session was interrupted and the issue-first discipline lapsed.
#
# Why this exists: hand-rolling 10+ retroactive issues with the right
# templates, labels, commit refs, and closing comments takes ~30 minutes per
# batch. This script does it in seconds and is idempotent — re-running with
# the same manifest is a no-op (it skips issues that already exist with the
# same title).
#
# Manifest format (one issue per line, pipe-separated):
#
#   <type>|<scope>|<title>|<commit-sha>|<body-file>
#
#   type       — feature|fix|chore|docs (matches the type:* label group)
#   scope      — api|dashboard|mobile|schema|auth|workflow (matches scope:*)
#   title      — full issue title, e.g. "feat: add user profile page"
#                MUST start with the conventional-commit prefix matching <type>
#   commit-sha — full or short SHA of the commit that landed this work
#                use - if no commit applies (rare)
#   body-file  — path to a file containing the issue body (markdown)
#                use - to use a generated default body
#
# Lines starting with # and blank lines are ignored.
#
# Example manifest (manifest.txt):
#
#   feature|workflow|feat: add label taxonomy bootstrap script|abc1234|-
#   chore|workflow|chore: scrub hardcoded brand references|def5678|bodies/scrub.md
#   docs|workflow|docs: rewrite deployment template|9012abc|-
#
# Usage:
#   ./gh-backfill-issues.sh manifest.txt                  # current gh repo
#   ./gh-backfill-issues.sh manifest.txt owner/repo       # explicit repo
#   DRY_RUN=1 ./gh-backfill-issues.sh manifest.txt        # show what would be created
#
# Requirements:
#   - gh CLI authenticated with write access on the target repo
#   - The label taxonomy already created (run setup-labels.sh first)

set -euo pipefail

MANIFEST="${1:-}"
REPO_ARG=()
if [[ $# -ge 2 ]]; then
  REPO_ARG=(--repo "$2")
fi
DRY_RUN="${DRY_RUN:-0}"

if [[ -z "${MANIFEST}" ]]; then
  echo "Usage: $0 <manifest-file> [owner/repo]" >&2
  echo "       DRY_RUN=1 $0 <manifest-file>" >&2
  exit 1
fi

if [[ ! -f "${MANIFEST}" ]]; then
  echo "Error: manifest file not found: ${MANIFEST}" >&2
  exit 1
fi

# Pull existing issue titles once so we can dedupe in O(1) per line.
echo "Fetching existing issues for dedupe..."
EXISTING_TITLES="$(gh issue list ${REPO_ARG[@]+"${REPO_ARG[@]}"} --state all --limit 1000 --json title --jq '.[].title')"

created=0
skipped=0
errors=0

while IFS='|' read -r type scope title sha body_file; do
  # Skip blank lines and comments.
  [[ -z "${type// }" ]] && continue
  [[ "${type:0:1}" == "#" ]] && continue

  # Validate fields.
  if [[ -z "${type}" || -z "${scope}" || -z "${title}" || -z "${sha}" || -z "${body_file}" ]]; then
    echo "  ERROR: malformed line (need 5 pipe-separated fields): ${type}|${scope}|${title}|..." >&2
    errors=$((errors + 1))
    continue
  fi

  # Skip if an issue with the same title already exists (idempotent).
  if grep -Fxq "${title}" <<<"${EXISTING_TITLES}"; then
    echo "  SKIP (exists): ${title}"
    skipped=$((skipped + 1))
    continue
  fi

  # Build the body.
  if [[ "${body_file}" == "-" ]]; then
    body="## Retroactive issue

This issue was back-filled by \`gh-backfill-issues.sh\` to provide an audit trail for work that landed before issue-first discipline was applied.

The work is in commit ${sha}."
  else
    if [[ ! -f "${body_file}" ]]; then
      echo "  ERROR: body file not found: ${body_file}" >&2
      errors=$((errors + 1))
      continue
    fi
    body="$(cat "${body_file}")"
  fi

  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "  DRY_RUN would create: ${title}"
    echo "    labels: type:${type},scope:${scope}"
    echo "    sha:    ${sha}"
    continue
  fi

  echo "  Creating: ${title}"
  url="$(gh issue create \
    ${REPO_ARG[@]+"${REPO_ARG[@]}"} \
    --title "${title}" \
    --label "type:${type},scope:${scope}" \
    --body "${body}")"
  number="${url##*/}"

  # Close immediately with a commit-reference comment.
  if [[ "${sha}" != "-" ]]; then
    gh issue close \
      ${REPO_ARG[@]+"${REPO_ARG[@]}"} \
      "${number}" \
      --comment "Back-filled retroactively. The work landed in ${sha}." \
      > /dev/null
  else
    gh issue close \
      ${REPO_ARG[@]+"${REPO_ARG[@]}"} \
      "${number}" \
      --comment "Back-filled retroactively." \
      > /dev/null
  fi

  created=$((created + 1))
done < "${MANIFEST}"

echo
echo "Done. Created: ${created}, Skipped: ${skipped}, Errors: ${errors}"

if [[ "${errors}" -gt 0 ]]; then
  exit 1
fi
