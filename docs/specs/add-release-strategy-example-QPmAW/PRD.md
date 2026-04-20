# Product Requirements Document — Release Strategy Worked Example

**Author:** Claude (spec-writer subagent)
**Date:** 2026-04-20
**Status:** Draft

---

## Problem Statement

PR #88 (merged 2026-04-20) shipped `docs/templates/release-strategy.md` — a blank sacred template that downstream projects copy and fill in to document their chosen release strategy. That PR explicitly deferred a companion worked example, noting: "A worked example is a P1 follow-on, tracked outside this spec" (PRD §Out of Scope; technical-spec §Open Questions #1). This PRD commissions that follow-up.

The blank template is structurally complete — nine sections, inline guidance comments, and a metadata block — but guidance comments alone leave a usability gap. A solo founder working through the Precondition Verification checklist or the Feature Flag Implementation table for the first time has no concrete anchor for what realistic, appropriately detailed content looks like. They must infer from guidance text alone whether their prose is at the right depth, whether they are correctly describing a role versus naming a vendor, and whether "N/A" in the Approval and CAB Workflow section is a legitimate answer for their project or an avoidance of work they should actually do.

The same gap affects blueprint contributors reviewing downstream release-strategy documents: without a shared reference showing agreed-upon section depth and prose register, review feedback varies between reviewers and is harder to make actionable.

A worked example at `docs/examples/release-strategy.md` closes both gaps. It demonstrates a fully filled-in Profile A (Simplified / GitHub Flow) release strategy for a representative fictional small-team SaaS — realistic enough to pattern-match against, tool-agnostic enough to not rot with stack changes, and structurally identical to the blank template so it can be used as a section-by-section guide.

## Target Users

| User Segment | Description | Priority |
|---|---|---|
| Solo founders and small-team leads | Copied `docs/templates/release-strategy.md` into their project and want a concrete reference to pattern-match against while filling it in. Most likely to stall at sections requiring structured tables (Feature Flag Implementation, Rollback Procedures) or nuanced role-based prose (Preview-Environment Approach, Schema Migration Methodology). Profile A (Simplified / GitHub Flow) users are the primary sub-group. | Primary |
| Blueprint contributors and spec reviewers | Open the example as a structural benchmark when reviewing a downstream project's filled-in release strategy, or when evaluating whether a proposed change to the blank template's section list creates awkward gaps or unclear guidance. | Secondary |

## User Journeys

### Journey 1: Filling in a stalled section using the example as a reference

**Trigger:** A solo founder is filling in the blank release-strategy template in their project repo. They reach the Preview-Environment Approach section and are unsure what level of detail is appropriate, or how to describe their infrastructure without naming a vendor.

1. Founder opens `docs/examples/release-strategy.md` (linked from `docs/templates/README.md`).
2. They read the Preview-Environment Approach section of the example — a paragraph describing an ephemeral per-PR URL, a seeded dev dataset strategy, and a tear-down-on-merge lifecycle, all in role language, with the platform named only in a footnote.
3. Founder understands the expected depth and framing, then writes their own section following the same pattern, substituting their actual platform and data-seeding approach.
4. They repeat this for the Rollback Procedures and Schema Migration Methodology sections, which are the most commonly under-filled in practice.

**Outcome:** The founder's release-strategy document is fully filled in with appropriately detailed, tool-agnostic prose — a genuine operational reference, not a half-empty skeleton.

### Journey 2: Using the example as a benchmark during PR review

**Trigger:** A blueprint contributor is reviewing a downstream project's filled-in `docs/release-strategy.md` as part of a PR. Several sections look thin — single-line answers where the guidance comments ask for a paragraph or a complete table.

1. Contributor opens `docs/examples/release-strategy.md` alongside the document under review.
2. They compare section depth and completeness against the example — specifically checking whether the Feature Flag Implementation table has all six rows populated and whether the Rollback Procedures table lists an ordered lever sequence.
3. Contributor leaves targeted review comments pointing to the example: "See `docs/examples/release-strategy.md` §Feature Flag Implementation for the expected depth."

**Outcome:** Review feedback is specific and actionable; the contributor does not have to reconstruct expectations from memory or describe in abstract terms what a complete answer looks like.

## Feature Matrix

