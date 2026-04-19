---
description: Orchestrate a new feature end-to-end — create issue/branch, then walk Stages 1 → 2.
argument-hint: <feature title in quotes>
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# /new-feature — Orchestrate a New Feature

One-shot entry point for a fresh feature. Creates the GitHub issue, branches from `main`, and walks the first two stages (Research → Plan). Stops before Build for human approval.

## Arguments

- `$ARGUMENTS` — the feature title (used for the issue title and slug).

## Steps

1. **Validate.** Current branch must be `main` with a clean tree. If not, abort and tell the user why.
2. **Slug the title** for branch and filenames. Example: `"User Profile Editing"` → `user-profile-editing`.
3. **Create the issue** via GitHub MCP (`mcp__github__issue_write`). Choose `type:feat` and any appropriate `scope:*` labels. Capture the returned issue number.
4. **Create the branch** (`feat/<issue-number>-<slug>`) via GitHub MCP (`mcp__github__create_branch`) and switch locally.
5. **Run `/research <slug>`** (invoke the workflow, don't re-type it). Wait for it to complete.
6. **Run `/plan <slug>`** once the brief is in place.
7. **Stop.** Tell the user: "Feature scaffolded through Stage 2. Review the plan, then run `/build` to continue."

## What this command does NOT do

- Write code
- Merge anything
- Skip the research or plan stages
