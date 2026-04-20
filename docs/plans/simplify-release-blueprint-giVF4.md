# Plan — Simplify Release Blueprint

**Slug:** `simplify-release-blueprint-giVF4`
**Branch:** `claude/simplify-release-blueprint-giVF4`
**Status:** Ready for `/build`
**Date:** 2026-04-20

---

## Inputs

| Artefact | Path |
|---|---|
| Research brief | `docs/research/simplify-release-blueprint-giVF4-brief.md` |
| PRD | `docs/specs/simplify-release-blueprint-giVF4/PRD.md` |
| Technical spec | `docs/specs/simplify-release-blueprint-giVF4/technical-spec.md` |

## Summary

Make the blueprint's implicit trunk-based release model explicit and opt-in. Pure documentation change — two files updated, no templates, starters, principles, hooks, or settings touched.

## Scope

- **In scope:** new `## Choosing a release strategy` section in `docs/guides/stage-4-ship.md`; new `## Release strategy profiles` section in `docs/guides/tool-reference.md` with two descriptive profiles (Simplified / GitHub Flow and Multi-environment / GitFlow).
- **Out of scope (deferred to separate PR):** `docs/templates/release-strategy.md` template commission (Principle 7 — templates sacred, dedicated branch required); any changes to `starters/`, `docs/principles/`, `.claude/hooks/`, `.claude/settings.json`, or `docs/guides/stage-5-run.md`.

## Implementation sequence

1. **Phase 1 — `docs/guides/stage-4-ship.md`.** Insert the new `## Choosing a release strategy` section between `## What you need` and `## How it works — Continuous deployment`. Content per technical-spec lines 140–154: intro paragraph, `### Profile A` with preconditions + "Best for" + cross-link, `### Profile B` with preconditions + "Best for" + drift warning + cross-link, closing note on the forthcoming template.
2. **Phase 2 — `docs/guides/tool-reference.md`.** Insert the new `## Release strategy profiles` section between `## Platform implementation profiles` (after Profile C) and `## Handoff patterns`. Include the opening paragraph, `### Profile A: Simplified (GitHub Flow)` with role table + expand-migrate-contract paragraph + back-link, `### Profile B: Multi-environment (GitFlow)` with role table + frequency-trade-off paragraph + back-link. Relative back-link path is `stage-4-ship.md#choosing-a-release-strategy` (no `../guides/` prefix — both files sit in `docs/guides/`).
3. **Phase 3 — Verify cross-links.** Manually follow each link. GitHub slugifies `### Profile A: Simplified (GitHub Flow)` to `profile-a-simplified-github-flow` and `### Profile B: Multi-environment (GitFlow)` to `profile-b-multi-environment-gitflow`. Confirm `## Choosing a release strategy` → `choosing-a-release-strategy`.

Phase 1 must land before Phase 2 in the diff so the anchor exists when the profile back-links are reviewed.

## Review checklist (from technical-spec Testing Strategy)

- [ ] All internal cross-links resolve (forward and back).
- [ ] Australian spelling check passes on both files (via the pre-commit hook).
- [ ] No vendor name appears as a requirement in either new section.
- [ ] No prescriptive language in profile bodies (no "recommended", "preferred", "default", "you should use").
- [ ] `git diff docs/templates/` returns empty.
- [ ] New sections sit in the positions specified (additive only, no header deletions).

## Exit criteria

- Both doc changes committed on this branch.
- Hard Rules hook passes at commit time (Rules 1, 7, 8, 9 are the relevant ones).
- Plan status updated to `complete` at merge via `memory-sync`.
- Follow-up issue filed at merge time for `docs/templates/release-strategy.md` (labelled `type:feature, scope:docs`).
- CHANGELOG Unreleased entry appended during `/ship`.

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Anchor slug drift if section titles are edited during review | Technical spec pins exact headings; reviewers must not rename without updating cross-links |
| Reviewer reads profile content as prescriptive | Opening paragraph of the profiles section states that neither is a default; choice follows from preconditions |
| Sentinel OS inadvertently named in guide content | Brief decision 7 forbids it; reviewers spot-check before merge |

## Next step

Run `/build` to execute Phases 1–3, then `/ship` to verify, append CHANGELOG, and open the PR.
