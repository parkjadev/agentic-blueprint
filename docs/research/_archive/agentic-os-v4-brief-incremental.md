# Research Brief — Agentic OS v4 (Solo Claude Code Pro-Code)

**Date:** 2026-04-21
**Researcher:** Claude (main-context synthesis; external citation pass deferred)
**Tool:** Repo analysis + prior brief review + author knowledge of 2025–2026 Anthropic primitives
**Confidence:** Medium — repo primitive counts are verified; external citations need a verification pass in Stage 2.

---

## Research Questions

1. Walking through every current primitive (7 commands, 5 subagents, 5 skills, 5 hooks, 12 principles, 12 templates, 2 starters, claude-config), what should a solo Claude Code developer keep, merge, rename, or delete?
2. Which Claude Code and Anthropic platform primitives (Skills, Subagents, Hooks, MCP, Agent SDK, background and managed agents, Scheduled Tasks) is v4 under-using, and which are over-engineered for one person?
3. What is the minimum lifecycle that still enforces spec-before-code and plan-before-build for a solo operator shipping SaaS web and mobile products?
4. What is the right packaging unit for IP that a solo dev can open-source or sell around Claude Code for SaaS and mobile — and what is the distribution channel?
5. What does the concrete Current → v4 primitive map look like, and in what order should the migration happen?

---

## Key Findings

### Finding 1 — The harness is well-designed but carries three-profile and enterprise-team assumptions the solo dev does not need

The current `docs/guides/tool-reference.md` maintains three platform profiles: Claude-native (A), Cursor + Perplexity (B), and OutSystems ODC (C). Hard Rule 9 treats all three as peers. For a solo developer who has committed to Claude Code as their primary collaborator, profiles B and C are dead weight — every guide page carries callouts and forks for tools they will never touch. Similarly, the spec-writer / spec-reviewer pairing and the `new-feature` orchestrator command mirror enterprise-team patterns (author + reviewer, PM + engineer) that collapse to one person in solo work.

The waste is not that the primitives are bad — they are carefully built — but that they add navigation and ceremony surface that a solo user pays for on every single read. Principle 11 (context economy) is being violated in the harness's own docs.

### Finding 2 — Claude Code primitives are well-used, but three Anthropic surfaces are under-exploited

Verified from the repo: 5 Skills, 5 Subagents, 5 Hooks, and a `claude-config/` bundle. This is a mature use of Claude Code's composable primitives. Three surfaces are notably absent and each represents leverage for a solo operator:

- **MCP server.** No MCP server lives in this repo. An "Agentic OS" MCP server exposing the five-stage lifecycle (current stage, active spec, plan status, hard-rules-check result) would let any Claude Code session — including future ones on SaaS or mobile product repos — read the lifecycle context without installing the full harness. This is also the single most sellable unit of IP in the Anthropic ecosystem as of 2026.
- **Agent SDK / managed agents.** The `researcher` and `docs-inspector` workflows are good candidates for long-running background or managed agents rather than synchronous subagents — which would also have avoided the two 5-minute stream-idle timeouts that stalled today's first two research attempts.
- **Scheduled Tasks.** Stage 5 (Run) guide describes scheduled automation but nothing in the harness wires it up. A solo dev running SaaS in production needs a concrete pattern here, not prose.

### Finding 3 — Twelve templates and twelve principles is too many for one operator

Verified count in `docs/templates/`: CHANGELOG, PRD, README, api-reference, api-spec, architecture, auth-spec, data-model-spec, deployment, release-strategy, research-brief, technical-spec. `api-reference` and `api-spec` overlap for most solo projects; `auth-spec` fits cleanly inside `technical-spec` unless the product is auth-heavy. Twelve principles (9 Hard + 3 meta) is fine as a reference document but heavy to onboard against — a solo dev reads it once and forgets it.

The cut is not about IP value (these templates are the IP) but about what ships in the *default* v4 onboarding. A 6-template default core plus 6 optional advanced templates in a `templates/advanced/` folder is the right shape.

### Finding 4 — The claude-config bundle is the IP; publish it as the headline artefact

`claude-config/` already contains the copy-ready bundle (commands, agents, skills, hooks, settings, memory guidelines, smoke-test scripts). It is the natural distribution channel. Two strengthening moves:

- Ship it as a **GitHub template repository** (`agentic-os-starter`) that one-shots a new project with commands, agents, hooks, and a starter `CLAUDE.md`. This is how Vercel, Next.js, and Turbo package their "create-X" experiences as of 2026.
- Publish the Skills and the MCP server (see Finding 2) as **separate composable units** so another developer can adopt just the spec-driven discipline without taking the whole harness. This matches the "Anthropic Skills are small and composable" design intent.

The two pro-code starters (`starters/nextjs/`, `starters/flutter/`) can stay in the monorepo for now but would benefit from being extracted as their own template repos on a v4.1 pass once the core bundle stabilises.

### Finding 5 — The v4 primitive diff

