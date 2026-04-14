# Stage 5: Run

> Automate the maintenance that keeps shipped products alive — PR triage, CI monitoring, dependency audits, and operational file processing.

## Why this stage exists

Most AI-assisted development guides end at deployment. Cursor's documentation
covers code generation and editing. Replit covers hosting. Neither offers
scheduled automation, recurring maintenance, or an operational layer for
non-code work. This is a critical gap: the moment a product ships, entropy
begins. Dependencies go stale, CI failures pile up unnoticed, documentation
drifts from reality, and administrative tasks accumulate in inboxes.

Without automated maintenance, technical debt compounds silently. A solo
founder shipping features all week will skip the Monday dependency audit, ignore
the flaky test that only fails on Tuesdays, and forget to update the API docs
after a schema migration. These are not character flaws — they are systemic
failures caused by relying on human memory for recurring work. The solution is
to make maintenance autonomous: define the task once, schedule it, and review
the output rather than performing the work manually.

This stage is also where the lifecycle becomes a loop. Issues discovered by
automated monitoring feed back into Stage 1 as research questions. Patterns
observed in operational work become product features. A dependency audit reveals
a deprecated package — that becomes a research task. A contract review surfaces
a recurring clause pattern — that becomes a template. Run is not the end of the
journey; it is the bridge back to the beginning.

## What you need

| Role | Recommended | Alternatives |
|---|---|---|
| Scheduled Automation | Claude Scheduled Tasks | GitHub Actions cron, any cron + AI API |
| Ops Surface | Claude Cowork | Manual processing, custom scripts |

## Automated maintenance

Schedule these tasks to run unattended. Each produces artefacts (PR comments,
new PRs, GitHub issues) that you review during your normal workflow. Your laptop
does not need to be open — scheduled tasks run on cloud infrastructure.

### Daily PR review triage

**Schedule:** `0 7 * * 1-5` (weekdays 07:00)

Reviews every open pull request for type safety, missing tests, security
concerns, performance issues, and inconsistency with existing codebase
patterns. Posts review comments with file-and-line references for any issues
found, or an approving comment with a brief summary for clean PRs.

**Prompt template (condensed):**

```
Review all open pull requests in this repository.

For each open PR:
1. Read the full diff
2. Summarise what the PR changes (2-3 sentences)
3. Check for: type safety issues, missing tests, security concerns,
   performance issues, pattern inconsistency, missing error handling
4. If issues found: post a review comment listing each with file:line
5. If clean: post an approving review comment with summary

Do not merge any PRs. Post review comments only.
```

**Review workflow:** Check GitHub notifications each morning. Fix flagged
issues, quick-scan approved PRs, then merge manually. Never auto-merge.

### CI failure monitor

**Schedule:** `0 9,11,13,15,17 * * 1-5` (every 2 hours during business hours)

Checks recent CI workflow runs. For straightforward failures (type errors, lint
violations, flaky tests), creates a fix branch and opens a PR with the
diagnosis. For failures requiring human judgement (architectural issues, failing
business logic tests), creates a GitHub issue with logs and a suggested
approach.

**Review workflow:** Merge auto-fix PRs after reviewing the diff. Prioritise
triage issues by severity. Investigate recurring failures for underlying
patterns.

### Weekly dependency audit

**Schedule:** `0 6 * * 1` (Monday 06:00)

Runs the package manager's audit command, flags critical vulnerabilities, and
lists outdated packages. Safe updates (patch and non-breaking minor versions)
are applied in a single PR with the full check suite run. Major version updates
and breaking changes are listed in the PR description under "Manual Review
Required" with links to changelogs and migration guides.

**Review workflow:** Review the update PR on Monday morning. Merge safe updates
if CI passes. Schedule time for major upgrades separately.

### Post-merge doc sync

**Schedule:** `0 8 * * 1-5` (weekdays 08:00)

Checks the git log for commits merged to main since the last run. If changes
affect API routes, database schema, auth flows, or environment variables,
creates a docs sync PR updating the corresponding documentation. Also checks
GitHub repository metadata (description, topics, homepage URL) against the
current README and tech stack, flagging any drift.

**Review workflow:** Review doc sync PRs for accuracy. If the task consistently
misses something, improve its prompt. Silent when no updates are needed.

### Writing your own task prompts

Follow this structure when creating new scheduled tasks:

```
[Clear objective — what should the tool do?]

For each [thing to check/process]:
1. [First action]
2. [Second action]
3. [Decision point]:
   - If [condition A]: [specific action with output format]
   - If [condition B]: [different action with output format]

[Constraints — what should the tool NOT do?]
```

**Tips:**
- Be explicit about constraints ("do not merge", "do not modify main directly")
- Specify output format ("create a PR with title format X")
- Include decision logic ("if straightforward, auto-fix; if complex, create an issue")
- Test interactively first — run the exact prompt in a live session before scheduling
- Start conservative — better to do too little than too much

