# Fix Workflow

Step-by-step guide for fixing a bug: from changelog entry through to production deployment.

**Primary surface:** Claude Code (Terminal)
**Related:** `feature-workflow.md` (same process, different trigger), `release-workflow.md` (promotion)

---

## Prerequisites

- A reported bug (support ticket, failing test, or self-discovered)
- CLAUDE.md is up to date
- Local `master` and `staging` branches are current

---

## Step-by-Step

### 1. Document the Bug

**Surface:** Claude Code (Terminal)

Start by recording what's broken. Update the changelog first — this forces you to describe the bug clearly:

```
> Add a [Fixed] entry to CHANGELOG.md under [Unreleased]:
> "Fixed [brief description of the bug]"
```

### 2. Create the GitHub Issue

**Surface:** Claude Code (Terminal)

```
> Create a GitHub issue for this bug. Title: "fix: [brief description]".
> Include: steps to reproduce, expected behaviour, actual behaviour,
> and any error messages or logs. Label it as "bug".
```

Include as much context as possible. The issue becomes Claude's reference when fixing the bug.

### 3. Create the Fix Branch

**Surface:** Claude Code (Terminal)

```
> Pull master and staging. Create a branch from master called fix/[description].
```

### 4. Diagnose the Root Cause

**Surface:** Claude Code (Terminal)

Don't jump to a fix. Understand why it's broken first:

```
> Read issue #[number]. Investigate the root cause.
> Check [relevant files/endpoints/tests]. Explain what's going wrong before proposing a fix.
```

Review Claude's diagnosis. Check:

- [ ] Root cause is identified, not just the symptom
- [ ] The failure path is understood
- [ ] No assumptions about the fix yet

### 5. Plan the Fix

**Surface:** Claude Code (Terminal)

```
> Plan the fix. Show me what you'll change and why. Don't write code yet.
```

Review the plan:

- [ ] Fix addresses the root cause, not just the symptom
- [ ] Minimal change — no "while I'm here" improvements
- [ ] Includes a test that would have caught this bug
- [ ] No unrelated changes

### 6. Implement the Fix

**Surface:** Claude Code (Terminal)

```
> Execute the fix plan.
```

Review each change. A good bug fix should be small and focused.

### 7. Write a Regression Test

**Surface:** Claude Code (Terminal)

Every bug fix must include a test that reproduces the original bug:

```
> Write a test that reproduces the bug (should fail without the fix, pass with it).
> Follow the patterns in src/test/.
```

### 8. Run the Check Suite

**Surface:** Claude Code (Terminal)

```
> Run pnpm type-check && pnpm lint && pnpm test:ci
```

All checks must pass. The new regression test must be included.

### 9. Commit and PR

**Surface:** Claude Code (Terminal)

```
> Commit with message "fix: [description] (#[issue-number])".
> Push and create a PR to staging. Link to issue #[number].
```

### 10. Merge, Test, Promote

Follow the same flow as a feature:

1. Wait for CI to pass
2. Merge to staging
3. Smoke test the fix on staging
4. Promote to production via `release-workflow.md`

---

## Hotfix Process

For critical production bugs that can't wait for the normal flow:

### 1. Branch from master (not staging)

```
> Create a branch from master called hotfix/[description].
```

### 2. Fix, test, commit (same as above but faster)

Skip the planning step if the fix is obvious. Still write a regression test.

### 3. PR directly to master

```
> Create a PR from this branch directly to master. Mark as urgent.
```

### 4. After merging to master, backport to staging

```
> Cherry-pick the fix commit onto staging to keep branches in sync.
```

---

## Checklist

- [ ] Bug documented in CHANGELOG.md
- [ ] GitHub issue created with reproduction steps
- [ ] Fix branch created from master
- [ ] Root cause diagnosed (not just symptom)
- [ ] Fix plan reviewed
- [ ] Fix implemented (minimal, focused change)
- [ ] Regression test written
- [ ] All checks pass
- [ ] PR created to staging with issue link
- [ ] CI passes
- [ ] Merged to staging
- [ ] Staging smoke test confirms fix
- [ ] Promoted to production

---

*See `docs/guides/release-workflow.md` for staging → production promotion.*
*See `docs/guides/agentic-workflow.md` for the full lifecycle reference.*