| Primitive | v3 (today) | v4 proposal | Why |
|---|---|---|---|
| **Commands** | 7 (`research`, `plan`, `build`, `ship`, `run`, `stage`, `new-feature`) | 6 — delete `new-feature` | Thin orchestrator; solo dev can call the three stage commands directly |
| **Subagents** | 5 (`researcher`, `spec-writer`, `spec-reviewer`, `starter-verifier`, `docs-inspector`) | 3 — keep `researcher`, `starter-verifier`; merge `spec-writer`+`spec-reviewer` → `spec-author`; drop `docs-inspector` | Solo = one reviewer; `docs-inspector` duplicates `memory-sync` skill |
| **Skills** | 5 (`australian-spelling`, `changelog-entry`, `hard-rules-check`, `memory-sync`, `spec-author`) | 5 — unchanged; promote `spec-author` skill to replace the two merged subagents | Skills are small and composable; ship count is right |
| **Hooks** | 5 | 5 — unchanged | All five earn rent; gates > guidance (Principle 12) |
| **Principles** | 12 (9 Hard + 3 meta) | 8 — drop Principle 9 (multi-profile descriptive) and collapse Principles 8 + 11 (tool-agnostic + context-economy) into a single lean principle | v4 is single-track; fewer rules, sharper enforcement |
| **Templates** | 12 flat | 6 default + 6 in `templates/advanced/` | Default core: PRD, technical-spec, data-model-spec, deployment, research-brief, CHANGELOG |
| **Starters** | 2 (`nextjs`, `flutter`) | 2 unchanged, plan extraction in v4.1 | Solo dev needs both surfaces; do not double work in v4 |
| **Platform profiles** | 3 (Claude-native, Cursor+Perplexity, OutSystems) | 1 (Claude-native) | Single-track; drop two profiles entirely |
| **New: MCP server** | — | `agentic-os-mcp` exposes lifecycle state | Distributable IP + ergonomics |
| **New: Background agent** | — | `researcher` runs as background/managed agent | Avoids 5-minute stream timeouts |

---

## Market Landscape

| Player | Approach | Strengths | Weaknesses |
|---|---|---|---|
| AWS Kiro | Spec-driven agentic IDE (VS Code fork) with Claude + Nova | Specs → code → tests pipeline; integrated agent hooks | AWS/Bedrock lock-in; proprietary spec format; not portable to Claude Code |
| Cursor + Agent Skills | Agentic IDE with parallel background agents | Large ecosystem; fast iteration loops | No Stage 1 (research) or Stage 5 (ops) surfaces |
| AutoGen / CrewAI scaffolds | Multi-agent Python frameworks | Flexible orchestration patterns | No opinionated delivery lifecycle; no spec discipline |
| OpenHands (All Hands AI) | Open-source agentic coder | Active community; MCP-native | IDE-style rather than lifecycle-style; no spec-driven gates |
| agentic-blueprint v3 (this repo) | Claude Code harness, sacred templates, five-stage lifecycle | Full lifecycle; discipline gates; composable Anthropic primitives | Heavy for a solo operator; three platform profiles bloat guides |

None of the competitors ship a spec-driven, gates-enforced, lifecycle-aware harness specifically for Claude Code. That is the v4 wedge.

---

## Implications

- **Delete the OutSystems and Cursor+Perplexity profiles** from `tool-reference.md` and remove Principle 9. Every guide page gets shorter.
- **Merge `spec-writer` and `spec-reviewer` subagents** into a single `spec-author` flow (the skill already exists; promote it). Drop the `new-feature` command and `docs-inspector` agent.
- **Build `agentic-os-mcp`** as the headline piece of distributable IP. It should expose five read-only resources (current stage, active plan, active spec, hard-rules status, changelog head) and nothing else for v4.
- **Convert `researcher` into a background/managed agent** invocation so it cannot stream-idle-timeout. Today's session hit this failure mode twice; it will keep happening until fixed.
- **Split templates** into `docs/templates/` (6 default) and `docs/templates/advanced/` (6 optional). Update `spec-author` skill and `/plan` command to reference the default set first.
- **Package claude-config as a GitHub template repo** (`agentic-os-starter`) as the primary distribution channel; Skills and the MCP server published separately for composable adoption.

---

## Open Questions

- **Callout renames when we drop two profiles:** the guides still contain `[Profile A/B/C]` scaffolding. Stage 2 must decide whether to remove all callouts entirely or keep Profile A framing as single-mode shorthand.
- **MCP server surface:** exactly which resources and tools does `agentic-os-mcp` expose in v4? Read-only only, or also `advance-stage` / `run-hard-rules-check` tools? This is the single largest scope decision for Stage 2.
- **Template migration path:** moving 6 templates into `templates/advanced/` is a Rule-7 (templates are sacred) touch. Does this land on a `docs/templates-restructure` branch with a dedicated PR, or does v4 carry a one-off Rule-7 exemption?
- **Researcher timeout fix:** is the right fix (a) background-agent refactor, (b) tighter prompt budgets per subagent call, or (c) both? Two data points today favour (a), but (b) is cheaper to ship first.
- **External citation gap:** this brief is Medium confidence because live web-search passes timed out. Stage 2 should run a focused citation pass against Anthropic's Claude Code docs, engineering blog, and 2025–2026 solo-dev case studies to upgrade confidence before code moves.

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
