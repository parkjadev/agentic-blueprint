# Product Requirements Document — Agentic Blueprint v5 (Platform-Agnostic Redesign)

**Author:** spec-author
**Date:** 2026-04-23
**Status:** Draft
**Scope:** product
**Parent:** none

> **Scope-aware sections.** This is a product-scope PRD. Vision, Success Metrics, Non-Goals, and Feature Matrix sections are rendered below. Child features are listed within the Feature Matrix.

<!-- Budget: words ≤ 4500 · feature-matrix rows ≤ 30 · open questions ≤ 10.
     Long-output agents (spec-author) must chunk via Write + Edit — first Write ≤ 1500 words,
     each subsequent Edit ≤ 1500 words (see agent large-output protocol). -->

---

## Vision

v5 re-frames the blueprint as a platform- and technology-agnostic framework for shipping AI-collaborated products. Where v4 shipped opinionated reference starters (Next.js, Flutter, .NET + Azure) and a fixed two-profile × three-beat matrix, v5 treats stack selection as a first-class research deliverable of the Spec beat: `/spec idea` uses `spec-researcher` to evaluate alternatives against the problem at hand and produces a stack recommendation grounded in evidence.

The intellectual property shifts from "a library of opinionated starters" to "a disciplined research + decision + lifecycle framework." The three-beat lifecycle (Spec → Ship → Signal) and hard-rule gates remain the durable core. What changes is that no stack is assumed — adopters on Rails, Go, Swift, or any other platform can adopt the blueprint and receive the full value of the Ship and Signal beats without friction from starter opinions they don't share.

v5's competitive positioning is "GitHub Spec Kit plus Ship plus Signal": where competitors stop at *Implement*, the blueprint's moat is the PR-driven ship loop with hard-rule gates, post-merge signal-sync, and periodic self-review that feeds back into the next Spec beat.

---

## Problem Statement

v4 made three structural bets that have not generalised:

1. **Opinionated starters locked the adopter surface.** Shipping Next.js, Flutter, and .NET + Azure starters served adopters who wanted validated scaffold code, but excluded the majority of the adopter spectrum — teams already committed to a different stack, solo developers who want only the discipline framework, and founders who need evidence-based stack selection before committing to code. The research brief (Finding 2) maps this as a 2×2 grid on scaffold-hunger × stack-conviction: v4 served only two of the four quadrants well.

2. **Stack selection was a shipped assumption, not a research deliverable.** The correct moment to choose a stack is during Spec beat, informed by problem constraints, team capability, and ecosystem fit. v4 embedded that choice in the starters before Spec ran. This inverted the intended order of operations and undermined the blueprint's own Spec-before-Ship principle (Hard Rule 3).

3. **Rule 2 ("starters boot clean") was vacuously passing** after the starters were retired in the v5 transition. A rule that never fires is not a gate. The Hard Rules system loses credibility if one of its five rules is permanently dormant.

Evidence: the starters were retired during the v5 transition (documented in `CLAUDE.md` transitional note), confirming that the v4 model did not survive contact with the broader adopter base. The closest competitor, GitHub Spec Kit (v0.1.4, Feb 2026), is agent-agnostic and spec-driven but stops at Implement — indicating the market values the agnostic framing but leaves the Ship + Signal moat uncontested.

---

## Target Users

The four personas from the adopter-spectrum 2×2 (scaffold-hunger × stack-conviction):

| User Segment | Description | Priority |
|---|---|---|
| Greenfield founder | Starting a new product, open stack, wants evidence-based stack selection and scaffold confidence | Primary |
| Stack-locked team | Existing codebase on a specific platform; wants the Spec + Ship + Signal discipline without starter friction | Primary |
| Discipline-only solo developer | Wants the three-beat lifecycle, hard rules, and templates; has no interest in scaffold code | Secondary |
| Reference-code reader | Browses starters for patterns and copy-pastes; lowest discipline engagement, highest scaffold interest | Secondary |

