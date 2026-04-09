#!/usr/bin/env bash
#
# unblock-protection.sh
#
# Temporarily disable `enforce_admins` on a protected branch so an admin can
# push a one-off emergency fix, then automatically restore it.
#
# Why this script exists: setting `enforce_admins=false` permanently is the
# single most common path back to broken branches. Operators say "just for one
# emergency" and then never turn it back on. This script enforces the
# auto-restore so the unblock window is always bounded.
#
# How it works:
#   1. Reads current branch protection
#   2. Sets enforce_admins=false
#   3. Prints a 60-second countdown (so you know the window is open)
#   4. Restores enforce_admins=true
#
# If the script is killed mid-window (Ctrl-C, terminal close, etc.) the
# `trap` ensures enforce_admins is still restored. Worst case: a stale
# enforce_admins=false that you can re-protect by running setup-branch-protection.sh.
#
# Usage:
#   ./unblock-protection.sh                        # current gh repo + main
#   ./unblock-protection.sh owner/repo             # explicit repo
#   ./unblock-protection.sh owner/repo my-branch   # explicit repo + branch
#   UNBLOCK_SECONDS=120 ./unblock-protection.sh    # custom window length
#
# Requirements:
#   - gh CLI authenticated with admin scope on the target repo

set -euo pipefail

REPO="${1:-}"
BRANCH="${2:-main}"
UNBLOCK_SECONDS="${UNBLOCK_SECONDS:-60}"

if [[ -z "${REPO}" ]]; then
  if ! REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)"; then
    echo "Error: no repo argument given and no current gh context. Pass owner/repo." >&2
    exit 1
  fi
fi

restore_protection() {
  echo
  echo "Restoring enforce_admins=true on ${REPO}@${BRANCH}..."
  if gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    "repos/${REPO}/branches/${BRANCH}/protection/enforce_admins" \
    > /dev/null 2>&1; then
    echo "Restored. Branch is protected again."
  else
    echo "WARNING: failed to restore enforce_admins automatically." >&2
    echo "Run 'setup-branch-protection.sh ${REPO} ${BRANCH}' to re-protect." >&2
    exit 1
  fi
}

# Always restore on exit, even if killed mid-countdown.
trap restore_protection EXIT

echo "Disabling enforce_admins on ${REPO}@${BRANCH} for ${UNBLOCK_SECONDS}s..."
gh api \
  --method DELETE \
  -H "Accept: application/vnd.github+json" \
  "repos/${REPO}/branches/${BRANCH}/protection/enforce_admins" \
  > /dev/null

echo
echo "==============================================================="
echo "  enforce_admins is OFF. You have ${UNBLOCK_SECONDS} seconds."
echo "  Push your fix now, then this script will auto-restore."
echo "  Ctrl-C is safe — restore still runs on exit."
echo "==============================================================="
echo

for ((i = UNBLOCK_SECONDS; i > 0; i--)); do
  printf "\r  %2ds remaining..." "${i}"
  sleep 1
done
printf "\r  0s remaining...\n"

# trap fires now, restoring protection.
