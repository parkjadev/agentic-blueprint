# Stage 3: Build

> Turn approved specs into working code through disciplined, plan-before-code execution.

---

## Why this stage exists

Every AI coding tool can write code. Cursor, Replit Agent, GitHub Copilot, Claude Code — they all generate functions, wire up routes, and scaffold components. Code generation is a commodity. The hard part was never typing; it was knowing *what* to type and *why*.

The Blueprint's value in Stage 3 is the **discipline layer**: CLAUDE.md for persistent project context, plan-before-code to catch mistakes before they ship, and spec-driven development to keep every session anchored to a reviewed design. Without the specs you produced in Stage 2, every tool produces confident, untested code that drifts from the actual requirement. You end up with a working demo that doesn't match the product you designed.

This is the densest stage in the lifecycle. It absorbs both feature development and bug-fix workflows into a single, consistent flow built on GitHub Flow: one long-lived branch (`main`), short-lived branches per issue, and a Vercel preview deploy per PR. There is no `staging` branch — see "Why GitHub Flow" below for the rationale.

---

## What you need

| Role | Recommended | Alternatives |
|---|---|---|
| **Agentic Coder** | Claude Code (Terminal + VS Code) | Cursor Agent, Replit Agent, GitHub Copilot |

The agentic coder reads your specs, plans the implementation, writes code, and runs the check suite — all within a single session you supervise and approve.

---

## Why GitHub Flow (and not a staging branch)

Every GitHub merge button rewrites SHAs in some form:

- **Squash merge** creates one new commit on the target branch with a new SHA.
- **Rebase and merge** rewrites every commit's SHA (it is *not* a true fast-forward).
- **Create a merge commit** creates a merge node with its own SHA.

The only true fast-forward is `git push --ff-only` from the CLI, which the GitHub UI cannot perform. Any flow that runs two long-lived branches and uses the GitHub UI to promote between them will diverge on every release, regardless of which merge button you click. The two branches become phantom-conflict generators, and you spend more time reconciling them than shipping.

The fix is structural: **don't run two long-lived branches.** With one branch (`main`), SHA-rewriting is harmless because there is no second branch to keep in sync.

```
issue #N
  └─ branch: feat/N-short-slug (from main)
       └─ PR → main  ──▶ Vercel preview deploy
            └─ smoke-test the preview
                 └─ squash-merge to main ──▶ production auto-deploys
                      └─ delete branch, close issue
```

> **Hard rule — never resurrect a `staging` branch.** If someone creates one "just for QA", delete it. Use a Vercel preview alias or a protected preview URL instead.

---

## How it works — Features

Every feature follows the same disciplined sequence. The issue number drives the branch name and commit footer, so it must exist before anything else.

### 1. Confirm the issue exists

**Hard rule: issue before branch.** If no GitHub issue exists for this work, create one first using the Feature template. Apply labels: `type:feature`, `scope:[area]`.

### 2. Create a branch from main

Pull the latest `main` and branch using the convention `<type>/<issue-number>-<slug>`:

```
git checkout main && git pull
git checkout -b feat/42-user-profile main
```

Branch types: `feat/`, `fix/`, `chore/`, `docs/`. The number must match the GitHub issue.

### 3. Plan the implementation

This is the critical step. Ask your agentic coder to read the specs and plan *before* writing any code:

```
> Read the specs in docs/specs/[feature-name]/ and issue #42.
> Plan the implementation. Show me the step-by-step plan before writing any code.
```

Review the plan against the spec:

- Build order matches dependencies (schema → API → auth → jobs → UI)
- No scope creep beyond the spec or the issue
- Testing approach is included
- No unnecessary abstractions or "improvements"

If the plan looks right, approve it. If not, request changes.

### 4. Execute the plan

The agentic coder proposes changes one at a time. Review each diff, approve or adjust, then move on. For long-running builds, use Remote Control from the Claude mobile app to monitor and approve actions while away from your desk.

### 5. Run the check suite

```
pnpm type-check && pnpm lint && pnpm test:ci
```

Do not proceed until all checks pass cleanly. If tests are missing, write them now — cover the happy path, validation errors, auth failures, and edge cases.

### 6. Commit with Conventional Commits

Use Conventional Commits and reference the issue in the footer:

```
feat(profile): add user profile page

Implements the profile view per the technical spec.

Refs: #42
```

### 7. Open a PR to main

Push the branch and open a PR using the pull request template. Title follows Conventional Commits. The body must include `Closes #42` to auto-close the issue on merge.

### 8. Wait for CI + preview deploy

Two things happen in parallel:

