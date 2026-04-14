# Tool Reference

> Which tool for which role — a decision framework, not a vendor pitch.

## The role model

Instead of mapping to specific products, this guide maps to **roles** that any
tool can fill. Choose the best available tool for each role based on your stack.

| Role | What it does | Claude | Cursor | Replit | Other |
|---|---|---|---|---|---|
| Research Tool | Deep research, market analysis, source synthesis | Claude web search | — | — | Perplexity, ChatGPT, Gemini |
| Thinking Partner | Brainstorm, PRD, strategy, critical assessment | Desktop Chat (Projects) | — | — | Any LLM with persistent context |
| Agentic Coder | Read codebase, write code, run tests, commit | Code CLI + VS Code | Agent + Background Agents | Agent | GitHub Copilot, Windsurf |
| Deployment Pipeline | CI/CD, preview deploys, monitoring | Code + Vercel MCP | GitHub/Vercel integrations | Built-in hosting | Any CI/CD pipeline |
| Scheduled Automation | Recurring tasks, monitoring, triage | Scheduled Tasks | — | — | GitHub Actions cron + AI API |
| Ops Surface | Non-code file processing, document generation | Cowork | — | — | Custom scripts, manual |
| Mobile Supervision | Remote monitoring, async delegation | Remote Control + Dispatch | Mobile agent | — | — |

### Reading the table

The "Claude" column lists the specific surface within the Claude ecosystem. The
"Other" column is not exhaustive — it lists common alternatives to illustrate
that the role can be filled by multiple tools. The Blueprint's guides are
written with Claude surfaces as the primary example, but the *patterns* apply
regardless of which tool fills each role.

Gaps in the table are meaningful. If a tool has no entry for Scheduled
Automation, it means that tool has no native equivalent — you would need to
build the capability yourself (e.g. a GitHub Actions cron job that calls an AI
API). The Blueprint covers those workarounds where relevant.

## Handoff patterns

Tools rarely operate in isolation. Most real work flows through multiple roles.
These are the proven handoff patterns.

### Thinking Partner to Agentic Coder

The most common handoff. Think through the problem in the thinking partner —
explore trade-offs, draft the approach. Once the approach is clear, summarise
the key decisions and hand off to the agentic coder with that context. The
coder writes specs, creates issues, and builds features.

**Why this works:** The thinking tool is unconstrained by tooling — you explore
freely without accidentally triggering file writes or commands. The coder is
constrained by design — it plans, you approve, it executes.

### Agentic Coder to Scheduled Automation

Develop and test a workflow interactively in the coder. Once it is reliable,
extract the prompt and schedule it to run on a cron. The scheduled task produces
artefacts (PRs, comments, issues) that you review during your normal workflow.

**Example:** You manually review PRs for a week using the coder. Once you trust
the review quality, schedule it as a daily task.

### Thinking Partner to Ops Surface

Use the thinking partner to frame the research strategy — what matters, what
does not, how to organise findings. Then drop raw materials into the ops folder
and tell the ops surface to compile using the structure you developed.

### Agentic Coder to Mobile Supervision

Start a long-running task in the coder on your desktop with a clear plan. Step
away. Use mobile supervision to monitor progress, approve actions, and steer
direction. Return to completed or near-complete work.

## Decision tree

Use this when you are not sure which tool to reach for.

```
What are you doing?
│
├─ Researching or thinking through a problem?
│  └─ Research Tool + Thinking Partner
│     Tip: Use persistent project context to accumulate decisions
│
├─ Writing specs or code?
│  ├─ Heavy multi-file work, running commands?
│  │  └─ Agentic Coder (CLI / primary agent)
│  ├─ Small targeted edit, reviewing a diff?
│  │  └─ Agentic Coder (editor extension)
│  └─ No local clone, working from browser?
│     └─ Agentic Coder (web / cloud IDE)
│
├─ Deploying or checking deployment status?
│  └─ Deployment Pipeline
│     Tip: Smoke-test preview URLs before merging
│
├─ Is it a recurring task that should run unattended?
│  └─ Scheduled Automation
│     Tip: Start with daily PR review — highest ROI
│
├─ Processing non-code files (invoices, contracts, research)?
│  └─ Ops Surface
│     Tip: Set up SKILL.md for consistent processing rules
│
├─ Away from your desk but need to check on work?
│  ├─ Session already running? → Monitor and approve remotely
│  └─ Need to start new work? → Delegate async task
│
└─ Not sure?
   └─ Default to Agentic Coder — it can do the most
```

## MCP integrations

Model Context Protocol extends your agentic coder with external tool access.
Instead of switching between terminal and web dashboards, the agent queries
deployment status, reads logs, and manages services directly.

### Vercel MCP

Provides deployment inspection, build and runtime logs, preview URLs, and
production monitoring.

**Configuration** (`.claude/settings.local.json`):

```json
{
  "mcpServers": {
    "vercel": {
      "command": "npx",
      "args": ["-y", "vercel-mcp-server"],
      "env": {
        "VERCEL_TOKEN": "your-vercel-token"
      }
    }
  }
}
```