| Feature | Description | Priority | Journey |
|---|---|---|---|
| Chosen Release Profile section — filled | Example states "Profile A: Simplified / GitHub Flow" with a realistic one-paragraph rationale covering team size, deployment cadence, and the absence of regulatory obligations | P0 | 1, 2 |
| Precondition Verification section — filled | All seven checklist items resolved with ticks and brief project-specific notes confirming how each precondition is met for the fictional project (Lumen) | P0 | 1, 2 |
| Branch Model and Environment Mapping section — filled | Realistic two-row table (`main` → Production, squash-merge trigger; `feat/<slug>` → Preview, PR-open trigger) plus a paragraph on merge discipline | P0 | 1, 2 |
| Preview-Environment Approach section — filled | Paragraph describing ephemeral per-PR URL, per-PR seed dataset strategy, tear-down-on-merge lifecycle, and the role of the preview-environment platform; platform named only in a footnote | P0 | 1, 2 |
| Feature Flag Implementation section — filled | All six table rows completed: mechanism (hosted flag service, role-described), owner (founder), rollout ladder (internal → 1% → 10% → 100%), default (off), cleanup policy (four-week window after full rollout), audit cadence (quarterly) | P0 | 1, 2 |
| Schema Migration Methodology section — filled | All six bullet fields completed: regime (live — first external user triggers expand-migrate-contract), destructive change procedure across three separate PRs, dry-run in preview environment, rollback notes, and deployment-event log as observability | P0 | 1, 2 |
| Approval and CAB Workflow section — filled | "N/A — no approval gate beyond PR review" with a one-sentence rationale and a note to revisit on first regulated deployment — modelling the correct N/A response for a small unregulated SaaS | P0 | 1, 2 |
| Rollback Procedures section — filled | All four rollback lever rows populated with lever name, how-to steps, side-effects, and authority; plus a decision-tree paragraph describing when to escalate between levers | P0 | 1, 2 |
| Unresolved Questions section — filled | At least one example question shown as closed with a resolution and date, demonstrating the intended housekeeping discipline; no open questions remain in the example (it models an approved, settled document) | P0 | 1, 2 |
| Metadata block — filled, Status: Approved | Author, date, and status set to "Approved" to model what a finalised, agreed-upon release strategy looks like | P0 | 1, 2 |
| Section headers byte-identical to the blank template | Every `##` heading in the example matches the blank template exactly; no sections added, removed, or renamed | P0 | 2 |
| No residual TODO markers | Zero instances of the literal string "TODO" in the example file | P0 | 1, 2 |
| Fictional project is tool-agnostic and role-based | Prose describes infrastructure by role (e.g. "hosted feature-flag service", "preview-environment platform") — no vendor names in the body text | P0 | 1, 2 |
| Cross-link from `docs/templates/README.md` | A short pointer ("see `docs/examples/release-strategy.md` for a worked example") added next to the `release-strategy.md` entry in the template catalogue | P0 | 1 |
| Optional cross-link from `docs/guides/stage-4-ship.md` | A one-line callout alongside the existing pointer to `docs/templates/release-strategy.md` at the end of the "Choosing a release strategy" section — included if it improves discoverability without cluttering the guide | P1 | 1 |
| `docs/examples/` directory established | The new file creates the `docs/examples/` directory, which becomes the home for future worked examples of other templates; this PR adds only `release-strategy.md` | P0 | 1, 2 |

## Non-Functional Requirements

| Requirement | Target | Measurement |
|---|---|---|
| Australian spelling | All prose in `docs/examples/release-strategy.md` and in the cross-link edits uses Australian English variants | Passes `bash .claude/skills/australian-spelling/scripts/check.sh docs/examples/release-strategy.md` with exit 0 |
| Tool-agnostic framing (Hard Rule 8) | No vendor names appear as requirements or prescriptions in the body prose; infrastructure described by role; vendors permitted only in footnotes as illustrative examples | Manual review: 0 instances of prescriptive vendor framing; passes hard-rules-check Rule 8 |
| Structural match to blank template | Section headers in the example are byte-identical to those in `docs/templates/release-strategy.md`; no sections added, removed, or reordered | Manual diff of `##` heading lines between example and blank template produces zero divergence |
| No residual TODO markers | The string "TODO" does not appear anywhere in the example file | `grep -c "TODO" docs/examples/release-strategy.md` returns 0 |
| Filled status block | Metadata block shows "Status: Approved" to model what a completed document looks like | Manual inspection of the metadata block |
| Hard-rules-check passage | All nine Hard Rules pass on the feature branch | `bash .claude/skills/hard-rules-check/scripts/check-all.sh` exits 0 |
| Example file is NOT sacred (explicit) | `docs/examples/release-strategy.md` is explicitly NOT subject to Hard Rule 7 (templates are sacred). It lives under `docs/examples/`, not `docs/templates/`. It SHOULD be updated whenever the blank template's section list changes. This must be called out in the technical spec and in the file's own header comment so future contributors do not treat it as protected. | File path is outside the `template-guard` hook's coverage; header comment states this explicitly |
| Sync discipline — manual for now | Structural drift between the example and the blank template is caught by PR reviewer eyes. If a future PR updates the blank template's section list, that same PR must update the example to match. No automated CI hook is required for this. | Reviewer checklist item; noted in the technical spec's Rollout Plan |

