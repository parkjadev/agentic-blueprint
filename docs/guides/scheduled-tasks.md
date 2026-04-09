# Scheduled Tasks

Recurring automation playbook. Scheduled tasks let Claude work when you don't — the highest-leverage capability for a solo studio.

**Primary surface:** Scheduled Tasks (Anthropic cloud)
**Setup via:** `/schedule` in Claude Code CLI, claude.ai web, or Claude Desktop
**Related:** `release-workflow.md` (post-deploy verification), `mcp-setup.md` (MCP integrations)

---

## Overview

Scheduled tasks are Claude Code sessions that run unattended on a cron schedule. They attach to a repo, execute a prompt, and produce artefacts (PR comments, new PRs, issues, reports). They run on Anthropic's infrastructure — your laptop doesn't need to be open.

### When to Use

- Repetitive work you do daily/weekly that follows a consistent pattern
- Monitoring and triage that should happen whether you remember or not
- Maintenance tasks that are easy to forget when you're busy shipping features

### When NOT to Use

- Work that needs interactive back-and-forth (use Claude Code directly)
- One-off tasks (use Dispatch or Claude Code)
- Tasks you haven't validated interactively first (test the prompt manually before scheduling)

---

## Setup

### Creating a Scheduled Task

**Via Claude Code CLI:**

```
> /schedule
```

Follow the prompts to configure:
1. **Name** — descriptive, e.g., "daily-pr-review"
2. **Schedule** — cron expression or natural language
3. **Repo** — which repository to attach to
4. **Prompt** — what Claude should do (see templates below)

**Via claude.ai web:**

1. Navigate to Scheduled Tasks section
2. Click "New Task"
3. Configure name, schedule, repo, and prompt

### Key Configuration

| Setting | Purpose | Example |
|---|---|---|
| **Schedule** | When the task runs (cron syntax) | `0 7 * * 1-5` (weekdays at 07:00) |
| **Repo** | Which repository Claude operates on | `parkjadev/agentic-blueprint` |
| **Prompt** | What Claude should do | See templates below |
| **Timezone** | For interpreting the schedule | `Australia/Sydney` (AEST) |

---

## Task Patterns

Each pattern below includes the full prompt template, schedule, expected output, and a review workflow.

### Daily: PR Review Triage

The highest-ROI scheduled task. Ensures every open PR gets reviewed daily, even when you're deep in feature work.

**Schedule:** `0 7 * * 1-5` (Every weekday at 07:00 AEST)
**Repos:** All active repositories

#### Prompt Template

```
Review all open pull requests in this repository.

For each open PR:
1. Read the full diff
2. Summarise what the PR changes (2-3 sentences)
3. Check for:
   - Type safety issues (any, type assertions, missing types)
   - Missing or inadequate tests
   - Security concerns (hardcoded secrets, SQL injection, XSS)
   - Performance issues (N+1 queries, unnecessary re-renders, missing indexes)
   - Inconsistency with existing patterns in the codebase
   - Missing error handling on external calls
4. If issues found: post a review comment on the PR listing each issue with file and line reference
5. If clean: post an approving review comment with a brief summary

Do not merge any PRs. Do not create new branches or make code changes.
Post review comments only.
```

#### Expected Output

- Review comments posted directly on each open PR
- Issues flagged with specific file:line references
- Clean PRs approved with summary

#### Review Workflow

1. Check your GitHub notifications each morning after the task runs
2. For flagged PRs: review the comments, fix issues, push updates
3. For approved PRs: do a quick manual scan, then merge if satisfied
4. Never auto-merge — the task flags and approves, you decide

---

### Daily: CI Failure Monitor

Catches CI failures early and attempts auto-fixes, so broken builds don't block the team.

**Schedule:** `0 9,11,13,15,17 * * 1-5` (Every 2 hours during business hours AEST)
**Repos:** All active repositories

#### Prompt Template

```
Check the latest CI workflow runs in this repository.

For each failed run in the last 2 hours:
1. Identify which job failed (type-check, lint, test)
2. Read the failure logs
3. Diagnose the root cause
4. If the fix is straightforward (type error, lint violation, flaky test):
   - Create a new branch: fix/ci-[short-description]
   - Apply the fix
   - Run the check suite to verify
   - Create a PR with title "fix: resolve CI failure — [description]"
   - Include the diagnosis in the PR description
5. If the fix requires human judgement (architectural issue, failing business logic test):
   - Create a GitHub issue titled "CI failure: [description]"
   - Include the diagnosis, failure logs, and suggested approach
   - Label it as "bug" and "needs-triage"

Do not merge any PRs. Do not modify `main` directly.
```

#### Expected Output

- Auto-fix PRs for straightforward failures
- GitHub issues for complex failures requiring human judgement

#### Review Workflow

1. Check for auto-fix PRs — review the diff, merge if correct
2. Check for triage issues — prioritise based on severity
3. If a failure recurs across multiple runs, investigate the underlying pattern

---

### Weekly: Dependency Audit

