# Product Requirements Document — Agentic Blueprint v5 (Platform-Agnostic Redesign)

**Author:** solo maintainer
**Date:** 2026-04-23
**Status:** Draft
**Scope:** product
**Parent:** none

> **Scope-aware sections.** Product-scope PRD — Vision, Feature Matrix, Success Metrics, Non-Goals rendered below.

<!-- Budget: words ≤ 4500 · feature-matrix rows ≤ 30 · open questions ≤ 10.
     Long-output agents (spec-author) must chunk via Write + Edit — first Write ≤ 1500 words,
     each subsequent Edit ≤ 1500 words (see agent large-output protocol). -->

---

## Vision

v5 re-frames the blueprint as a platform- and technology-agnostic framework for shipping AI-collaborated products. v4 shipped opinionated reference starters (Next.js, Flutter, .NET + Azure); v5 treats stack selection as a first-class research deliverable of the Spec beat. The intellectual property shifts from "a library of opinionated starters" to "a disciplined research + decision + lifecycle framework."

Competitive positioning: **Spec Kit plus Ship plus Signal.** Where GitHub Spec Kit (v0.1.4, Feb 2026) stops at *Implement*, the blueprint's moat is the PR-driven ship loop with hard-rule gates, post-merge signal-sync, and periodic self-review that feeds back into the next Spec beat.

---

## Problem Statement

v5.0 is built to solve one immediate problem: **the blueprint must be usable on my next real project, whatever stack that project turns out to need.** v4 assumed Next.js / Flutter / .NET + Azure — that assumption blocked use on anything else and made the Spec beat's stack-selection discipline redundant.

Three structural bets in v4 did not hold:

