# Stage 4: Ship

> Get merged code into production, verify it works, and supervise deployments from anywhere.

---

## Why this stage exists

Merging a PR is not shipping. Shipping means the change is live, verified, and recoverable if something goes wrong. Most AI coding tools treat deployment as someone else's problem — Replit deploys only to its own hosting (unusable for production apps that need Vercel, AWS, or Railway), and Cursor can trigger deploys but offers no mobile supervision for monitoring long builds or approving post-deploy actions while you're away from your desk.

For solo founders and small teams, the gap is acute. You merge at 2pm, step into a meeting, and have no way to verify the deploy or respond to a failure until you're back at your desk. Stage 4 closes that gap with continuous deployment pipelines and mobile supervision tools that let you ship, verify, and recover from your phone.

This stage also covers versioned releases for projects that need tagged snapshots — published libraries, mobile app store submissions, or any context where "latest main" is not a sufficient release artefact.

---

## What you need

| Role | Recommended | Alternatives |
|---|---|---|
| **Deployment Pipeline** | Vercel + GitHub Actions CI/CD | AWS, Railway, Fly.io, any CI/CD platform |
| **Mobile Supervision** | Claude Dispatch + Remote Control | Cursor mobile agent (limited) |

---

## Choosing a release strategy

The blueprint supports two named release models. Choosing explicitly — before writing pipeline configuration — prevents mismatched infrastructure, where a team attempts continuous deployment without the preconditions it needs, or carries a multi-environment apparatus it never actually requires. Neither model is a blueprint default; the choice follows from the preconditions below.

### Profile A: Simplified (GitHub Flow)

Trunk-based: one long-lived branch (`main`), ephemeral PR branches, merge to `main` equals production deploy.

**Preconditions**

1. **Automated test coverage** at a minimum smoke-test level, enforced as a CI merge gate.
2. **Per-PR preview environments** that mirror production closely enough to surface integration issues before merge.
3. **Runtime activation control** — a mechanism to deploy code dark and activate it for users selectively. Feature flags fill this role.
4. **Schema-change discipline** — destructive migrations (column drop, rename, type change) follow the expand-migrate-contract pattern across multiple PRs, never bundled with the application code that depends on the new schema.

**Best for:** solo founders, small product teams, high-deployment-frequency SaaS, any context where regulatory or contractual obligations do not require pre-production human sign-off.

