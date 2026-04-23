# 2. Starters stay generic and boot clean (retired in v5.0)

> **Retired.** This rule was active in v4 when the blueprint shipped Next.js / Flutter / .NET + Azure starters. PR #109 retired the starters; PR #115 (v5.0 PRD) resolved the retire-vs-reframe question as retire. Archived here for provenance; can be rebuilt if plugin packs ship in v5.x. Hook enforcement removed from `check-all.sh` in the same PR that archived this file.

## The rule

Starters under `starters/` contain only generic infrastructure patterns AND pass their own check suite with zero errors.

- **Generic:** brand names become `TODO: your-company-name`; vertical-specific routes become `/api/examples/`; seed data uses `Widget`/`Example`; UI copy uses placeholder strings with a `TODO:` comment.
- **Clean boot:** every starter compiles, lints, and passes tests on a fresh clone.
  - Next.js: `pnpm install && pnpm type-check && pnpm lint && pnpm test:ci`
  - Flutter: `flutter analyze && flutter test`

## Why

This merges two v3 rules (no domain logic + boots clean) because they answer the same question: "would a brand-new adopter who clones this repo get a working foundation, or land in a broken, single-customer-specific codebase?"

A starter that references `AcmeCorp` or ships type errors is actively misleading. One broken boot burns the next hundred users; one leaked brand caps the reuse at one company. The framework is the product — the starters are proof it works generically.

## In practice

- Grep for known brand tokens before every merge: `grep -rn "ACME\|MyCompany\|ClientName" starters/`
- Feature PRs touching `starters/` re-run the full boot locally.
- `/ship` delegates to the `starter-verify` skill, which runs smoke-test scripts in isolation so noisy build output stays out of the main conversation.
- Starter-local conventions (e.g. the Next.js optional-services Zod pattern) live in `starters/nextjs/CLAUDE.md`, not as blueprint-wide Hard Rules.

## When it fails

- Domain-string grep hit → find-replace with a generic term + `TODO:` breadcrumb.
- Smoke-test fails → fix at the root. Never silence with `@ts-ignore`, `.eslintignore`, or `// ignore:` unless the fix is a separate, scoped task.
- A new dependency breaks a starter → either update the starter or hold the dependency bump. Never merge half-broken.

## Related

- `starter-verify` skill — `.claude/skills/starter-verify/` (v4 replaces the v3 `starter-verifier` agent).
- `claude-config/scripts/bootstrap-smoke-test.sh` — the underlying script.
- `starters/nextjs/CLAUDE.md` — optional-services / Zod convention (starter-local, not blueprint-wide).
