---
description: Start Stage 4 — Ship. Verifies starters, updates CHANGELOG, and prepares the PR.
argument-hint: <optional PR title>
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# /ship — Stage 4: Ship

You are entering **Stage 4** of the five-stage lifecycle. The goal is to get the approved, built work ready for merge.

## Preconditions

- Build is complete and the plan is fully executed.
- Working tree is clean or has only intended changes staged.

## Steps

1. **Run `hard-rules-check` skill** — all 9 rules must pass. Block on any failure.
2. **Delegate to `starter-verifier` subagent** to run clean-boot on every starter that was touched. Smoke-test output stays in the subagent's context, not yours.
3. **Reach for the `changelog-entry` skill** to append an `Unreleased` entry to `CHANGELOG.md`. The skill wraps the keepachangelog format.
4. **Delegate to `docs-inspector` subagent** for a cross-reference audit — no broken links, no stale TODOs, specs and docs in sync.
5. **Create the PR** via the GitHub MCP server (`mcp__github__create_pull_request`). Title: what was shipped, in one line. Body: links to the plan, specs, and research brief.
6. **Do NOT auto-merge.** Let the human review.
7. **Suggest the next step** — once merged, run `/run memory-sync` to close the loop.

## What this command does NOT do

- Force-push, amend published commits, or skip hooks
- Deploy to production — that's the human operator's decision post-merge
- Merge the PR
