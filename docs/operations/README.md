# docs/operations/

Runbooks for Stage 5 (Run) — the ongoing operational work that happens
*after* a feature ships. Principles live in `docs/principles/`; this
directory holds the step-by-step "how we respond when X".

## Contents

- [`incident-response.md`](./incident-response.md) — triage playbook for
  production incidents: on-call flow, postmortem template pointers,
  comms templates.

## When to read what

| Situation | Start here |
|---|---|
| Production alert fires | `incident-response.md` |
| Post-merge doc drift | `.claude/skills/memory-sync/SKILL.md` |
| Docs cross-references broken | Run `/run health-check` (docs-inspector subagent) |
| Retrospective on a shipped feature | `docs/templates/retrospective.md` (when available) |

## The relationship to Stage 5

The `/run` slash command is the entry point for all Stage 5 work. It
dispatches to the right skill or subagent based on the task name:

- `/run memory-sync` → `memory-sync` skill.
- `/run health-check` → `docs-inspector` subagent.
- `/run incident <slug>` → this directory's `incident-response.md`.

When a new operational pattern stabilises, write it up here and link
it from `/run`. Runbooks live in operations; the triggers live in
`.claude/commands/run.md`.
