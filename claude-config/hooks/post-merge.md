# Post-Merge Hook Patterns

Automation patterns that fire after a PR is merged. Different from `post-deploy.md` (which runs after a successful deployment) — these hooks fire on `git pull` after the merge has landed in `main` locally.

---

## Overview

Post-merge automation closes the loop between a shipped PR and the Signal beat's bookkeeping artefacts — CHANGELOG entries, cross-reference audits, stale-brief archival. v5 centralises this work in the `signal-sync` skill, so most teams just wire a hook to invoke it.

---

## Pattern 1: Run `signal-sync` after every merge to `main`

The `signal-sync` skill handles the post-merge bookkeeping v4 used to scatter across ad-hoc scripts:

- Appends the merged PR to `CHANGELOG.md`'s `[Unreleased]` block (if user-visible)
- Updates any status markers the spec carries
- Cross-references the PR against the spec's acceptance criteria
- Flags stale briefs in `docs/research/` that no longer match shipped state

### As a Claude Code hook

Configure in `.claude/settings.local.json`:

```json
{
  "hooks": {
    "post-merge": [
      {
        "command": "bash .claude/skills/signal-sync/scripts/sync.sh",
        "description": "Run signal-sync after every merge to main",
        "blocking": false
      }
    ]
  }
}
```

### As a manual step

After merging a PR, from a Claude Code session on `main`:

```
/signal sync
```

Picks up the merge SHA automatically and runs the same flow.

---

## Pattern 2: Doc-sweep checklist prompt

Most doc-drift checks need a human eye (does the README headline still describe the project?). The post-merge hook can prompt the operator rather than running checks itself:

```json
{
  "hooks": {
    "post-merge": [
      {
        "command": "echo 'Doc-sweep checklist — see docs/guides/tool-reference.md.'",
        "description": "Nudge the operator through the post-merge doc sweep",
        "blocking": false
      }
    ]
  }
}
```

The canonical checklist lives in `docs/guides/tool-reference.md` under "Doc-sweep checklist (post-ship)".

---

## Tips

- **Keep post-merge hooks non-blocking.** A failing post-merge hook should never prevent the operator from continuing — the merge has already happened and the hook is bookkeeping. Always use `"blocking": false`.
- **Idempotency matters.** Hooks fire on every merge, including `git pull` that fast-forwards local `main`. Scripts they invoke must be safe to re-run.
- **Don't put validation in post-merge hooks.** Validation belongs in CI or the PR template's Test plan checklist. Post-merge is for state synchronisation only.
