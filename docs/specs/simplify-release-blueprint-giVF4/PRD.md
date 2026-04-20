# Product Requirements Document — Simplify Release Blueprint

**Author:** Claude (spec-writer subagent)
**Date:** 2026-04-19
**Status:** Shipped (#84)

---

## Problem Statement

The blueprint's stage guides and templates already describe GitHub Flow (trunk-based, main → production) as the default delivery model — but nowhere is it labelled as a *choice*. It is presented as the way, with no articulation of what it requires to be safe, and no alternative offered for teams whose context (compliance obligations, CAB processes, shared QA environments) makes a multi-environment model the right fit instead.

This has two practical consequences. First, teams adopting the simplified model may do so without understanding its preconditions — automated test coverage, per-PR preview environments, runtime activation control via feature flags, and expand-migrate-contract discipline for schema changes — and ship unreliable or risky deployments. Second, teams for whom the simplified model is genuinely inappropriate (regulated industries, enterprise change-management contexts) receive no signal that a different strategy exists, and may either follow guidance that does not suit them or abandon the blueprint entirely.

The motivating experience behind this work was a real product team that used the blueprint's continuous-deployment guidance as justification for shipping to production without feature flags or meaningful test coverage, and encountered preventable production incidents as a result. No named reference to that team appears in the published guides; the experience shapes the content rather than being cited as an example.

External evidence (Forsgren, Humble, Kim — *Accelerate*, 2018; subsequent DORA surveys through 2024) confirms that high-performing teams favour trunk-based development, but the same research consistently identifies the preconditions listed above as mandatory for safe execution.

## Target Users

| User Segment | Description | Priority |
|---|---|---|
| Solo founders and small product teams | Primary audience for the blueprint. Reading `stage-4-ship.md` to understand how to deploy their product. Need explicit guidance on what the simplified model requires before they can safely adopt it. | Primary |
| Enterprise or regulated-industry teams | Reading the blueprint and discovering that the default model is incompatible with their CAB process or compliance requirements. Need a named alternative and clear criteria for choosing it. | Secondary |
| Blueprint contributors | Reviewing or extending the blueprint's guide and profile content. Need the conceptual framing to be clear so future additions stay consistent with Principles 8 and 9. | Secondary |

## User Journeys

### Journey 1: First-time adopter choosing a release model

**Trigger:** A solo founder working through `docs/guides/stage-4-ship.md` reaches the "How it works — Continuous deployment" section and wants to understand whether it is appropriate for their project.

1. User reads the new "Choosing a release strategy" section near the top of `stage-4-ship.md`.
2. User sees the two named strategies, their preconditions, and the criteria for choosing between them.
3. User follows the cross-link to `tool-reference.md` and reads the profile that matches their context.
4. User returns to the stage guide with a clear decision and proceeds to implement accordingly.

**Outcome:** The user has made an informed, explicit choice about their release model before writing any pipeline configuration.

### Journey 2: Enterprise adopter identifying the correct model

**Trigger:** A platform engineer at a regulated company reads the blueprint's ship guide and finds that the default "merge to main equals production" model is incompatible with their CAB sign-off requirement.

1. User reads the "Choosing a release strategy" section.
2. The compliance / CAB note points them toward Profile B (Multi-environment / GitFlow) in `tool-reference.md`.
3. User reads Profile B and sees a model that reflects long-lived branches, shared staging, and human approval gates.
4. User adopts the blueprint's spec-driven and plan-before-code disciplines while applying a branching strategy that fits their context.

**Outcome:** The user applies the blueprint's discipline without being forced into a model that violates their organisational constraints.

### Journey 3: Contributor adding a new profile or platform note

**Trigger:** A contributor wants to add guidance for a fourth platform profile in `tool-reference.md` or extend the release strategy section.

1. Contributor reads the existing "Release strategy profiles" section.
2. The section's structure and descriptive framing (no prescriptive language, roles not vendors) makes the convention clear.
3. Contributor authors a new entry following the same pattern without inadvertently violating Principles 8 or 9.

**Outcome:** The convention established by Profiles A and B is clear enough that extensions stay consistent without reviewer intervention.

## Feature Matrix

| Feature | Description | Priority | Journey |
|---|---|---|---|
| "Choosing a release strategy" section in `stage-4-ship.md` | A named section near the top of the stage guide that makes the two strategies explicit, lists preconditions for each, and links to the profiles in `tool-reference.md`. | P0 | 1, 2 |
| Profile A: Simplified (GitHub Flow) in `tool-reference.md` | A descriptive profile entry for trunk-based, main → production delivery, covering branch model, environment topology, required infrastructure roles, and appropriate context. | P0 | 1, 3 |
| Profile B: Multi-environment (GitFlow) in `tool-reference.md` | A descriptive profile entry for long-lived branch, shared staging, CAB-compatible delivery, covering branch model, environment topology, and appropriate context. | P0 | 2, 3 |
| Back-links from each profile to `stage-4-ship.md` | A short note at the end of each profile directing readers back to the stage guide for operational detail. | P1 | 1, 2 |
| Expand-migrate-contract callout in the `stage-4-ship.md` section | Explicit mention of the three-PR migration pattern as a precondition for safe continuous deployment, surfacing what is already implicit in `docs/templates/deployment.md`. | P0 | 1 |

## Non-Functional Requirements

| Requirement | Target | Measurement |
|---|---|---|
| Australian spelling | All prose in the new sections uses Australian English variants | Passes `bash .claude/skills/australian-spelling/scripts/check.sh` with exit 0 |
| Tool-agnostic framing | No vendor names appear as requirements; only roles are described | Manual review against Principle 8; no instances of "you must use [vendor]" |
| Descriptive profiles | Both profiles presented with equal framing; neither is labelled "recommended" or "default" in the profile section | Manual review against Principle 9 |
| Internal links resolve | All `[text](path#anchor)` references in new content navigate to the correct location | Manual link-check during review |
| No template modifications | `docs/templates/` directory is unchanged by this PR | `git diff docs/templates/` returns empty |

## Success Metrics

| Metric | Current | Target | Timeframe |
|---|---|---|---|
| Compliance with Principle 8 (tool-agnostic) in new sections | 0 (no new content exists) | 0 vendor-prescriptive phrases in the two new sections | At merge |
| Compliance with Principle 9 (descriptive profiles) in new profiles | 0 (no release-strategy profiles exist) | Both profiles use only descriptive framing; no prescriptive language | At merge |
| Internal link resolution | Not applicable (no new links) | All cross-links between `stage-4-ship.md` and `tool-reference.md` resolve without 404 | At merge |
| Reviewer confidence in section completeness | N/A | No "TBD" or placeholder text in merged sections | At merge |

## Out of Scope

- Commissioning `docs/templates/release-strategy.md` — deferred to a separate PR on a `docs/*` or `templates/*` branch per Principle 7. That template will capture per-project decisions about branching model, environment matrix, preview infrastructure, feature flag provider, and migration strategy.
- Changes to `starters/nextjs/` — the Next.js starter already implements GitHub Flow via `vercel.json` and `ci.yml`. Additions for feature-flag-gated deployments or smoke-test gates wait for a concrete use case per Principle 2 (no speculative domain logic).
- Changes to `starters/flutter/` — Flutter has no native per-PR preview URL concept; no equivalent of GitHub Flow's preview-per-PR model applies. Not Applicable for this work.
- New entries in `docs/principles/` — a release strategy is not a hard rule. Adding one would contradict Principles 8 and 9.
- Changes to hooks, settings, or the pre-commit gate — no new automated enforcement is introduced by this feature.
- A Sentinel OS case study document — the motivating experience shapes content only; it is not published as a named artefact.
- Updates to `docs/guides/stage-5-run.md` — the research brief identifies this as optional and lower-priority than the ship guide update. Deferred.

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | ~~Section placement in `stage-4-ship.md`?~~ **Resolved (2026-04-20):** inserts after `## What you need` and before `## How it works — Continuous deployment`, so the reader has role-level orientation before choosing a model. See the technical-spec rollout plan for exact anchors. | — | Closed |
| 2 | ~~Follow-up issue for `docs/templates/release-strategy.md`?~~ **Resolved (2026-04-20):** yes — file at merge time, labelled `type:feature, scope:docs`, so the deferred template has a discoverable home. | Author | At merge |

## Appendix

**Research brief:** `docs/research/simplify-release-blueprint-giVF4-brief.md`

**External evidence:**
- Forsgren, Humble, Kim — *Accelerate* (2018): trunk-based development correlated with high delivery performance
- DORA State of DevOps surveys (2019–2024): 182× deployment frequency, 127× faster change lead time for elite versus low performers
- Mergify: "Trunk-based development vs GitFlow — which branching model actually works?" — confirms preconditions
- Atlassian: Trunk-based development guide — confirms preconditions
- Defacto: Database schema migrations guide — expand-migrate-contract rationale
- Uffizzi: Preview environments guide — per-PR preview environment taxonomy

**Related blueprint files:**
- `docs/guides/stage-4-ship.md` — file being updated
- `docs/guides/tool-reference.md` — file being updated
- `docs/templates/deployment.md` — already references expand-migrate-contract; no changes in this PR
- `docs/guides/_archive/release-workflow.md` — documents historical decision to abandon staging → main promotion

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
