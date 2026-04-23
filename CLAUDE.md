# CLAUDE.md

Primitive map for Claude Code (and any other agent) working in this repository. Start here, then drill into the harness, templates, or research briefs as needed.

> **Transitional note — v5 agnostic redesign in flight.** The v4 reference starters (`starters/nextjs/`, `starters/flutter/`, `starters/dotnet-azure/`) have been retired. The blueprint is being re-framed so `/spec idea` drives stack selection via research rather than shipping opinionated starters. The authoritative design for v5 will land under `docs/specs/agentic-blueprint-v5-agnostic/` when `/spec idea` completes. Until then, expect the harness to reference retired primitives in a few places — those will be reconciled by the v5 PR.

## What this repo is

A framework for building products with AI collaborators. Ships document templates, workflow guides, and a beat-aware Claude Code harness.

The master plan is the **three-beat lifecycle**: **Spec → Ship → Signal**.

- **Spec** — research + plan collapsed. Frame the problem, define done. Human-led.
- **Ship** — build + test + deploy + release as one automated PR-driven loop with gates.
- **Signal** — run + monitor + learn + scheduled automation. Feeds back into Spec.

v4 collapses the previous five-stage model (Research & Think → Plan → Build → Ship → Run) because Claude Code now closes Plan → Build → Ship in one continuous motion — the spec IS the plan.

## Harness map (where to look for what)

| Primitive | Location | Purpose |
|---|---|---|
| Slash commands | `.claude/commands/` | Beat entry points: `/spec <idea\|epic\|feature\|fix\|chore>`, `/ship`, `/signal <init\|sync\|audit\|status>`, `/beat <status\|install\|update>` |
| Subagents | `.claude/agents/` | Isolated workers: `spec-researcher`, `spec-author` |
| Skills | `.claude/skills/` | Progressive-disclosure helpers: `australian-spelling`, `hard-rules-check`, `signal-sync` |
| Hooks | `.claude/hooks/` | `session-start`, `beat-aware-prompt`, `template-guard`, `pre-write-spelling`, `pre-commit-secret-scan`, `pre-commit-gate`, `prune-merged-branches` |
| Settings | `.claude/settings.json` | Permission baseline and hook wiring |
| Sacred templates | `docs/templates/` | The core IP — spec-driven document templates. Never modify in a feature PR (Rule 4) |
| Beat guides | `docs/guides/` | Long-form guides for each beat, plus a tool-reference (v5 will re-frame this around research-driven stack selection) |
| Research briefs | `docs/research/` | Spec-beat output; lands via `/spec idea` or `/spec feature` |
| Specs | `docs/specs/<slug>.md` (flat) or `docs/specs/<slug>/` (folder) | Spec-beat output; filled-in templates with `scope:` + `parent:` frontmatter |
| Copy-ready bundle | `claude-config/` | What downstream projects copy via `/beat install` |

When in doubt, run `/beat` for a read-only status snapshot + the next-best command.

## Hard Rules

Enforced by `.claude/hooks/pre-commit-gate.sh` via the `hard-rules-check` skill. Four enforced Hard Rules + three meta-principles. Rationale and remediation live in [`docs/principles/`](./docs/principles/). (Rule 2 retired in v5.0 — see [`_archive/02-starters-generic-boot-clean.md`](./docs/principles/_archive/02-starters-generic-boot-clean.md); numbering preserved so downstream references to Rules 3/4/5 don't silently shift.)

**Hard Rules (hook-gated):**

1. [Australian spelling throughout](./docs/principles/01-australian-spelling.md)
3. [Spec-before-Ship](./docs/principles/03-spec-before-ship.md)
4. [Templates versioned, not edited in flight](./docs/principles/04-templates-versioned.md) — covers `docs/templates/` and `docs/contracts/`
5. [Descriptive profiles, not prescriptive](./docs/principles/05-descriptive-profiles.md)

**Meta-principles (design of the harness; not hook-gated):**

6. [Progressive disclosure](./docs/principles/06-progressive-disclosure.md)
7. [Context economy](./docs/principles/07-context-economy.md)
8. [Gates over guidance](./docs/principles/08-gates-over-guidance.md)

## Tagged-exception prefixes

The pre-commit gate reads the commit message first. These prefixes skip specific rules — replacing `--no-verify` with named, auditable overrides:

| Prefix | Skips | Use case |
|---|---|---|
| `[release]` | Rule 4 (templates) | Explicit template rebuilds |
| `[infra]` | Rule 3 (Spec-before-Ship) | CI, hooks, dependency bumps, harness-level work |
| `[docs]` | Rule 3 (Spec-before-Ship) | Doc-only commits |
| `[bulk]` | >50-file runaway guard | Genuine bulk updates |

Rules 1 and 5 are never skippable. Every skip is recorded in the git log.

## Quick reference — the three beats

1. **Spec** → `/spec <idea|epic|feature|fix|chore> <slug>` → research brief + PRD + technical-spec under `docs/specs/`, GitHub issue, branch
2. **Ship** → `/ship` → idempotent PR loop: implement → CI → preview smoke-test → squash-merge → verify
3. **Signal** → `/signal <init|sync|audit|status>` → scheduled tasks, post-merge sync, periodic self-review, learnings log

For the long-form version, read `docs/guides/` end-to-end.

## Adopting v4 into an existing repo

`/beat install` ports the blueprint into an existing codebase without touching source code:

- Dry-runs first, reports what it will create/merge/skip
- Copies `.claude/` bundle, merges existing `CLAUDE.md` via a fenced `<!-- agentic-blueprint:begin/end -->` block
- Creates `docs/` scaffolding and copies the 9 v4 templates
- Installs the GitHub Actions hard-rules wrapper (or prints porting notes for other CI)
- Writes `claude-config/VERSION` (semver) for future `/beat update` runs

See [beat.md](./.claude/commands/beat.md) for the full install/update flow.
