# 3. All starters must boot clean

> Hard Rule. Verified by `claude-config/scripts/bootstrap-smoke-test.sh` and
> the `starter-verifier` subagent.

## The rule

Every starter passes its own check suite with zero errors.

- **Next.js** (`starters/nextjs/`): `pnpm install && pnpm type-check && pnpm lint && pnpm test:ci`
- **Flutter** (`starters/flutter/`): `flutter analyze && flutter test`

Never merge a change that breaks a starter's clean boot.

## Why

A starter that doesn't pass its own checks is actively misleading. It
tells a new user "this is a working foundation" while shipping type
errors, lint warnings, or failing tests. The trust collapse is
permanent — one broken boot burns the next hundred users.

## In practice

- Feature PRs that touch a starter re-run the full boot locally before
  marking the PR ready.
- The `/ship` command delegates to the `starter-verifier` subagent,
  which runs the smoke-test script in isolation so the noisy output
  doesn't pollute the main conversation.
- CI (`.github/workflows/`) re-runs the check on every PR against
  `starters/**` paths.

## When it fails

- Run `bash claude-config/scripts/bootstrap-smoke-test.sh` locally and
  fix at the root. Do not silence with `@ts-ignore`, `// ignore:`, or
  `.eslintignore` entries that mask the issue.
- If a new dependency is breaking a starter, either update the starter
  to match or hold the dependency bump — do not merge half-broken.

## Related

- `starter-verifier` subagent — `.claude/agents/starter-verifier.md`
- Rule 4 — optional services must not become mandatory via broken boots.
