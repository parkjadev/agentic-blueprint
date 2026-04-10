# Post-Merge Hook Patterns

Automation patterns that fire after a PR is merged. Different from `post-deploy.md` (which runs after a successful deployment) — these hooks fire on `git pull` after the merge has landed in `main` locally.

---

## Overview

Post-merge automation keeps secondary state (plan files, project boards, status dashboards) in sync with what's actually shipped. The most useful pattern is updating plan-file status markers so the team can see at a glance which phases of a multi-PR feature have landed.

---

## Pattern 1: Update Plan Status Markers

Plan files (`docs/specs/<feature>/plan.md`) carry inline status markers that this hook updates whenever a PR closes a numbered phase.

### Convention

Every phase heading in a plan file ends with a status marker in HTML comment form:

```markdown
## Phase 1: Schema and types <!-- status: pending -->
## Phase 2: API routes <!-- status: pending -->
## Phase 3: UI <!-- status: pending -->
```

When a PR lands that completes a phase, the marker becomes:

```markdown
## Phase 2: API routes <!-- status: shipped (#42) -->
```

### As a Claude Code Hook

The hook fires whenever Claude Code observes a successful `git merge` or `gh pr merge`. It looks at the merged PR's title and body for a `Phase N` reference and the PR number, then runs:

```json
{
  "hooks": {
    "post-merge": [
      {
        "command": "claude-config/scripts/update-plan-status.sh \"$PLAN_FILE\" \"$PHASE_LABEL\" \"$PR_NUMBER\"",
        "description": "Mark a plan phase as shipped after its PR lands",
        "blocking": false
      }
    ]
  }
}
```

The hook needs three env vars set by the wrapper:

- `PLAN_FILE` — path to the plan file (e.g. `docs/specs/user-profile/plan.md`)
- `PHASE_LABEL` — the phase string to match (e.g. `Phase 2`)
- `PR_NUMBER` — the merged PR's number (just digits)

In practice the wrapper extracts these from the PR's metadata and the spec being implemented. Most teams configure the hook to be invoked manually from the plan-execution prompt:

```
> I just merged PR #42 which completed Phase 2 of the user-profile plan.
> Run claude-config/scripts/update-plan-status.sh on the plan file to mark
> Phase 2 as shipped, then commit the change as "docs: mark user-profile
> Phase 2 as shipped".
```

### As a Manual Check

After a PR lands:

```bash
./claude-config/scripts/update-plan-status.sh docs/specs/user-profile/plan.md "Phase 2" 42
```

Idempotent — re-running with the same args is a no-op (the marker already contains the PR number, so the script's regex won't match a second time).

---

## Pattern 2: Doc Sweep

After every merge to `main`, run the doc-sweep checklist from `agentic-workflow.md` Phase 10. This is documented as a manual step rather than an automated hook because most of the checks need a human eye (does the README headline still accurately describe what the project does?). The post-merge hook can prompt the operator with the checklist:

```json
{
  "hooks": {
    "post-merge": [
      {
        "command": "echo 'Run doc-sweep checklist? See agentic-workflow.md Phase 10.'",
        "description": "Prompt for doc sweep after merging to main",
        "blocking": false
      }
    ]
  }
}
```

---

## Tips

- **Keep post-merge hooks non-blocking.** A failing post-merge hook should never prevent the operator from continuing — the merge has already happened and the hook is bookkeeping. Always use `"blocking": false`.
- **Idempotency matters.** Hooks fire on every merge, including `git pull` that fast-forwards local `main`. Scripts they invoke must be safe to re-run.
- **Don't put validation in post-merge hooks.** Validation belongs in CI or in the PR template's Test plan checklist. Post-merge is for state synchronisation only.
