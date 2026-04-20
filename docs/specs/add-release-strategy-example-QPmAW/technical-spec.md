# Technical Spec — Release Strategy Worked Example

**Author:** Claude (main agent, drafting after spec-writer timeouts)
**Date:** 2026-04-20
**Status:** Shipped (#93)
**PRD:** [`docs/specs/add-release-strategy-example-QPmAW/PRD.md`](./PRD.md)
**Issue:** Follow-up from [parkjadev/agentic-blueprint#88](https://github.com/parkjadev/agentic-blueprint/pull/88) (tracked in that PR's §Follow-ups)

---

## Overview

Add a single new file at `docs/examples/release-strategy.md` — a fully filled-in worked example of the sacred blank template shipped in PR #88. Demonstrates Profile A (Simplified / GitHub Flow) for a fictional small-team SaaS named "Lumen". Adds a one-line cross-link in `docs/templates/README.md` and a one-line "Example" callout in `docs/guides/stage-4-ship.md`. Docs-only feature: no code, no schema, no API, no UI.

## What's Already in Place (excluded from this plan)

| Capability | Where it lives | Notes |
|---|---|---|
| Blank sacred template (nine sections, inline guidance) | `docs/templates/release-strategy.md:1-147` | Shipped PR #88; this spec references its section headers exactly but does not modify it |
| Stage-4 guide and profile descriptions | `docs/guides/stage-4-ship.md`, `docs/guides/tool-reference.md` | Shipped PR #84; the example's filled content is consistent with Profile A as described there; no edits apart from a single-line callout |
| Template catalogue | `docs/templates/README.md` | One-line addition registering the new worked example; no other edit |
| Template-guard hook | `.claude/hooks/template-guard.sh:33-50` | Protects `docs/templates/*`. Because we edit `docs/templates/README.md`, the branch must be prefixed `docs/*` or `templates/*` (see Phase 1 below) |
| Hard Rules enforcement | `.claude/skills/hard-rules-check/scripts/check-all.sh` | Runs Australian spelling, tool-agnostic, spec-present, plan-present gates |
| Australian spelling wordlist | `.claude/skills/australian-spelling/references/wordlist.md` | Used to validate prose in the new example |
| Predecessor specs and plan | `docs/specs/release-strategy-template-Hhjow/*`, `docs/plans/release-strategy-template-Hhjow.md` | Referenced for structural conventions only; unchanged |

**Excluded from scope:** any sacred-template modifications in `docs/templates/` beyond the single-line cross-link in `README.md`; any second worked example (Profile B or other templates); any automated structural-drift check between the example and the blank template; any starter or CI changes.

## Data Model Changes

None. This feature adds a markdown file, not a data structure.

### Migration Strategy

- [x] **Pre-launch?** N/A — docs artefact; no database involved.
- [x] Migration is additive — N/A.
- [x] Destructive split — N/A.
- [x] Tested on dev database — N/A.
- [x] Rollback plan documented — see Rollout Plan below (rollback = revert the PR).

## API Changes

None. No endpoints added or modified.

## Auth & Authorisation

None. No runtime access-control surface added. The example file lives outside `docs/templates/` and is therefore NOT subject to the `template-guard` hook (this is a deliberate design decision — see PRD §Non-Functional Requirements, "Example is not sacred").

## Background Jobs

None.

## UI Changes

No application UI. The artefact is a markdown file rendered in GitHub and readable from downstream project repos as a reference.

## Testing Strategy

### Unit Tests
- [ ] N/A — no executable code.

### Integration Tests
- [ ] N/A — no integrations.

### E2E Tests
- [ ] N/A — no user flow to exercise.

### Verification Steps (replaces unit/integration/E2E for a docs artefact)

- [ ] `bash .claude/skills/hard-rules-check/scripts/check-all.sh` exits 0 on the renamed feature branch (covers Rules 1, 5, 6, 7, 8 directly; Rules 2, 3, 4, 9 are N/A because no starter or code changes).
- [ ] `bash .claude/skills/australian-spelling/scripts/check.sh docs/examples/release-strategy.md` exits 0.
- [ ] `grep -c "TODO" docs/examples/release-strategy.md` returns 0 — no residual placeholder markers.
- [ ] Section-header diff — every section header in `docs/examples/release-strategy.md` appears, in the same order and at the same heading level, as in `docs/templates/release-strategy.md`. No added, removed, or reordered sections.
- [ ] Manual link check — every internal cross-reference in the new example resolves to an existing file on the feature branch.
- [ ] Spec-reviewer pass confirms: no vendor name appears in body prose as a requirement (footnote use is permitted for illustrative grounding); metadata block follows the sacred-template convention but the footer is the distinct worked-example variant (see Phase 2); the "this is a worked example, copy the blank template instead" note is present at the top of the file.

## Rollout Plan

Single-file change with two small cross-link edits. No phasing, no feature flags, no staged rollout.

### Phase 1: Rename branch to satisfy template-guard <!-- status: shipped (#93) -->

- Current branch: `claude/add-release-strategy-example-QPmAW`.
- `template-guard` hook at `.claude/hooks/template-guard.sh:33-50` blocks writes under `docs/templates/*` from any branch not prefixed `docs/*` or `templates/*`. This PR edits `docs/templates/README.md` for the catalogue cross-link, so the current branch name would block the build.
- Rename locally: `git branch -m claude/add-release-strategy-example-QPmAW docs/add-release-strategy-example-QPmAW`.
- Push the renamed branch: `git push -u origin docs/add-release-strategy-example-QPmAW`.
- Delete the obsolete remote: `git push origin --delete claude/add-release-strategy-example-QPmAW` (only if already pushed; otherwise skip).
- Verify: `git rev-parse --abbrev-ref HEAD` returns the new name; a dry-run `git add docs/templates/README.md` on the renamed branch does not trip the hook.

### Phase 2: Draft the example and register it in the catalogue <!-- status: shipped (#93) -->

- Create `docs/examples/release-strategy.md` with the nine sections from the blank template at `docs/templates/release-strategy.md`, in the same order and at the same heading level:
  1. Chosen Release Profile — declares "Profile A: Simplified / GitHub Flow" with a one-paragraph rationale naming the nearest blueprint profile and explaining fit for Lumen (solo founder, pre-revenue, low deployment volume, no regulated data).
  2. Precondition Verification — all seven checklist items ticked, each annotated with a brief role-based note (e.g. "Observability: error-tracking service captures error rate and latency; deployment markers emitted on each production build").
  3. Branch Model and Environment Mapping — two-row table (`main` production, squash-merge on PR merge; `feat/<slug>` preview, auto-deploy on PR open, auto-teardown on merge). Squash-merge discipline stated with rationale.
  4. Preview-Environment Approach — prose describing the per-PR ephemeral URL, shared non-production dataset seeded per-build, auto-teardown lifecycle; the preview-environment platform named in a footnote only.
  5. Feature Flag Implementation — all six table rows filled: mechanism (hosted flag service, role-described), owner (founder), rollout ladder (internal → 1% → 10% → 100%), default (off), cleanup policy (retired within four weeks of 100% rollout), audit cadence (quarterly catalogue review).
  6. Schema Migration Methodology — regime: live (first external user already onboarded, so expand-migrate-contract applies); trigger that moved the project from pre-launch into this regime documented; destructive change procedure: expand → migrate → contract across three PRs; dry-run requirement: preview branch database; rollback notes; observability signals (deployment-event log).
  7. Approval and CAB Workflow — "N/A — no approval gate beyond PR review. Revisit on first regulated deployment." — modelling the correct N/A response for a small pre-revenue SaaS.
  8. Rollback Procedures — four-row table populated: disable feature flag (on-call, instant), promote previous deployment (on-call, seconds), revert offending commit (on-call with lead approval, standard deploy time), restore database from snapshot (lead only, possible data loss). Decision-tree prose explaining escalation between levers.
  9. Unresolved Questions — a small illustrative table with one entry already resolved (struck through with resolution note), modelling how the section evolves over time.
- Inline HTML-comment guidance blocks from the blank template are REMOVED in the example. The example shows the finished artefact, not another template to fill; leaving them in would be misleading and increase structural noise.
- Top-of-file note (directly under the metadata block, above the first heading): "Worked example of `docs/templates/release-strategy.md`. Copy the blank template — not this file — when starting a new project. Updated when the blank template's section list changes."
- Metadata block: Author "Lumen founder (example)", Date "2026-04-20", Status "Approved" — modelling a completed document.
- Footer distinguishes the example from a sacred template — use `*Worked example — see [docs/templates/release-strategy.md](../templates/release-strategy.md) for the blank template.*` rather than the standard `*Template from [agentic-blueprint]...*` footer. This prevents readers from mistaking the file as something to be copied verbatim.

### Phase 3: Cross-link from the template catalogue and Stage-4 guide <!-- status: shipped (#93) -->

- Add a single line to `docs/templates/README.md` next to the existing `release-strategy.md` entry: "See `docs/examples/release-strategy.md` for a worked example." Exact wording and placement finalised at build time to match the catalogue's existing row structure.
- Add a single sentence to `docs/guides/stage-4-ship.md` alongside the existing reference to the blank template: "See `docs/examples/release-strategy.md` for a worked example of a filled-in release strategy." Close to the blank-template pointer; no section restructure.

### Production rollout

1. **Preview:** PR opens → reviewers read the rendered markdown on GitHub → run verification steps (see Testing Strategy).
2. **Production:** Squash-merge to `main` → example is immediately available for downstream projects to reference.
3. **Rollback trigger:** Structural issue discovered post-merge → revert the PR; the new `docs/examples/` directory disappears; both cross-link edits revert cleanly. No runtime risk.

### Sync discipline (reviewer checklist)

No automated drift check is in scope for this PR. If a future PR modifies the blank template's section list (adds, removes, renames, or reorders a section), the same PR MUST update `docs/examples/release-strategy.md` to match. Reviewers of any PR touching `docs/templates/release-strategy.md` should open the example side-by-side and confirm the headers still align. This expectation is stated in the PRD's Non-Functional Requirements ("Sync discipline — manual") and recorded here so the obligation is visible at build time.

## Dependencies

- The blank template at `docs/templates/release-strategy.md` must exist (it does — PR #88 merged 2026-04-20).
- The Stage-4 guide and profile descriptions in `docs/guides/` — cross-referenced from the example's filled content; not modified.
- No new tooling, no new skills, no hook changes.

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | ~~Does editing `docs/templates/README.md` trip the `template-guard` hook from the current branch name?~~ **Resolved 2026-04-20:** yes — `docs/templates/README.md` matches `docs/templates/*` at `.claude/hooks/template-guard.sh:33`. Resolution: rename the branch to `docs/add-release-strategy-example-QPmAW` before /build (see Phase 1). | Main agent | Resolved |
| 2 | ~~Should the example retain the blank template's inline HTML guidance comments?~~ **Resolved 2026-04-20:** no — removing them avoids the misleading impression that the example is another template to fill. The top-of-file note explicitly redirects readers to copy the blank template. | Main agent | Resolved |
| 3 | ~~Should a Profile B (Multi-environment / GitFlow) example ship in the same PR?~~ **Resolved 2026-04-20:** no — separate PR. Profile B requires different fictional project framing (regulated context, CAB detail) and would widen this PR unnecessarily. Tracked as a P1 follow-on. | Main agent | Resolved |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