**Common usage:**
- Check deployment status after merge: `Check the latest production deployment. Is it healthy?`
- Read build logs on failure: `The preview deployment for PR #42 failed. Show me the build logs.`
- Post-deploy verification: `Check production runtime logs for the last 30 minutes. Any errors?`

### GitHub (gh CLI)

Already authenticated via `gh auth login` — no MCP server needed. Covers
issues, PRs, CI status, releases, and repository management.

**Common usage:**
- Create issues: `gh issue create --title "..." --label "type:feature,scope:api"`
- Check CI: `gh run list --limit 5`
- Create releases: `gh release create v1.0.0 --notes "..."`
- Review PRs: `gh pr view 42 --comments`

### Custom MCP servers

Build a custom MCP server when you need your agent to interact with a service
that lacks an existing integration — internal APIs, third-party services
(Slack, Linear), database inspection, or project-specific utilities.

**Minimal TypeScript skeleton:**

```typescript
import { McpServer } from '@anthropic-ai/mcp';

const server = new McpServer({
  name: 'my-project-mcp',
  version: '1.0.0',
});

server.tool('check-service-status', {
  description: 'Check the status of an external service',
  parameters: {
    type: 'object',
    properties: {
      service: { type: 'string', description: 'Service name' },
    },
    required: ['service'],
  },
  handler: async ({ service }) => {
    // TODO: Implement actual status check
    const response = await fetch(`https://api.example.com/status/${service}`);
    const data = await response.json();
    return { status: data.status, lastChecked: new Date().toISOString() };
  },
});

server.start();
```

**Tips:** One server per integration (not one mega-server). Handle errors
gracefully — the agent needs useful messages to self-correct. Use environment
variables for secrets, never hardcode them.

## Plan-mode patterns

These patterns separate cheap plans from expensive ones. Apply them whenever
your agentic coder produces an implementation plan before writing code.

### Pre-flight existence checks

Every line in a plan that claims "X is missing" or "needs Y" must be confirmed
by actually reading the file first. Plans built from memory and assumption are
wrong roughly half the time — items downgrade once you inspect the current
state. The fix is cheap: read the files before planning.

### Reference files by full path

Every file the plan touches gets named by its repo-relative path
(`src/lib/auth/get-auth.ts`), not by description ("the auth helper"). The
implementation phase should not have to re-search to find what the plan was
referring to.

### Include "What's already in place"

Every approved plan should include a section near the top listing what already
exists and is excluded from the plan. This prevents the agent from re-exploring
code the plan author already read and stops it from re-suggesting work that is
already done.

### Reference issue templates and label vocabulary

When the plan calls for filing implementation issues, it should already know the
type/scope label for each one. A plan that says "file `feat/profile` issue with
`type:feature, scope:dashboard`" is ready to execute; "file an issue for the
profile feature" is not.

## Doc-sweep checklist

Run this after every user-visible change — new features, renamed endpoints,
stack swaps, deprecated modules. These items drift silently if not checked.

- [ ] **README** — does the headline still describe what the project does? Does the quickstart still work?
- [ ] **CHANGELOG.md** — is the change under `[Unreleased]` with the issue number?
- [ ] **GitHub repo description** — `gh repo view --json description --jq .description`. Still accurate?
- [ ] **GitHub repo topics** — `gh repo view --json repositoryTopics --jq '.repositoryTopics[].name'`. Still reflect the stack?
- [ ] **GitHub About URL** — `gh repo view --json homepageUrl --jq .homepageUrl`. Points at a live deployment?
- [ ] **Architecture diagram** — if docs reference components that moved, update them
- [ ] **CLAUDE.md / project config** — did you change a hard rule, file path, or pattern that the config documents?

> Update GitHub-side metadata via the CLI (`gh repo edit --description "..." --add-topic foo --homepage https://...`), not the web UI. The web UI is the easiest place to forget.

## Anti-patterns

| Anti-pattern | Why it fails | Do this instead |
|---|---|---|
| Code in the thinking tool | No codebase context, cannot test or commit | Think in the thinking partner, build in the agentic coder |
| Ideate in the terminal | The agent wants to take action, creates friction when you are just exploring | Brainstorm in the thinking partner, switch to the coder when ready |
| Skip the plan step | The agent makes architectural decisions you disagree with, costly to undo | Always review the plan before any code is written |
| Skip specs entirely | Ambiguity compounds — you spend more time correcting than writing | Write specs, even brief ones, before coding |
| Schedule untested prompts | Poor output quality discovered days later | Test every prompt interactively in a live session before scheduling |
| Do routine work manually | Inconsistent execution, easy to skip when busy | Automate with scheduled tasks — they run whether you remember or not |
| One giant PR | Hard to review, risky to deploy, blocks everything | One feature per branch, one branch per PR |
| Use the editor extension as primary surface | Works for small edits but hits limitations on multi-file features | Use the CLI agent as primary; editor extension for targeted edits and diffs |
| Trust AI judgement calls without review | Extraction is reliable, risk assessment is not | Review every output that involves a judgement call |
| Never update project config | The agent loses context on future sessions, repeats mistakes | Keep CLAUDE.md and SKILL.md current as the project evolves |
