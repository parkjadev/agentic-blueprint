<!--
Pull request template — see claude-config/github/pull_request_template.md in agentic-blueprint.

Reminders before opening:
- Branch name must be <type>/<issue-number>-<slug> (feat/42-user-profile, fix/57-rate-limiter, etc.)
- Use squash merge when this PR lands. Never "Rebase and merge" — it rewrites SHAs.
- The Vercel preview URL is your "staging environment". Smoke-test it before requesting review.
-->

## Summary

<!-- One or two sentences: what does this PR do and why? -->

Closes #

## Changes

<!-- Bulleted list of the substantive changes. Skip trivial mechanical edits. -->

-
-
-

## Test plan

<!-- How did you verify this works? Tick boxes as you go. The preview deploy is the place to do real verification — not main. -->

- [ ] `pnpm type-check`
- [ ] `pnpm lint`
- [ ] `pnpm test:ci`
- [ ] Smoke-tested on the Vercel preview URL
- [ ] Manual verification: <!-- describe what you clicked / curled / inspected -->

## Schema changes

<!-- Delete this section if there are no schema changes. -->

- [ ] No schema changes
- [ ] Additive only (new columns/tables/indexes — safe to ship in one PR)
- [ ] Destructive change — followed expand-migrate-contract (link the related PRs)

## Risk / rollback

<!-- What could break? If it does, how do we roll back? -->

- **Risk:**
- **Rollback:** Vercel → Deployments → Promote previous deploy. (For data corruption: Supabase point-in-time recovery.)

## Screenshots / preview

<!-- Optional. Vercel will post the preview URL automatically. Drop screenshots here for UI changes. -->
