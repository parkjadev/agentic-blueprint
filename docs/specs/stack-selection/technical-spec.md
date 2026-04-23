---
scope: feature
parent: agentic-blueprint-v5-agnostic
status: Draft
---

# Feature — Stack Selection section in research-brief + spec-researcher guidance

## Problem

v5's core pivot is that **stack selection is an output of the Spec beat, not an input** (v5 PRD Feature Matrix row 2). The research brief is the artefact that should carry that output. Today, neither `docs/templates/research-brief.md` nor the `spec-researcher` agent definition give authors a structured place to record alternatives, evaluation criteria, and a justified recommendation. `/spec idea` runs can silently skip the whole exercise.

Research-brief Finding 9 R2 ("Stack research in `spec-researcher` is too shallow to be useful", likelihood High) is the risk this feature mitigates.

## Solution

Two minimal edits:

1. **`docs/templates/research-brief.md`** — add a "Stack Selection" section with three sub-headings (Evaluation Criteria, Alternatives Considered, Recommendation). Scope-conditional: render for `/spec idea` product briefs, skip for feature-scope briefs.
2. **`.claude/agents/spec-researcher.md`** — add an Inputs bullet plus a Process step that activates when the scope hint is `product`. The step requires at least three alternatives evaluated against the criteria table and a recommendation with a one-paragraph justification.

No new primitives, no new files beyond the spec itself.

## Changes

| Path | Change |
|---|---|
| `docs/templates/research-brief.md` | Add "Stack Selection" section between "Market Landscape" and "Implications". Scope-conditional comment at top of section. |
| `.claude/agents/spec-researcher.md` | Inputs: add "Scope `product` implies Stack Selection is required". Process: add step 4b — "if scope is `product`, populate Stack Selection with ≥ 3 alternatives + criteria + recommendation". |

## Technical notes

- **Scope-conditional rendering convention.** The PRD template already uses this pattern ("Render the *Vision*, *Success Metrics*, *Non-Goals* sections only when `Scope: product`"). Use the same convention in the research-brief template.
- **Alternative count floor: 3.** Evaluating one option and declaring it "the choice" is assertion, not research. Two options is a binary with no control. Three forces discrimination and surfaces the real trade-offs. The agent should refuse to write a stack recommendation with fewer than three alternatives considered.
- **Evaluation criteria aren't prescribed.** The template prompts the author to name 4–6 criteria relevant to the product (examples: data-sovereignty, runtime-cost ceiling, team-skill inventory, time-to-first-deploy, ecosystem maturity). Don't bake a fixed criteria list into the template — that's Rule 5 prescriptiveness.
- **Budget impact.** The added section fits within the existing 4000-word cap in the research-brief budget preamble (set in PR #114). No preamble change needed.

## Testing

Manual smoke:

1. Run `/spec idea <throwaway>` on a scratch branch. Verify `spec-researcher` populates Stack Selection with three alternatives and a recommendation.
2. Run `/spec feature <slug>`. Verify the brief (if one is produced at all) does NOT have Stack Selection filled — it's product-scoped only.
3. Read the resulting brief — confirm the Recommendation paragraph cites the criteria table, not ad-hoc claims.

Automated smoke: none in v5.0. The brief format check is operator-review for now.

## Acceptance criteria

- [x] Template has a "Stack Selection" section with the three sub-headings
- [x] Template carries a scope-conditional comment directing when to render
- [x] `spec-researcher.md` Inputs + Process reflect the new expectation
- [x] Australian spelling passes
- [x] Rule 4 passes via `templates/*` branch name

## Out of scope

- Machine-readable schema for Stack Selection (e.g. YAML that validates alternatives). Stays prose-only in v5.0.
- Automated criterion-library (shared list of reusable criteria). Prescriptive-risk per Rule 5.
- Changes to `/spec idea` command prompt. The template + agent cover the contract; the command doesn't need to know.

## References

- v5 PRD Feature Matrix row 2: `docs/specs/agentic-blueprint-v5-agnostic/PRD.md`
- Research brief Finding 9 R2: `docs/research/agentic-blueprint-v5-agnostic-brief.md`
- Existing scope-conditional pattern: `docs/templates/PRD.md` — "Scope-aware sections" block
