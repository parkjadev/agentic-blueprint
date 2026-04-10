#!/usr/bin/env bash
#
# update-plan-status.sh
#
# Update status markers in plan files when a PR lands. Plan files
# (`docs/specs/<feature>/plan.md`) become static the moment they're approved
# unless something keeps them in sync with what's actually been shipped. This
# script is that something.
#
# Convention: every phase line in a plan file carries an inline status marker
# in HTML comment form, like this:
#
#     ## Phase 1: Schema and types <!-- status: pending -->
#     ## Phase 2: API routes <!-- status: pending -->
#     ## Phase 3: UI <!-- status: pending -->
#
# When a PR lands that completes a phase, run:
#
#     ./update-plan-status.sh docs/specs/user-profile/plan.md "Phase 1" 42
#
# …and the marker becomes:
#
#     ## Phase 1: Schema and types <!-- status: shipped (#42) -->
#
# The script only touches the matching marker, never adjacent prose.
#
# Usage:
#   ./update-plan-status.sh <plan-file> <phase-label> <pr-number>
#
# Example:
#   ./update-plan-status.sh docs/specs/user-profile/plan.md "Phase 1" 42
#
# Intended to be invoked from a Claude Code post-merge hook — see
# claude-config/hooks/post-merge.md.

set -euo pipefail

PLAN_FILE="${1:-}"
PHASE="${2:-}"
PR="${3:-}"

if [[ -z "${PLAN_FILE}" || -z "${PHASE}" || -z "${PR}" ]]; then
  echo "Usage: $0 <plan-file> <phase-label> <pr-number>" >&2
  echo "Example: $0 docs/specs/user-profile/plan.md \"Phase 1\" 42" >&2
  exit 1
fi

if [[ ! -f "${PLAN_FILE}" ]]; then
  echo "Error: plan file not found: ${PLAN_FILE}" >&2
  exit 1
fi

# Validate PR number is purely digits.
if ! [[ "${PR}" =~ ^[0-9]+$ ]]; then
  echo "Error: PR number must be digits only, got: ${PR}" >&2
  exit 1
fi

# We update lines that match: <heading marker> <phase label> ... <!-- status: pending -->
# The match is intentionally narrow:
#   - Anchored to lines that contain the literal phase label (case-sensitive)
#   - Only modifies the inline `<!-- status: pending -->` marker, leaving the
#     rest of the heading text untouched
#   - Idempotent: re-running with the same args is a no-op (marker already
#     contains the PR number, so the regex won't match)
#
# We use a portable sed pattern that works on both BSD (macOS) and GNU sed:
# write to a tmp file, then mv into place.

TMP="$(mktemp)"
trap 'rm -f "${TMP}"' EXIT

# Escape the phase label for sed (basic regex metacharacters).
phase_escaped="$(printf '%s' "${PHASE}" | sed 's/[][\.*^$/]/\\&/g')"

awk -v phase="${PHASE}" -v pr="${PR}" '
{
  if (index($0, phase) > 0 && match($0, /<!--[[:space:]]*status:[[:space:]]*pending[[:space:]]*-->/)) {
    sub(/<!--[[:space:]]*status:[[:space:]]*pending[[:space:]]*-->/, "<!-- status: shipped (#" pr ") -->")
    matched = 1
  }
  print
}
END {
  if (!matched) {
    exit 1
  }
}
' "${PLAN_FILE}" > "${TMP}"

if [[ $? -ne 0 ]]; then
  echo "No pending status marker found for phase: ${PHASE}" >&2
  echo "(Either the phase label doesn't match, or the marker is already shipped, or the marker is missing.)" >&2
  exit 2
fi

mv "${TMP}" "${PLAN_FILE}"

echo "Updated ${PLAN_FILE}: ${PHASE} → shipped (#${PR})"
