# Research Brief — Agentic Blueprint v5 (Platform-Agnostic)

**Date:** 2026-04-23
**Researcher:** Claude (main-context synthesis; fresh session after v5-handoff-notes.md)
**Tool:** Repo analysis + carried-over WebSearch findings from 2026-04-22 session (see handoff notes for provenance)
**Confidence:** Medium-High — competitor landscape and retired-starter patterns are grounded in direct evidence; migration cost estimates and IP-angle framing are opinion informed by v4 outcomes.

---

## Research Questions

1. **Market landscape** — who else operates in the AI-first project-blueprint / spec-driven-kit / agentic-scaffold space in April 2026?
2. **User research proxies** — what did v4 starter adopters actually do with the starters, and what does that tell us about the adopter spectrum?
3. **What replaces the retired v4 starters?** Enumerate ≥5 options, pick one.
4. **`/beat install` in a starter-less world** — what does install deliver if the IP isn't a pre-built tree?
5. **Hard Rules audit** — for each of the five Hard Rules and three meta-principles, does v5 keep it, reframe it, or retire it?
6. **v4 adopter migration** — how do existing v4 users move to v5 without regression?
7. **`tool-reference.md` evolution** — what is this doc when there's no canonical stack?
8. **Business model / IP angle** — what is the sellable IP in v5?
9. **Risks register** — what are the six-plus genuine risks of this pivot, with likelihood / impact / mitigation?
10. **Recommendations** — three-to-five opinionated calls the PRD should build on.

---

## Key Findings

### Finding 1 — The space has a clear market leader; v5's moat is Ship + Signal

The most direct competitor is **GitHub Spec Kit** (`github/spec-kit`, v0.1.4 as of February 2026). It is an open-source, spec-driven toolkit with a five-phase flow (Specify → Plan → Tasks → Implement) that is agent-agnostic across 30+ CLIs and IDEs — Claude Code, Copilot, Gemini CLI, Cursor, Windsurf, Amazon Q. A CLI bootstraps per-agent templates. Positioning overlap with v5 is near-total on the Spec half.

Spec Kit stops at *Implement*. It has no opinion about how the PR reaches production, no post-merge synchronisation ritual, and no periodic self-review. That is exactly where v5's Ship and Signal beats live. The moat is not "we also do specs" — the moat is **the full Spec → Ship → Signal loop with hard-rule gates, post-merge signal-sync, and scheduled automation** as a single opinionated discipline.

Adjacent players sharpen the picture. **AWS Kiro** is a proprietary IDE built around a near-identical lifecycle (Constitution / Specify / Plan / Tasks / Implement / PR) but is paid, AWS-flavoured, and locks users into its surface. **OpenSpec, Devika, Tessl, and Augment Code** each ship some spec-driven agentic workflow with varying autonomy — none combine repo-native install, hook-enforced hard rules, and a three-beat cadence. The **Claude Code Plugin Marketplace** (plugin format: `.claude-plugin/marketplace.json`, slash commands + agents + hooks + MCP servers, curated by Dan Ávila's DevOps bundle and Seth Hobson's 80+ subagents) is not a competitor — it is v5's natural distribution channel. The **AGENTS.md standard** (agreed by Google, OpenAI, Sourcegraph, Cursor, Factory; adopted by n8n, LangFlow, llama.cpp, Bun) is the emerging vendor-neutral rule format; v5 that stays CLAUDE.md-only is leaving half the market on the table.

Source to cite in the PRD: *"Spec-Driven Development Is Eating Software Engineering: A Map of 30+ Agentic Coding Frameworks (2026)"* by Vishal Mysore, March 2026, Medium.

### Finding 2 — v4 adopter behaviour splits along a two-axis spectrum

No formal user research exists for v4 — the blueprint is young and the audience small. The evidence available is (a) the retired starter contents, (b) PR history, and (c) the author's own stated usage. From those:

