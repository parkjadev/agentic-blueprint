# Release Strategy — Lumen

**Author:** Lumen founder (example)
**Date:** 2026-04-20
**Status:** Approved

> **Worked example** of [`docs/templates/release-strategy.md`](../templates/release-strategy.md). Copy the blank template — not this file — when starting a new project. This file is updated whenever the blank template's section list changes.

---

## Chosen Release Profile

**Profile A — Simplified / GitHub Flow.**

Lumen is a solo-founder productivity SaaS with roughly twenty early-access users, one long-lived branch (`main`), and per-PR preview environments provided by the hosting platform. Deployment volume sits at around two to four production merges per week; there is no regulated data, no compliance gate, and no second engineer who would benefit from a longer-lived integration branch. Profile A is the right shape: one protected trunk, short-lived feature branches, preview environments as the de-facto "staging", and feature flags where risk needs staged exposure. A Multi-environment / GitFlow profile would add ceremony that the team size cannot sustain.

## Precondition Verification

- [x] Observability covers error rate, latency, and deployment markers — error-tracking service ingests browser and server exceptions; the hosting platform's analytics dashboard surfaces p50/p95 latency; every production deployment emits a release marker visible on the error-rate timeline.
- [x] Automated tests gate the merge-to-main path — branch protection on `main` requires the CI workflow to pass; the workflow runs unit tests, type checks, and a headless smoke test against the preview URL.
- [x] A rollback lever exists and has been exercised at least once — the hosting platform's "promote previous deployment" flow was rehearsed during onboarding and took twelve seconds end-to-end; the runbook captures the exact click-path.
- [x] Feature-flag mechanism is in place — a hosted feature-flag service is wired into the web and worker processes; the catalogue currently carries four flags.
- [x] Database migration tooling supports expand-migrate-contract — the ORM's migration CLI supports additive column adds, backfills, and drop operations as separate migrations; see §Schema Migration Methodology below.
- [x] Branch-protection rules match the chosen profile — `main` is protected; direct pushes are disallowed; PRs require one approving review (solo founder can self-approve via the admin override, documented in the operations handbook) and a green CI run.
- [x] On-call and incident-response procedure is documented — the founder is the sole on-call; escalation tree is trivial (founder → external advisor for severe data incidents). The incident-response runbook lives alongside this document at `docs/operations/incident-response.md`.

## Branch Model and Environment Mapping

| Branch | Lifecycle | Environment | Deploy trigger | Notes |
|---|---|---|---|---|
| `main` | Long-lived, protected | Production | Squash-merge to `main` | Canonical shipping branch; deployed automatically by the hosting platform |
| `feat/<slug>` | Short-lived, per-PR | Preview (per-PR URL) | PR opened | Auto-deletes on merge; seeded with the shared dev dataset |
| `hotfix/<slug>` | Short-lived, per-incident | Preview → Production | PR opened → squash-merge | Same lifecycle as `feat/`; prefix signals incident context for reviewers |

**Merge discipline:** squash-merge. Chosen for a linear history that maps one-to-one with production releases, and to keep `git bisect` trivial. The only exception is release-tag commits, which are annotated tags pointing at existing squash-merge commits on `main`; no merge commits are introduced.

## Preview-Environment Approach

Every open PR receives an ephemeral preview URL of the form `https://lumen-<pr-number>.preview.example`. The preview platform[^1] rebuilds on each push to the PR branch and tears the environment down when the PR merges or closes. Preview environments share a single non-production database, reseeded nightly from an anonymised snapshot; per-PR seeded databases are out of scope for Lumen's current scale but are an option if data isolation becomes a concern.

There is no long-lived shared "staging" branch. Preview URLs are the review surface for visual changes, manual exploratory testing, and the automated smoke test that the CI workflow runs before allowing merge. The preview environment for a PR is destroyed as soon as the PR is closed, so any state discovered in preview must be reproducible from a fresh seed; state that is not reproducible is a signal to fix the seed script, not to preserve the environment.

## Feature Flag Implementation

