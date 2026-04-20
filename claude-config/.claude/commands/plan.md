---
description: Start Stage 2 — Plan. Drafts specs from docs/templates/, then runs a second-opinion review.
argument-hint: <feature slug>
allowed-tools: Bash, Read, Write, Glob, Grep, Edit
---

# /plan — Stage 2: Plan

You are entering **Stage 2** of the five-stage lifecycle. The goal is to produce one or more spec documents before any code is written (Hard Rule #5 — spec-driven; Hard Rule #6 — plan-before-code).

## Arguments

- `$ARGUMENTS` — the feature slug (matches the research brief filename).

## Preconditions

- A research brief exists at `docs/research/<slug>-brief.md` (or user has said a brief isn't needed for this small change).
- You are on a feature branch, not `main`.
- **Branch prefix matches hook-guarded target directories.** If the feature will edit `docs/templates/` then the branch must start with `docs/` or `templates/` — see `.claude/hooks/template-guard.sh`. Check now, not in Stage 3; renaming the branch mid-build is avoidable rework.

## Steps

1. **Check preconditions.** If the brief is missing, prompt the user: run `/research <slug>` first or confirm they want to skip.
2. **Determine which specs this feature needs.** Default set — PRD, technical-spec. Add api-spec, data-model-spec, auth-spec, architecture only if the feature touches those surfaces. Reference `docs/templates/README.md` for the full catalogue.
3. **Spawn the `spec-writer` subagent once per spec.** Do not bundle multiple specs into a single invocation — a long single-stream run can hit an API idle timeout and leave the specs dir half-populated. Independent specs can be spawned in parallel. Pass each invocation:
   - The feature slug
   - The single spec to produce on this run
   - A pointer to the research brief
   - The output path under `docs/specs/<slug>/`
4. **Wait for spec-writer**, then **spawn the `spec-reviewer` subagent** to review those specs against the Hard Rules and prose discipline. Spawn in a fresh subagent so review is independent.
5. **Relay both outputs** to the user: a short summary of the specs drafted, plus the reviewer's findings. Ask the user to approve or iterate.
6. **Once approved**, write a plan file at `docs/plans/<slug>.md` linking the specs and describing the implementation sequence. **Every plan file MUST carry a status line with an HTML-comment marker**, e.g. `**Status:** Approved — ready for /build <!-- status: pending -->`. The marker is what `claude-config/scripts/update-plan-status.sh` flips to `shipped (#<PR>)` during Stage 5 memory-sync — omitting it silently breaks post-merge sync.
7. **Suggest the next step** — `/build` once the plan is approved.

## What this command does NOT do

- Write code
- Modify templates in `docs/templates/` (Hard Rule #7 — sacred)
- Skip the reviewer pass