- The starters were a **demonstration of discipline**, not production templates. The load-bearing IP inside `starters/nextjs/CLAUDE.md` and `starters/flutter/CLAUDE.md` was the shared `ApiResponse<T>` envelope contract, the optional-service gating pattern, and the clean-boot harness — not the specific choice of Next.js 15 or Flutter 3.27.
- Adopters split on two axes: **scaffold-hunger** (want a working tree day one ↔ want discipline only) and **stack-conviction** (already chosen their stack ↔ open to recommendations).

Four adopter personas fall out:

| Persona | Scaffold-hunger | Stack-conviction | v4 experience | v5 need |
|---|---|---|---|---|
| **Greenfield founder** | High | Low | Forced into Next.js or Flutter; the "default choice" was really "only choice" | Wants the blueprint to help *choose* the stack, then scaffold it |
| **Stack-locked team** | High | High | Ignored the starter; lifted templates + hard rules into their own repo | Wants `/beat install` to work cleanly on their existing stack with zero starter baggage |
| **Discipline-only solo dev** | Low | Variable | Used templates + CLAUDE.md, never touched the starter tree | Wants a leaner install — no starter, no verification harness, just the discipline layer |
| **Reference-code lurker** | High | Low | Read the starter code for patterns, never ran it | Wants the blueprint to produce *reference snippets on demand* (via Spec research), not shipped code to maintain |

**Inference:** the starters served persona 4 (reference lurker) moderately well and persona 1 (greenfield founder) poorly once their stack disagreed with the starter. Personas 2 and 3 didn't need starters at all. v5 must serve all four without regression.

### Finding 3 — Starter replacement: five options, one recommendation

The v4 starters were a promise ("we've done the plumbing for you") backed by real working trees (`starters/nextjs/`, `starters/flutter/`, `starters/dotnet-azure/`). That promise needs a successor or an honest deprecation. Five live options:

**Option A — Research-derived scaffold (emit at Spec time).** `/spec idea` runs `spec-researcher` against the problem, picks a stack, and at the end of the Spec beat *generates* a fresh scaffold tailored to that stack (Next.js + Supabase, or Flutter + Firebase, or .NET + Azure, or whatever the research recommends). Pros: maximally tailored; no unused choices checked in; scaffold reflects 2026 best practice at generation time. Cons: brittle (generator must track moving ecosystem); verification story (clean boot) is harder when every scaffold is one-off.

**Option B — Adopter-curated source pointers.** The blueprint ships *no* scaffold. `/spec idea` produces a stack recommendation and links to curated external starters (create-t3-app, very-good-cli, dotnet new templates). Pros: zero maintenance burden; lets upstream tooling do what it does best. Cons: loses the shared-contract discipline (`ApiResponse<T>` envelope across Next.js + Flutter) that was v4's subtle crown jewel.

**Option C — Stack-agnostic reference contracts only.** Ship a `docs/contracts/` library (API envelope, error-code taxonomy, auth-token shape, telemetry schema) that is stack-agnostic prose + JSON Schema. Adopters translate to their stack. Pros: preserves the load-bearing IP from v4 starters; no runtime code to maintain. Cons: higher adopter friction — someone has to write the Next.js adapter.

**Option D — Plugin-pack of per-stack scaffold plugins.** Ship v5 core as one plugin on the Claude Code Marketplace. Separately, ship community-maintained per-stack plugins (`agentic-blueprint-nextjs-supabase`, `agentic-blueprint-flutter`, `agentic-blueprint-dotnet-azure`). Pros: decouples stack churn from blueprint churn; uses the distribution channel that's already winning; each pack has its own maintainer. Cons: governance overhead; risks a fragmented experience if packs drift.

**Option E — "Scaffold on demand" slash command.** `/scaffold <template>` inside a post-Spec repo emits a scaffold from a versioned template registry. The template is chosen by the Spec research but the generation is deferred to Ship. Pros: keeps Spec deliverables small; lets Ship be the step that actually touches code. Cons: another primitive to learn; duplicates work if Option A already emits the scaffold.

**Recommendation: C + D, with A deferred.** Core v5 ships Option C (stack-agnostic reference contracts) as the non-negotiable discipline layer — that is the sellable IP. Option D (per-stack plugin packs) becomes the distribution strategy for teams that want a working tree, with the first three packs re-created from the retired v4 starters by community or the author on a separate cadence. Option A is an aspirational long-term direction once the generator tooling matures; not in v5.0. This combination preserves v4's contract discipline, removes the starter-maintenance treadmill from the core repo, and uses the marketplace as leverage.

