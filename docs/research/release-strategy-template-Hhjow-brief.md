# Research Brief — Release Strategy Template (`docs/templates/release-strategy.md`)

**Date:** 2026-04-20
**Researcher:** Claude (researcher subagent)
**Tool:** Internal repo analysis + GitHub issue #86
**Confidence:** High

---

## Scoping Decision

**Option (a) chosen — skip fresh research.**

The prior brief `docs/research/simplify-release-blueprint-giVF4-brief.md` already covers the market context, user problem, competitor branching-model patterns, and technical feasibility for this space. Issue #86 scopes the deliverable as *a new sacred template* (`docs/templates/release-strategy.md`) that was explicitly deferred from PR #84 (Decision 5 of the prior brief). No new market or technical research is required; the design inputs already exist.

---

## Research Questions

1. Does existing research sufficiently characterise the domain content the template must capture?
2. What structural conventions must the new template follow to be consistent with the existing sacred templates?

---

## Key Findings

### Finding 1 — Prior brief fully covers domain content

See `docs/research/simplify-release-blueprint-giVF4-brief.md` — Findings 1–6 and the Market Landscape table. That brief characterises: simplified (GitHub Flow / TBD) vs multi-environment (GitFlow) branching models; ephemeral preview environment requirements; feature-flag patterns and provider landscape; schema-migration discipline (expand-migrate-contract); and compliance / CAB carve-outs. All of this maps directly to the sections issue #86 requires in the new template.

### Finding 2 — Issue #86 specifies the required template sections

GitHub issue #86 (`parkjadev/agentic-blueprint`) lists the following sections as required template content:

- Chosen release profile (simplified / GitHub Flow, multi-environment / GitFlow, or custom variant)
- Precondition verification (alignment with guide requirements)
- Branch model and environment mapping
- Preview-environment approach
- Feature flag implementation (owner and lifecycle management)
- Schema migration methodology
- Approval and change-advisory board (CAB) workflow (if applicable)
- Rollback procedures
- Unresolved questions

### Finding 3 — Structural constraints from existing sacred templates

Existing templates in `docs/templates/` (e.g. `deployment.md`, `technical-spec.md`, `data-model-spec.md`) use: a top-level `# [Project Name] — [Document Type]` heading; a metadata block (date, author, status); clearly labelled `##` sections with inline guidance comments; `| column |` tables where appropriate; and a footer referencing agentic-blueprint. The new template must follow this pattern. No sections from issue #86 conflict with this convention.

---

## Market Landscape

See `docs/research/simplify-release-blueprint-giVF4-brief.md` — Market Landscape section. Not reproduced here to avoid duplication.

---

## Implications

- The Stage 2 plan should commission `docs/templates/release-strategy.md` using the section list from issue #86 as the spec input.
- The branch must match `docs/*` or `templates/*` per `.claude/hooks/template-guard.sh:39`. The working branch was renamed from `claude/release-strategy-template-Hhjow` to `docs/release-strategy-template-Hhjow` during Stage 2 to satisfy this gate.
- All guidance text in the template must use Australian spelling and remain tool-agnostic per Hard Rules 1 and 8.
- No domain-specific business logic in any example content (Hard Rule 2).
- The template is a *sacred* artefact once merged — it must not be modified as a side-effect of any other feature PR (Hard Rule 7).

---

## Open Questions

- Whether a worked example (filled-in sample) should accompany the blank template as a non-sacred sibling file — not blocked, but worth confirming in Stage 2.

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
