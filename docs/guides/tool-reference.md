# Tool Reference

> Which tool for which role — a decision framework, not a vendor pitch.

> **Transitional note — v5 agnostic redesign in flight.** The two fixed platform profiles below (Claude-native, OutSystems ODC) and the references to `starters/nextjs/` / `starters/flutter/` describe the v4 model, which is in the process of being superseded. The v4 reference starters have been retired; the v5 redesign will replace the fixed-profile matrix with a research-driven stack selection during the Spec beat. Track the design at `docs/specs/agentic-blueprint-v5-agnostic/` once `/spec idea` lands.

v4 ships two platform profiles: **Claude-native** (pro-code SaaS + mobile) and **OutSystems ODC** (low-code enterprise delivery). Spec and Signal artefacts are identical across both profiles; only Ship mechanics diverge. That's where the sellable IP concentrates — the discipline travels; the deployment tooling doesn't.

## The role model

Seven roles. Any tool can fill any role; profiles pick specific tools for each.

| Role | What it does |
|---|---|
| Research tool | Deep research, market analysis, source synthesis |
| Thinking partner | Brainstorm, PRD, strategy, critical assessment |
| Agentic coder / builder | Read, write, run tests, commit |
| Deployment pipeline | CI/CD, preview deploys, rollback |
| Scheduled automation | Recurring tasks, monitoring, triage |
| Ops surface | Non-code file processing, document generation, runbooks |
| Mobile supervision | Remote monitoring, async delegation |

Gaps in a profile are meaningful. If a profile has no native equivalent for a role, the adopter fills the gap with external tooling (typically GitHub Actions cron + an AI API, or manual process).

## Beat × profile matrix

This is the load-bearing table. Spec and Signal rows are identical across profiles; Ship diverges.

| Beat | Claude-native | OutSystems ODC |
|---|---|---|
| **Spec** | Claude Desktop for ideation + `/spec` for artefact generation. `spec-researcher` subagent for deep research. `spec-author` subagent for PRD + technical-spec | Same templates (`docs/templates/`) and `/spec` flow. ODC Lifecycle captures scope decisions. Specs live in git even when implementation is in ODC Studio |
| **Ship** | `/ship` — Claude Code PR loop, GitHub Flow, CI gates, `starter-verify` skill, Dispatch + Remote Control for mobile supervision during long builds. Deploy target is project-specific; common choices include Vercel (Next.js), Azure App Service / Container Apps via Bicep, AWS, and Fly.io | ODC Service Studio + Mentor build the app; ODC pipelines handle Dev → Test → Prod promotion. Specs stay in git; the deploy step is replaced by ODC's promotion flow. `/ship` still orchestrates the pre-build gate and CHANGELOG update |
| **Signal** | `/signal init` → Claude Scheduled Tasks for automation; `/signal sync` for post-merge close-out; `/signal audit` for weekly self-review; Cowork for ops-heavy non-code workflows; incident runbooks in `docs/operations/` | ODC LifeTime dashboards + Architecture Dashboard fill the monitoring role. External scheduled jobs (Claude Scheduled Tasks or GitHub Actions) cover anything ODC doesn't. Same `incident-runbook.md` template, same `docs/signal/learnings.md` accumulator |

## Profile A — Claude-native

**Best for:** solo founders, small product teams, pro-code SaaS + mobile.

| Role | Tool |
|---|---|
| Research tool | Claude web search; Perplexity Deep Research for broader passes |
| Thinking partner | Claude Desktop Chat (Projects) |
| Agentic coder | Claude Code (Terminal + VS Code) |
| Deployment pipeline | Claude Code driving GitHub Actions + a platform of choice. Common choices: Vercel (Next.js and similar edge-first stacks), Azure via Bicep + `az` CLI, AWS (CDK / Terraform), Fly.io, Railway |
| Scheduled automation | Claude Scheduled Tasks (`/signal init`) |
| Ops surface | Cowork |
| Mobile supervision | Dispatch + Remote Control |

