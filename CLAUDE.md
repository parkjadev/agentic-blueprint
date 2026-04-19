# CLAUDE.md

Primitive map for Claude Code (and any other agent) working in this repository.
Start here, then drill into the harness, templates, or starters as needed.

## What this repo is

A framework for building products with AI collaborators, covering the full
lifecycle from research through operations. Ships document templates, workflow
guides, optional code starters, and a lifecycle-aware Claude Code harness.

The master plan is the five-stage lifecycle:
**Research & Think → Plan → Build → Ship → Run**.

## Harness map (where to look for what)

| Primitive | Location | Purpose |
|---|---|---|
| Slash commands | `.claude/commands/` | Lifecycle entry points: `/research`, `/plan`, `/build`, `/ship`, `/run`, `/stage`, `/new-feature` |
| Subagents | `.claude/agents/` | Isolated workers: `researcher`, `spec-writer`, `spec-reviewer`, `starter-verifier`, `docs-inspector` |
| Skills | `.claude/skills/` | Progressive-disclosure helpers: `australian-spelling`, `spec-author`, `hard-rules-check`, `changelog-entry`, `memory-sync` |
| Hooks | `.claude/hooks/` | `session-start`, `stage-aware-prompt`, `template-guard`, `pre-write-spelling`, `pre-commit-gate` |
| Settings | `.claude/settings.json` | Permission baseline and hook wiring |
| Sacred templates | `docs/templates/` | The core IP — spec-driven development templates. Never modify in a feature PR |
| Stage guides | `docs/guides/` | Long-form guides for each lifecycle stage, plus a tool-reference appendix |
| Research briefs | `docs/research/` | Stage 1 output; lands via `/research <slug>` |
| Plans | `docs/plans/` | Stage 2 output; one plan file per feature |
| Specs | `docs/specs/<slug>/` | Stage 2 output; filled-in templates |
| Starters | `starters/nextjs/`, `starters/flutter/` | Optional reference implementations |
| Copy-ready bundle | `claude-config/` | What downstream projects copy into their own repos |

When in doubt, run `/stage` for a read-only snapshot of where we are.

## Hard Rules

Enforced by `.claude/hooks/pre-commit-gate.sh` via the `hard-rules-check`
skill. All nine must pass before any commit or push. Rationale and
remediation guidance live in [`docs/principles/`](./docs/principles/).

1. [Australian spelling throughout](./docs/principles/01-australian-spelling.md)
2. [No domain-specific business logic in starters](./docs/principles/02-no-domain-logic-in-starters.md)
3. [All starters must boot clean](./docs/principles/03-starters-boot-clean.md)
4. [Optional services (Zod schemas in `env.ts`)](./docs/principles/04-optional-services.md)
5. [Spec-driven](./docs/principles/05-spec-driven.md)
6. [Plan-before-code](./docs/principles/06-plan-before-code.md)
7. [Templates are sacred](./docs/principles/07-templates-are-sacred.md)
8. [Tool-agnostic framing](./docs/principles/08-tool-agnostic-framing.md)
9. [Platform profiles are descriptive, not prescriptive](./docs/principles/09-platform-profiles-descriptive.md)

Three meta-principles shape the harness itself:
[progressive disclosure](./docs/principles/10-progressive-disclosure.md),
[context economy](./docs/principles/11-context-economy.md), and
[gates over guidance](./docs/principles/12-gates-over-guidance.md).

## Quick reference — the five stages

1. **Research & Think** → `/research <slug>` → brief in `docs/research/<slug>-brief.md`
2. **Plan** → `/plan <slug>` → specs in `docs/specs/<slug>/` + plan in `docs/plans/<slug>.md`
3. **Build** → `/build` → implementation guided by the plan, gated by Hard Rules
4. **Ship** → `/ship` → starter-verifier, changelog-entry, PR via GitHub MCP
5. **Run** → `/run <task>` → post-merge sync, docs-inspector, incident response

For the long-form version, read `docs/guides/` end-to-end.
