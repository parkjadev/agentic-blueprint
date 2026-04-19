---
description: Start Stage 5 — Run. Post-merge operations — sync memory, validate docs, handle incidents.
argument-hint: <task — e.g. memory-sync, health-check, incident>
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# /run — Stage 5: Run

You are entering **Stage 5** of the five-stage lifecycle. The goal is to keep the framework, docs, and operational state in sync after a merge or deployment.

## Arguments

- `$ARGUMENTS` — the operational task. Common values:
  - `memory-sync` — sync `docs/research/`, spec status, CHANGELOG, plan files after a merge
  - `health-check` — verify cross-references across docs; report broken links or stale TODOs
  - `incident <slug>` — start an incident postmortem using `docs/templates/` (if available)

## Steps

1. **Confirm the task.** If `$ARGUMENTS` is empty, list the common tasks and ask which one.
2. **For `memory-sync`:** reach for the `memory-sync` skill. It wraps `claude-config/scripts/update-plan-status.sh` and updates plan status, CHANGELOG, and research indices.
3. **For `health-check`:** delegate to the `docs-inspector` subagent. It audits cross-references and returns a punch-list.
4. **For `incident <slug>`:** confirm the slug, create `docs/incidents/<date>-<slug>.md` from template (or fall back to a stub), and walk the user through the triage.
5. **Summarise the result** to the user in one short paragraph plus a next-step suggestion.

## What this command does NOT do

- Write new feature code (that's `/build`)
- Touch specs (that's `/plan`)
- Rewrite history
