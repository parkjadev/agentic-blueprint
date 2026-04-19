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

These are enforced by `.claude/hooks/pre-commit-gate.sh` via the
`hard-rules-check` skill. All nine must pass before any commit or push.

1. **Australian spelling throughout** — favour, colour, organisation, behaviour, licence (noun), etc. Applies to all prose, comments, and string literals in every file in this repo.
2. **No domain-specific business logic in starters** — starters contain only generic infrastructure patterns. Anything that ties a starter to a specific product, brand, or vertical must be replaced with a generic example and a `TODO:` marker before merging.
3. **All starters must boot clean** — `starters/nextjs/` must pass `pnpm install && pnpm type-check && pnpm lint && pnpm test:ci` with zero errors. `starters/flutter/` must pass `flutter analyze && flutter test` with zero errors. Never merge code that breaks a starter's clean boot.
4. **Optional services** — in starters, use optional Zod schemas in `env.ts` so services gracefully skip when env vars are missing. Only Supabase is required; everything else (Stripe, Inngest, Resend) must be opt-in.
5. **Spec-driven** — every feature starts as a spec document before any code is written.
6. **Plan-before-code** — review the plan before any code generation. No Auto Mode.
7. **Templates are sacred** — the templates in `docs/templates/` are the core IP. Edit for clarity, never remove sections.
8. **Tool-agnostic framing** — guides recommend tools but never require a specific vendor. The discipline is the product, not the toolchain.
9. **Platform profiles are descriptive, not prescriptive** — profiles show how tools map to roles. They do not endorse or require any specific vendor. New profiles can be added for any toolchain that covers the five roles.

> TODO: when `docs/principles/` lands, move the long-form rationale for each
> rule out of this file and leave only one-liners + links here.

## Quick reference — the five stages

1. **Research & Think** → `/research <slug>` → brief in `docs/research/<slug>-brief.md`
2. **Plan** → `/plan <slug>` → specs in `docs/specs/<slug>/` + plan in `docs/plans/<slug>.md`
3. **Build** → `/build` → implementation guided by the plan, gated by Hard Rules
4. **Ship** → `/ship` → starter-verifier, changelog-entry, PR via GitHub MCP
5. **Run** → `/run <task>` → post-merge sync, docs-inspector, incident response

For the long-form version, read `docs/guides/` end-to-end.
