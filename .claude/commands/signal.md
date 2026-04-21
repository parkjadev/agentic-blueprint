---
description: Signal — run + monitor + learn + scheduled automation. Feeds back into Spec.
argument-hint: <init|sync|audit|status> [scope]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# /signal — Signal beat (v4)

The **Signal** beat is what v3 called Run. It covers scheduled automation (PR triage, CI monitor, dependency audit, doc sync), incident logging, CHANGELOG close-out, and periodic self-review. Signal is where learnings feed back into the next `/spec idea`.

## Sub-verbs

| Sub-verb | Purpose |
|---|---|
| `/signal init` | Install the scheduled-task manifest (`claude-config/scheduled-tasks.yaml`) into Claude Scheduled Tasks (or GitHub Actions cron for adopters without Claude Scheduled Tasks). Idempotent — rerun to apply manifest changes |
| `/signal sync` | Post-merge sync: plan-status marker updates, CHANGELOG close-out, cross-reference validation, stale-brief archival. Invokes the `signal-sync` skill |
| `/signal audit` | Periodic (default weekly) self-review: re-reads open specs, flags drift between spec and reality, summarises features shipped in the last 30 days, prompts update of parent-idea PRD if learnings warrant. Solo-dev substitute for peer review |
| `/signal status` | Dashboard — scheduled tasks, open PRs, CI health, recent incidents, API spend (if `ANTHROPIC_ADMIN_KEY` is configured). `--json` flag for external wiring |

`/signal` without sub-verb defaults to `/signal status`.

## Steps — `/signal init`

1. Read `claude-config/scheduled-tasks.yaml` — the manifest lists every recurring job (PR triage, CI monitor, dependency audit, post-merge doc sync) with cron, prompt, output path, and budget fields (`max_tokens_per_run`, `max_runs_per_day`, `timeout_ms`).
2. For each entry, reconcile with existing scheduled tasks:
   - Missing → create
   - Present but changed → update
   - Present and unchanged → skip
3. Report what was created / updated / skipped.
4. Print the cron summary and next-run time for each.

## Steps — `/signal sync`

1. Confirm we're on `main` (or an adopter's mainline equivalent) after a merge. Refuse if on a feature branch.
2. **Invoke `signal-sync` skill** — runs the post-merge sync script:
   - Plan-file status markers: `in_progress` → `shipped`
   - CHANGELOG `[Unreleased]` validation + release-cut helper if requested
   - Cross-reference audit: every CHANGELOG entry traces to a merged PR; every plan references its specs
   - Stale-brief sweep: research briefs older than 180 days with no inbound references move to `docs/research/_archive/`
3. Review diff, commit as `chore: signal-sync after #<PR>`.

## Steps — `/signal audit`

1. Read every file under `docs/specs/` with `status:` other than `shipped`.
2. For each, diff against current code state — has the spec drifted? Are the acceptance criteria still accurate?
3. Summarise features shipped in the last 30 days (via merged PR list).
4. Write findings to `docs/signal/learnings.md` (append) and a transient report `docs/signal/audit-<YYYY-MM-DD>.md`.
5. Return: count of drifted specs, one-line per each with suggested action (`/spec feature <slug> --revise`).

## Steps — `/signal status`

1. Scheduled tasks — last run, next run, failure count in the last 7 days.
2. Open PRs — count, age of oldest.
3. CI health — last 10 runs on `main`, pass/fail ratio.
4. Recent incidents — last 5 `incident-runbook`-tagged issues or commits.
5. API spend (opt-in, requires `ANTHROPIC_ADMIN_KEY`) — month-to-date total, delta vs previous month.

Report in human-readable table by default; add `--json` for dashboard wiring.

## What this command does NOT do

- Write specs or code (that's `/spec` and `/ship`)
- Modify past CHANGELOG entries (immutable)
- Auto-archive briefs without a dry-run first
