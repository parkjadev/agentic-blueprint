# Plan — Release Strategy Worked Example

**Slug:** `add-release-strategy-example-QPmAW`
**Branch:** `docs/add-release-strategy-example-QPmAW` (to be renamed from `claude/add-release-strategy-example-QPmAW` before /build — see Step 1)
**Issue:** Follow-up from [parkjadev/agentic-blueprint#88](https://github.com/parkjadev/agentic-blueprint/pull/88) — §Follow-ups committed to a P1 worked-example PR; no new GitHub issue opened yet.
**Status:** Approved — ready for /build <!-- status: pending -->

---

## Linked artefacts

- PRD — [`docs/specs/add-release-strategy-example-QPmAW/PRD.md`](../specs/add-release-strategy-example-QPmAW/PRD.md)
- Technical spec — [`docs/specs/add-release-strategy-example-QPmAW/technical-spec.md`](../specs/add-release-strategy-example-QPmAW/technical-spec.md)
- Blank template being illustrated — [`docs/templates/release-strategy.md`](../templates/release-strategy.md)
- Predecessor PR #88 artefacts — [`docs/specs/release-strategy-template-Hhjow/PRD.md`](../specs/release-strategy-template-Hhjow/PRD.md), [`docs/specs/release-strategy-template-Hhjow/technical-spec.md`](../specs/release-strategy-template-Hhjow/technical-spec.md), [`docs/plans/release-strategy-template-Hhjow.md`](./release-strategy-template-Hhjow.md)
- Predecessor research briefs (domain context; no fresh brief this PR) — [`docs/research/release-strategy-template-Hhjow-brief.md`](../research/release-strategy-template-Hhjow-brief.md), [`docs/research/simplify-release-blueprint-giVF4-brief.md`](../research/simplify-release-blueprint-giVF4-brief.md)

## Goal

Materialise `docs/examples/release-strategy.md` — a fully filled-in worked example of the sacred blank template shipped in PR #88. Demonstrates Profile A (Simplified / GitHub Flow) for a fictional small-team SaaS named "Lumen". Add a one-line cross-link from `docs/templates/README.md` and a one-line callout in `docs/guides/stage-4-ship.md`. One PR, docs-only.

## Decisions locked during Stage 2

1. **Research skipped.** PR #88's brief plus `simplify-release-blueprint-giVF4-brief.md` already cover the domain. Remaining work is scoping, not discovery — locked in the PRD.
2. **Location.** `docs/examples/release-strategy.md` — outside `docs/templates/`, deliberately NOT subject to Hard Rule 7. Creates the `docs/examples/` directory; a README inside `docs/examples/` becomes appropriate once a second example lands (not in scope here).
3. **Profile demonstrated.** Profile A (Simplified / GitHub Flow). A Profile B variant is a P1 follow-on, tracked outside this PR.
4. **Fictional project.** "Lumen" — solo-founder productivity SaaS, live (first external user onboarded), pre-revenue. Tool-agnostic framing throughout; vendor names permitted in footnotes only.
5. **Branch rename required before /build.** Current branch `claude/add-release-strategy-example-QPmAW` will be blocked by `.claude/hooks/template-guard.sh` when editing `docs/templates/README.md` for the catalogue cross-link. Rename to `docs/add-release-strategy-example-QPmAW` as Step 1.
6. **Inline guidance comments removed in the example.** The example shows the finished artefact, not another template to fill. A top-of-file note redirects readers to the blank template.
7. **Distinct footer.** Example uses `*Worked example — see [docs/templates/release-strategy.md](../templates/release-strategy.md) for the blank template.*` rather than the sacred-template footer, to avoid the "copy this file" misreading.
8. **Spec set.** PRD + technical-spec only. No api-spec, data-model-spec, auth-spec, or architecture — the feature has no such surfaces.
9. **Migration regime in the example:** live (expand-migrate-contract), trigger to tighten: first external user (already past). Rollout ladder: internal → 1% → 10% → 100%. Both choices aligned across PRD and technical-spec after the reviewer pass.

## Implementation sequence

### Step 1 — Rename the branch

`template-guard` requires `docs/*` or `templates/*` branch prefix for writes under `docs/templates/`. Rename before any file write:

1. `git branch -m claude/add-release-strategy-example-QPmAW docs/add-release-strategy-example-QPmAW`
2. `git push -u origin docs/add-release-strategy-example-QPmAW`
3. If the old branch is already on the remote: `git push origin --delete claude/add-release-strategy-example-QPmAW`
4. Verify with `git rev-parse --abbrev-ref HEAD`.

### Step 2 — Author the worked example

Create `docs/examples/release-strategy.md`. Structure:

- Metadata block: Author "Lumen founder (example)", Date "2026-04-20", Status "Approved".
- Top-of-file note: "Worked example of `docs/templates/release-strategy.md`. Copy the blank template — not this file — when starting a new project. Updated when the blank template's section list changes."
- Nine sections, byte-identical headers (same order and heading level) to the blank template at `docs/templates/release-strategy.md`:
  1. Chosen Release Profile — Profile A / Simplified / GitHub Flow, with fit rationale for Lumen.
  2. Precondition Verification — all seven items ticked with role-based notes.
  3. Branch Model and Environment Mapping — two-row table (`main` production / squash-merge; `feat/<slug>` preview / auto-deploy on PR open).
  4. Preview-Environment Approach — ephemeral per-PR URL, shared dev dataset, auto-teardown on merge; preview platform named in footnote only.
  5. Feature Flag Implementation — six-row table: hosted flag service (role-described), founder-owned, rollout ladder internal → 1% → 10% → 100%, default off, four-week cleanup, quarterly audit.
  6. Schema Migration Methodology — live regime (expand-migrate-contract), trigger that moved the project from pre-launch documented, three-PR destructive procedure, preview dry-run, rollback notes, deployment-event log as observability.
  7. Approval and CAB Workflow — "N/A — no approval gate beyond PR review. Revisit on first regulated deployment."
  8. Rollback Procedures — four rows: disable flag / promote previous deployment / revert commit / restore snapshot. Decision-tree prose for escalation.
  9. Unresolved Questions — illustrative table with one entry shown resolved (strikethrough + resolution note).
- Remove the inline HTML-comment guidance blocks from the blank template (they do not belong in a finished-artefact example).
- Footer: `*Worked example — see [docs/templates/release-strategy.md](../templates/release-strategy.md) for the blank template.*` — NOT the sacred-template footer.

### Step 3 — Register the example in the catalogue and guide

1. Add one line to `docs/templates/README.md` next to the existing `release-strategy.md` entry: "See `docs/examples/release-strategy.md` for a worked example." Exact wording and placement match the catalogue's existing row structure.
2. Add one sentence to `docs/guides/stage-4-ship.md` alongside the existing reference to the blank template: "See `docs/examples/release-strategy.md` for a worked example of a filled-in release strategy."

### Step 4 — Run the gates

Run in order on the renamed feature branch:

1. `bash .claude/skills/australian-spelling/scripts/check.sh docs/examples/release-strategy.md`
2. `bash .claude/skills/hard-rules-check/scripts/check-all.sh`
3. `grep -c "TODO" docs/examples/release-strategy.md` → returns 0.
4. Section-header diff between the example and the blank template — zero divergence in header text, order, and heading level.
5. Manual link check — every relative link in the new example resolves on the feature branch.
6. Reviewer-style eyeballing — no vendor names in body prose as requirements; metadata block, top-of-file note, and distinct worked-example footer all present.

### Step 5 — Commit and open the PR

- Conventional commit message: `docs(examples): add release-strategy worked example`.
- PR body references PR #88 (the deferral), the PRD, and the technical-spec.
- CHANGELOG entry via the `changelog-entry` skill happens in Stage 4 (/ship), not here.

## Out of scope (guardrails for /build)

- Do not modify any sacred template beyond the single catalogue-row addition to `docs/templates/README.md`.
- Do not add a second worked example (Profile B, other templates).
- Do not add any automated drift check between the example and the blank template — sync is manual for now (recorded in the technical-spec's "Sync discipline" subsection).
- Do not touch `starters/`, `.github/workflows/`, or the CI gate.
- Do not refactor adjacent files "while here".

## Risks

| Risk | Mitigation |
|---|---|
| Branch rename forgotten, `template-guard` blocks catalogue edit mid-build | Step 1 is first and has a verify command; pre-commit-gate will also catch the violation if missed |
| Section headers drift from the blank template | Step 4 #4 adds an explicit diff check; reviewer cross-checks before merge |
| Guidance prose slips into prescriptive vendor framing inside the example body | `hard-rules-check` (Rule 8) runs in Step 4; vendor names permitted only in footnotes |
| Readers mistake the example for another template to copy | Top-of-file note + distinct footer + `docs/examples/` location (not `docs/templates/`) |
| Example structurally drifts from the blank template after a future PR | Technical-spec §Sync discipline records the reviewer obligation; no tooling scoped for this PR |

## Next step

Rename the branch (Step 1), then run `/build`.

---

*Plan generated in Stage 2. See `CLAUDE.md` Hard Rules 5 and 6.*
