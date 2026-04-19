---
description: Start Stage 3 — Build. Implements the approved plan while enforcing Hard Rules and starter clean-boot.
argument-hint: <optional sub-task>
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# /build — Stage 3: Build

You are entering **Stage 3** of the five-stage lifecycle. The goal is to implement the plan that was approved in Stage 2.

## Preconditions

- An approved plan exists at `docs/plans/<slug>.md`.
- Corresponding specs exist under `docs/specs/<slug>/`.
- You are on a feature branch (`<type>/<issue-number>-<slug>`).

## Steps

1. **Find the plan.** If `$ARGUMENTS` is provided, use it as the slug. Otherwise look at the current branch name and infer the slug. If no plan exists, abort and tell the user to run `/plan <slug>` first.
2. **Read the plan and the specs** — use Read on each file. Do not skip this step.
3. **Implement one discrete step at a time.** Follow the sequence in the plan. After each step:
   - Run the relevant starter `/check` command (if a starter was touched)
   - Update the plan's status markers so the work is resumable
4. **Reach for the `hard-rules-check` skill** before writing code that touches starters, env config, or `docs/templates/`. The skill runs `scripts/check-all.sh` against the 9 Hard Rules.
5. **Delegate verification to the `starter-verifier` subagent** when a starter's clean boot needs checking — this protects the main context from noisy build output.
6. **When the plan is fully executed**, suggest the next step — `/ship` to prepare for merge.

## What this command does NOT do

- Skip checks to go faster
- Edit templates in `docs/templates/` (blocked by `template-guard` hook)
- Create a PR — that's `/ship`
