# Feature Workflow

Step-by-step guide for building a new feature: from a GitHub issue through to a production deployment on `main`.

**Primary surface:** Claude Code (Terminal)
**Secondary surface:** VS Code Extension (for diff review), Remote Control (for mobile supervision)
**Depends on:** Committed specs (see `prd-to-specs.md`)
**Branching model:** [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow) — one long-lived branch (`main`), short-lived feature branches, preview deploy per PR.

---

## Why GitHub Flow (and not a `staging` branch)

Earlier versions of this blueprint prescribed a two-tier workflow: `feature → PR to staging → merge → PR to main → merge`. **Do not use that pattern.**

GitHub's "Rebase and merge" rewrites commit SHAs at merge time. The commits that land on `staging` are not the same objects as the commits that land on `main`, so the two branches drift apart on every merge. Once they drift, every promotion PR shows phantom conflicts and you spend more time reconciling branches than shipping. This is the failure mode that informed the rewrite — don't relive it.

**Use this instead:** branch from `main`, open a PR to `main`, let Vercel build a preview deployment for that PR, smoke-test the preview, then merge. If you need a shared environment for QA or stakeholder review, use a long-lived **Vercel preview URL** — never a long-lived branch.

```
issue #N
  └─ branch: feat/N-short-slug (from main)
       └─ PR → main  ──▶ Vercel preview deploy + Neon preview DB branch
            └─ smoke test the preview
                 └─ squash-merge to main ──▶ production auto-deploys
                      └─ delete branch, close issue
```

> **Hard rule — never resurrect `staging`.** If somebody on the team creates a `staging` branch "just for QA", delete it. Use a Vercel preview alias or a protected preview URL instead.

---

## Prerequisites

- Technical specs committed to `docs/specs/[feature-name]/`
- **A GitHub issue exists** for this work (Hard Rule: issue before branch — see `CLAUDE.md`)
- CLAUDE.md is up to date
- Local `main` is current (`git checkout main && git pull`)
- Branch protection is configured on `main` (see `claude-config/scripts/setup-branch-protection.sh`)

---

## Step-by-Step

### 1. Confirm the Issue

**Surface:** Claude Code (Terminal)

Every feature starts as a GitHub issue. If one doesn't exist yet, create it before you do anything else:

```
> Create a GitHub issue from docs/specs/[feature-name]/technical-spec.md.
> Use the Feature issue template. Apply labels: type:feature, scope:[area].
```

The issue number drives the branch name and the commit footer, so you need it before you can branch.

### 2. Update Specs (if needed)

**Surface:** Claude Code (Terminal)

Before starting, check that the specs still reflect what you want to build:

```
> Read the technical spec at docs/specs/[feature-name]/technical-spec.md.
> Update it to reflect [changes]. Commit the update.
```

### 3. Create the Feature Branch

**Surface:** Claude Code (Terminal)

Branch from the latest `main`. Use the convention `<type>/<issue-number>-<slug>`:

```
> Pull main. Create a branch called feat/42-user-profile from main.
```

Claude Code will run:
- `git checkout main && git pull`
- `git checkout -b feat/42-user-profile main`

Branch types: `feat/`, `fix/`, `chore/`, `docs/`. The number must match the GitHub issue.

### 4. Plan the Implementation

**Surface:** Claude Code (Terminal)

This is the critical step. Ask Claude to plan before coding:

```
> Read the specs in docs/specs/[feature-name]/ and issue #42.
> Plan the implementation. Show me the step-by-step plan before writing any code.
```

Review the plan against the spec. Check:

- [ ] Build order matches dependencies (schema → API → auth → jobs → UI)
- [ ] No scope creep beyond the spec or the issue
- [ ] Testing approach is included
- [ ] No unnecessary abstractions or "improvements"

If the plan looks right, approve it. If not, tell Claude what to change.

### 5. Execute the Plan

**Surface:** Claude Code (Terminal)

```
> Execute the plan. Start with step 1.
```

Claude Code proposes changes one at a time. Review the diff, approve or request adjustments, then move on.

**For long-running builds:** if you need to step away, the session continues on your desktop. Use **Remote Control** from the Claude mobile app to monitor and approve actions.

### 6. Run the Check Suite

**Surface:** Claude Code (Terminal)

```
> Run pnpm type-check && pnpm lint && pnpm test:ci
```

Do not proceed until all checks pass cleanly.

### 7. Write Tests

**Surface:** Claude Code (Terminal)

If the plan didn't include tests, or if coverage is insufficient:

```
> Write unit tests for the new code. Follow the patterns in src/test/.
> Cover: happy path, validation errors, auth failures, edge cases.
```

Run the full suite again after adding tests.

### 8. Commit the Work

**Surface:** Claude Code (Terminal)

