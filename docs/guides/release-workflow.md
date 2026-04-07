# Release Workflow

How to promote changes from staging to production and clean up afterwards.

**Primary surface:** Claude Code (Terminal)
**Secondary surface:** Scheduled Tasks (post-deploy smoke test)
**Depends on:** Feature or fix merged to staging and smoke-tested

---

## Prerequisites

- Feature/fix PR has been merged to staging
- Staging deployment is live and verified
- CI is green on the staging branch
- No merge conflicts between staging and master

---

## Step-by-Step

### 1. Verify Staging

**Surface:** Claude Code (Terminal)

Before promoting, confirm staging is healthy:

```
> Check the staging deployment. Hit the health endpoint at [staging-url]/api/health.
> Verify the new changes work as expected.
```

If using Vercel MCP:

```
> Use Vercel MCP to check the latest staging deployment status and any build errors.
```

### 2. Create PR to Master

**Surface:** Claude Code (Terminal)

```
> Create a PR from staging to master.
> Title: "release: [brief description of what's being promoted]"
> Include a summary of all changes being promoted (may be multiple features/fixes).
```

The PR description should list:
- All features/fixes included in this release
- Links to the original PRs and issues
- Any special deployment considerations (migrations, env vars)

### 3. Wait for CI

**Surface:** Claude Code (Terminal)

CI runs again on the master PR. This is the final gate:

- Type-check
- Lint
- Unit tests

All must pass before merging.

### 4. Review and Merge

**Surface:** Claude Code (Terminal)

Review the PR one final time. Then:

```
> Merge the PR to master.
```

Vercel auto-deploys to production on merge.

### 5. Verify Production

**Surface:** Claude Code (Terminal)

Immediately after merge, verify production:

```
> Check the production deployment. Hit [production-url]/api/health.
> Verify it returns a healthy response.
```

If you have a Vercel MCP connection:

```
> Use Vercel MCP to check the production deployment status, build logs,
> and runtime logs for any errors.
```

### 6. Post-Deploy Smoke Test

**Surface:** Claude Code (Terminal) or Scheduled Tasks

Run a quick smoke test on critical paths:

```
> Hit the following production endpoints and verify responses:
> - GET /api/health (should return 200)
> - GET /api/[resource] (should return 200 with valid pagination)
> - [any feature-specific endpoints]
```

For automated post-deploy verification, configure a Scheduled Task (see `scheduled-tasks.md`) that runs after each master merge.

### 7. Close the Issue

**Surface:** Claude Code (Terminal)

```
> Close issue #[number] with a comment linking to the production deployment.
```

### 8. Delete the Feature Branch

**Surface:** Claude Code (Terminal)

```
> Delete the feature/[name] branch (both local and remote).
```

### 9. Sync Local Branches

**Surface:** Claude Code (Terminal)

```
> Checkout master and pull. Checkout staging and pull.
> Prune any stale remote-tracking branches.
```

This keeps your local state clean for the next feature.

### 10. Update the Changelog

**Surface:** Claude Code (Terminal)

If you're cutting a versioned release (not just continuous deployment):

```
> In CHANGELOG.md, rename [Unreleased] to [X.Y.Z] — YYYY-MM-DD.
> Create a new empty [Unreleased] section above it.
> Commit with message "docs: release vX.Y.Z changelog".
```

---

## Rollback

If production is broken after merge:

### Quick Rollback (Vercel Dashboard)

1. Open Vercel dashboard → project → Deployments
2. Find the last known good deployment
3. Click "Promote to Production"
4. Verify health check passes

### Rollback via Claude Code

```
> The latest production deploy is broken. Revert the merge commit on master.
> Push the revert. This will trigger a new deploy with the previous code.
```

### Database Rollback

If the issue is a bad migration:

1. Use Neon point-in-time recovery to create a branch from before the migration
2. Update `DATABASE_URL` in Vercel environment variables
3. Redeploy

This is the nuclear option. Only use it if the migration caused data corruption.

---

## Post-Deploy Monitoring

After every production deploy, monitor for 24 hours:

| Signal | Where to Check | Action Threshold |
|---|---|---|
| Error rate | Vercel Analytics / logs | > 1% of requests |
| Response time | Vercel Analytics | > 2x baseline P95 |
| Health check | `GET /api/health` | Any non-200 response |
| User reports | Support channels | Any P0 bug report |

If any threshold is hit within 24 hours, trigger the rollback procedure.

---

## Checklist

- [ ] Staging verified and healthy
- [ ] PR created from staging to master
- [ ] CI passes on the master PR
- [ ] PR reviewed and merged
- [ ] Production deployment succeeded
- [ ] Health check returns 200
- [ ] Post-deploy smoke test passes
- [ ] GitHub issue closed
- [ ] Feature branch deleted (local + remote)
- [ ] Master and staging pulled locally
- [ ] CHANGELOG.md updated (if versioned release)

---

*See `docs/guides/feature-workflow.md` and `docs/guides/fix-workflow.md` for the pre-release workflow.*
*See `docs/guides/agentic-workflow.md` for the full lifecycle reference.*
