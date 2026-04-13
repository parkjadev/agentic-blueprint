# Changelog

All notable changes to the agentic-blueprint template repository.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [2.1.0] — 2026-04-13

### Added

- **GitHub Flow as default** — replaced the two-tier staging/main workflow with single-main, per-PR Vercel previews, per-PR Neon branches (#1)
- **Issue templates** — feature, bug, chore, docs templates with required acceptance criteria and scope dropdown (#2)
- **PR template** — linked issue, test plan, schema-change checklist, rollback section (#2)
- **Auto-label workflow** — GitHub Action that applies `scope:*` label from the issue form dropdown (#12)
- **Branch protection script** — `setup-branch-protection.sh` with `enforce_admins=true`, squash-only, `SOLO=1` flag for solo devs (#3, #65)
- **Unblock protection script** — temporary `enforce_admins` bypass with 60-second auto-restore (#9)
- **Label taxonomy script** — `setup-labels.sh` creates `type:*` / `scope:*` / status labels (#4)
- **Backfill issues script** — `gh-backfill-issues.sh` for retroactive issue creation from a manifest (#11)
- **Plan status script** — `update-plan-status.sh` updates inline status markers in plan files when PRs land (#17)
- **Bootstrap smoke test** — `bootstrap-smoke-test.sh` + meta-CI workflow that scaffolds the template into a tmpdir and runs check:all (#25)
- **Flutter CI workflow** — `flutter.yml` with `dart analyze --fatal-warnings` + `flutter test`, path-filtered (#23)
- **Doc-drift test** — Vitest pattern asserting package.json version appears in CHANGELOG (#20)
- **Post-merge hook config** — plan status markers, doc-sweep prompt (#17)
- **16 Hard Rules** in CLAUDE.md.template including:
  - Issue before branch (#2)
  - One long-lived branch / squash-merge (#1)
  - Expand-migrate-contract with pre-launch corollary (#5, #10)
  - No business logic in chores (#15)
  - Verify file existence before recommending from memory (#15)
  - Plan-mode hygiene: pre-flight checks, full file paths, label vocab (#18)
- **Reusable Infrastructure section** in CLAUDE.md.template listing all `src/lib/*` modules (#16)
- **Doc-sweep checklist** in agentic-workflow.md Phase 10, including GitHub About section (#14)
- **Issue-first bootstrap** in README quickstart — "file issue #1 before you touch anything" (#13)
- **`@t3-oss/env-nextjs`** as default env validation replacing hand-rolled Zod (#24)
- **`loginRateLimiter`** (5 req / 15 min) in the rate-limit factory (#22)
- **svix** documented as default Clerk webhook verifier (#21)

### Changed

- **Deployment template** fully rewritten with `{{database}}`/`{{auth}}`/`{{hardware}}` placeholders, environment isolation matrix, three-tier rollback, post-deploy verification (#6)
- **Merge UI warnings** reframed: all merge types rewrite SHAs, not just rebase. The single-branch model is the real protection. (#7, #19)
- **CI workflow** (Next.js) — path-filtered to ignore Flutter changes, branches set to `[main]` (#23)
- **analysis_options.yaml** (Flutter) — strict options moved to `language:` for Dart 3.6+ (#61)
- **ESLint config** — added `plugin:@typescript-eslint/recommended` to extends (#51)

### Fixed

- Pre-existing TypeScript errors in `playwright.config.ts` and `storage/index.ts` (#47)
- Missing `@typescript-eslint/eslint-plugin` + parser in devDependencies (#49)
- Unused variables in starter route handlers and test helpers (#53)
- Unused import in Flutter test file (#59)
- Deprecated Flutter analysis options (#61)
- 9 Flutter info-level lint issues (super parameters, import ordering, trailing commas) (#63)
- `setup-labels.sh` empty-array bug under `set -u` (#4, fixed in d10049b)

### Removed

- **Staging branch references** — all guides, templates, and configs updated to single-main (#1)
- **Hardcoded brand references** — all AccessFit247/Sentinel/named-project references replaced with generic placeholders (#8)
- **`release-workflow.md`** — collapsed to a redirect explaining the move to GitHub Flow (#1)

---

*Built with Claude by [ARK360](https://github.com/parkjadev).*