1. **Starters locked the adopter surface.** The starter tree committed to one stack per profile, which inverted the Spec-before-Ship principle (Rule 3). The correct moment to pick a stack is *during* the Spec beat, informed by the problem, not *before* it.
2. **Rule 2 ("starters boot clean") became vacuous** once the starters were retired in the v5 transition (PR #109). A rule that never fires is not a gate.
3. **The contract discipline was trapped inside the starter code.** The `ApiResponse<T>` envelope and optional-service gating patterns are load-bearing IP; they belong in first-class, language-neutral reference artefacts, not in one starter's codebase.

v5.0 fixes these three structurally and ships the minimum surface I need to use the blueprint on my next project. Broader adopter concerns (migration, plugin packs, AGENTS.md portability, marketplace governance) are deferred — they're speculative demand and v5.0 isn't the moment to pay for them.

---

## Target Users

| User Segment | Description | Priority |
|---|---|---|
| Solo maintainer (me) | Building the blueprint; will use v5 on the next real project to validate the design | Primary |
| Future adopters | Greenfield founders, stack-locked teams, discipline-only solo devs (per research brief Finding 2) | **Out of scope for v5.0** — revisit after v5 has survived real use |

v5.0 is scoped for one user. Designing for hypothetical adopters without a pilot project is premature optimisation. Once the blueprint has been used on a real project end-to-end, the PRD for a v5.x adopter release (with plugin packs, AGENTS.md, migration guide) can be written with evidence rather than speculation.

---

## User Journeys

### Journey 1: Start my next project with `/spec idea`

**Trigger:** I begin a new project and want the blueprint to help choose the stack rather than assume one.

1. `/spec idea <product-name>` runs in a fresh repo (or an existing one — install path doesn't matter yet).
2. `spec-researcher` produces a research brief with a ranked stack recommendation — evaluation criteria, trade-offs, and one pick with justification. Chunked-write protocol (PRs #113/#114) ensures the brief lands reliably.
3. `spec-author` drafts PRD + architecture referencing the recommended stack, pulling relevant interface definitions from `docs/contracts/`.
4. I review, possibly override the stack pick, then `/ship` scaffolds the project manually against the chosen stack using the contracts as the wire-level spec.

**Outcome:** the project starts with an evidence-based stack pick and a spec-gated first PR. No opinionated starter tree got in the way.

### Journey 2: Adopt the blueprint into an existing repo mid-project

**Trigger:** I realise partway through a project that I want the blueprint's discipline layer.

1. Copy `.claude/` bundle + sacred templates + `docs/contracts/` into the repo.
2. Merge CLAUDE.md via the fenced `<!-- agentic-blueprint:begin/end -->` block.
3. Run `/spec feature <slug>` for the next feature; full Spec beat runs against the existing architecture.
4. Hard-rule gates fire on the next commit.

**Outcome:** blueprint discipline applied to an existing codebase with zero starter-related friction. Same as Journey 1 minus the stack-selection research.

---

## Feature Matrix

<!-- P0 = must have for v5.0. P1 = should have if cheap. P2 = explicitly deferred. -->

| Feature | Description | Priority | Journey |
|---|---|---|---|
| `docs/contracts/` reference library | Stack-agnostic interface contracts (prose + JSON Schema where appropriate) that replace opinionated starters as the blueprint's reference artefact. Rule-4 protected. Day-one content: `ApiResponse<T>` envelope, error-code taxonomy, auth-token shape, telemetry schema — carried forward from retired v4 starters. | P0 | 1, 2 |
| Stack-agnostic `/spec idea` flow | `spec-researcher` evaluates stack alternatives against the problem at hand; produces a research brief with a ranked recommendation. Stack selection is an output of Spec, not an input. | P0 | 1 |
| Hard Rule 2 retirement (not reframe) | Retire Rule 2 for v5.0 — with no starters and no plugin packs in v5.0, the reframe ("plugin must boot clean") would be vacuous again. Principles file reduces to 4 Hard Rules (1, 3, 4, 5) + 3 meta-principles. Reinstate if/when plugin packs land in v5.x. | P0 | — |
| `/beat install` cleanup | Remove starter-related copy paths and the legacy `starter-verify` skill dispatch. No new install mechanics — `/beat install` keeps doing what it does minus the starter surface. | P0 | 2 |
| `tool-reference.md` reframe | Rewrite `docs/guides/tool-reference.md` as a role + inputs matrix rather than a shopping list — already groundwork for non-Claude agents without committing to AGENTS.md emission yet. | P0 | 1, 2 |
| Research-budget guardrail baseline | Lock the chunked-write protocol + template budget preambles (already shipped in #113/#114) as v5.0 baseline — no reversion. | P0 | 1 |
| AGENTS.md emitter | Emit `AGENTS.md` alongside `CLAUDE.md` from `/beat install`. | **P2 — deferred** | — |
| Plugin-pack marketplace integration | Per-stack plugin packs on the Claude Code Marketplace. | **P2 — deferred** | — |
| v4 migration guide | Pin + shim + `migrating-from-v4.md`. | **P2 — deferred** (no v4 adopters to migrate) | — |
| Option A scaffold generator | AI-driven project scaffolder that generates a repo tree from a spec. | **P2 — deferred** | — |

---

## Non-Functional Requirements

| Requirement | Target | Measurement |
|---|---|---|
| `/beat install` idempotency | Running install twice produces the same result; no duplicate content in `CLAUDE.md` fence | Manual smoke test on fresh repo |
| Context-budget compliance | `spec-researcher` + `spec-author` respect the template budget comments (words ≤ 4000 / 4500) | Word-count check during self-review |
| Hard-rule gate reliability | All remaining four Hard Rules produce non-zero exit on violation | Existing CI check (`hard-rules-check` skill) |
| Australian spelling | All prose in templates, guides, specs, and `CLAUDE.md` passes the `australian-spelling` check | Pre-commit hook (Rule 1) |
| Stream-idle-timeout rate | Zero incidents on spec-author / spec-researcher runs post-v5.0 | Operator observation over next 5 /spec runs |

---

## Success Metrics

v5.0 success is evaluated by whether I can use it on my next real project. Metrics below are acceptance criteria, not marketing goals.

| Metric | Target | Timeframe |
|---|---|---|
| Next real project started via `/spec idea` on v5.0 | 1 project initialised end-to-end through the Spec → Ship → Signal loop | Within 60 days of v5.0 merge |
| Stack-selection research produces a defensible recommendation | The brief from `/spec idea` lists ≥ 2 alternatives with trade-offs; the pick is explained, not asserted | First `/spec idea` run post-merge |
| `docs/contracts/` used, not ignored | At least one Ship PR references a contract for its API shape | First feature PR on the next project |
| Stream-idle-timeout incidents | 0 (regression target — current state after #113/#114) | Through v5.0 + next project |

---

## Out of Scope

v5.0 deliberately excludes the following. Each is a legitimate future concern, not a rejected direction — but paying for any of these without a pilot project is speculation.

- **v4 migration support.** No v4 adopters exist. No pin, no shim, no `migrating-from-v4.md`. v4 artefacts get deleted cleanly where they block v5.0.
- **Plugin-pack marketplace integration.** No marketplace listing, no governance document, no seed packs. Defer until a second user materialises or until I want to ship one.
- **AGENTS.md emission.** Deferred until I'm actively using a non-Claude agent. Claude Code is the only runtime I'll be on through v5.0.
- **Option A scaffold generator.** Manual scaffolding against the contracts is adequate for v5.0.
- **Signal beat platform-agnostic redesign.** `signal-sync` assumes Vercel. If the next project uses Vercel, defer. If not, handle when it bites.
- **CI wrapper portability beyond GitHub Actions.** GitLab/CircleCI porting notes stay at "guidance" level.
- **Multi-profile or multi-persona documentation.** Descriptive-profiles (Rule 5) still applies, but the v4 three-profile docs (Claude-native, Cursor+Perplexity, OutSystems ODC) can be trimmed to just the one profile I actually use.

---

## Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | GitHub Spec Kit ships a Ship-equivalent phase in v0.2 and erodes the differentiator before v5.0 is battle-tested | Medium | Medium | Use v5.0 on the next real project ASAP; don't block on polish. Competitive positioning only matters if there's an audience. |
| R2 | Stack-selection research in `spec-researcher` produces shallow or repetitive output | High | Medium | Evaluation criteria embedded in research-brief template (already shipped in #114); first `/spec idea` run on next project is the acceptance test. |
| R6 | Context-economy regression (stream-idle timeouts return) | Low (post-#113/#114) | Medium | Chunked-write protocol in agents + template budgets; operator observation on next 5 runs. |
| R7 | `docs/contracts/` becomes a de-facto starter and drifts from "reference" to "mandate" | Medium | Medium | Template-guard hook protects the folder (Rule 4); JSON Schema alongside prose keeps contracts structural, not prescriptive. |
| R_solo | I don't actually start a new project in the next 60 days, and v5.0 never sees real use | Medium | High | Pick a small deliberate test project (could be a throwaway) to validate the end-to-end loop rather than wait for a "real" project. |

Risks R3 (plugin-pack governance), R4 (v4 migration friction), R5 (AGENTS.md fragmentation), R8 (Claude-only artefact) from the research brief are out of scope for v5.0 — all require adopters that don't exist yet.

---

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | When does v5.0 cut as a versioned release? Options: (a) at merge of this PRD's Ship epic, (b) only after the first real project has completed its Spec beat on v5.0 | Maintainer | Before final Ship epic merge |
| 2 | Is "retire Rule 2" the right call, or is it better to reframe to something non-vacuous (e.g. "the project initialised by `/spec idea` must boot clean")? The reframe requires Option A; retirement is simpler. | Maintainer | Before Hard Rule 2 feature PR |
| 3 | Should v5.0 trim the v4 three-profile docs (Claude-native, Cursor+Perplexity, OutSystems ODC) down to the one profile in active use, or leave them as reference? | Maintainer | During `tool-reference.md` reframe feature PR |

---

## Appendix

- Research brief: `docs/research/agentic-blueprint-v5-agnostic-brief.md`
- Reliability fix PRs: #113 (agent protocols), #114 (template budgets)
- v4 starters retirement: PR #109 (`a53f0ff`), transitional note in `CLAUDE.md`
- Closest competitor: GitHub Spec Kit v0.1.4 (Feb 2026)
- Scope change log: this PRD was initially drafted for a multi-adopter v5.0 release; rescoped to solo-maintainer v5.0 on 2026-04-23 after confirming no current adopters and no active pilot project. Broader-adopter concerns (plugin packs, AGENTS.md, migration guide) move to v5.x, contingent on real demand.

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
