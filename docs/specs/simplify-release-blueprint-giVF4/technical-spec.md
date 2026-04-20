# Technical Spec — Simplify Release Blueprint

**Author:** Claude (spec-writer subagent)
**Date:** 2026-04-19
**Status:** Draft
**PRD:** `docs/specs/simplify-release-blueprint-giVF4/PRD.md`
**Issue:** TBD — file against this spec at Stage 3 entry

---

## Overview

This spec describes the documentation-only changes that make the blueprint's implied release strategy explicit and opt-in. Two files are updated: `docs/guides/stage-4-ship.md` gains a "Choosing a release strategy" section that surfaces preconditions and names the two valid models; `docs/guides/tool-reference.md` gains a `## Release strategy profiles` section containing Profile A (Simplified / GitHub Flow) and Profile B (Multi-environment / GitFlow), following the existing platform-profile convention. No code, templates, starters, principles, hooks, or settings are modified in this PR. See the PRD for full problem framing and evidence.

---

## What's Already in Place (excluded from this plan)

| Capability | Where it lives | Notes |
|---|---|---|
| GitHub Flow description as default | `docs/guides/stage-4-ship.md:28–65` | "The default: merge to main equals production deploy" section exists; no changes to it |
| Versioned-release workflow | `docs/guides/stage-4-ship.md:69–95` | Already complete; untouched |
| Rollback procedures | `docs/guides/stage-4-ship.md:99–134` | Already complete; untouched |
| Platform implementation profiles (A/B/C) | `docs/guides/tool-reference.md:36–93` | Existing three profiles establish the naming convention and table format we follow |
| Expand-migrate-contract reference | `docs/templates/deployment.md` | Already references the pattern in a template comment; this spec surfaces it in the stage guide instead |
| Branch-strategy rationale (archive) | `docs/guides/_archive/release-workflow.md` | Records historical decision to abandon staging → main promotion; informs Profile A rationale but is not linked from published content |

**Excluded from scope:** `docs/templates/` (no template is created or modified), `starters/nextjs/`, `starters/flutter/`, `docs/principles/`, `.claude/hooks/`, `.claude/settings.json`, `docs/guides/stage-5-run.md`.

---

## Data Model Changes

Not applicable — this feature introduces no data model. All changes are to documentation prose.

### Migration Strategy

Not applicable — no database migration is required. The expand-migrate-contract pattern is *described* in the new guide content as a precondition for safe continuous deployment; it is not itself executed as part of this PR.

---

## API Changes

Not applicable — this feature introduces no API changes. All changes are to documentation prose.

---

## Auth & Authorisation

Not applicable — this feature introduces no auth surface. The guides are public documentation with no authentication requirement.

---

## Background Jobs

None.

---

## UI Changes

No UI changes. All changes are to Markdown documentation files.

---

## Testing Strategy

Because this feature is pure documentation, the test plan is a manual review checklist rather than automated test suites. The checklist must be completed before the PR is merged.

### Unit Tests

Not applicable — no application code is introduced.

### Integration Tests

Not applicable — no application code is introduced.

### E2E Tests

Not applicable — no application code is introduced.

### Documentation review checklist

- [ ] All internal cross-links in the new "Choosing a release strategy" section resolve. Specifically: the link to `tool-reference.md#profile-a-simplified-github-flow` and the link to `tool-reference.md#profile-b-multi-environment-gitflow` must navigate to the correct anchors.
- [ ] The back-link from each profile to `stage-4-ship.md#choosing-a-release-strategy` resolves correctly.
- [ ] Australian spelling check passes: `bash .claude/skills/australian-spelling/scripts/check.sh docs/guides/stage-4-ship.md` exits 0.
- [ ] Australian spelling check passes: `bash .claude/skills/australian-spelling/scripts/check.sh docs/guides/tool-reference.md` exits 0.
- [ ] No vendor name appears as a requirement in either new section. Permitted: vendor names as *examples* in a list of tools that fill a role (e.g. "runtime activation control — e.g. LaunchDarkly, PostHog, Unleash"). Not permitted: "you must use X" or "requires X".
- [ ] Neither profile uses prescriptive language (Principle 9). Words such as "recommended", "preferred", "default", or "you should use" must not appear in the profile body. The "Best for:" descriptor conveys context, not mandate.
- [ ] `git diff docs/templates/` returns empty — no template file is touched.
- [ ] The new `## Release strategy profiles` section sits after `## Platform implementation profiles` in `tool-reference.md` and before `## Handoff patterns`, preserving the existing document order.
- [ ] The new "Choosing a release strategy" section in `stage-4-ship.md` sits after the introductory "Why this stage exists" and "What you need" sections and before the "How it works — Continuous deployment" section, so it reads as a decision gate before operational detail.
- [ ] No section headers are deleted from either file; only additive changes are made.