See [Profile A: Simplified (GitHub Flow)](tool-reference.md#profile-a-simplified-github-flow) in the Tool Reference for the full infrastructure role map.

### Profile B: Multi-environment (GitFlow)

Long-lived `main`, `develop`, and release branches; a shared staging environment; a human approval gate before production.

**Preconditions**

1. **Shared staging environment** that closely mirrors production and is used for QA and stakeholder sign-off before promotion to `main`.
2. **Approval workflow** — a Change Advisory Board (CAB), QA lead sign-off, or equivalent, required before merging release branch to `main`.
3. **Branch protection rules** on `main` that enforce the approval gate.

Staging–production environment drift is the primary operational risk of this model and must be managed actively. A staging environment that has diverged from production gives false confidence rather than real coverage.

**Best for:** regulated industries (banking, healthcare, government), enterprise teams with CAB obligations, any context where contractual or regulatory requirements mandate pre-production human sign-off.

See [Profile B: Multi-environment (GitFlow)](tool-reference.md#profile-b-multi-environment-gitflow) in the Tool Reference for the full infrastructure role map.

Capture the chosen model's decisions in a per-project release-strategy document using [`docs/templates/release-strategy.md`](../templates/release-strategy.md).

---

## How it works — Continuous deployment

The default: merge to `main` equals production deploy. No manual promotion, no release manager, no ceremony.

### 1. PR is squash-merged to main

Stage 3 ends with a squash-merge. The moment it lands on `main`, the deployment pipeline activates.

### 2. CI re-runs against main

GitHub Actions runs the full check suite (`type-check`, `lint`, `test:ci`) against the merged commit on `main`. This catches integration issues that the PR checks might miss (e.g. two PRs merged in quick succession whose changes conflict at runtime).

### 3. Platform auto-deploys

Vercel (or your platform) detects the new commit on `main` and builds the production deployment automatically. No manual trigger required.

### 4. Post-deploy verification

Immediately after the deploy completes, verify it works:

```
> Hit the production /api/health endpoint.
> Confirm it returns 200 and response time is acceptable.
> Check the new endpoints/pages from this deploy.
```

If you have Vercel MCP connected:

```
> Use Vercel MCP to check the production deployment status,
> build logs, and runtime logs for the last 10 minutes.
```

### 5. Clean up

- Branch auto-deletes (configure this in GitHub repo settings)
- Issue auto-closes (via `Closes #N` in the PR body)
- Pull `main` and prune stale remote-tracking branches locally
- Add an entry to CHANGELOG.md under `[Unreleased]`

---

## How it works — Versioned releases

Most projects ship continuously — every merge to `main` is a release. Use versioned releases only when you need tagged snapshots: published libraries, mobile app store submissions, or contractual version requirements.

### 1. Rename [Unreleased] in CHANGELOG

In `CHANGELOG.md`, rename the `[Unreleased]` section to `[X.Y.Z] — YYYY-MM-DD`. Create a new empty `[Unreleased]` section above it.

### 2. Commit on a release branch

```
git checkout -b docs/release-X.Y.Z main
```

Commit with message `docs: release vX.Y.Z changelog`. Open a PR to `main` using the standard PR template.

### 3. Merge and tag

After the PR merges, tag the merge commit:

```
git checkout main && git pull
git tag vX.Y.Z
git push --tags
```

The tag points at the production deploy. There is no separate "promote to production" step because the merge to `main` already deployed it.

---

## Rollback procedures

When production breaks after a deploy, you have three options in order of speed.

### 1. Platform promote (fastest — seconds)

Roll back the runtime without touching git:

1. Open your platform dashboard (e.g. Vercel → project → Deployments)
2. Find the last known-good deployment
3. Click **Promote to Production**
4. Verify `/api/health` returns 200

This is the fastest recovery. Use it when you need production stable immediately.

### 2. Revert commit on main (minutes)

If the bad change must come out of `main` (e.g. it is blocking other PRs):

```
> Revert the merge commit on main. Push the revert.
> CI + Vercel will redeploy with the previous code.
> Open a follow-up issue to fix forward.
```

This leaves a clean git history and triggers a fresh deploy.

### 3. Database point-in-time recovery (last resort)

If a migration caused data corruption:

1. Use your database provider's point-in-time recovery to restore to before the migration
2. Update `DATABASE_URL` in your platform's environment variables if needed
3. Redeploy

This is the nuclear option — only use it if data is actually corrupted. For schema-only mistakes, prefer fixing forward with an expand-migrate-contract follow-up.

---

## Mobile supervision

Two mobile capabilities let you stay productive away from your desk during deploys and long-running builds.

### Remote Control — monitor and steer

Use Remote Control when you have an active Claude Code session running and need to step away:

1. **Start the session at your desk** with a clear, specific plan
2. **Open Claude mobile app → Remote Control** → select your session
3. **Monitor and approve** — read output, approve file writes and commands, send corrections if needed
4. **Return to your desk** to review the completed work

**Tips:**

- Front-load the plan. Quality of remote supervision depends on quality of the initial plan.
- Batch approvals every 10–15 minutes rather than checking constantly.
- If Claude hits a problem needing deep thought, send "pause, I'll look at this when I'm back."
- Best for the *middle* of a plan — don't start a new plan from your phone.

### Dispatch — fire and forget

Use Dispatch when you think of work that needs doing while you are away from your desk:

1. **Define the task clearly** in the Claude mobile app — include repo, file paths, issue references, and acceptance criteria
2. **Assign and walk away** — Claude works on your desktop autonomously
3. **Return to results** — check GitHub for new PRs, review diffs, merge or continue interactively

**Decision guide:** Use Remote Control for in-progress work you are steering. Use Dispatch for independent, well-defined tasks you can hand off entirely.

### Dispatch task templates

These proven patterns work well as fire-and-forget tasks:

**Bug fix:**
> In [repo], fix [specific bug]. The issue is in [file] — [root cause]. See issue #N for details. Include a regression test. Create a PR to main. Reference "Closes #N".

**Documentation update:**
> In [repo], update [doc file] to reflect [specific change]. Follow the existing document style. Create a PR.

**Test coverage:**
> In [repo], add unit tests for [file/module]. Cover: happy path, validation errors, auth failures, edge cases. Follow patterns in src/test/. Run pnpm test:ci. Create a PR.

**Dependency update:**
> In [repo], update [package] from [old] to [new]. Check the changelog for breaking changes. Update affected code. Run pnpm type-check && pnpm lint && pnpm test:ci. Create a PR if all checks pass.

**Small feature:**
> In [repo], add [specific feature]. See spec at [path]. Follow existing patterns in [reference file]. Include tests. Create a PR to main. Reference "Closes #N".

---

## Exit criteria

- [ ] Production deploy verified (health check returns 200)
- [ ] Branch deleted, issue closed
- [ ] CHANGELOG updated (entry under `[Unreleased]`, or version cut if applicable)
- [ ] Rollback path confirmed (you know which prior deployment to promote if needed)

---

## Platform notes

- **Claude-native:** Claude Code + Vercel MCP for deployment. Dispatch and Remote Control for mobile supervision.
- **Cursor + Perplexity:** Cursor integrates with GitHub and Vercel. Mobile agent available but limited compared to Dispatch/Remote Control.
- **OutSystems ODC:** ODC has a built-in deployment pipeline (Development → QA → Production). The Blueprint's deployment template captures environment configuration, promotion criteria, and rollback procedures — relevant regardless of whether deployment is CLI-driven or portal-driven.

## Anti-patterns

| Anti-pattern | Why it fails | Do this instead |
|---|---|---|
| Skip post-deploy verification | A green CI does not mean production is healthy. Build artefacts, environment variables, and runtime behaviour can differ. | Always verify production after every deploy — health check at minimum. |
| Manual deployment | Manual steps are forgotten under pressure, vary between deploys, and cannot be audited. | Automate: merge to `main` triggers deploy. No human in the loop. |
| No rollback plan | When production breaks at 6pm on a Friday, you need a recovery path you can execute in under a minute, not one you have to figure out in a panic. | Know your three rollback options (platform promote, revert commit, database recovery) before you ship. |
| Over-supervise remote sessions | Checking Remote Control every two minutes is slower than sitting at your desk. You lose the benefit of async work. | Batch-approve every 10–15 minutes. Trust the plan you approved. |
| Deploy without CI gate | Skipping CI to "ship faster" means shipping untested code to production. The time you save deploying is spent debugging in production. | Always require CI to pass before merge. No exceptions. |
