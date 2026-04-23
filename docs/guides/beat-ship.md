# Beat — Ship

> Build + test + deploy + release as one idempotent PR-driven loop with automated gates.

## Why this beat exists

Claude Code in 2026 collapses the v3 Plan → Build → Ship stages into one continuous motion. A PR is the unit of delivery, not a journey through three stages. Maintaining the old mental model creates PR-spanning friction and encodes a handoff-era assumption that no longer holds.

The **Ship** beat is where the spec contract becomes running code — and where the automated gates live. The human decides when to merge; the loop handles build → test → PR → CI → deploy → verify without discrete stage boundaries.

## Why GitHub Flow (Profile A)

The default release profile is simplified GitHub Flow:

- One long-lived branch (`main`).
- Feature branches short-lived, one per spec.
- Per-PR preview deployment.
- Squash-merge to `main` auto-deploys production.
- Feature flags gate risky changes.

Multi-environment / GitFlow profiles are available in `docs/templates/delivery.md` for regulated domains and teams with external QA — but the default is trunk-based.

## Idempotence and resumability

Rerunning `/ship` on the same branch is deliberately safe. The command detects current state:

- Branch exists, no commits → resume at **Execute**.
- Commits on branch, no PR → resume at **Open PR**.
- PR open, CI green, not merged → resume at **Squash-merge**.
- PR merged, no post-merge verification → resume at **Verify**.

`/ship` prints its detected state at the top of each run so the user sees where it's picking up. No `--retry` flag is typically needed; `--resume` exists for explicit continuation after interruption.

## How it works — feature path

### 1. Status check

`/ship` reads git state, open PR state, last CI run, and classifies the current position in the loop. If the branch has uncommitted changes or the PR is already merged with no follow-up, it says so and stops.

### 2. Implementation plan

Reads `docs/specs/<slug>.md` and any parent spec (via the `parent:` frontmatter). Produces a one-page implementation sequence: what files will change, what tests will be added, what migrations (if any) will run, what rollback lever applies. Presents to the user for approval — no surprises during execution.

### 3. Execute

Writes code, runs tests as it goes, commits in logical chunks with conventional-commit subjects. Tagged-exception prefixes (`[release]`, `[infra]`, `[docs]`, `[bulk]`) are used only when the commit genuinely fits the exception — `[infra]` is not a catch-all for inconvenient gates.

### 4. Local gate

Runs `bash .claude/skills/hard-rules-check/scripts/check-all.sh`. All 4 Hard Rules must pass. Tagged-exception prefixes in the commit range are honoured.

### 5. CHANGELOG entry

For user-visible changes, invokes the `signal-sync` skill's `append-changelog.sh` script to add an `[Unreleased]` entry under the correct keepachangelog category. Skipped for `[infra]`/`[docs]`/`chore/*` work with no user-facing effect.

### 6. Open PR

Pushes the branch, opens a PR via GitHub MCP, links to the issue and parent spec. Fills the PR body from the technical-spec frontmatter + implementation-plan summary.

### 7. Preview smoke-test

When the platform posts the preview URL, curls the health endpoint and the one or two critical paths the spec named as acceptance criteria. Screenshots or log captures go to `docs/signal/` if the project has that convention.

### 8. Squash-merge on green

Requires explicit user confirmation unless the project has auto-merge configured. Conversation-resolution and CI checks must be green.

### 9. Verify

Watches the production auto-deploy, re-curls the health endpoint, inspects runtime logs for error-rate spikes. Hands off to `/signal sync` for CHANGELOG close-out and cross-reference audit.

## How it works — fix path

Minimum-viable version of the feature path:

1. Read the `[scope: fix]` technical-spec — just Problem, Root cause, Fix, Regression test.
2. Implement the fix and the regression test together. Regression test must fail before the fix and pass after.
3. Gate, PR, preview smoke-test, merge, verify.

Hotfixes that must skip preview smoke-test are labelled `[hotfix]` on the PR title for audit trail, and the incident owner documents the bypass in `docs/operations/`.

## How it works — chore path

Commit with `[infra]` or `[docs]` prefix on a `chore/*` branch or a feature branch. The pre-commit gate skips Rule 3 (Spec-before-Ship) for these prefixes. CHANGELOG entry is skipped unless the chore has user-visible effects.

## The CLAUDE.md advantage

Every Claude Code session reads `CLAUDE.md` at the repo root — plus any nested `CLAUDE.md` files in directories it opens. This means starter-local conventions (like the Next.js optional-services Zod pattern in `starters/nextjs/CLAUDE.md`) get loaded automatically when the agent works in that subtree. No configuration needed.

## Exit criteria

- PR squash-merged on green CI + preview smoke-test.
- Production deploy verified — health endpoint 200, no error-rate spike in 15 minutes.
- CHANGELOG `[Unreleased]` entry (if user-visible).
- Branch auto-deleted; issue auto-closed via "Closes #N" in PR body.

## Platform profiles

- **Claude-native**: `/ship` orchestrates the full loop. Claude Code drives GitHub Actions; deploy target is project-specific (Vercel, Azure via Bicep, AWS, Fly.io — pick what fits the stack). Deploy inspection via the platform's MCP or CLI (Vercel MCP for Next.js; `az` / `aws` / `fly` CLIs otherwise). Dispatch + Remote Control for mobile supervision during long builds.
- **OutSystems ODC**: Ship mechanics diverge — ODC Service Studio + Mentor produce the build; ODC pipelines handle Dev → Test → Prod promotion. The spec contract and CI gate logic from `/ship` are still relevant; the deploy step is replaced by the ODC promotion flow. Docs stay in git.

See `docs/guides/tool-reference.md` for the full matrix.

## Anti-patterns

| Anti-pattern | Why it fails | Do this instead |
|---|---|---|
| Rebase-and-merge to `main` | Rewrites commit SHAs; breaks any multi-tier flow and confuses history | Always squash-merge; never "Rebase and merge" in the UI |
| "While I'm here" scope creep | One-file fix becomes a 20-file refactor; reviewer can't isolate the intended change | If you notice something unrelated, file an issue and keep the current PR tight |
| No regression test for a bug fix | The fix "works" until the bug reappears; you've spent effort without building protection | Regression test must fail before the fix and pass after; commit them together |
| Deploying without reading the spec | The implementation drifts from what was agreed | `/ship` reads the spec first; if you're in doubt, re-read before coding |

---

*Previous beat: [Spec](beat-spec.md)* · *Next beat: [Signal](beat-signal.md)*