---

## Rollout Plan

This PR contains only documentation changes. There is no runtime deployment or feature-flag activation sequence. The rollout phases track the two files being updated, in dependency order.

### Phase 1: Update `docs/guides/stage-4-ship.md` <!-- status: pending -->

Add the "Choosing a release strategy" section as specified in the "File changes" section below. This must land before Phase 2 because the profiles will back-link to this section's anchor; the anchor must exist before the back-link is reviewed.

- Add new section with the exact heading `## Choosing a release strategy`
- Include preconditions sub-section for Profile A
- Include compliance / CAB note directing readers to Profile B
- Include cross-links to both profiles in `tool-reference.md`
- Expand-migrate-contract callout present

### Phase 2: Update `docs/guides/tool-reference.md` <!-- status: pending -->

Add the `## Release strategy profiles` section with two profiles.

- Add section heading `## Release strategy profiles` after `## Platform implementation profiles`
- Add `### Profile A: Simplified (GitHub Flow)` with full content
- Add `### Profile B: Multi-environment (GitFlow)` with full content
- Each profile back-links to `stage-4-ship.md#choosing-a-release-strategy`

### Production rollout

Both phases are delivered in a single PR. There is no preview environment or deployment step — the change is effective when the PR is merged to `main` and the Markdown files are updated in the repository.

Rollback: revert the PR. No data migration or infrastructure change means rollback is instantaneous.

---

## File Changes (authoritative specification)

### `docs/guides/stage-4-ship.md`

**Position:** insert the new section after the `## What you need` section (line 23 in the current file) and before the `## How it works — Continuous deployment` section (line 27).

**Section heading (exact):**

```
## Choosing a release strategy
```

**Section content requirements:**

- Open with one paragraph explaining that the blueprint supports two named release models and that choosing explicitly — before writing pipeline configuration — prevents mismatched infrastructure.
- Sub-section `### Profile A: Simplified (GitHub Flow)` containing:
  - One-sentence description: trunk-based, `main` → production, ephemeral PR branches.
  - A "Preconditions" list with four items: (1) comprehensive automated test coverage at a minimum smoke-test level; (2) per-PR preview environments that mirror the production environment closely enough to surface integration issues; (3) runtime activation control — a mechanism to deploy code dark and activate it selectively (feature flags fill this role); (4) schema-change discipline — destructive migrations follow the expand-migrate-contract pattern across multiple PRs, never bundled with the application code change that depends on the new schema.
  - A "Best for:" descriptor: solo founders, small product teams, high-deployment-frequency SaaS, any context where regulatory or contractual obligations do not require pre-production human sign-off.
  - A cross-link: "See [Profile A: Simplified (GitHub Flow)][tool-ref-profile-a] in the Tool Reference for the full infrastructure role map."
- Sub-section `### Profile B: Multi-environment (GitFlow)` containing:
  - One-sentence description: long-lived `main`, `develop`, and release branches; shared staging environment; human approval gate before production.
  - A "Preconditions" list: shared staging environment that closely mirrors production; a Change Advisory Board or equivalent approval workflow; branch protection rules on `main` that require passing the approval gate.
  - A "Best for:" descriptor: regulated industries (banking, healthcare, government), enterprise teams with CAB obligations, any context where contractual or regulatory requirements mandate pre-production human sign-off.
  - A note that staging-production environment drift is the primary operational risk of this model and must be managed actively.
  - A cross-link: "See [Profile B: Multi-environment (GitFlow)][tool-ref-profile-b] in the Tool Reference for the full infrastructure role map."
- Close with a note that `docs/templates/release-strategy.md` — a per-project template for capturing the chosen model's decisions — is forthcoming in a separate PR.

**Cross-link anchor targets** (to be used in the Markdown links above):

- `docs/guides/tool-reference.md#profile-a-simplified-github-flow`
- `docs/guides/tool-reference.md#profile-b-multi-environment-gitflow`

---

### `docs/guides/tool-reference.md`

