---
description: Ship — build + test + deploy as one idempotent PR-driven loop with automated gates.
argument-hint: [--resume]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# /ship — Ship beat (v4)

The **Ship** beat collapses the v3 Build + Ship stages. One continuous loop from spec-approved branch to merged-and-verified PR.

Rerunning `/ship` on the same branch is **idempotent**: it detects current state (PR open? CI status? deploy done?) and resumes from there. No `--resume` flag needed in most cases; flag is available for explicit continuation after an interruption.

## Preconditions

- On a feature / fix / chore branch (not `main`, not `master`)
- Spec exists at `docs/specs/<slug>.md` (folder or flat file) — unless `[infra]`/`[docs]` commit prefix is used or branch is `chore/*`
- All 5 Hard Rules currently pass (`bash .claude/skills/hard-rules-check/scripts/check-all.sh`)

## Steps

1. **Status check.** Read git state — branch, uncommitted changes, PR open?, last CI run. Classify current position in the Ship loop.
2. **Implementation plan.** Read `docs/specs/<slug>.md` (and parent spec if linked via `parent:` frontmatter). Produce a one-page implementation sequence. Present to user for approval.
3. **Execute.** Write code, run tests as you go. Commit in logical chunks with conventional-commit subjects (prefix per tagged-exception table if applicable).
4. **Gate.** Run `bash .claude/skills/hard-rules-check/scripts/check-all.sh` locally. All 5 rules must pass.
5. **Starter check (if touched).** Invoke the `starter-verify` skill — runs the starter smoke-test in isolation so noisy output stays out of this conversation.
6. **Changelog.** If the change is user-visible, invoke the `signal-sync` skill (its changelog sub-command) to append an `[Unreleased]` entry. Skip for `[infra]`/`[docs]`/`chore/*` work that has no user-facing effect.
7. **Open PR.** Push branch, open PR via GitHub MCP, link to issue + parent spec. Wait for CI.
8. **Preview smoke-test.** When Vercel/platform posts the preview URL, curl the health endpoint and the one or two critical paths the spec named.
9. **Squash-merge on green.** Confirm with user before merging, unless the project has configured auto-merge.
10. **Post-merge verification.** Watch the production auto-deploy, re-curl the health endpoint. Hand off to `/signal sync` for CHANGELOG close-out + docs sweep.

## Rerun semantics

Common resume points:
- Branch exists, no commits → resume at step 3 (Execute).
- Commits on branch, no PR → resume at step 7 (Open PR).
- PR open, CI green, not merged → resume at step 9 (Squash-merge).
- PR merged, no post-merge verification yet → resume at step 10.

`/ship` prints its detected state at the top of each run so the user sees where it's picking up.

## What this command does NOT do

- Write specs (that's `/spec`)
- Run post-merge scheduled tasks (that's `/signal init` / `/signal sync`)
- Touch templates (Rule 4) — if the work needs template changes, those land in a separate `[release]` commit under `/spec idea` or a dedicated rebuild flow

## Gates honoured

All 5 v4 Hard Rules fire locally and via the `.github/workflows/hard-rules.yml` CI workflow. Tagged-exception prefixes (`[release]`, `[infra]`, `[docs]`, `[bulk]`) are honoured on both sides.
