---
scope: fix
status: Draft
---

# Fix — v5.0.4 install-time polish (skills frontmatter, install.sh nesting, Rule 4 amend)

## Problem

Three bugs surfaced after v5.0.3 cleanly installed in an adopter repo. All three are adopter-visible and blocked clean workflow:

1. **Skills still have comma-separated `allowed-tools`.** v5.0.3 fixed the command files (`/spec`, `/ship`, etc.) but left the 3 skills (`australian-spelling`, `hard-rules-check`, `signal-sync`) in the broken format — Claude Code reads the string literally, and the tool allow-list is effectively empty. Skills are still "tolerated" (they load) but the allow-list is wrong.
2. **`install.sh` `cp -R` nesting on re-runs.** When `.claude/commands/` already exists, `cp -R src dest` creates `dest/commands/commands/*` instead of replacing. Showed up during `--force` re-install: adopter saw `commands/beat/beat`-shaped duplicates.
3. **Rule 4 gate doesn't honour `PENDING_COMMIT_SUBJECT` on `git commit --amend`.** #116 fixed Rule 3 for first-commit-with-tagged-prefix, but Rule 4 walks committed history directly (`git log -1 --format=%s $sha`) for each commit — the amended commit's NEW subject is invisible because the amend hasn't landed yet. Blocks `git commit --amend -m "[release] ..."` from inside Claude Code.

## Fix

### 1. Skills `allowed-tools` comma → space

Six files (3 skills × 2 locations: live + bundle mirror). Mechanical sed replacement, same pattern as #128.

### 2. `install.sh` nesting fix

Rewrite the backup + copy section so each target directory is `rm -rf`'d before `cp -R`. Applies to both the fresh backup location (`_pre-install-backup/`) and each live subdirectory (`commands/`, `agents/`, `skills/`, `hooks/`). Idempotent across repeated runs and `--force` re-installs.

### 3. Rule 4 pending-subject awareness for amend

Two-part fix mirroring how #116 handled Rule 3:

- **`.claude/hooks/pre-commit-gate.sh`** — detect `--amend` in the git command and export `PENDING_AMEND=1` alongside `PENDING_COMMIT_SUBJECT`.
- **`.claude/skills/hard-rules-check/scripts/check-all.sh`** Rule 4 — when iterating commits, if the commit is HEAD and `PENDING_AMEND=1` and `PENDING_COMMIT_SUBJECT` is set, treat the subject as the pending one (what the amend will rewrite to) instead of the still-on-disk value.

This keeps `--no-verify` un-needed and preserves the named-exception audit trail.

## Changes

| Path | Change |
|---|---|
| `.claude/skills/australian-spelling/SKILL.md` | `Read, Edit, Bash` → `Read Edit Bash` |
| `.claude/skills/hard-rules-check/SKILL.md` | `Read, Grep, Glob, Bash` → `Read Grep Glob Bash` |
| `.claude/skills/signal-sync/SKILL.md` | `Read, Edit, Bash, Glob, Grep` → `Read Edit Bash Glob Grep` |
| `claude-config/.claude/skills/*/SKILL.md` | Bundle mirrors — same 3 fixes |
| `claude-config/scripts/install.sh` | `rm -rf` before each `cp -R` for backup + live subdirs; idempotent across re-runs |
| `.claude/hooks/pre-commit-gate.sh` | Detect `--amend`, export `PENDING_AMEND` |
| `.claude/skills/hard-rules-check/scripts/check-all.sh` | Rule 4 honours `PENDING_AMEND` + `PENDING_COMMIT_SUBJECT` on the HEAD commit |
| `claude-config/.claude/hooks/pre-commit-gate.sh` | Bundle mirror |
| `claude-config/.claude/skills/hard-rules-check/scripts/check-all.sh` | Bundle mirror |
| `claude-config/VERSION` | `5.0.3` → `5.0.4` |
| `CHANGELOG.md` | `[5.0.4]` entry |

## Regression tests

- **Skills frontmatter:** `grep "allowed-tools: Read,"` returns zero hits after fix
- **Nesting:** install into a scratch repo that already has `.claude/commands/custom.md`, with `--force`; verify resulting `.claude/commands/` has blueprint commands (no nested `commands/commands/`)
- **Amend gate:** on a branch with a sacred-path-touching commit whose subject lacks `[release]`, run `git commit --amend -m "[release] ..."` through the hook — expect pass (pre-fix: fail)

Verified in-session for (1) via grep and (2) via `--force --dry-run` into `/tmp/test-install2`. (3) verified by code review; full end-to-end amend test is post-merge since the hook under test is what the adopter environment runs.

## Acceptance criteria

- [x] All 6 skill files use space-separated `allowed-tools`
- [x] `install.sh` no longer nests on re-run
- [x] Hook + gate know about `--amend`
- [x] `VERSION` reads `5.0.4`
- [x] Hard Rules CI passes

## Out of scope

- **Subagents (`.claude/agents/*.md`)** still use comma-separated `tools:`. Same "different parser, no symptom yet" rationale as #128. Revisit if/when adopter use surfaces a break.
- **CI install smoke-test.** Would have caught #126/#127/#128/this PR at merge time. Worth a v5.1 epic but premature without a second pilot.

## References

- Bug report from real adopter install of v5.0.3 (Sentinel OS)
- Prior PRs: #116 (Rule 3 pending-subject), #127 (v5.0.2 install.sh paths), #128 (v5.0.3 commands frontmatter)
