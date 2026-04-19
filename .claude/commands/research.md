---
description: Start Stage 1 — Research & Think. Runs web and codebase research in an isolated subagent and drops a research brief in docs/research/.
argument-hint: <topic or feature name>
allowed-tools: Bash, Read, Write, Glob, Grep
---

# /research — Stage 1: Research & Think

You are entering **Stage 1** of the five-stage lifecycle. The goal is to produce a research brief under `docs/research/` before any planning begins.

## Arguments

- `$ARGUMENTS` — the topic or feature to research (e.g. `user-onboarding`, `rate-limiting-strategies`).

## Steps

1. **Confirm scope.** Restate the topic and the question(s) the brief must answer. If `$ARGUMENTS` is empty, ask the user what to research.
2. **Spawn the `researcher` subagent** to do the actual work in isolation. Pass it:
   - The topic and scope you confirmed in step 1
   - The target output path: `docs/research/<slug>-brief.md` (slug the topic)
   - A pointer to `docs/templates/research-brief.md` for the format
3. **Wait for the subagent** to return. Its result is a filled-in research brief on disk.
4. **Summarise the brief for the user** in 3–5 bullets — surface the recommendation, the main risks, and any open questions. Do NOT paste the full brief back into the conversation (context economy).
5. **Suggest the next step** — typically `/plan <slug>` once the brief is agreed.

## What this command does NOT do

- Write specs (that's Stage 2 / `/plan`)
- Write code (that's Stage 3 / `/build`)
- Skip the template — the brief must use the `docs/templates/research-brief.md` structure