**Position:** insert the new section after the closing prose of `### Profile C: OutSystems ODC` (currently ending around line 93) and before `## Handoff patterns` (currently line 95).

**Section heading (exact):**

```
## Release strategy profiles
```

**Opening paragraph:** one sentence explaining that these profiles describe two branching and environment models, following the same descriptive convention as the platform implementation profiles above. Neither is presented as the default — the choice follows from preconditions described in `stage-4-ship.md`.

**Sub-section heading (exact):**

```
### Profile A: Simplified (GitHub Flow)
```

**Profile A content requirements:**

- "Best for:" line — same context descriptor as in `stage-4-ship.md` (solo founders, small product teams, high-deployment-frequency SaaS, no regulatory sign-off obligations).
- Role table with four rows:

| Infrastructure role | Description | Example tools (not exhaustive) |
|---|---|---|
| Version control | Single long-lived branch (`main`); ephemeral PR branches deleted after merge | GitHub, GitLab, Bitbucket |
| Per-PR preview environment | Isolated environment built automatically on PR open; mirrors production configuration | Any platform with native preview support or CI-driven ephemeral environments |
| CI gate | Automated test suite that must pass before merge; blocks merge on failure | GitHub Actions, GitLab CI, CircleCI, any CI platform |
| Runtime activation control | Mechanism to deploy code dark and activate it for users selectively, decoupling deployment from release | Feature flag services; self-hosted or managed |

- Paragraph on schema changes: expand-migrate-contract is mandatory under this model. Destructive schema changes (column drop, rename, type change) must be split across three PRs — expand (add new), migrate (backfill/dual-write), contract (remove old) — never bundled with the application code that depends on the new schema.
- Back-link: "For operational detail and preconditions, see [Choosing a release strategy](stage-4-ship.md#choosing-a-release-strategy) in the Stage 4 guide."

**Sub-section heading (exact):**

```
### Profile B: Multi-environment (GitFlow)
```

**Profile B content requirements:**

- "Best for:" line — regulated industries, enterprise teams with CAB obligations, any context where regulatory or contractual requirements mandate pre-production human sign-off.
- Role table with four rows:

| Infrastructure role | Description | Notes |
|---|---|---|
| Version control | Three long-lived branches: `main` (production-equivalent), `develop` (integration), release branches (cut from `develop`) | Hotfixes branch from `main` and merge back to both `main` and `develop` |
| Shared staging environment | Long-lived environment matching production configuration, used for QA and stakeholder sign-off before promotion to `main` | Staging-production drift is the primary operational risk; parity must be maintained actively |
| Approval gate | Human sign-off step (CAB, QA lead, or equivalent) required before merging release branch to `main` | Gate mechanism varies by organisation; examples include a protected-branch review rule, a change-management ticket, or an external approval workflow |
| CI gate | Automated test suite that must pass on every branch; does not replace the human approval gate | Same tooling options as Profile A |

- Paragraph noting that deployment frequency under this model is lower by design. The trade-off is deliberate: the approval gate provides an audit trail and regulatory compliance path at the cost of longer lead time.
- Back-link: "For operational detail and preconditions, see [Choosing a release strategy](stage-4-ship.md#choosing-a-release-strategy) in the Stage 4 guide."

---

## Dependencies

- None external. Both files being updated (`stage-4-ship.md` and `tool-reference.md`) are stable and not being modified by any other in-flight PR.
- The deferred `docs/templates/release-strategy.md` is a downstream dependency of this PR, not a prerequisite. It should reference the profile names and precondition lists established here.

---

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | ~~Should the "Choosing a release strategy" section sit before or after `## What you need` in `stage-4-ship.md`?~~ **Resolved (2026-04-20):** *after* `## What you need`, so readers have role-level orientation before making a model decision. Fixed in Phase 1 of the rollout plan above. | — | Closed |
| 2 | ~~Should a follow-up issue be filed for `docs/templates/release-strategy.md`?~~ **Resolved (2026-04-20):** yes — file a GitHub issue at merge time, labelled `type:feature, scope:docs`, so the deferred template has a discoverable home and is not buried in CHANGELOG. Added to the PR exit checklist. | Author | At merge |
| 3 | The Profile A example-tools column intentionally omits specific vendor names to comply with Principle 8. If reviewers find this too abstract, a parenthetical "(e.g. …)" list is acceptable provided no vendor is presented as required. Confirm acceptable level of specificity at review. | Reviewer | At PR review |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