### Finding 4 — `/beat install` in a starter-less world delivers the discipline layer

In v4, `/beat install` was a fat operation: copy `.claude/` bundle, merge `CLAUDE.md`, scaffold `docs/` with nine templates, install GitHub Actions wrapper, write `claude-config/VERSION`. In a starter-less v5, install delivers *less code and more contract*:

- `.claude/` bundle (commands, agents, skills, hooks, settings) — unchanged, minus any starter-specific skills
- `CLAUDE.md` merged via the `<!-- agentic-blueprint:begin/end -->` fence — unchanged contract
- `AGENTS.md` emitted alongside or as a symlink for non-Claude agents — **new in v5**
- `docs/templates/` (sacred templates, Hard Rule 4) — unchanged
- `docs/principles/` — updated to reflect v5 Hard Rules (see Finding 5)
- `docs/guides/` — rewritten to describe the stack-selection research flow rather than the old three-profile model
- `docs/contracts/` — **new in v5**, ships the stack-agnostic reference contracts from Finding 3 Option C
- `claude-config/VERSION` — unchanged
- CI wrapper — unchanged; hard-rules-check skill runs identically
- **No `starters/` directory, no `bootstrap-smoke-test.yml`, no `starter-verify` skill**

The install experience for a new adopter in v5 looks like: clone or bring your own repo, `/beat install`, then `/spec idea <product>` — at which point `spec-researcher` asks about the problem and produces a stack recommendation along with pointers to marketplace plugins if the adopter wants a scaffold. This is both smaller (fewer files copied) and larger (a research step is now part of onboarding) than v4's install. The net cognitive load for persona 2 and 3 adopters drops; for persona 1 it stays similar; for persona 4 it rises slightly and is offset by the plugin-pack escape hatch.

### Finding 5 — Hard Rules audit: four survive, one is vacuous, meta-principles all survive

Walking each rule against the v5 design:

| # | Rule | v5 verdict | Notes |
|---|---|---|---|
| 1 | Australian spelling | **Survives unchanged** | Non-negotiable constraint from the handoff. Hook + wordlist stay as-is. |
| 2 | Starters stay generic and boot clean | **Retired or reframed** | With no `starters/` directory, the rule is vacuous. Options: delete it, or reframe as *"any stack-pack plugin must boot clean via its own declared verification harness"*. Recommend reframe — keeps the boot-clean contract alive for Option D plugin packs. |
| 3 | Spec-before-Ship | **Survives unchanged** | The core three-beat invariant. Tagged-exception prefixes (`[release]`, `[infra]`, `[docs]`, `[bulk]`) continue to provide named escapes. |
| 4 | Templates versioned, not edited in flight | **Survives unchanged** | Sacred templates are the most durable piece of IP. Hook guard stays. `docs/contracts/` (new in v5) inherits the same protection. |
| 5 | Descriptive profiles, not prescriptive | **Survives and strengthens** | The pivot is *built on this rule* — v5 describes the stack-selection discipline rather than prescribing the stack. The rule text may need a rewrite to reflect the broader application. |
| 6 | Progressive disclosure (meta) | **Survives** | Applies harder in v5: without starters, every primitive must earn its place. Expect pressure to delete one or two skills that only existed to service the starter-verify flow. |
| 7 | Context economy (meta) | **Survives** | The handoff file itself is evidence this principle was violated in the last session (180k tokens, 600 turns). v5 should encode a tighter budget discipline in the research and spec-author agents. |
| 8 | Gates over guidance (meta) | **Survives** | CI-level hard-rules-check is still the production gate. If anything, v5 needs *more* gates (e.g. AGENTS.md-emitted checks) as the surface broadens. |

The only structural change is Rule 2. Recommend **reframe, don't retire** — the boot-clean contract is load-bearing even for optional plugin packs, and a reframe keeps continuity for v4 readers.

### Finding 6 — v4 adopter migration: pin, shim, and guide

