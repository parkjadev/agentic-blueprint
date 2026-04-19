# Changelog

All notable changes to the agentic-blueprint template repository.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- `.claude/` harness — 7 slash commands (`/research`, `/plan`, `/build`, `/ship`, `/run`, `/stage`, `/new-feature`), 5 subagents (`researcher`, `spec-writer`, `spec-reviewer`, `starter-verifier`, `docs-inspector`), 5 skills with progressive-disclosure references (`australian-spelling`, `spec-author`, `hard-rules-check`, `changelog-entry`, `memory-sync`), and 5 hooks (`session-start`, `stage-aware-prompt`, `template-guard`, `pre-write-spelling`, `pre-commit-gate`) wired in `.claude/settings.json`.
- `docs/principles/` — 12 principle files (9 Hard Rule rationales + 3 meta-principles: progressive disclosure, context economy, gates over guidance) plus a `README.md` index.
- `docs/operations/` — Stage 5 runbook surface, including `incident-response.md` with severity ladder, first-15-minutes flow, roles, comms templates, and postmortem outline.
- `starters/nextjs/CLAUDE.md` and `.claude/` — per-starter harness (settings, `/check`, `/migrate`).
- `starters/flutter/.claude/` — per-starter harness (settings, `/check`, `/generate`).
- `claude-config/.claude/` — mirror of the root harness for the copy-ready bundle.
- `.github/workflows/hard-rules-check.yml` — CI gate that runs the Hard Rules script on every PR.
- Custom sign-in/sign-up pages with email confirmation flow and Suspense boundary (#71)
- OAuth callback handler at `/auth/callback` (#71)
- DB trigger `handle_new_user()` for automatic profile creation on sign-up (#71)
- Supabase init error handling in Flutter `main.dart` (#71)
- `.gitignore` entries for build artefacts (#71)

### Changed

- `CLAUDE.md` rewritten as a primitive map: harness table, lifecycle quick-ref, Hard Rules compressed to one-liner links into `docs/principles/`.
- `starters/flutter/CLAUDE.md` trimmed 250 → 136 lines — framework Hard Rules delegated to `docs/principles/`, Flutter-specific conventions preserved.
- `claude-config/CLAUDE.md.template` shrunk 309 → 93 lines — it's now a tight stub downstream projects fill in, not a full manual.
- `claude-config/README.md` rewritten for the new copy-ready layout that includes the mirrored `.claude/` harness.
- **Supabase as sole backend** — migrated from Neon + Clerk + Upstash + R2 to Supabase (PostgreSQL, Auth, Storage). Required services: 3 → 1. Required env vars: 6 → 4 (#71)
- **Unified auth** — Supabase Auth replaces Clerk (web) + custom JWT (mobile). Single `getAuth()` path for both platforms via `@supabase/ssr` Bearer token forwarding (#71)
- **Flutter auth** — `supabase_flutter` SDK replaces custom JWT + `flutter_secure_storage`. Router wired to actual feature screens (#71)
- **Rate limiting** — in-memory sliding window with inline eviction replaces Upstash Redis (#71)
- **Storage** — Supabase Storage replaces Cloudflare R2 (#71)

### Removed

- `@clerk/nextjs`, `@neondatabase/serverless`, `@upstash/ratelimit`, `@upstash/redis`, `jose`, `svix` packages (#71)
- `flutter_secure_storage` package (#71)
- `mobile-jwt.ts`, `resolve-clerk-user.ts`, `clerk.d.ts`, `auth_guard.dart`, `secure_storage.dart` (#71)
- Clerk catch-all auth pages (`[[...sign-in]]`, `[[...sign-up]]`) (#71)

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
