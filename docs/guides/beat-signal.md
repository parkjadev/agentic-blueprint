# Beat — Signal

> Run + monitor + learn + scheduled automation. Feeds back into Spec.

## Why this beat exists

Shipping is not the end of the story. Production systems drift: dependencies age, error rates spike quietly, scheduled tasks fail without alerts, research briefs go stale, CHANGELOGs accumulate pending entries. v3 called this "Run" and treated it as an afterthought. v4 promotes it to a first-class beat because the loop back from production into the next `/spec idea` is where durable improvement actually happens.

**Signal** is also where the solo-developer substitute for peer review lives. Without a team to catch drift, the developer needs automated periodic self-review — `/signal audit` plays that role.

## Sub-verbs

| Sub-verb | Purpose |
|---|---|
| `/signal init` | Install the scheduled-task manifest (`claude-config/scheduled-tasks.yaml`) into Claude Scheduled Tasks or GitHub Actions cron |
| `/signal sync` | Post-merge close-out: plan-status markers, CHANGELOG validation, cross-reference audit, stale-brief archival |
| `/signal audit` | Periodic self-review: open-spec drift check, 30-day shipped-features summary, prompt to revise parent idea |
| `/signal status` | Dashboard — scheduled tasks, open PRs, CI health, recent incidents, API spend (opt-in). `--json` flag for external wiring |

Default (no sub-verb) runs `/signal status`.

## How it works — `/signal init`

Reads `claude-config/scheduled-tasks.yaml` — the manifest listing every recurring job with cron, prompt, output path, and budget fields (`max_tokens_per_run`, `max_runs_per_day`, `timeout_ms`). Reconciles each entry with existing scheduled tasks:

- Missing → create.
- Present but changed → update.
- Present and unchanged → skip.

Prints the resulting cron summary and next-run time. Idempotent — rerun any time the manifest changes.

Default four recurring jobs shipped in the manifest:

| Job | Cron | Purpose |
|---|---|---|
| PR triage | `0 7 * * 1-5` | Scan open PRs each morning, comment on stale ones, flag unreviewed |
| CI failure monitor | `0 9,11,13,15,17 * * 1-5` | Check `main` CI every 2 hours during business hours |
| Dependency audit | `0 6 * * 1` | Weekly dependency + advisory scan → `docs/signal/dependencies.md` |
| Post-merge doc sync | `0 8 * * 1-5` | Daily `/signal sync` on `main` to keep plan status + CHANGELOG fresh |

## How it works — `/signal sync`

Runs on `main` after a merge (refuses on a feature branch). Invokes the `signal-sync` skill:

1. Plan-status markers: `in_progress` → `shipped` for any plan whose feature merged.
2. CHANGELOG `[Unreleased]` validation — every entry traces to a merged PR. Release-cut helper if requested.
3. Cross-reference audit — broken internal links, stale `TODO:` markers, plan-spec alignment.
4. Stale-brief sweep: research briefs older than 180 days with no inbound references move to `docs/research/_archive/`.

Reviews the diff, commits as `chore: signal-sync after #<PR>`.

## How it works — `/signal audit`

Solo-dev substitute for a peer reviewer. Runs weekly (typically via scheduled task):

1. Reads every `docs/specs/*.md` with `status:` other than `shipped`.
2. For each, diffs against current code state. Has the spec drifted? Are the acceptance criteria still accurate?
3. Summarises features shipped in the last 30 days (via merged PR list).
4. Appends findings to `docs/signal/learnings.md` (accumulating, durable) and writes a transient report to `docs/signal/audit-<YYYY-MM-DD>.md`.
5. Returns: count of drifted specs, one-line per each with suggested action (`/spec feature <slug> --revise`).

The `docs/signal/learnings.md` file is what future `/spec idea` runs read to avoid re-litigating past decisions.

## How it works — `/signal status`

Five readouts:

1. **Scheduled tasks** — last run, next run, failure count in the last 7 days.
2. **Open PRs** — count, age of oldest, number stale (>7 days).
3. **CI health** — last 10 runs on `main`, pass/fail ratio.
4. **Recent incidents** — last 5 `incident-runbook`-tagged issues or commits.
5. **API spend** (opt-in, requires `ANTHROPIC_ADMIN_KEY`) — month-to-date total + delta vs previous month.

Human-readable by default; `--json` for dashboard wiring.

## Cost and agent guardrails

Scheduled-task entries in `claude-config/scheduled-tasks.yaml` accept budget fields:

```yaml
- name: pr-triage
  cron: "0 7 * * 1-5"
  max_tokens_per_run: 50000
  max_runs_per_day: 5
  timeout_ms: 300000
```

Exceeding any budget aborts the run and logs to `docs/signal/agent-log.md`. Subagents invoked from scheduled tasks inherit these limits.

## The feedback loop

Signal feeds Spec. The `docs/signal/learnings.md` file + the weekly `/signal audit` output are inputs for the next `/spec idea --revise <product>` pass. Incidents captured in `docs/templates/incident-runbook.md`-filled files surface common failure modes that shape the next iteration's non-goals and success metrics.

## Exit criteria (post-install)

- At least the 4 default scheduled tasks are running (via `/signal init`).
- `docs/signal/` is bootstrapped with `learnings.md`, `agent-log.md`, `dependencies.md`, `spend.md` — accumulating logs seeded empty at install.
- A `/signal audit` has run at least once so the team understands its output shape.

## Platform

Scheduled automation fills the Signal beat's Scheduled-automation role. The canonical example is Claude Scheduled Tasks, but anything that can run a cron plus hit an AI API works — GitHub Actions `schedule`, external task runners, or project-native timers where the stack provides them. The monitoring + Ops-surface roles map to whatever dashboards and runbook targets the deploy stack provides. See `docs/guides/tool-reference.md` for the role × inputs matrix.

## Anti-patterns

| Anti-pattern | Why it fails | Do this instead |
|---|---|---|
| No automation at all | Small problems accumulate until they become incidents; the developer spends time on toil | Install the 4 default scheduled tasks via `/signal init` on day one |
| Over-automate on day one | Noisy alerts train the developer to ignore automation output | Start with the 4 defaults; add more only when a specific pain point justifies it |
| Trust AI ops output blindly | Scheduled-task output is a signal, not a verdict; drift and false positives happen | Review `docs/signal/agent-log.md` weekly during `/signal audit` |
| Skip `/signal audit` | Specs silently drift from reality; parent PRDs calcify against new learnings | Run `/signal audit` weekly (it's one of the 4 default scheduled tasks) |
| No feedback into next Spec | Learnings stay in the developer's head; next idea repeats past mistakes | Append to `docs/signal/learnings.md` after incidents and audits; `/spec idea` reads it automatically |

---

*Previous beat: [Ship](beat-ship.md)*