The v4 starters were retired in PR #109 (squash commit `a53f0ff`). Any v4 adopter who ran `/beat install` before that commit has a repo that references retired primitives. Three migration instruments are needed:

**Pin.** Document the last-known-good v4 commit (`3bb4c27`, pre-retirement main tip) and recommend v4 adopters who do not want to migrate immediately pin to that commit in their `claude-config/VERSION` check. The `/beat update` flow must refuse to overwrite to v5 without an explicit `--v5` flag, and must print a short migration summary when it does.

**Shim.** For the subset of v5 primitives that have a v4 analogue (e.g. if Rule 2 is reframed rather than deleted, the existing `starter-verify` skill can be renamed rather than removed), emit a shim that logs a deprecation warning and forwards to the v5 primitive. Two-release deprecation window: v5.0 ships the shim with a warning; v5.1 removes it. The shim budget is small — maybe three primitives — and nothing structural.

**Guide.** Ship `docs/guides/migrating-from-v4.md` walking through the conversion: delete `starters/`, adopt `docs/contracts/`, update CLAUDE.md to reflect new Hard Rule 2 text, install the AGENTS.md emitter. Include a table of "what moved where" so v4 readers can grep for familiar terms and land on the new docs. The migration guide is also the artefact that lets a lurker skim-evaluate whether v5 is worth adopting.