The v5 feature set is primarily designed for the first three personas. Persona 4 (reference-code reader) is served by the plugin-pack marketplace model (P1) rather than in-repo starters.

---

## User Journeys

### Journey 1: Greenfield founder adopts the blueprint via `/beat install`

**Trigger:** Founder initialises a new repo and wants a disciplined AI-collaboration workflow.

1. Founder runs `/beat install` in a fresh repository.
2. Install script dry-runs and reports what it will create.
3. Script copies `.claude/` bundle, merges `CLAUDE.md` via fence block, emits `AGENTS.md`, copies sacred templates and `docs/contracts/`, writes `claude-config/VERSION`.
4. Founder runs `/spec idea my-product` — `spec-researcher` evaluates stack alternatives, produces a research brief with a stack recommendation.
5. `spec-author` drafts PRD + architecture spec referencing the brief's recommendation.
6. Founder reviews and approves the spec; `/ship` opens a PR with the chosen stack scaffolded according to `docs/contracts/`.

**Outcome:** Founder has a spec-gated, platform-appropriate project with full three-beat lifecycle from day one.

### Journey 2: Stack-locked team adopts into an existing repo

**Trigger:** Engineering lead wants AI-collaboration discipline without replacing their existing stack.

1. Lead runs `/beat install` in their existing monorepo.
2. Install script skips starters entirely (none exist in v5); merges `CLAUDE.md` fence block without touching source code; emits `AGENTS.md`.
3. Lead maps their existing folder structure to `docs/contracts/` interface definitions.
4. Team runs `/spec feature auth-refresh` — full Spec beat runs against their existing architecture.
5. `/ship` executes against their stack; hard-rule gates fire as normal.

**Outcome:** Team has blueprint discipline layered onto their existing codebase with zero starter friction.

### Journey 3: v4 adopter migrates to v5

**Trigger:** Existing v4 adopter sees the v5 release and wants to migrate.

1. Adopter reads `docs/guides/migrating-from-v4.md`.
2. Adopter pins their current install to commit `3bb4c27` while planning migration.
3. Adopter runs `/beat update` — shim layer translates renamed primitives for two release cycles.
4. Adopter removes shim after migration window closes.

**Outcome:** v4 adopter migrates without breaking their existing workflow, with a clear deprecation timeline.

---

## Feature Matrix

<!-- P0 = must have for v5.0. P1 = should have (v5.x). P2 = nice to have / deferred. -->