Keeps dependencies current and secure without manual effort.

**Schedule:** `0 6 * * 1` (Every Monday at 06:00 AEST)
**Repos:** All active repositories

#### Prompt Template

```
Run a comprehensive dependency audit for this repository.

1. Check for security vulnerabilities:
   - Run the package manager's audit command
   - Flag any critical or high severity vulnerabilities
   - Note the affected package, vulnerability ID, and recommended fix

2. Check for outdated packages:
   - List packages with available major version updates
   - List packages with available minor/patch updates
   - Flag any deprecated packages

3. For safe updates (patch versions, minor versions with no breaking changes):
   - Create a single branch: chore/dependency-updates-[date]
   - Apply all safe updates
   - Run the full check suite (type-check, lint, test)
   - If checks pass: create a PR with title "chore: dependency updates [date]"
   - List every updated package with old → new version in the PR description

4. For major version updates or breaking changes:
   - Do NOT apply these automatically
   - List them in the PR description under a "Manual Review Required" section
   - Include links to the changelog/migration guide for each

Do not auto-merge. Do not update major versions without explicit approval.
```

#### Expected Output

- A single PR per repo with all safe dependency updates
- PR description includes full audit report and manual review items

#### Review Workflow

1. Review the dependency update PR on Monday morning
2. Check the "Manual Review Required" section for breaking changes
3. Merge safe updates if CI passes
4. Schedule time for major version upgrades if needed

---

### Post-Merge: Doc Sync

Keeps documentation in sync with code changes automatically.

**Schedule:** `0 8 * * 1-5` (Every weekday at 08:00 AEST — checks for merges since last run)
**Repos:** All active repositories

#### Prompt Template

```
Check the git log for any commits merged to main since yesterday.

For each merge, check if the changes affect:
- API routes (src/app/api/**) → update docs/api-reference.md
- Database schema (src/lib/db/schema.ts) → update the relevant data-model-spec.md
- Auth flows (src/lib/auth/**, src/middleware.ts) → update auth-spec.md
- Environment variables (src/env.ts) → update deployment.md

Then run the GitHub-side metadata check (see "Doc Sweep Checklist" in
agentic-workflow.md Phase 10):

  gh repo view --json description,homepageUrl,repositoryTopics

Compare against the current README headline and tech stack. If any of:
- description no longer reflects what the project does
- homepageUrl is dead or points at a stale environment
- topics are missing a major piece of the stack
…then they should be updated as part of this sync.

If documentation updates are needed:
1. Create a branch: docs/sync-[date]
2. Update the affected documentation to reflect the code changes
3. If GitHub metadata is stale, include the gh repo edit commands in the PR description
4. Run a consistency check: do the docs match the current code?
5. Create a PR with title "docs: sync documentation with recent changes"
6. List each documentation file (and any GitHub metadata field) that needs updating

If no documentation updates are needed, do nothing (no PR, no issue, no comment).
```

#### Expected Output

- Doc sync PR when code changes affect documented surfaces
- No output when changes don't affect docs (silent success)

#### Review Workflow

1. Review doc sync PRs — check that the updates are accurate
2. Merge if the documentation correctly reflects the code
3. If the task misses something, improve the prompt to cover that case

---

## Creating Your Own Patterns

### Template Structure

When creating a new scheduled task, follow this structure:

```
[Clear objective — what should Claude do?]

For each [thing to check/process]:
1. [First action]
2. [Second action]
3. [Decision point]:
   - If [condition A]: [specific action with output]
   - If [condition B]: [different action with output]

[Constraints — what should Claude NOT do?]
```

### Tips for Effective Prompts

- **Be explicit about constraints.** "Do not merge" is better than assuming Claude won't.
- **Specify output format.** "Create a PR with title format X" prevents inconsistent naming.
- **Include decision logic.** "If straightforward, auto-fix. If complex, create an issue." gives Claude clear rules.
- **Test interactively first.** Run the exact prompt in a live Claude Code session. Validate the output. Only schedule it once you trust the results.
- **Start conservative.** It's better to schedule a task that does too little (and you add to it) than one that does too much (and you have to clean up).

### Monitoring Scheduled Tasks

Check your scheduled tasks regularly:

- **Daily:** Scan GitHub notifications for task output (PR comments, new PRs, issues)
- **Weekly:** Review the scheduled task dashboard — are tasks running? Any failures?
- **Monthly:** Evaluate task quality — are the outputs useful? Any prompts need tuning?

---

## Checklist

- [ ] Task tested interactively in Claude Code first
- [ ] Prompt is explicit about what to do AND what not to do
- [ ] Schedule and timezone are correct
- [ ] Repo is attached
- [ ] Output format is specified (PR, comment, issue)
- [ ] Review workflow is defined (how you'll check the output)
- [ ] Constraints prevent destructive actions (no auto-merge, no force push)

---

*See `docs/guides/claude-surfaces.md` for the full surface decision tree.*
*See `docs/guides/agentic-workflow.md` for how scheduled tasks fit into the lifecycle.*