```
> Commit all changes with a descriptive message. Reference issue #42.
```

Use Conventional Commits and reference the issue in the footer:

```
feat(profile): add user profile page

Implements the profile view per the technical spec.

Refs: #42
```

### 9. Open the PR

**Surface:** Claude Code (Terminal)

```
> Push the branch and open a PR to main using the pull request template.
> Title: "feat: add user profile page". Link issue #42.
```

The PR template (see `claude-config/github/pull_request_template.md`) prompts for:
- Linked issue (`Closes #42`)
- Summary of changes
- Test plan
- Preview URL (Vercel fills this in automatically)

### 10. Wait for CI + Preview

**Surface:** Claude Code (Terminal) or GitHub

Two things happen in parallel:

- **GitHub Actions** runs type-check, lint, and unit tests against the PR.
- **Vercel** builds a preview deployment with its own Neon database branch and posts the URL on the PR.

If CI fails:

```
> Check the CI failure on this PR. Diagnose and fix it.
```

### 11. Smoke Test the Preview

**Surface:** Claude Code (Terminal) or Browser

Verify the feature on the preview URL (not on `main`):

```
> Hit the preview URL's /api/health endpoint and the new endpoints I just added.
> Verify they return the expected responses.
```

This is your "staging environment" — it's a real, isolated, throwaway environment per PR. No persistent staging branch needed.

### 12. Merge to `main`

**Surface:** Claude Code (Terminal)

Once CI is green, the preview is verified, and the PR is reviewed:

```
> Squash-merge the PR to main.
```

**Use squash merge (not rebase merge).** Squash merge produces one new commit on `main` and we expect that — so SHA rewriting causes no drift, because there is no second branch to keep in sync.

> **Watch out for "Rebase and merge".** Despite the name, GitHub's "Rebase and merge" is not a true fast-forward — it rewrites every commit's SHA. If you ever add a second long-lived branch to this flow (don't), this is the landmine that breaks it.

Vercel auto-deploys `main` to production on merge.

### 13. Verify Production

**Surface:** Claude Code (Terminal)

Immediately after merge:

```
> Hit the production /api/health endpoint and the new feature endpoints.
> Confirm responses look healthy.
```

If you have the Vercel MCP connected:

```
> Use Vercel MCP to check the production deployment status, build logs,
> and runtime logs for the last 10 minutes.
```

### 14. Clean Up

**Surface:** Claude Code (Terminal)

```
> Close issue #42 with a comment linking to the production deployment.
> Delete the feat/42-user-profile branch (local and remote).
> Pull main and prune stale remote-tracking branches.
> Add an entry to CHANGELOG.md under [Unreleased].
```

---

## Rollback

If production breaks immediately after merge:

### Quick Rollback (Vercel)

1. Open Vercel dashboard → project → Deployments
2. Find the last known-good deployment
3. Click **Promote to Production**
4. Verify `/api/health` returns 200

This is the fastest recovery — it rolls back the runtime in seconds without touching git.

### Rollback via Revert Commit

If the bad change must come out of `main` (e.g. it's blocking other PRs):

```
> Revert the merge commit on main. Push the revert. CI + Vercel will redeploy
> with the previous code. Open a follow-up issue to fix forward.
```

### Database Rollback

If a migration caused data corruption:

1. Use Neon point-in-time recovery to create a branch from before the migration
2. Update `DATABASE_URL` in Vercel environment variables
3. Redeploy

This is the nuclear option — only use it if data is actually corrupted. For schema-only mistakes, prefer fixing forward with an expand-migrate-contract follow-up (see `CLAUDE.md` Hard Rules).

---

## Mobile Supervision

If the feature build is long-running and you need to step away:

1. Start the session in Claude Code on your desktop with a clear plan
2. Open Claude mobile app → Remote Control
3. Monitor progress and approve actions while away
4. Return to desktop to review the completed work

This works best when the plan is well-defined and you're mostly approving predictable actions.

---

## Checklist

- [ ] GitHub issue exists and is labelled
- [ ] Specs are committed and up to date
- [ ] Branch created from `main` using `<type>/<issue-number>-<slug>`
- [ ] Plan reviewed and approved
- [ ] Code implemented
- [ ] `pnpm type-check` passes
- [ ] `pnpm lint` passes
- [ ] `pnpm test:ci` passes
- [ ] Tests written for new code
- [ ] PR opened to `main` with `Closes #N`
- [ ] CI green on the PR
- [ ] Vercel preview smoke-tested
- [ ] Squash-merged to `main`
- [ ] Production health check passes
- [ ] Issue closed, branch deleted, CHANGELOG updated

---

*See `docs/guides/fix-workflow.md` for the bug-fix variant of this flow.*
*See `docs/guides/agentic-workflow.md` for the full lifecycle reference.*
