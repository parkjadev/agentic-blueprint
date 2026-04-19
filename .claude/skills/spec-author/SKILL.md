---
name: spec-author
description: Use when drafting any spec document — PRD, technical spec, API spec, data-model spec, auth spec — or when docs/templates/ is being populated for a new feature. Fills the sacred templates with feature-specific content while preserving every section header. Loads template references on demand rather than inlining them. Keywords — spec, PRD, technical spec, API spec, data-model, auth spec, template, feature planning, Stage 2 Plan.
allowed-tools: Read, Write, Edit, Glob
model: sonnet
---

# Spec author

The spec templates in `docs/templates/` are the contract (Hard Rule #7 — sacred). This skill is how you fill them in correctly.

## When to reach for this skill

- You are the `spec-writer` subagent, or the user is drafting a spec in the main conversation
- A PRD, technical-spec, api-spec, data-model-spec, auth-spec, or architecture doc is being created or updated
- Asked anything mentioning "spec", "PRD", "template", "draft the plan", "feature brief"

## How to use it

1. **Inventory the template set on demand.** Run `ls docs/templates/` in Bash, or use Glob. Do not pre-load them.
2. **Read only the template(s) you need.** Each template has section headers, explanatory comments, and examples. Preserve every section header.
3. **When you need worked examples**, load one of the `references/` files below. Don't load them all.
   - `references/prd-examples.md` — filled-in PRD patterns
   - `references/api-examples.md` — filled-in API spec patterns
   - `references/data-model-examples.md` — data model patterns
   - `references/auth-examples.md` — auth spec patterns
4. **For routine template copies**, use the shared assets:
   - `assets/` — pre-stripped copies of each template, ready to write to `docs/specs/<slug>/<name>.md`
5. **Never modify `docs/templates/`** — that's Hard Rule #7.

## Section-header discipline

- Every template section must survive in the draft. If a section is genuinely not applicable, keep the header and write "Not applicable — <one-sentence reason>".
- Do not add new top-level sections unless the template explicitly invites them. Sub-sections are fine.
- Citations (for PRDs) go under the existing "Evidence / References" section — don't invent a new one.

## Quality gates

- Australian spelling throughout (reach for the `australian-spelling` skill).
- Every claim that's not self-evident must cite a source — the research brief, an external link, or a prior spec.
- No "TBD" in a section that the feature actually requires. "TBD" means the author didn't do the work.
- Data-model fields must match API-spec response shapes. Auth-spec flows must match data-model user states.

## Do NOT

- Re-derive template structure from memory — always Read the template file
- Dump the full drafted spec into your caller's context; return a summary instead
- Edit templates in `docs/templates/`