## Success Metrics

| Metric | Current | Target | Timeframe |
|---|---|---|---|
| Example file exists at the correct path | File does not exist | `docs/examples/release-strategy.md` present on the feature branch | At merge |
| All nine sections filled with no residual TODOs | Not applicable — file does not exist | `grep -c "TODO" docs/examples/release-strategy.md` returns 0 | At merge |
| Section headers byte-identical to blank template | Not applicable — file does not exist | Manual header diff produces zero divergence | At PR review |
| Hard-rules-check exits 0 | Not applicable — branch does not exist | `bash .claude/skills/hard-rules-check/scripts/check-all.sh` exits 0 | At merge |
| Spec-reviewer confirms no prescriptive vendor references | Not applicable — file does not exist | 0 vendor names presented as requirements in body prose | At PR review |
| Cross-link present in `docs/templates/README.md` | No cross-link present | One-line pointer to `docs/examples/release-strategy.md` appears next to the `release-strategy.md` entry | At merge |

## Out of Scope

- Worked examples for any other templates (PRD, technical-spec, api-spec, data-model-spec, auth-spec, architecture, deployment, api-reference) — this PR introduces the `docs/examples/` directory but adds only one file.
- A Profile B (Multi-environment / GitFlow) variant of the release-strategy example — the primary audience is Profile A users; a Profile B example is a P1 follow-on requiring separate project framing.
- Any CI hook or automated check to verify the example stays in sync with the blank template's section list — structural drift is caught by reviewer eyes; automated tooling is deferred indefinitely.
- Modifications to `docs/templates/release-strategy.md` or any other existing sacred template — Hard Rule 7 prohibits this as a side-effect of another feature PR.
- Changes to `starters/nextjs/` or `starters/flutter/` — the example is a documentation artefact, not a code artefact.
- Content changes to `docs/guides/stage-4-ship.md` beyond the optional one-line callout described in the Feature Matrix (P1).
- A separate "how to read this example" guide page — the file's own metadata block carries a brief note that it is illustrative.

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | Should the optional cross-link in `docs/guides/stage-4-ship.md` be included in this PR? Recommended resolution: yes — add a single sentence after the existing "Capture the chosen model's decisions…" sentence at the end of the "Choosing a release strategy" section. The discoverability gain outweighs the minimal diff, and the change is consistent with how the existing sentence already points to `docs/templates/release-strategy.md`. Close at the technical-spec stage. | Spec author | 2026-04-21 |
| 2 | Should a Profile B (Multi-environment / GitFlow) worked example be tracked as an explicit follow-on? Recommended resolution: yes — open a follow-on issue after this PR merges. Profile A covers the primary audience; Profile B needs different fictional framing (regulated domain, CAB workflow detail). Not in scope here but worth ensuring it does not get lost. | Human reviewer | 2026-04-28 |
| 3 | What fictional project name should the example use? Recommended resolution: "Lumen" — a generic, non-trademarked name for a solo-founder productivity SaaS with no domain-specific business logic and no connotation of a regulated industry. Close before the build stage. | Spec author | 2026-04-21 |

## Appendix

**Predecessor artefacts (PR #88 — the blank template this example illustrates):**
- `docs/specs/release-strategy-template-Hhjow/PRD.md` — establishes the blank template; explicitly defers the worked example in §Out of Scope and §Open Questions #1
- `docs/specs/release-strategy-template-Hhjow/technical-spec.md` — implementation detail; §Open Questions #1 is the authoritative deferral record

**Research briefs (domain content the example draws on):**
- `docs/research/release-strategy-template-Hhjow-brief.md` — structural constraints and open question on the worked example
- `docs/research/simplify-release-blueprint-giVF4-brief.md` — domain content (Findings 1–6) covering profile descriptions, preconditions, flag patterns, migration discipline, and CAB carve-outs

**Blank template being illustrated:**
- `docs/templates/release-strategy.md` — the nine-section sacred template whose TODOs the example realises

**Blueprint guides cross-referenced in the example:**
- `docs/guides/stage-4-ship.md` — Stage 4 guide; "Choosing a release strategy" section and Profile A preconditions
- `docs/guides/tool-reference.md` — §Release strategy profiles: Profile A and Profile B infrastructure role maps

**Hard Rules directly relevant to this feature:**
- Hard Rule 1 (Australian spelling) — applies to all prose in the example and in the cross-link edits
- Hard Rule 7 (templates are sacred) — deliberately does NOT apply to `docs/examples/`; the example file can be updated freely as the blank template evolves
- Hard Rule 8 (tool-agnostic framing) — applies to all body prose in the example; vendor names permitted only in footnotes as illustrative examples

**GitHub context:**
- PR #88 on `parkjadev/agentic-blueprint` — merged 2026-04-20; authoritative deferral rationale

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
