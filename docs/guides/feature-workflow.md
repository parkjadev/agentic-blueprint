# Feature Workflow

Step-by-step guide for building a new feature: from specs through to production deployment.

**Primary surface:** Claude Code (Terminal)
**Secondary surface:** VS Code Extension (for diff review), Remote Control (for mobile supervision)
**Depends on:** Committed specs (see `prd-to-specs.md`)
**Related:** `release-workflow.md` (staging → production promotion)

---

## Prerequisites

- Technical specs committed to `docs/specs/[feature-name]/`
- GitHub issue created and linked to specs
- CLAUDE.md is up to date
- Local `master` and `staging` branches are current

---

## Step-by-Step

### 1. Update Specs (if needed)

**Surface:** Claude Code (Terminal)

Before starting, check that the specs still reflect what you want to build. If anything has changed since the spec was written:

```
> Read the technical spec at docs/specs/[feature-name]/technical-spec.md.
> Update it to reflect [changes]. Commit the update.
```

### 2. Create the Feature Branch

**Surface:** Claude Code (Terminal)

```
> Pull master and staging. Create a feature branch from master called feature/[name].
```

Claude Code will run:
- `git checkout master && git pull`
- `git checkout staging && git pull`
- `git checkout -b feature/[name] master`

### 3. Plan the Implementation

**Surface:** Claude Code (Terminal)

This is the critical step. Ask Claude to plan before coding:

```
> Read the specs in docs/specs/[feature-name]/. Plan the implementation.
> Show me the step-by-step plan before writing any code.
```

Review the plan against the spec. Check:

- [ ] Build order matches dependencies (schema → API → auth → jobs → UI)
- [ ] No scope creep beyond the spec
- [ ] Testing approach is included
- [ ] No unnecessary abstractions or "improvements"

If the plan looks right, approve it. If not, tell Claude what to change.

### 4. Execute the Plan

**Surface:** Claude Code (Terminal)

```
> Execute the plan. Start with step 1.
```

Claude Code proposes changes one at a time. For each change:

- Review the diff
- Approve or request adjustments
- Move to the next step

**For long-running builds:** If you need to step away, the session continues on your desktop. Use **Remote Control** from the Claude mobile app to monitor progress and approve actions.

### 5. Run the Check Suite

**Surface:** Claude Code (Terminal)

After all code is written:

```
> Run pnpm type-check && pnpm lint && pnpm test:ci
```

If anything fails:

```
> Fix the [type-check/lint/test] failures and run the checks again.
```

Do not proceed until all checks pass cleanly.

### 6. Write Tests

**Surface:** Claude Code (Terminal)

If the plan didn't include tests, or if coverage is insufficient:

```
> Write unit tests for the new code. Follow the patterns in src/test/.
> Cover: happy path, validation errors, auth failures, edge cases.
```

Run the full suite again after adding tests.

### 7. Commit the Work

**Surface:** Claude Code (Terminal)

```
> Commit all changes with a descriptive message. Reference issue #[number].
```

Use conventional commits:
- `feat: add [feature] (#42)` for new features
- `fix: resolve [issue] (#42)` for fixes

### 8. Create PR to Staging

**Surface:** Claude Code (Terminal)

```
> Push the branch and create a PR to staging. Link to issue #[number].
> Include a summary of changes and how to test them.
```

The PR should include:
- Summary of what changed
- Link to the GitHub issue
- Link to the technical spec
- How to test (manual steps or automated)

### 9. Wait for CI

**Surface:** Claude Code (Terminal) or GitHub

CI runs automatically on the PR:
- Type-check
- Lint
- Unit tests

If CI fails:

```
> Check the CI failure on this PR. Diagnose and fix it.
```

### 10. Merge to Staging

**Surface:** Claude Code (Terminal)

Once CI passes and the PR is reviewed:

```
> Merge the PR to staging.
```

Vercel auto-deploys the staging environment.

### 11. Smoke Test Staging

**Surface:** Claude Code (Terminal) or Browser

Verify the feature works in the staging environment:

```
> Check the staging deployment at [staging-url]. Hit the health endpoint.
> Verify the new [feature] endpoints return expected responses.
```

### 12. Promote to Production

**Surface:** Claude Code (Terminal)

→ Continue with `docs/guides/release-workflow.md`

---

## Mobile Supervision

If the feature build is long-running and you need to step away:

1. **Start the session** in Claude Code on your desktop with a clear plan
2. **Open Claude mobile app** → Remote Control
3. **Monitor progress** — see what Claude is doing, read output
4. **Approve actions** — approve file writes, command execution
5. **Steer direction** — send instructions if Claude is going off-track
6. **Return to desktop** — review the completed work

This works best when the plan is well-defined and you're mostly approving predictable actions.

---

## Checklist

- [ ] Specs are committed and up to date
- [ ] Feature branch created from master
- [ ] Plan reviewed and approved
- [ ] Code implemented
- [ ] `pnpm type-check` passes
- [ ] `pnpm lint` passes
- [ ] `pnpm test:ci` passes
- [ ] Tests written for new code
- [ ] PR created to staging with issue link
- [ ] CI passes on PR
- [ ] Merged to staging
- [ ] Staging smoke test passes

---

*See `docs/guides/release-workflow.md` for staging → production promotion.*
*See `docs/guides/agentic-workflow.md` for the full lifecycle reference.*
