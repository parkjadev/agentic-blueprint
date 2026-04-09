# Fix Workflow

Step-by-step guide for fixing a bug: from a GitHub issue through to a production deployment on `main`.

**Primary surface:** Claude Code (Terminal)
**Branching model:** GitHub Flow — same as `feature-workflow.md`. The only differences are the trigger (a bug, not a spec) and the discipline around root-cause analysis.

---

## Prerequisites

- A reported bug (support ticket, failing test, monitoring alert, or self-discovered)
- CLAUDE.md is up to date
- Local `main` is current (`git checkout main && git pull`)

---

## Step-by-Step

### 1. Create the GitHub Issue First

**Surface:** Claude Code (Terminal)

Hard rule: **issue before branch**. Even for a "quick fix", file the issue first — the issue number drives the branch name and the commit footer, and gives Claude a stable place to read context from.

```
> Create a GitHub issue using the Bug template.
> Title: "fix: [brief description]".
> Include: steps to reproduce, expected behaviour, actual behaviour,
> environment, and any error messages or logs.
> Apply labels: type:fix, scope:[area].
```

### 2. Document the Bug in CHANGELOG

**Surface:** Claude Code (Terminal)

Add a `[Fixed]` entry under `[Unreleased]` so you don't forget:

```
> Add a [Fixed] entry to CHANGELOG.md under [Unreleased]:
> "Fixed [brief description] (#N)"
```

### 3. Create the Fix Branch

**Surface:** Claude Code (Terminal)

Branch from the latest `main` using the `<type>/<issue-number>-<slug>` convention:

```
> Pull main. Create a branch called fix/57-rate-limiter-window from main.
```

### 4. Diagnose the Root Cause

**Surface:** Claude Code (Terminal)

Don't jump to a fix. Understand why it's broken first:

```
> Read issue #57. Investigate the root cause.
> Check [relevant files/endpoints/tests]. Explain what's going wrong before proposing a fix.
```

Review Claude's diagnosis:

- [ ] Root cause identified, not just the symptom
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

A good bug fix should be small and focused.

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

### 9. Commit, Push, PR

**Surface:** Claude Code (Terminal)

```
> Commit with message "fix: [description]" and footer "Refs: #57".
> Push and open a PR to main using the pull request template.
> Title: "fix: [description]". Body should include "Closes #57".
```

### 10. CI, Preview, Smoke Test, Merge

Same as `feature-workflow.md`:

1. Wait for GitHub Actions to pass
2. Vercel posts a preview URL on the PR
3. Reproduce the original bug against the preview — confirm the fix works in a real environment
4. Squash-merge to `main` (production auto-deploys)
5. Verify production `/api/health` and the previously-broken endpoint
6. Close the issue, delete the branch, pull `main`

---

## Hotfixes

There is no separate "hotfix" branch in GitHub Flow. A hotfix is just a bug fix that you ship faster:

1. **Same flow** — issue, branch from `main`, fix, test, PR, preview, merge.
2. **Skip the planning ceremony** if the fix is one or two lines and obvious. Still write the regression test.
3. **Mark the PR as urgent** in the title (e.g. `fix(urgent): rate limiter resets…`) and ping reviewers.
4. **Verify production aggressively** after merge — health check, the previously-broken path, and Vercel runtime logs.

You do **not** need to "backport" anything because there is no second long-lived branch to backport to. This is the main reason GitHub Flow is simpler than the old two-tier model: one branch, one source of truth, no cherry-pick gymnastics.

---

## Checklist

- [ ] GitHub issue created with reproduction steps and labels
- [ ] CHANGELOG entry added under `[Unreleased]`
- [ ] Branch created from `main` using `fix/<N>-<slug>`
- [ ] Root cause diagnosed (not just symptom)
- [ ] Fix plan reviewed
- [ ] Fix implemented (minimal, focused change)
- [ ] Regression test written
- [ ] All checks pass
- [ ] PR opened to `main` with `Closes #N`
- [ ] CI green
- [ ] Preview reproduces and resolves the bug
- [ ] Squash-merged to `main`
- [ ] Production verified
- [ ] Issue closed, branch deleted

---

*See `docs/guides/feature-workflow.md` for the canonical GitHub Flow guide.*
*See `docs/guides/agentic-workflow.md` for the full lifecycle reference.*
