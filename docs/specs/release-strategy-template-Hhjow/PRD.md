# Product Requirements Document — Release Strategy Template

**Author:** Claude (spec-writer subagent)
**Date:** 2026-04-20
**Status:** Shipped (#88)

---

## Problem Statement

The blueprint's Stage 2 now produces guide and profile content that helps teams *choose* a release strategy (see PR #84, shipped). However, once a team has made that choice, there is no structured artefact for them to record *what they decided* and *why*. Teams fall back to ad-hoc documentation, wiki pages, or nothing at all — creating onboarding friction, decision amnesia, and a gap between the strategy chosen at project start and what is actually operating months later.

The missing artefact is `docs/templates/release-strategy.md`: a sacred template (per Hard Rule 7) that downstream projects copy into their own repos and fill in to document their release strategy. This was explicitly identified and deferred in Decision 5 of the `simplify-release-blueprint-giVF4` research brief (2026-04-19), and subsequently commissioned via GitHub issue #86 on `parkjadev/agentic-blueprint`.

Without this template, teams using the blueprint lack a canonical structure for capturing: their chosen release profile; the branch model and environment mapping that implements it; how preview environments, feature flags, schema migrations, approval workflows, and rollback procedures are handled for their specific project. The gap is especially sharp for teams onboarding new engineers or handing off to a new operator — the information exists only in individuals' heads or in scattered Slack threads.

## Target Users

| User Segment | Description | Priority |
|---|---|---|
| Solo founders and small product teams | Primary blueprint audience. Copying the template into their repo to document the release strategy they chose using the Stage 4 guide and profile. Need a clear, guided structure that prompts them to record decisions they might otherwise skip. | Primary |
| Engineering leads at growing startups | Filling in or reviewing the template to establish shared team understanding of branching model, environment topology, flag lifecycle ownership, and rollback procedures before onboarding new engineers. | Primary |
| Blueprint contributors and reviewers | Using the template as the canonical structural reference when reviewing downstream release documentation or extending the blueprint with new profile variants. | Secondary |

## User Journeys

### Journey 1: New project setup

**Trigger:** A founder has just created a new project repo from the blueprint starter and has worked through `docs/guides/stage-4-ship.md`, choosing Profile A (Simplified / GitHub Flow).

1. User opens the blank `docs/templates/release-strategy.md` template (or copies it from the blueprint).
2. User fills in each section guided by the inline comments — chosen release profile, branch model, environment matrix, preview approach, feature flag ownership, migration methodology, approval workflow (if applicable), and rollback procedures.
3. User commits the filled-in file to their project repo as `docs/release-strategy.md`.
4. User references the document when configuring CI/CD, environment variables, and branch protection.

**Outcome:** The project has a single, structured source of truth for its release strategy, attached to the codebase from the first deploy.

### Journey 2: Team handoff or onboarding

**Trigger:** A new engineer joins a project that already has a filled-in release strategy document.

1. New engineer opens `docs/release-strategy.md` in the project repo.
2. They read through each section to understand how branches map to environments, where to find feature flags, how to handle a schema migration safely, and what to do if a deploy goes wrong.
3. New engineer runs their first deployment following the documented rollback procedure, confident they know what lever to pull if needed.

**Outcome:** Onboarding time for release-related questions is reduced; the document answers the questions a senior engineer would otherwise field.

### Journey 3: Incident response

**Trigger:** A production incident occurs — an unexpected error spike after a deploy.

1. On-call engineer opens `docs/release-strategy.md` and navigates to the Rollback Procedures section.
2. The section describes the correct rollback lever for this project's infrastructure and the order in which to try them.
3. Engineer executes the procedure without improvising under pressure.

**Outcome:** Mean time to recovery is shorter and the rollback is executed safely, not ad-hoc.

## Feature Matrix

| Feature | Description | Priority | Journey |
|---|---|---|---|
| Chosen release profile section | Captures which of the blueprint's named profiles (Simplified / GitHub Flow, Multi-environment / GitFlow, or custom variant) the project has adopted, and why | P0 | 1, 2 |
| Precondition verification section | A checklist confirming that the infrastructure required by the chosen profile is in place before the team ships to production | P0 | 1 |
| Branch model and environment mapping section | Describes the long-lived and short-lived branches, which environment each maps to, and the deployment trigger for each | P0 | 1, 2 |
| Preview environment approach section | Records how per-PR preview environments are provisioned for this project, including which tool or platform fills that role | P0 | 1, 2 |
| Feature flag implementation section | Captures which tool or mechanism provides runtime activation control, who owns flag lifecycle, and how stale flags are cleaned up | P0 | 1, 2 |
| Schema migration methodology section | Documents the expand-migrate-contract discipline for this project, including how destructive changes are staged across PRs | P0 | 1, 2 |
| Approval and CAB workflow section | Captures any human approval gates required before production changes, including compliance context where applicable | P0 | 1, 2 |
| Rollback procedures section | Documents the ordered rollback levers available to this project, with specific steps for each | P0 | 1, 2, 3 |
| Unresolved questions section | A tracked list of open questions about the release strategy that remain to be resolved | P1 | 1 |
| Inline guidance comments | Each section contains an HTML comment block explaining what to write there and pointing to relevant blueprint resources | P0 | 1 |
| Metadata block (author, date, status, related template) | Consistent with all other sacred templates; allows downstream version tracking | P0 | 1, 2 |

## Non-Functional Requirements

| Requirement | Target | Measurement |
|---|---|---|
| Australian spelling | All prose in the template uses Australian English variants | Passes `bash .claude/skills/australian-spelling/scripts/check.sh` with exit 0 |
| Tool-agnostic framing | No vendor names appear as requirements in guidance comments; only roles are described | Manual review against Hard Rule 8; no instances of "you must use [vendor]" |
| No domain-specific business logic | Template guidance comments reference only generic concepts — no named projects, proprietary workflows, or vendor-specific identifiers | Manual review against Hard Rule 2 |
| Sacred template structure | Section headers must be preserved as-is once the template is merged to `main`; fills are downstream-project concerns | Enforced by Hard Rule 7 and the `template-guard` hook |
| Consistent structural conventions | Heading style, metadata block format, inline comment style, and footer match the conventions used by `deployment.md`, `technical-spec.md`, and `data-model-spec.md` | Manual review at spec-reviewer stage |
| Internal link resolution | Any cross-references to blueprint guides or principles resolve correctly | Manual link-check during review |

## Success Metrics

| Metric | Current | Target | Timeframe |
|---|---|---|---|
| Template exists and passes hard-rules-check | Template does not yet exist | `bash .claude/skills/hard-rules-check/scripts/check-all.sh` exits 0 on the branch | At merge |
| All nine required sections present | 0 sections (template does not exist) | All nine sections from issue #86 present with guidance comments | At merge |
| Structural consistency with existing templates | Not applicable — template is new | Reviewer confirms heading style, metadata block, and footer match at least two existing sacred templates | At PR review |
| No prescriptive vendor references in guidance comments | Not applicable — template is new | 0 instances of "you must use [vendor]" or equivalent in guidance comment text | At PR review |

## Out of Scope

- Any changes to the existing sacred templates in `docs/templates/` — Hard Rule 7 prohibits modifications as a side-effect of another feature PR.
- Changes to `starters/nextjs/` or `starters/flutter/` — the template is a documentation artefact, not a code artefact.
- A worked example (filled-in sample) of the template — this is the open question tracked below. A blank template is the P0 deliverable; a companion example file is a potential P1 follow-on.
- Updates to the blueprint's CI hooks or pre-commit gate to validate filled-in release-strategy documents — out of scope; the `template-guard` hook already prevents unintended template modification.
- Content additions to `docs/guides/tool-reference.md` or `docs/guides/stage-4-ship.md` — those changes shipped in PR #84.
- Commissioning any other new templates — this PR delivers exactly one new template.

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | ~~Should a filled-in worked example accompany the blank template?~~ **Resolved 2026-04-20:** deferred to a follow-up PR. This PR ships exactly the P0 blank template. A worked example is a P1 follow-on, tracked outside this spec. | Human reviewer | Resolved |

## Appendix

**Research briefs:**
- `docs/research/release-strategy-template-Hhjow-brief.md` — scoping and structural constraints for this feature
- `docs/research/simplify-release-blueprint-giVF4-brief.md` — domain content (Findings 1–6) and Decision 5 (template deferred)

**GitHub issue:** #86 on `parkjadev/agentic-blueprint` — authoritative section list

**Related blueprint files:**
- `docs/guides/stage-4-ship.md` — stage guide updated by PR #84; cross-references the release strategy concept
- `docs/guides/tool-reference.md` — profile A and B descriptions updated by PR #84
- `docs/templates/deployment.md` — existing sacred template; structural convention reference
- `docs/templates/technical-spec.md` — existing sacred template; structural convention reference
- `docs/templates/data-model-spec.md` — existing sacred template; structural convention reference

**External evidence:**
- Forsgren, Humble, Kim — *Accelerate* (2018): preconditions for safe trunk-based development
- DORA State of DevOps surveys (2019–2024): deployment frequency and change lead time benchmarks
- Atlassian: Change Advisory Board explainer — compliance carve-out rationale

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