The migration cost for persona 2 and 3 adopters is close to zero (they weren't using starters). For persona 1 and 4 adopters, the cost is reading one guide and re-installing. This is a one-afternoon migration for any active adopter — which keeps the pivot honest.

### Finding 7 — `tool-reference.md` evolves into a role + inputs matrix

`docs/guides/tool-reference.md` in v4 was a shopping-list style enumeration of tools per stage (research tools, planning tools, build tools, ship tools). It assumed a fixed stack and a fixed lifecycle. In v5, neither assumption holds — the research step chooses tools per-project, and the lifecycle is three beats not five.

Three evolution options:

- **Archive it.** Move to `docs/guides/_archive/` with a breadcrumb. Clean but throws away useful provenance.
- **Rebuild as a shopping list.** Same format, updated entries. Defers the problem: the shopping list will drift again as tools churn.
- **Reframe as a role + inputs matrix.** Recommend. For each of the three beats, describe the *role* the agent is playing (research analyst, spec author, code implementer, reviewer, monitor) and the *inputs* the role needs (repo context, problem statement, external web search, MCP servers, etc.). Specific tool names become examples, not prescriptions. This is the Hard-Rule-5 reframing applied to tool choice: describe the role, don't prescribe the tool.

The third option aligns with the "descriptive profiles, not prescriptive" invariant and stays useful as tools churn underneath. It also doubles as a blueprint for the Claude Code Marketplace plugin-pack authors — a pack declares which roles it provides and which inputs it expects.

### Finding 8 — The sellable IP is the disciplined research-to-signal loop

The question "what is the IP worth" is sharper in v5 than v4. In v4 it was ambiguous: was the IP the starters, the templates, the hard rules, or the harness? Retiring the starters resolves the ambiguity. The IP in v5 is:

1. **The sacred document templates** (PRD, technical-spec, architecture, research-brief, release-strategy, etc.) — nine documents, locked by Hard Rule 4, that encode a particular discipline of *thinking before shipping*. These are the most copy-able and most defensible artefact.
2. **The three-beat lifecycle with hard-rule gates** — the claim that every unit of delivery moves through Spec → Ship → Signal with CI-enforced checks at the boundaries. Spec Kit does not have this; Kiro does but is paid and locked; no open competitor combines the two.
3. **The contract-first reference library** (`docs/contracts/`) — cross-stack contracts like the `ApiResponse<T>` envelope that constrain multi-runtime products to a single wire-level API shape. This is the load-bearing piece from the retired starters, elevated to core IP.
4. **The adopt-in-place install model** — merge a fence into an existing CLAUDE.md, leave source code alone, write a VERSION file, update without clobbering. This is operationally hard to get right and is a real moat.

What *isn't* the IP: the specific slash commands, the specific agents, the specific skills. Those are implementation of the above. Any competitor could implement the same primitives; few will ship the discipline that makes them cohere.

**Business-model angle:** v5 stays OSS. The sellable layer is consulting / paid plugin packs / private hard-rule profiles for enterprise. The marketplace plugin channel lowers distribution cost and lets the author gauge interest without commercial infrastructure.

### Finding 9 — Risks register

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | **Spec Kit closes the gap fast.** GitHub ships a Ship-equivalent phase in v0.2, eliminating the clearest differentiator. | Medium | High | Ship v5 before Spec Kit v0.2 lands; make Signal (post-merge sync + periodic self-review) the second moat so competitive parity requires two phases, not one. |
| R2 | **Stack-selection research produces shallow or repetitive output.** `spec-researcher` recommends Next.js + Supabase for 80% of briefs because that's what the training data biases toward. | High | Medium | Add explicit evaluation criteria to the research-brief template (data-sovereignty needs, runtime-cost ceiling, team-skill inventory) so recommendations are forced to diverge when inputs diverge. Test with three deliberately-different `/spec idea` runs before v5.0 ships. |
| R3 | **Plugin-pack governance collapses.** Three community packs exist for six months then bit-rot; the experience degrades when a new adopter lands on a stale pack. | Medium | High | Publish a pack-maintenance contract upfront (every plugin pack declares `claude-config/VERSION` compatibility, must pass a boot-clean check in its own CI). Mark unmaintained packs in the marketplace listing. Seed the first three packs in-house. |
| R4 | **Migration friction loses v4 adopters.** Persona 1/4 adopters who liked the starter default drop the blueprint rather than read a migration guide. | Medium | Medium | Keep v4 pin-able indefinitely; write the migration guide before v5.0 ships; offer a 30-minute migration call for known v4 adopters. |
| R5 | **AGENTS.md adoption stalls or splinters.** The standard forks between vendors and emitting AGENTS.md becomes a liability rather than an asset. | Low | Medium | Emit AGENTS.md only when the adopter opts in; keep CLAUDE.md the primary file; monitor the standard's governance quarterly. |
| R6 | **Context-economy violation in `spec-researcher`.** The stack-selection research itself becomes long-running and context-bloated (the failure mode that triggered this handoff in the first place). | High | Medium | Encode a hard budget in the research-brief template (word count ceiling, question cap, single-call default). Codify "no more than one WebSearch per question" as a skill-level guardrail. Bias toward repo-analysis + carried-over findings over fresh queries. |
| R7 | **`docs/contracts/` becomes the new starter** — adopters copy-paste it, edit it, and drift, re-creating the v4 problem on a slightly smaller surface. | Medium | Medium | Template-guard the contracts folder via Hard Rule 4. Any edit requires a `[release]` commit prefix, same as templates. Provide machine-readable JSON Schema alongside prose so adopters can import the contract rather than fork it. |
| R8 | **The blueprint becomes a Claude Code-only artefact** despite the agent-agnostic ambition. AGENTS.md emission is half-hearted; the prose still assumes Claude. | High | Low-Medium | Audit the v5 doc tree for Claude-specific language before ship. Keep the command surface tool-portable (slash commands are per-agent; the *discipline* is universal). Recruit one non-Claude-Code adopter to pilot before v5.0. |

R2 and R6 are the highest-priority mitigation items for the PRD — both attack the research step, which is the new load-bearing primitive in v5.

## Market Landscape

| Player | Approach | Strengths | Weaknesses |
|---|---|---|---|
| **GitHub Spec Kit** (`github/spec-kit`, v0.1.4 Feb 2026) | Open-source, spec-driven, agent-agnostic across 30+ CLIs/IDEs. Specify → Plan → Tasks → Implement. | Maturity, distribution, multi-agent support, GitHub gravity. | No Ship phase, no Signal phase, no hard-rule gates, no post-merge sync. |
| **AWS Kiro** | Proprietary IDE built around Constitution / Specify / Plan / Tasks / Implement / PR. | Full lifecycle under one roof; polished UX. | Paid, AWS-flavoured, IDE-locked, not repo-native. |
| **OpenSpec / Devika / Tessl / Augment Code** | Varying spec-driven agentic frameworks. | Each has a pocket of distinctive capability. | None combine repo-native install, hard-rule gates, and three-beat cadence. |
| **Claude Code Plugin Marketplace** | Plugin format: slash commands + agents + hooks + MCP servers. Community curators (Dan Ávila, Seth Hobson). | Natural distribution channel for v5. Low distribution cost. | Governance nascent; fragmentation risk. |
| **AGENTS.md standard** | Vendor-neutral rule format (Google, OpenAI, Sourcegraph, Cursor, Factory). Adopted by n8n, LangFlow, llama.cpp, Bun. | Growing ubiquity; vendor-neutral. | Standard is still young; may fork. |
| **Cursor rules (`.cursor/rules/`)** | Path-scoped rules, large community base. | Reach across Cursor users. | Tool-specific; AGENTS.md is the forward-compatible bet. |
| **Create-T3-App, degit, Yeoman, Nx, Turborepo** | Pre-AI scaffold generators. | Battle-tested scaffolding; active communities. | No spec discipline; no Signal loop; no agentic context. |

## Implications

**Recommendation 1 — Position v5 explicitly as "Spec Kit plus Ship plus Signal".** The PRD should name Spec Kit as the closest competitor, describe exactly where v5 diverges (post-Implement: automated PR loop, hard-rule gates, post-merge signal-sync, periodic self-review), and commit to shipping before Spec Kit's next minor release. A single-sentence positioning statement belongs in `README.md` and in the marketplace listing.

**Recommendation 2 — Replace starters with a two-layer strategy: `docs/contracts/` in core + per-stack plugin packs on the marketplace.** The core repo ships contracts (stack-agnostic API envelope, error taxonomy, auth shape, telemetry schema) as sacred templates under Hard Rule 4. The marketplace ships per-stack plugin packs maintained on a separate cadence. `/spec idea` research either recommends a pack or points to an adopter-curated source. This preserves v4's contract discipline, removes the starter-maintenance treadmill, and uses the distribution channel that's already winning.

**Recommendation 3 — Ship AGENTS.md alongside CLAUDE.md as a first-class install artefact.** v5 `/beat install` emits both files (or a symlink) from the same source of truth. This expands the addressable audience to any AGENTS.md-compliant agent and de-risks R8 (Claude-Code-only lock-in). Quarterly audit of the AGENTS.md standard's governance decides whether the commitment stays.

**Recommendation 4 — Reframe Hard Rule 2 rather than retire it.** The boot-clean contract survives as *"any stack-pack plugin must boot clean via its own declared verification harness"*. This keeps the discipline alive for Option D plugin packs and keeps continuity for v4 readers. Meta-principles (6, 7, 8) and all other rules survive unchanged.

**Recommendation 5 — Encode a research-budget guardrail in the `spec-researcher` skill and the research-brief template.** Word-count ceiling (4000 words max), question cap (ten per brief), single-call default for the main `Write`, hard bias toward repo-analysis + carried-over findings over fresh WebSearch. This directly attacks R2 (shallow research) and R6 (context bloat) — the two highest-priority risks. The failure mode that triggered this handoff itself was a context-economy violation; v5 must encode the lesson in the tooling, not rely on the operator to remember.

## Open Questions

- **AGENTS.md emission mechanics** — symlink or separate file? The PRD should make this call with reference to the standard's current guidance as of ship date.
- **Plugin-pack governance model** — who owns the first three packs (Next.js, Flutter, .NET + Azure)? In-house for six months then community handover, or community from day one with seed authorship?
- **Migration-guide scope** — does the guide cover all four personas or explicitly punt on persona 4 (reference lurker)? Argue for covering all four but with honest friction estimates.
- **Signal beat evolution** — does v5 add a new Signal primitive (e.g. `/signal digest` for periodic auto-summary) or stay at parity with v4? Defer to PRD.
- **CI wrapper portability** — v4 ships a GitHub Actions wrapper and prints porting notes for GitLab/CircleCI. v5 should either formalise the porting or commit to GitHub-only. Defer to PRD.

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