`CLAUDE.md` provides project context across sessions. Specs live in `docs/specs/<slug>.md` (flat v4 layout). Architecture decisions are committed to the repo. The Claude ecosystem covers all three beats natively.

### Canonical flow

```
/spec feature checkout-flow
  → spec-researcher writes research brief
  → spec-author drafts PRD + technical-spec (two-pass with self-review)
  → branch feat/42-checkout-flow created, issue #42 filed
/ship
  → implementation → CI green → PR → preview smoke-test → squash-merge → production deploy
  → signal-sync appends CHANGELOG [Unreleased] entry
/signal sync
  → plan-status markers updated, cross-reference audit green
```

## Profile B — OutSystems ODC

**Best for:** enterprise teams using OutSystems Developer Cloud for rapid application delivery. Ships with the same Spec and Signal discipline as Profile A; only Ship mechanics differ.

| Role | Tool |
|---|---|
| Research tool | Claude web search; Perplexity Deep Research |
| Thinking partner | Claude Desktop Chat (Projects) or any persistent-context LLM |
| Agentic builder | OutSystems Mentor + Enterprise Context Graph (inside ODC Studio) |
| Deployment pipeline | ODC LifeTime promotion (Dev → Test → Prod) |
| Scheduled automation | Claude Scheduled Tasks or GitHub Actions cron (external) + ODC Timers (in-app) |
| Ops surface | ODC LifeTime dashboards + Architecture Dashboard; Cowork for non-code ops |
| Mobile supervision | Not applicable — ODC portal is the supervision surface |

Specs live in git (or a shared drive mirror), even when the implementation surface is ODC Studio. `docs/templates/architecture.md` maps cleanly to ODC module structure, entity model, service actions, and integration topology. Mentor's orchestrated agents consume the PRD + technical-spec directly as prompts.

### Canonical flow

```
/spec feature checkout-flow
  → same spec artefacts as Profile A
  → branch feat/42-checkout-flow created in git; implementation happens in ODC Studio
ODC Mentor + Service Studio build the app
  → Developer refines in ODC Studio with the PRD + technical-spec as Mentor prompts
  → ODC LifeTime promotes Dev → Test → Prod (no squash-merge; git branch captures design artefacts only)
/signal sync
  → plan-status + CHANGELOG updated; audit trail in git even though runtime is in ODC
```

## Cross-profile handoff patterns

Even within a single profile, tools hand off to each other at beat boundaries:

- **Thinking Partner → Agentic Coder**: deliberate Spec → Ship handoff. The PRD + technical-spec are the contract.
- **Agentic Coder → Scheduled Automation**: Ship → Signal handoff. The CHANGELOG entry + the updated plan status are the baton.
- **Thinking Partner → Ops Surface**: when an incident runbook reveals a recurring pattern, reframe it as a product question for the next Spec cycle.

## MCP integrations worth naming

- **Deployment MCP (platform-specific)** — deployment inspection and log tail during `/ship` preview smoke-test. One common choice is Vercel MCP when the stack is Next.js; Azure, AWS, and Fly.io fill the role via their own CLIs (`az`, `aws`, `fly`) or project-specific MCP servers where available.
- **GitHub CLI (`gh`)** — no MCP needed; the CLI covers issue, PR, and label operations well enough.
- **Anthropic Admin API** — for `/signal status` API-spend reporting when `ANTHROPIC_ADMIN_KEY` is configured.

Additional profile-specific MCP integrations can be added as the ecosystem grows. An OutSystems-published MCP server exposing ODC deployment state would be the cleanest Profile B extension; it doesn't yet exist publicly as of 2026.

## Doc-sweep checklist (post-ship)

After the Ship beat, verify these surfaces stay in sync — `/signal sync` automates most:

- `README.md` — top-level description still accurate
- `CHANGELOG.md` — `[Unreleased]` entry present for user-visible changes
- `CLAUDE.md` — primitive map still matches the harness
- Architecture diagrams (if any) — still reflect data flow
- Repo description + topics on GitHub — for discoverability

---

*Related: [principles](../principles/) · [templates](../templates/) · [guides index](./README.md)*