- **GitHub Actions** runs type-check, lint, and unit tests against the PR.
- **Vercel** (or your platform) builds a preview deployment and posts the URL on the PR.

If CI fails, diagnose and fix before proceeding.

### 9. Smoke-test the preview

Verify the feature on the preview URL — not on `main`. This is your "staging environment": a real, isolated, throwaway environment per PR. No persistent staging branch needed.

### 10. Squash-merge to main

**Always squash merge, never rebase merge.** Squash merge produces one clean commit on `main`. Since there is no second long-lived branch to keep in sync, SHA-rewriting causes no drift.

Vercel auto-deploys `main` to production on merge.

### 11. Verify production

Immediately after merge, hit the production health endpoint and the new feature endpoints. Confirm responses are healthy. If you have Vercel MCP connected, check deployment status, build logs, and runtime logs.

---

## How it works — Bug fixes

Bug fixes follow the same GitHub Flow, with three key additions: root-cause diagnosis, minimal scope, and a mandatory regression test.

### 1. Create the issue first

**Same hard rule: issue before branch.** Even for a "quick fix", file the issue first. Include: steps to reproduce, expected behaviour, actual behaviour, environment, and any error messages or logs. Apply labels: `type:fix`, `scope:[area]`.

### 2. Diagnose the root cause

Do not jump to a fix. Ask your agentic coder to investigate *why* it is broken before proposing a solution:

```
> Read issue #57. Investigate the root cause.
> Explain what's going wrong before proposing a fix.
```

Verify: root cause identified (not just the symptom), failure path understood, no premature assumptions about the fix.

### 3. Branch from main

```
git checkout -b fix/57-rate-limiter-window main
```

### 4. Plan the minimal fix

```
> Plan the fix. Show me what you'll change and why. Don't write code yet.
```

Review: fix addresses the root cause, minimal change with no "while I'm here" improvements, includes a test that would have caught this bug, no unrelated changes.

### 5. Implement the fix + write a regression test

A good bug fix is small and focused. Every bug fix **must** include a test that reproduces the original bug — it should fail without the fix and pass with it.

### 6. Same PR → merge → verify flow

Run the check suite, commit, open a PR, wait for CI, reproduce the original bug against the preview to confirm the fix, squash-merge, verify production.

### Hotfix pattern

There is no separate "hotfix" branch in GitHub Flow. A hotfix is just a bug fix you ship faster:

1. **Same flow** — issue, branch from `main`, fix, test, PR, preview, merge.
2. **Skip the planning ceremony** if the fix is one or two lines and obvious. Still write the regression test.
3. **Mark the PR as urgent** in the title (e.g. `fix(urgent): rate limiter resets…`) and ping reviewers.
4. **Verify production aggressively** — health check, the previously-broken path, and runtime logs.

No backporting is needed because there is no second long-lived branch to backport to. This is the main reason GitHub Flow is simpler than the old two-tier model.

---

## The CLAUDE.md advantage

Project context files — CLAUDE.md for Claude Code, `.cursorrules` for Cursor — make every coding session productive from the first message. Without them, every session starts cold: the agent doesn't know your conventions, your architecture, or your hard rules. It guesses, and it guesses wrong.

A well-maintained CLAUDE.md encodes your project's hard rules, architecture overview, check commands, and execution context. The agentic coder reads it at session start and follows it throughout. This is the difference between "write me a route" (generic) and "write me a route that follows *this project's* patterns" (productive).

Keep CLAUDE.md up to date as your project evolves. Stale context is worse than no context.

---

## Exit criteria

- [ ] PR created with all checks passing (type-check, lint, test:ci)
- [ ] PR linked to a GitHub issue (`Closes #N`)
- [ ] Preview deploy smoke-tested
- [ ] Ready for squash-merge to `main`

---

## Anti-patterns

| Anti-pattern | Why it fails | Do this instead |
|---|---|---|
| Code without specs | The agent builds confidently toward the wrong target. Rework is expensive. | Complete Stage 2 first. Every feature starts as a spec. |
| Skip plan review | Subtle errors compound across files. By the time you notice, the fix is a rewrite. | Always review the plan before approving execution. |
| Rebase-merge to main | GitHub's rebase rewrites SHAs. With two branches this causes phantom conflicts. Even with one branch, squash is cleaner. | Always squash-merge. One commit per feature on `main`. |
| "While I'm here" scope creep | Bug-fix PRs that include improvements are harder to review, harder to revert, and hide regression risk. | One issue, one branch, one concern. File a separate issue for improvements. |
| No regression test for bugs | The same bug will return. Without a test, you won't know until a user reports it again. | Every bug fix includes a test that fails without the fix and passes with it. |
