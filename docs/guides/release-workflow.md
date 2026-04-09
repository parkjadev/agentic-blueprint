# Release Workflow

> **This guide has been collapsed into `feature-workflow.md`.**
>
> The blueprint used to prescribe a two-tier `feature → staging → main` promotion flow with a separate "release" step that opened a PR from `staging` to `main`. We removed it. GitHub's "Rebase and merge" rewrites commit SHAs at merge time, which causes the two long-lived branches to drift on every release and turns every promotion into a phantom merge conflict.
>
> The blueprint now uses **GitHub Flow**: one long-lived branch (`main`), one short-lived branch per issue, one PR per branch, and a Vercel preview deploy per PR. The PR *is* the release.

## What goes where now

- **Branching, plan, code, test, PR, merge:** see [`feature-workflow.md`](./feature-workflow.md).
- **Bug fixes (including hotfixes):** see [`fix-workflow.md`](./fix-workflow.md).
- **Production verification, rollback, smoke tests:** see the "Verify Production" and "Rollback" sections of [`feature-workflow.md`](./feature-workflow.md).
- **Post-deploy automation (scheduled health checks, runtime log scanning):** see [`scheduled-tasks.md`](./scheduled-tasks.md).
- **CHANGELOG / versioned release cuts:** see "Cutting a Versioned Release" below.

## Cutting a Versioned Release

If you ship continuously to production (default), you don't need versioned releases — every merge to `main` is a release. Use this section only when you tag versioned snapshots (e.g. for a published library or a mobile app store submission).

```
> In CHANGELOG.md, rename [Unreleased] to [X.Y.Z] — YYYY-MM-DD.
> Create a new empty [Unreleased] section above it.
> Commit on a docs/release-X.Y.Z branch with message "docs: release vX.Y.Z changelog".
> Open a PR to main using the standard PR template.
> After merge, tag the merge commit: git tag vX.Y.Z && git push --tags.
```

The tag points at the production deploy. There is no separate "promote to production" step because the merge to `main` already deployed it.

---

*See `docs/guides/feature-workflow.md` for the canonical flow.*
*See `docs/guides/agentic-workflow.md` for the full lifecycle reference.*
