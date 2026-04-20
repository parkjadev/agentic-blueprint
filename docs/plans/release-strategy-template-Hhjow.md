# Plan — Release Strategy Template

**Slug:** `release-strategy-template-Hhjow`
**Branch:** `docs/release-strategy-template-Hhjow` (renamed from `claude/release-strategy-template-Hhjow` during Stage 2 to satisfy the `template-guard` escape-hatch)
**Issue:** [parkjadev/agentic-blueprint#86](https://github.com/parkjadev/agentic-blueprint/issues/86)
**Status:** Approved — ready for /build <!-- status: pending -->

---

## Linked artefacts

- Research brief — [`docs/research/release-strategy-template-Hhjow-brief.md`](../research/release-strategy-template-Hhjow-brief.md)
- Predecessor brief — [`docs/research/simplify-release-blueprint-giVF4-brief.md`](../research/simplify-release-blueprint-giVF4-brief.md) (domain content; Decision 5 deferred this template)
- PRD — [`docs/specs/release-strategy-template-Hhjow/PRD.md`](../specs/release-strategy-template-Hhjow/PRD.md)
- Technical spec — [`docs/specs/release-strategy-template-Hhjow/technical-spec.md`](../specs/release-strategy-template-Hhjow/technical-spec.md)

## Goal

Materialise `docs/templates/release-strategy.md` — a new sacred template — plus a single-line catalogue entry in `docs/templates/README.md`. One PR, docs-only.

## Decisions locked during Stage 2

1. **Branch prefix.** Working branch renamed to `docs/release-strategy-template-Hhjow` so the `template-guard` hook at `.claude/hooks/template-guard.sh:39` permits edits under `docs/templates/`.
2. **Worked example deferred.** A filled-in example is not part of this PR — it is tracked as a potential P1 follow-on. This PR ships exactly the P0 blank template.
3. **Spec set.** PRD + technical-spec only. No api-spec, data-model-spec, auth-spec, or architecture — the feature has no such surfaces.

## Implementation sequence

### Step 1 — Author the template

Create `docs/templates/release-strategy.md` with exactly the nine sections from issue #86, in this order, each carrying an inline HTML-comment guidance block:

1. Chosen release profile
2. Precondition verification
3. Branch model and environment mapping
4. Preview-environment approach
5. Feature flag implementation (owner and lifecycle)
6. Schema migration methodology
7. Approval and CAB workflow
8. Rollback procedures
9. Unresolved questions

Prefix with the sacred-template metadata block (Author, Date, Status) borrowed from `docs/templates/deployment.md`; close with the standard footer `*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*`.

Guidance prose must be role-based, not vendor-prescriptive — cross-reference `docs/guides/stage-4-ship.md`, `docs/guides/tool-reference.md`, and relevant files under `docs/principles/` where helpful.

### Step 2 — Register in the catalogue

Add one line to `docs/templates/README.md` pointing at the new file. Keep the addition minimal — one row in the existing catalogue table.

### Step 3 — Run the gates

Run in order on the feature branch:

1. `bash .claude/skills/australian-spelling/scripts/check.sh docs/templates/release-strategy.md`
2. `bash .claude/skills/hard-rules-check/scripts/check-all.sh`
3. Manual link check — every relative link in the new template resolves.
4. Spec-reviewer-style eyeballing: metadata block and footer match an existing sacred template; nine sections present; no vendor names as requirements inside guidance comments.

### Step 4 — Commit and open the PR

- Conventional commit message: `docs(templates): add release-strategy template (#86)`
- PR body references issue #86, PRD, and technical-spec.
- CHANGELOG entry via the `changelog-entry` skill happens in Stage 4 (/ship), not here.

## Out of scope (guardrails for /build)

- Do not modify any existing sacred template other than the single catalogue-row addition to `docs/templates/README.md`.
- Do not add a worked-example file.
- Do not touch `starters/`, `.github/workflows/`, `docs/guides/`, or the CI gate.
- Do not refactor other files "while here".

## Risks

| Risk | Mitigation |
|---|---|
| Template section headers drift from issue #86 wording | Use the list in this plan verbatim; reviewer cross-checks before merge |
| Guidance prose slips into prescriptive vendor framing (Rule 8) | Spec-reviewer pass specifically checks this; australian-spelling + hard-rules scripts run in Step 3 |
| Branch rename lost in the remote (nothing pushed yet) | No action — first push creates the correctly-named remote ref |
| README.md catalogue ordering contested during review | Append to the end of the catalogue table; re-order is a trivial follow-up if wanted |

## Next step

`/build` on branch `docs/release-strategy-template-Hhjow`.

---

*Plan generated in Stage 2. See `CLAUDE.md` Hard Rules 5 and 6.*
