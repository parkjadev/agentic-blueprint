# Changelog

All notable changes to the agentic-blueprint template repository.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [5.0.3] — 2026-04-23

Patch release. Fixes `allowed-tools` frontmatter format on all four slash-command definitions so Claude Code actually parses the tool allow-list instead of treating it as a literal string.

### Fixed

- **`allowed-tools` frontmatter converted from comma-separated to space-separated.** All four slash commands (`/spec`, `/ship`, `/signal`, `/beat`) previously carried `allowed-tools: Bash, Read, Write, Edit, Glob, Grep` — the comma-separated form is human-readable but not a valid YAML list, and Claude Code's command loader read it as a literal string. Commands ran but triggered permission prompts for every tool the frontmatter should have granted. Fixed to space-separated form across both the live `.claude/commands/` and the bundle mirror at `claude-config/.claude/commands/` (#128).

## [5.0.2] — 2026-04-23

Patch release. Fixes `install.sh` crashes on first real adopter use — the v5.0.1 `bootstrap.sh` one-liner runs cleanly but the underlying installer was broken at several source paths, producing mid-install crashes (`cat: …/CLAUDE.md: No such file or directory`) and latent bugs that `--dry-run` couldn't see because it only echoed commands without stat-ing sources.

### Fixed

- **`claude-config/scripts/install.sh` source paths corrected.** `SRC_DIR` resolved to `claude-config/` but roughly half the references assumed it was the blueprint repo root. Rewritten with explicit `BUNDLE_DIR` (= `claude-config/`) + `BLUEPRINT_ROOT` (= parent) variables and every reference updated to the right one. Concrete fixes: `CLAUDE.md` → `CLAUDE.md.template`; `$SRC_DIR/.github/…` → `$BLUEPRINT_ROOT/.github/…`; `$SRC_DIR/docs/…` → `$BLUEPRINT_ROOT/docs/…`; `$SRC_DIR/claude-config/VERSION` → `$BUNDLE_DIR/VERSION` (the former resolved to `claude-config/claude-config/VERSION`) (#127).

### Added

- **Pre-flight stat check in `install.sh`.** Before writing anything, verifies every required source path exists. Fails fast with the full missing-paths list instead of partial-install + mid-run crash. Catches the next class of path-mismatch bug at invocation instead of two-thirds of the way through (#127).

## [5.0.1] — 2026-04-23

Patch release. Closes the first-time adopter bootstrap gap v5.0 shipped with and trims the last cross-version migration artefact.

### Added

- **`bootstrap.sh`** at repo root — non-circular install entry point. v5.0's documented install path (`/beat install`) assumes the `.claude/` bundle is already in the adopter's repo; for first-time adopters that's a chicken-and-egg. `bootstrap.sh` works via `bash <(curl -fsSL …/bootstrap.sh)` or a local clone; it clones the blueprint to a tmp dir if needed and delegates to `claude-config/scripts/install.sh`. No logic duplication — dispatch-only (#126).

### Removed

- **`MIGRATION-v3-to-v4.md`** (repo root) — v3→v4 upgrade guide. No live references; only mention was in the v4 research brief (archival context). Same reasoning that kept v5.0 from shipping a v4 migration guide: cross-version migration support has no users to serve (#126).

## [5.0.0] — 2026-04-23

The platform-agnostic redesign. Stack selection becomes an output of the Spec beat (via `spec-researcher`), not an assumption baked into opinionated starters. The load-bearing IP from the retired v4 starters — interface contracts like the `ApiResponse<T>` envelope, error taxonomy, auth-token shape, telemetry schema — is lifted into first-class reference artefacts under `docs/contracts/`, protected by Rule 4. Hard Rules reduce to 4 (1, 3, 4, 5) + 3 meta-principles; Rule 2 is retired with its numbering preserved so downstream references don't shift.

### Added

- **`docs/contracts/`** — stack-agnostic interface library (README + 4 day-one contracts: `api-response.md`, `error-taxonomy.md`, `auth-token.md`, `telemetry.md`). Prose + JSON Schema draft 2020-12. Rule-4 protected; `contracts/*` branches honoured as a dedicated edit context (#117).
- **Stack Selection section** in `docs/templates/research-brief.md` and matching guidance in `spec-researcher.md` — product-scope briefs must evaluate ≥ 3 alternatives against discriminating criteria and produce a justified recommendation. Stack is an output of Spec, not an input (#118).
- **Chunked-write + context-pack protocols** in `spec-author.md` and `spec-researcher.md` — first `Write` ≤ 1500 words, subsequent sections via `Edit` in ≤ 1500-word chunks, heartbeat within 3 tool calls. Caller may inline a context pack to save Reads. Directly mitigates the stream-idle timeouts that plagued pre-#113 subagent runs (#113).
- **Budget preambles** on `research-brief.md` (words ≤ 4000) and `PRD.md` (words ≤ 4500) — template-level context-economy guardrail (#114).
- **v5 product spec** — `docs/research/agentic-blueprint-v5-agnostic-brief.md` + `docs/specs/agentic-blueprint-v5-agnostic/{PRD.md, architecture.md}` (#112, #115).

### Changed

- **Rule 4 extended to cover `docs/contracts/`** — `template-guard.sh` protects both sacred paths; `check-all.sh` Rule 4 check accepts `docs/*`, `templates/*`, or `contracts/*` as dedicated edit branches; `[release]` commit prefix works for both (#117).
- **Pre-commit gate sees the pending commit subject.** `range_has_prefix` in `check-all.sh` now also reads `PENDING_COMMIT_SUBJECT`, parsed from the `-m` / `-F` args by `pre-commit-gate.sh`. Fixes the bug where first-commit-on-branch with an `[infra]` / `[docs]` / `[release]` exception was blocked even though the subject was correct (#116).
- **`tool-reference.md` reframed** as a role × inputs matrix with an explicit "not a prescription" note, dropping the v4 two-profile split (Claude-native / OutSystems ODC). Beat guides lose their "Platform profiles" blocks (#121).
- **`hard-rules-check` SKILL.md rewritten** — description aligned to v5's 4 rules (was still enumerating pre-v4 "9 Hard Rules"). `rules-detail.md` updated with Rule 2 archive note and v3 → v4 → v5 historical trail (#119).

### Removed

- **Hard Rule 2** (starters generic and boot clean) — archived to `docs/principles/_archive/02-starters-generic-boot-clean.md`. Reinstate if plugin packs land in v5.x (#119).
- **`starter-verify` skill** — removed from live `.claude/skills/` and the `claude-config/.claude/` adopter bundle. Rule 2 retirement left the skill with no rule to enforce (#120).
- **`/beat install --new <project>` sub-verb** — greenfield scaffolding from retired starters. New projects now run `/beat install` in an empty repo then `/spec idea` for stack-selection research (#120).
- **Two-profile platform split** — Profile A (Claude-native) and Profile B (OutSystems ODC) sections removed from `tool-reference.md` and beat guides. Rule 5 principle untouched; only the v4 two-profile enumeration is retired (#121).

### v4 artefacts (retired in-flight before v5.0)

Starters and their support infrastructure were retired in preparation for v5.0 (commit `a53f0ff`, PR #109):

- `starters/nextjs/`, `starters/flutter/`, `starters/dotnet-azure/`
- `.github/workflows/bootstrap-smoke-test.yml` + the three `dotnet-*` workflows
- `claude-config/scripts/bootstrap-smoke-test.sh`

Adopters of v4 can pin to the pre-retirement commit (`3bb4c27`) if they need the previous starter trees; v5.0 does not ship a migration guide because no external v4 adopters are known.

## [3.0.0] — 2026-04-20

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
- Added 'Choosing a release strategy' section to Stage 4 guide; added release-strategy profiles to Tool Reference documenting preconditions for simplified and multi-environment models (#84).

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

### Fixed

- Hard Rules CI check now handles detached-HEAD checkouts (actions/checkout@v4 PR events) and missing local main ref (#85).

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
