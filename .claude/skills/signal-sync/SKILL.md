---
name: signal-sync
description: Use during the Signal beat (/signal sync, /signal audit) to close the loop after a merge — plan-status markers, CHANGELOG append/validate, cross-reference audit, stale-brief archival. Merged v3 memory-sync + changelog-entry + docs-inspector logic into one skill. Keywords — Signal beat, post-merge, changelog, memory sync, docs sync, cross-reference audit, close the loop.
allowed-tools: Read Edit Bash Glob Grep
model: sonnet
---

# Signal sync

The Signal beat's post-merge housekeeping. Updates plan status, appends / validates CHANGELOG entries, audits cross-references, archives stale briefs. Replaces v3's three overlapping pieces (`memory-sync` skill, `changelog-entry` skill, `docs-inspector` agent).

## When to reach for this skill

- During `/signal sync` after a PR merges to `main`
- During `/signal audit` for the periodic self-review
- Asked anything about "close the loop", "sync docs", "append changelog entry", "cross-reference check", "stale briefs"

## Sub-commands

### `bash .claude/skills/signal-sync/scripts/sync.sh`

Post-merge housekeeping. Idempotent.
- Runs `claude-config/scripts/update-plan-status.sh` if present.
- Archives research briefs older than 180 days with no recent inbound references → `docs/research/_archive/`.
- Validates every plan file references its specs folder or file.

### `bash .claude/skills/signal-sync/scripts/append-changelog.sh --category <Added|Changed|Deprecated|Removed|Fixed|Security> --message "<sentence>" --pr <n>`

Appends a keepachangelog entry under `## [Unreleased]`. Creates the category subheader if missing. Australian spelling enforced via `pre-write-spelling` hook.

### `bash .claude/skills/signal-sync/scripts/audit.sh`

Cross-reference audit. Reports:
- Broken internal markdown links
- Stale `TODO:` markers (older than 30 days by git blame)
- CHANGELOG `[Unreleased]` entries with no matching PR
- Plan files that don't reference their specs
- Specs with `status:` other than `shipped` whose code has drifted from the spec (for `/signal audit`)

Outputs a punch-list to stdout; writes a transient report to `docs/signal/audit-$(date +%F).md`.

## Entry conventions (for append-changelog)

- One line per entry. Start with a verb in past tense.
- Always include the PR number in parentheses at the end: `… (#123)`.
- Australian spelling — `pre-write-spelling` hook blocks US variants.

## Do NOT

- Delete plan files or briefs — move to `_archive/` if needed.
- Rewrite past released CHANGELOG sections (immutable history).
- Run `sync.sh` on a feature branch — only on `main` after a merge.
- Open a release cut from this skill — that's a human operation.