| Dimension | This project |
|---|---|
| Mechanism | Hosted feature-flag service, wired into the web and worker processes via a thin wrapper; SDK evaluates flags in memory with five-second TTL. |
| Owner | Founder. The four-flag catalogue is small enough that a dedicated owner is unnecessary; the founder reviews it quarterly. |
| Rollout ladder | Internal (staff accounts) → 1% → 10% → 100%. Each step holds for at least 24 hours unless a regression is detected. |
| Default for new flags | Off. A new flag is dark until its author explicitly promotes it to the internal step. |
| Cleanup policy | Flags retired within four weeks of 100% rollout. The quarterly audit pulls a report of all flags at 100% for more than twenty-eight days and opens retirement tickets. |
| Audit cadence | Quarterly. The founder walks the catalogue, confirms each flag's owner and intended lifetime, and retires stale entries. |

## Schema Migration Methodology

- **Regime:** live (expand-migrate-contract). Lumen crossed from pre-launch into this regime when the first external user signed up; that was the documented trigger to tighten, agreed at project kickoff.
- **Trigger to tighten:** first external user. Already past; noted here for future reference and in case the regime ever needs to be explained to a second engineer joining the team.
- **Destructive change procedure:** any drop, rename, or NOT-NULL tightening is split across three PRs. **Expand** adds the new column or table, leaving the old one in place. **Migrate** backfills data and dual-writes from application code. **Contract** drops the old column or table. Each PR lands separately and is observed in production for at least one deployment cycle before the next begins.
- **Dry-run requirement:** migrations are rehearsed against the preview environment's database before the PR is merged. The CI workflow runs the migration as part of the preview build and fails the PR if it does not apply cleanly.
- **Rollback:** additive migrations are reversible by running the ORM's `migrate:down` command. Destructive migrations (the contract phase of an expand-migrate-contract split) are guarded by a twenty-four-hour delay after the preceding migrate phase; rollback inside that window is a revert of the contract PR. Outside the window, rollback requires a fresh expand-migrate-contract cycle in the reverse direction and is treated as a separate change rather than a rollback.
- **Observability:** the deployment-event log captures migration start, completion, and row-count delta. An anomaly in the row-count delta triggers a pager alert; the on-call compares the delta against the migration's expected scope before clearing.

## Approval and CAB Workflow

N/A — no approval gate beyond PR review. Lumen handles no regulated data, has no external auditor, and operates a single-person engineering function; a Change Advisory Board would be ceremony without substance. Revisit on first regulated deployment (for example, processing healthcare or payment-card data), at which point a lightweight approval gate becomes appropriate.

## Rollback Procedures

| Order | Lever | How to run | Side-effects | Authority |
|---|---|---|---|---|
| 1 | Disable the feature flag | Open the hosted flag service, toggle the offending flag to "off" globally | Instant; reversible; affects only users currently in the flag's rollout set | Founder (solo on-call) |
| 2 | Promote the previous deployment | Hosting platform dashboard → Deployments → pick the last green deploy → "Promote to production" | Seconds of request queueing; no data loss | Founder (solo on-call) |
| 3 | Revert the offending commit on `main` | `git revert <sha>` on `main`, push, wait for the auto-deploy to complete | One standard deployment cycle (~3 minutes); reverts application code only, not data | Founder (solo on-call); external advisor notified if the revert touches a destructive migration |
| 4 | Restore the database from snapshot | Hosting platform → Database → Backups → pick the nearest snapshot before the incident → restore | Possible data loss back to the snapshot point; write outage for the duration of the restore | Founder only, after the external advisor has confirmed the scope of loss |

**Decision tree.** Lever 1 is tried first whenever the failing code path is behind a flag — the flag is the cheapest and most precise reversal. Lever 2 is the default when the code path is unflagged but the previous deployment is known-good and the offending change did not include a destructive migration. Lever 3 is reached when the issue is subtle enough that a forward fix is preferable to a promotion, or when multiple deploys have occurred since the regression landed. Lever 4 is the last resort and is reserved for data corruption; application-level incidents do not reach it. If a decision between levers takes more than five minutes under pressure, the founder declares an incident per `docs/operations/incident-response.md` and uses the incident channel as the coordination point instead of continuing to roll back alone.

## Unresolved Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | ~~Should `main` tags become immutable once the first paying customer signs up?~~ **Resolved 2026-04-20:** yes. The first paying customer is the trigger; tag protection will be enabled on `main` at that moment, with the operations handbook updated in the same PR. | Founder | Resolved |

[^1]: Preview environments are provided by the project's hosting platform; the specific vendor is recorded in the operations handbook, not this strategy document, so a platform switch is a one-line change rather than a multi-section rewrite.

---

*Worked example — see [docs/templates/release-strategy.md](../templates/release-strategy.md) for the blank template.*
