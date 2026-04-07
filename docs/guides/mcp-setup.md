# MCP Setup

How to configure Model Context Protocol (MCP) integrations for Claude Code: Vercel deployments, GitHub operations, Dispatch, and custom MCP servers.

**Primary surface:** Claude Code (Terminal)
**Related:** `feature-workflow.md`, `release-workflow.md`, `remote-workflow.md`

---

## Overview

MCP extends Claude Code with external tool access. Instead of switching between the terminal and web dashboards, Claude can directly query deployment status, read logs, manage PRs, and interact with third-party services.

Key integrations:

| Integration | Purpose | How |
|---|---|---|
| **Vercel** | Deployments, logs, preview URLs | Vercel MCP server |
| **GitHub** | Issues, PRs, actions, repos | `gh` CLI (built-in, no MCP needed) |
| **Dispatch** | Remote task assignment from mobile | Claude mobile app |
| **Custom MCP** | Project-specific external APIs | Custom MCP server |

---

## Vercel MCP

### What It Provides

- List and inspect deployments
- Read build logs and runtime logs
- Check deployment status (building, ready, error)
- Access preview URLs
- Monitor production deployments

### Setup

1. **Install the Vercel MCP server** — follow the [Vercel MCP documentation](https://vercel.com/docs/workflow-collaboration/vercel-mcp) for current setup instructions

2. **Configure in Claude Code** — add to your project's `.claude/settings.local.json`:

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

3. **Verify** — in Claude Code:

```
> List my Vercel projects.
```

### Common Usage Patterns

**Check deployment status after merge:**
```
> Check the latest production deployment for [project]. Is it healthy?
```

**Read build logs when deploy fails:**
```
> The latest staging deployment failed. Show me the build logs.
```

**Monitor preview deploys on PRs:**
```
> What's the preview URL for the latest deployment? Check if it's ready.
```

**Post-deploy verification:**
```
> Check the production runtime logs for the last 30 minutes. Any errors?
```

---

## GitHub via `gh` CLI

### What It Provides

GitHub integration doesn't need MCP — the `gh` CLI is available directly in Claude Code's terminal. It covers:

- Issue management (create, list, close, comment)
- PR management (create, review, merge)
- Actions/CI status (list runs, view logs)
- Repository management (clone, fork, settings)
- Release management (create, list)

### Setup

The `gh` CLI should already be authenticated. Verify in Claude Code:

```
> Run gh auth status
```

If not authenticated, run `gh auth login` in your terminal outside Claude Code.

### Common Usage Patterns

**Create an issue from a spec:**
```
> Create a GitHub issue for implementing [feature]. Reference the spec at docs/specs/[feature]/technical-spec.md.
> Add labels: enhancement, P0. Assign to me.
```

**Check CI status:**
```
> Check the CI status for this PR. If it failed, show me the failing job logs.
```

**List open PRs:**
```
> List all open PRs in this repo. Show title, author, and CI status.
```

**Review a PR:**
```
> Review PR #42. Check the diff against the technical spec. Flag any issues.
```

**Create a release:**
```
> Create a GitHub release for v1.2.0. Use the CHANGELOG.md entry as release notes.
```

---

## Dispatch

### What It Provides

Dispatch lets you assign tasks to Claude Code from the Claude mobile app. Claude works on your desktop machine while you're away.

### Setup

1. **Claude Code must be running** on your desktop (or use `claude --daemon` for background operation)
2. **Claude mobile app** installed and signed in to the same account
3. **Repo must be open** in the Claude Code session

### How to Use

From the Claude mobile app:

1. Open Dispatch
2. Select the target machine and repo
3. Describe the task:

> "In agentic-blueprint, create a PR that adds error handling to the health check endpoint. Follow the patterns in the existing API routes."

4. Claude works autonomously on your desktop
5. When you return, the work is done — review the PR

### Best Practices

- **Be specific.** "Fix the bug" is too vague. "Fix the 401 error on GET /api/projects when using mobile JWT — the token verification is checking the wrong claim" is actionable.
- **Reference files and issues.** "See issue #42 and the spec at docs/specs/auth/auth-spec.md" gives Claude context.
- **Set clear acceptance criteria.** "The PR should include a regression test and all checks should pass."
- **Don't use for interactive work.** If the task needs back-and-forth, wait until you're at your desk.

---

## Custom MCP Servers

### When to Build One

Build a custom MCP server when you need Claude Code to interact with an external service that doesn't have an existing MCP integration:

- Internal APIs (admin dashboards, monitoring)
- Third-party services (Slack, Linear, custom CRM)
- Database inspection tools
- Project-specific utilities

### Skeleton

A minimal MCP server in TypeScript:

```typescript
// mcp-server/index.ts
import { McpServer } from '@anthropic-ai/mcp';

const server = new McpServer({
  name: 'my-project-mcp',
  version: '1.0.0',
});

// Define a tool
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

### Configuration

Add your custom MCP server to `.claude/settings.local.json`:

```json
{
  "mcpServers": {
    "my-project": {
      "command": "npx",
      "args": ["tsx", "mcp-server/index.ts"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

### Tips

- Keep MCP servers focused — one server per integration, not one mega-server
- Handle errors gracefully — Claude needs useful error messages to self-correct
- Include descriptions on every tool — Claude uses these to decide when to call each tool
- Don't put secrets in the server code — use environment variables via the `env` config

---

## Scheduled Task Integration

Scheduled Tasks can use MCP tools if configured. This enables automation patterns like:

- **Post-deploy health check:** Scheduled task runs after merge, uses Vercel MCP to check deployment status
- **Daily monitoring:** Scheduled task uses custom MCP to check external service health
- **Automated reporting:** Scheduled task uses GitHub CLI to generate weekly PR/issue summaries

See `docs/guides/scheduled-tasks.md` for the full scheduled tasks playbook.

---

## Troubleshooting

### MCP server won't connect

1. Check the command path — can you run it manually in the terminal?
2. Check environment variables — are they set correctly?
3. Check Claude Code logs for connection errors
4. Try restarting Claude Code after config changes

### `gh` CLI not authenticated

Run outside Claude Code:
```bash
gh auth login
```

Follow the browser-based auth flow. Once authenticated, it works in Claude Code automatically.

### Vercel MCP returns permission errors

1. Check your Vercel token has access to the project
2. Verify the token isn't expired
3. Ensure the token has the required scopes (read deployments, read logs)

---

*See `docs/guides/claude-surfaces.md` for the full surface decision tree.*
*See `docs/guides/agentic-workflow.md` for the full lifecycle reference.*