## Operations

Non-code operational work — invoices, contracts, research, venture
administration — belongs in a dedicated ops surface, not in your codebase.

### Folder structure

```
~/Documents/Claude/
├── operations/
│   ├── invoices/          # Receipt photos, invoice PDFs
│   ├── contracts/         # Legal docs, equity deeds, agreements
│   ├── research/          # Market research, competitor analysis inputs
│   └── templates/         # Document templates for ops tasks
├── ventures/
│   ├── [venture-name]/
│   │   ├── meeting-notes/
│   │   ├── partner-comms/
│   │   └── timelines/
│   └── [another-venture]/
└── SKILL.md               # Persistent context — brand voice, processing rules
```

**Key principles:** One folder per concern (do not mix invoices with
contracts). Venture-specific work lives under `ventures/`; cross-venture
operations live under `operations/`. Drop files into the right folder first,
then ask the ops surface to process them.

### SKILL.md — persistent context

Create a `SKILL.md` in the root of your ops folder. This is the equivalent of
`CLAUDE.md` for non-code work — it persists across sessions and defines how
your ops surface behaves.

```markdown
# Ops Skills

## Brand Voice
- Professional but approachable
- Australian English (favour, colour, organisation)
- Short sentences, active voice

## Invoice Processing
When processing invoices in operations/invoices/:
1. Extract: date, vendor, amount (AUD), GST, category
2. Categories: Software, Infrastructure, Professional Services, Office, Travel
3. Append to operations/invoices/expenses.csv
4. Move processed files to operations/invoices/processed/
5. Flag any invoice over $1,000 for manual review

## Contract Review
When reviewing documents in operations/contracts/:
1. Extract: parties, effective date, term, key obligations, termination clauses
2. Check red flags: auto-renewal without notice, broad non-competes,
   unlimited liability, IP assignment without consideration, foreign governing law
3. Produce summary at operations/contracts/reviews/[filename]-review.md
4. Rate risk: Low / Medium / High with justification
```

Update `SKILL.md` as patterns emerge. If you keep correcting the same mistake,
add a rule to prevent it.

### Common ops tasks

- **Expense processing** — drop receipts into `invoices/`, extract data per SKILL.md rules, append to CSV, move to `processed/`
- **Contract review** — drop document into `contracts/`, produce a review summary with red flags and risk rating
- **Research compilation** — drop sources into `research/`, compile by theme into a brief with relevance scores and a "So What?" section
- **Venture administration** — organise meeting notes, extract action items, draft follow-up emails, update timelines
- **Document generation** — combine templates with source data to produce status reports, investor updates, or proposals

## The feedback loop

Stage 5 is not the end of the lifecycle — it is the bridge back to Stage 1.

Automated maintenance surfaces issues that become research questions: a
dependency audit reveals a deprecated package with no clear replacement (Stage 1
research); a CI monitor detects a recurring failure pattern that points to an
architectural weakness (Stage 2 spec work). Operational tasks reveal
opportunities: a contract review surfaces a clause pattern that should become a
template; an expense processing run reveals a spending category that needs
better tooling.

Capture these observations. File them as GitHub issues, add them to your
backlog, or note them in your next Stage 1 research session. The loop only
works if you close it.

## Exit criteria

- [ ] At least 2 scheduled tasks running (start with PR review + CI monitor)
- [ ] Ops folder structure set up with `SKILL.md` drafted
- [ ] Feedback captured for next iteration (issues filed, backlog updated)
- [ ] Review workflow defined for each active task

## Platform notes

- **Claude-native:** Scheduled Tasks for automated PR triage, CI monitoring, and dependency audits. Cowork for non-code ops. This is the most complete implementation — no gaps.
- **Cursor + Perplexity:** No native automation or ops surface. Use GitHub Actions for scheduled maintenance tasks. Non-code ops remain manual or require external tooling. This is the biggest gap in the Cursor ecosystem.
- **OutSystems ODC:** ODC Timers handle in-app scheduled jobs (data sync, cleanup). For external maintenance (dependency audits, documentation sync), use Claude Scheduled Tasks or GitHub Actions. Cowork handles ops tasks (invoicing, contracts) regardless of build platform.

## Anti-patterns

| Anti-pattern | Why it fails | Do this instead |
|---|---|---|
| No automation at all | Maintenance depends on memory; skipped when busy | Start with 2 tasks — PR review and CI monitor |
| Over-automate on day one | Untested prompts produce poor output at scale | Test each prompt interactively before scheduling |
| Trust AI ops output blindly | Extraction errors compound; risk ratings miss nuance | Review every output — AI is good at structure, less reliable at judgement |
| Skip SKILL.md | Inconsistent processing, same corrections every session | Write SKILL.md before your first ops session |
| No feedback loop | Issues discovered in Run never reach the backlog | File an issue or note for every pattern worth addressing |
