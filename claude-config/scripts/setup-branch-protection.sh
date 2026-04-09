#!/usr/bin/env bash
#
# setup-branch-protection.sh
#
# Configure branch protection for `main` on a freshly created repo so it
# matches the agentic-blueprint defaults.
#
# Defaults applied:
#   - Pull request required before merging (1 approval)
#   - Conversation resolution required before merging
#   - Required status checks: the CI workflow defined in
#     starters/nextjs/.github/workflows/ci.yml (job name: "Type Check, Lint & Test")
#   - Linear history required (forces squash merges)
#   - Force pushes blocked
#   - Deletion blocked
#   - enforce_admins = true (admins cannot bypass — non-negotiable)
#
#     Why this is non-negotiable: setting it to false "for emergencies" is the
#     single most common path back to broken branches. The temptation goes:
#     "I just need to push this hotfix, I'll turn enforce_admins off for a
#     minute, push, and turn it back on." Then nobody turns it back on, and
#     three weeks later somebody force-pushes to main by accident.
#
#     If you genuinely need to bypass protection for a one-off emergency, run
#     `unblock-protection.sh` instead — it temporarily disables enforce_admins,
#     prints a 60-second countdown, and auto-restores. There is no path through
#     this script (or any other in claude-config/scripts/) that leaves
#     enforce_admins permanently off.
#
# Usage:
#   ./setup-branch-protection.sh                        # uses gh's current repo + 'main'
#   ./setup-branch-protection.sh owner/repo             # explicit repo, default branch 'main'
#   ./setup-branch-protection.sh owner/repo my-branch   # explicit repo + branch
#   REQUIRED_CHECK="My Check Name" ./setup-branch-protection.sh
#
# Requirements:
#   - gh CLI authenticated with admin scope on the target repo
#   - jq (only for the verification step at the end — optional)

set -euo pipefail

REPO="${1:-}"
BRANCH="${2:-main}"
REQUIRED_CHECK="${REQUIRED_CHECK:-Type Check, Lint & Test}"

if [[ -z "${REPO}" ]]; then
  if ! REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)"; then
    echo "Error: no repo argument given and no current gh context. Pass owner/repo." >&2
    exit 1
  fi
fi

echo "Configuring branch protection on ${REPO}@${BRANCH}"
echo "  required check: ${REQUIRED_CHECK}"
echo

# The branch protection API is finicky about field shapes. We send the full
# document via stdin so jq/heredoc handles escaping for us.
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "repos/${REPO}/branches/${BRANCH}/protection" \
  --input - <<JSON
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["${REQUIRED_CHECK}"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": false
}
JSON

echo
echo "Branch protection applied. Disabling merge commit + rebase merge so squash is the only option..."

# Repo-level merge button settings: only squash merges allowed.
gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  "repos/${REPO}" \
  -f allow_squash_merge=true \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f delete_branch_on_merge=true \
  -f allow_auto_merge=true \
  > /dev/null

echo "Squash-only merge configured. Branches will auto-delete on merge."
echo
echo "Verification:"
gh api "repos/${REPO}/branches/${BRANCH}/protection" \
  | (jq '{
      required_status_checks,
      enforce_admins,
      required_linear_history,
      allow_force_pushes,
      allow_deletions,
      required_conversation_resolution
    }' 2>/dev/null || cat)

echo
echo "Done. ${REPO}@${BRANCH} is now protected per agentic-blueprint defaults."