| Feature | Description | Priority | Journey |
|---|---|---|---|
| `docs/contracts/` reference library | Stack-agnostic interface contracts (JSON Schema + prose) that replace opinionated starters as the blueprint's reference artefact. Rule-4 protected. | P0 | 1, 2 |
| AGENTS.md emitter | `/beat install` emits `AGENTS.md` alongside `CLAUDE.md` as a first-class agent-configuration artefact, enabling non-Claude agents to read blueprint conventions. | P0 | 1, 2 |
| Hard Rule 2 reframe | Reframe Rule 2 from "starters boot clean" to "any stack-pack plugin must boot clean via its own declared verification harness." Eliminates the vacuously-passing rule. | P0 | 1, 2, 3 |
| v4 migration guide | `docs/guides/migrating-from-v4.md` — pin instruction, shim layer for renamed primitives (two-release deprecation window), persona-specific guidance. | P0 | 3 |
| Research-budget guardrail | Encode a hard context budget in the `spec-researcher` agent and research-brief template; single WebSearch-or-question constraint per research step. (PRs #113/#114 already shipped the template change — v5.0 locks this as baseline.) | P0 | 1 |
| `/beat install` v5 | Updated install script: ships `.claude/` bundle + `CLAUDE.md` fence merge + `AGENTS.md` emission + sacred templates + `docs/contracts/` + `VERSION` file. Removes `starters/`, `bootstrap-smoke-test.yml`, and legacy `starter-verify` skill. | P0 | 1, 2 |
| Stack-agnostic `/spec idea` flow | `spec-researcher` evaluates stack alternatives against the problem at hand; produces a research brief with a ranked recommendation. Stack selection is the output of Spec, not an input. | P0 | 1 |
| `tool-reference.md` reframe | Reframe `docs/guides/tool-reference.md` as a role + inputs matrix rather than a shopping list. Supports the agent-agnostic positioning. | P0 | 1, 2 |
| Plugin-pack governance document | Defines the maintenance contract, in-house seed packs (minimum three), and marketplace listing criteria for per-stack plugin packs (Option D). | P1 | 1, 4 |
| Plugin pack: Next.js | Per-stack plugin pack for the Claude Code Marketplace — verification harness, contracts mapping, Rule-2-compliant boot check. Seeds the plugin-pack model. | P1 | 1 |
| Plugin pack: Flutter | Per-stack plugin pack for the Claude Code Marketplace — as above for Flutter. | P1 | 1 |
| Plugin pack: .NET + Azure | Per-stack plugin pack for the Claude Code Marketplace — as above for .NET + Azure. | P1 | 1 |
| `spec-researcher` evaluation criteria template | Formalised evaluation-criteria section in the research-brief template so stack research is reproducible and auditable across runs. | P1 | 1 |
| Signal beat evolution notes | Document how the Signal beat (scheduled tasks, post-merge sync, self-review) evolves in a platform-agnostic context where there is no fixed deployment target. | P1 | 2 |
| Option A scaffold generator | AI-driven project scaffolder that generates a repo from a spec + stack recommendation. Deferred — complexity outweighs v5.0 benefit; revisit for v5.x. | P2 | 1 |

---

## Non-Functional Requirements

| Requirement | Target | Measurement |
|---|---|---|
| `/beat install` idempotency | Running install twice must produce the same result with no duplicate content in `CLAUDE.md` | Manual + automated test in CI |
| `AGENTS.md` portability | Emitted `AGENTS.md` must be parseable by at minimum Claude Code and one non-Claude agent (e.g. Cursor, Copilot Workspace) | Pilot validation with non-Claude adopter |
| Context budget compliance | `spec-researcher` must not exceed the hard token budget defined in the research-brief template | Pre-commit check on research-brief word count |
| Hard-rule gate reliability | All five Hard Rules must produce non-zero exit on violation; Rule 2 must fire on a synthetic failing plugin pack | CI integration test |
| Migration guide coverage | All v4 primitives that are renamed or removed in v5 must have a shim or explicit removal note in the migration guide | Checklist in migration guide appendix |
| Australian spelling | All prose in templates, guides, specs, and `CLAUDE.md` must pass the `australian-spelling` check script | Pre-commit hook (Rule 1) |

---

## Success Metrics

| Metric | Current | Target | Timeframe |
|---|---|---|---|
| Plugin-pack adoption count | 0 (no packs exist) | 3 in-house seed packs published; ≥ 1 community pack | 90 days post-v5.0 |
| Non-Claude-agent install success rate | Not measured (Claude-only) | ≥ 1 confirmed non-Claude-agent adoption (AGENTS.md read + Spec beat completed) | 60 days post-v5.0 |
| Migration-guide completion by known v4 adopters | 0% | ≥ 80% of known v4 adopters migrated or pinned | 60 days post-v5.0 |
| PR-through-Ship-beat time vs v4 baseline | Unmeasured | No regression; target ≤ v4 median (establish baseline at v5.0 GA) | 30 days post-v5.0 |
| Stream-idle-timeout incident rate | Unknown pre-#113/#114 | Zero incidents post-v5.0 | 30 days post-v5.0 |
| Adopter spectrum coverage | 2 of 4 personas served (v4) | All 4 personas have a documented, working adoption path | At v5.0 launch |

---

## Out of Scope

- Redesigning the three-beat lifecycle (Spec → Ship → Signal). The lifecycle is the durable IP and is not changing.
- Abandoning `CLAUDE.md` as the primary harness-configuration file. `AGENTS.md` is additive, not a replacement.
- Becoming an IDE extension, web application, or SaaS product. The blueprint remains a repo-native framework.
- Mandating a specific stack for any adopter. Stack selection is always a research output, never an assumption.
- Option A scaffold generator. Deferred to v5.x — the complexity of a generative scaffolder is out of scope for the platform-agnostic reframe.
- Redesigning the CI wrapper beyond the GitHub Actions hard-rules wrapper. GitLab/CircleCI porting notes are guidance, not first-class deliverables in v5.0.
- Removing or weakening the five Hard Rules. Rule 2 is reframed, not retired.
- Supporting multiple simultaneous versions of the blueprint in a single repo. Adopters pin to a commit; divergence is managed via the migration guide.

---

## Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | GitHub Spec Kit closes the Ship + Signal gap before v5.0 ships | Medium | High | Ship v5.0 before Spec Kit v0.2; maintain "Spec Kit plus Ship plus Signal" positioning narrative |
| R2 | Stack research in `spec-researcher` is too shallow to be useful | High | Medium | Embed evaluation criteria in the research-brief template (P0); require three divergent test runs during development |
| R3 | Plugin-pack governance collapses — packs go stale or proliferate without standards | Medium | High | Publish governance document (P1); seed three in-house packs before marketplace opens; define maintenance contract |
| R4 | Migration friction causes known v4 adopters to abandon the blueprint | Medium | Medium | Pin to `3bb4c27` indefinitely; publish migration guide at v5.0 GA; offer 30-minute migration call for known adopters |
| R5 | AGENTS.md standard fragments — different agents expect different schemas | Low | Medium | Opt-in emission only; conduct quarterly governance audit; monitor emerging standards |
| R6 | `spec-researcher` violates context-economy principle — burns the context window | High | Medium | Hard budget encoded in template and agent definition (P0); single WebSearch-or-question constraint; PRs #113/#114 already address this |
| R7 | `docs/contracts/` becomes a new opinionated starter by accretion | Medium | Medium | Rule-4 protection on contracts; JSON Schema alongside prose keeps contracts structural not prescriptive; template-guard hook fires on any edit |
| R8 | Blueprint remains Claude-only despite agent-agnostic ambition | High | Low–Medium | Audit all prose for Claude-specific references; recruit at least one non-Claude pilot adopter before v5.0 GA; AGENTS.md emission is the primary structural mitigation |

---

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | Should `AGENTS.md` be emitted as a symlink to `CLAUDE.md` (shared content, two filenames) or as a separate file with agent-agnostic prose? Symlink is simpler but may not survive certain VCS operations. | Blueprint maintainer | Before v5.0 architecture sign-off |
| 2 | Who owns plugin-pack governance long-term — the blueprint maintainer, a community committee, or a marketplace-level review? The brief recommends the maintainer seeds the first three packs but does not resolve long-term ownership. | Blueprint maintainer | Before P1 plugin-pack work begins |
| 3 | Does the v4 migration guide need persona-specific guidance for persona 4 (reference-code reader)? These adopters may not be reachable via the guide at all — they consume starters passively. | Blueprint maintainer | 30 days post-v5.0 GA |
| 4 | How does the Signal beat evolve in a platform-agnostic context? Currently, `signal-sync` assumes a Vercel deployment. The architecture spec must answer this but the answer may require a separate Signal-beat epic. | spec-author / maintainer | Architecture spec draft |
| 5 | How portable is the CI wrapper beyond GitHub Actions? The brief flags GitLab and CircleCI as porting targets but the v5.0 scope does not include first-class CI portability. Define the boundary. | Blueprint maintainer | Before v5.0 launch |

---

## Appendix

- Research brief: `docs/research/agentic-blueprint-v5-agnostic-brief.md`
- v4 starters retirement note: `CLAUDE.md` transitional section
- PRs implementing research-budget guardrail: #113, #114
- Competitor reference: GitHub Spec Kit v0.1.4 (Feb 2026)
- Hard Rules principles: `docs/principles/`

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
