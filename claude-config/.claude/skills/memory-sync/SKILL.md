---
name: memory-sync
description: Use after a PR merges or a feature ships, to sync docs/research/, spec status, plan files, and CHANGELOG. Wraps claude-config/scripts/update-plan-status.sh and validates cross-references. Keywords — memory sync, docs sync, post-merge, plan status, update specs, close loop, Stage 5 Run.
allowed-tools: Read, Edit, Bash, Glob
model: sonnet
---

# Memory sync

After a merge, the plan files, specs, research indices, and CHANGELOG can drift. This skill closes the loop.

## When to reach for this skill

- After a PR merges to `main`
- During `/run memory-sync`
- When the `docs-inspector` subagent flags drift
- Asked anything about "post-merge", "close the loop", "sync docs", "plan status"

## How to use it

1. **Run the sync script:**

   ```bash
   bash .claude/skills/memory-sync/scripts/sync.sh
   ```

   It wraps `claude-config/scripts/update-plan-status.sh` and:
   - Updates plan-file status markers (`in_progress` → `shipped`) based on merged PRs
   - Moves stale research briefs into `docs/research/_archive/` if they're older than the policy
   - Prints a short summary of what changed
2. **Read `references/sync-rules.md`** only if the script's output lists an item you don't recognise. The rules doc explains each sync decision.
3. **Review the diff.** The script writes changes to disk; git status will show what moved.
4. **Commit the sync** on `main` with a `chore:` commit. This is one of the few exceptions where a chore can touch many files.

## Policy summary (source of truth is `references/sync-rules.md`)

- Plan files stay on disk forever; status markers change over time
- Research briefs stay in `docs/research/` while their feature is active; move to `_archive/` after 180 days of no references
- CHANGELOG entries don't move — they immortalise the moment
- Spec status updated via frontmatter `status:` field

## Do NOT

- Delete plan files or briefs — move to `_archive/` if needed
- Rewrite old CHANGELOG entries
- Run this on a feature branch — only on `main` after a merge
