# Claude Surfaces Guide

Which Claude surface to use, when, and how to hand off between them.

This is the anchor document for the entire blueprint. Every other guide references this one. If you read nothing else, read this.

---

## The Core Principle

Each Claude surface is optimised for a specific mode of work. Using the wrong surface for the job creates friction, wastes context, and produces worse outcomes. The rule is simple:

- **Think** where thinking is cheap (Chat)
- **Build** where building is powerful (Code)
- **Automate** where automation is native (Scheduled Tasks)
- **Operate** where files live (Cowork)
- **Supervise** where you are (Mobile)

---

## The Claude Stack — Surface Map

| Surface | Access | Optimised For | Strengths | Limitations |
|---|---|---|---|---|
| **Claude Desktop — Chat** | Desktop app, web (claude.ai), mobile | Strategic thinking, PRD drafting, document review, critical assessment | Long conversational context, Projects for persistent venture context, file uploads for review, no tooling overhead | No codebase access, no file writes, no CLI tools |
| **Claude Desktop — Cowork** | Desktop app (Mac/Windows) | Agentic file automation, non-code tasks | Reads/writes local files, processes PDFs and images, works on folders autonomously | No git, no CLI tools, no deployments, research preview |
| **Claude Code — Terminal CLI** | Terminal (`claude` command) | Full codebase operations, agentic coding | Full filesystem + git + CLI access, plan → approve → execute, MCP integrations, hooks | Terminal-first (no inline autocomplete), requires local repo clone |
| **Claude Code — VS Code Extension** | VS Code sidebar | Inline diffs, @-mentions, plan review within editor | Visual diffs, file-scoped context via @-mentions, tight editor integration | Narrower context than Terminal CLI, secondary to CLI for heavy work |
| **Claude Code — Web** | claude.ai/code | Browser-based coding, no local setup required | Access any repo without cloning, parallel sessions, works from any device | No local filesystem access, no custom MCP servers |
| **Claude Code — Scheduled Tasks** | CLI (`/schedule`), web, desktop | Recurring automated jobs on Anthropic cloud | Runs unattended on a cron, repo-attached, produces PRs and comments | No interactive approval, limited to what can be expressed in a prompt |
| **Dispatch** | Claude mobile app | Remote task assignment to desktop Claude Code | Assign work from your phone, Claude works on your desktop, return to completed results | One-way assignment — no interactive back-and-forth during execution |
| **Remote Control** | Claude mobile app | Monitor and control active Claude Code sessions | Approve actions, read output, steer direction — all from your phone | Requires an active Claude Code session already running |

---

## Lifecycle Stage → Surface Map

This is the primary reference table. For every stage of the product lifecycle, it tells you which surface to use and how work flows to the next stage.

| Lifecycle Stage | Primary Surface | Secondary Surface | Handoff Pattern |
|---|---|---|---|
| **Ideation** | Claude Desktop Chat | — | Conversation → exported summary → commit to repo |
| **PRD Drafting** | Claude Desktop Chat (Projects) | — | Iterate in Chat → finalise as markdown → commit via Code |
| **Critical Review** | Claude Desktop Chat (Projects) | — | Upload document → request assessment → incorporate feedback |
| **Technical Specs** | Claude Desktop Chat → Claude Code | — | Think through approach in Chat → write specs in Code → commit |
| **Issue Creation** | Claude Code (Terminal) | — | `gh issue create` with labels, assignees, project board |
| **Feature Development** | Claude Code (Terminal) | VS Code Extension | Plan → approve → code → test → PR |
| **Code Review** | Claude Code (Terminal) | VS Code Extension | Review diffs, run checks, approve or request changes |
| **Testing** | Claude Code (Terminal) | — | Write + run tests, lint, type-check |
| **Deployment** | Claude Code + Vercel MCP | — | Push → monitor deploy → promote staging → production |
| **CI Monitoring** | Scheduled Tasks | Remote Control (mobile) | Auto-triage failures → notify → fix or escalate |
| **PR Triage** | Scheduled Tasks | — | Daily automated review → comment on PRs → flag issues |
| **Dependency Audit** | Scheduled Tasks | — | Weekly scan → create update PR → await human merge |
| **File Operations** | Cowork | — | Point at folder → describe task → review output |
| **Document Generation** | Cowork | — | Templates + data → generated output → review |
| **Research Compilation** | Claude Desktop Chat | Cowork | Think and strategise in Chat → compile and organise in Cowork |
| **Mobile Supervision** | Remote Control | Dispatch | Monitor active sessions → approve actions from phone |
| **Task Delegation** | Dispatch (mobile) | — | Assign from phone → Claude works on desktop → return to results |

---

## Decision Tree

Use this when you're not sure which surface to reach for.

```
What are you doing?
│
├─ Thinking, planning, or reviewing a document?
│  └─ Use Claude Desktop Chat
│     └─ Tip: Use Projects to keep venture-specific context persistent
│
├─ Writing or modifying code?
│  ├─ Heavy feature work, multi-file changes, or running commands?
│  │  └─ Use Claude Code (Terminal CLI)
│  ├─ Small targeted edit or reviewing a specific diff?
│  │  └─ Use Claude Code (VS Code Extension)
│  └─ No local clone available or working from browser?
│     └─ Use Claude Code (Web)
│
├─ Processing non-code files (invoices, contracts, research)?
│  └─ Use Cowork
│     └─ Tip: Set up SKILL.md for consistent processing rules
│
├─ Setting up recurring automation?
│  └─ Use Scheduled Tasks
│     └─ Tip: Start with daily PR review — highest ROI
│
├─ Away from your desk but need to check on work?
│  ├─ Is a Claude Code session already running?
│  │  └─ Use Remote Control to monitor and approve
│  └─ Need to start new work?
│     └─ Use Dispatch to assign a task
│
└─ Not sure?
   └─ Default to Claude Code (Terminal CLI) — it can do the most
```

---

## Handoff Patterns

Surfaces rarely operate in isolation. Most real work flows through multiple surfaces. These are the proven handoff patterns.

### Chat → Code (the most common handoff)

**When:** You've finished thinking and need to start building.

**Pattern:**
1. Think through the problem in Claude Desktop Chat — explore trade-offs, draft the approach
2. Once the approach is clear, summarise the key decisions
3. Open Claude Code and reference those decisions: "Implement the approach we discussed — [paste summary]"
4. Claude Code writes specs, creates issues, builds features

**Why this works:** Chat is unconstrained by tooling. You can explore freely without accidentally triggering file writes or CLI commands. Code is constrained by design — it plans, you approve, it executes.

**Anti-pattern:** Trying to write code in Chat. Chat will produce code blocks, but it can't run them, test them, lint them, or commit them. The code will be stale the moment you paste it.

### Code → Scheduled Tasks (automate the routine)

**When:** You've built a workflow that should run unattended.

**Pattern:**
1. Develop and test the workflow interactively in Claude Code
2. Once it's reliable, extract the prompt and schedule it via `/schedule`
3. Scheduled task runs on cron, produces PRs or comments
4. You review the output during your normal workflow

**Example:** You manually review PRs for a week using Claude Code. Once you trust the review quality, schedule it as a daily task.

**Anti-pattern:** Scheduling a task you haven't validated interactively first. If the prompt doesn't produce good results in a live session, it won't improve by running unattended.

### Chat → Cowork (think then compile)

**When:** You need to produce a structured document from unstructured research.

**Pattern:**
1. Use Chat to think through the research — what matters, what doesn't, how to frame it
2. Drop raw materials (PDFs, articles, screenshots) into your Cowork folder
3. Tell Cowork to compile using the structure you developed in Chat

**Why this works:** Chat is better at strategic framing. Cowork is better at processing many files and producing structured output.

### Code → Remote Control (start then supervise)

**When:** You're starting a long-running task and need to step away.

**Pattern:**
1. Start the task in Claude Code on your desktop — give it a clear plan
2. Walk away. Open the Claude mobile app.
3. Use Remote Control to monitor progress, approve actions, steer direction
4. Return to your desktop with the work completed or ready for final review

**Anti-pattern:** Using Remote Control for tasks that need your full attention. If you're approving every action from your phone, you'd be faster at your desk.

### Dispatch → Code (delegate then return)

**When:** You think of something that needs doing but you're not at your desk.

**Pattern:**
1. Open the Claude mobile app
2. Use Dispatch to describe the task: "In repo X, create a PR that fixes issue #42"
3. Claude works on your desktop machine
4. When you return, the PR is ready for review

**Why this works:** Dispatch is async by design. You describe what you want, Claude figures out how. No interactive back-and-forth needed.

---

## Anti-Patterns

These are common mistakes that waste time or produce poor results. Each one maps to a surface being used outside its strength.

### Don't code in Chat

**What happens:** You ask Chat to write a function. It produces a plausible code block. You paste it into your editor. It doesn't account for your imports, your types, your existing patterns. You spend 20 minutes adapting it.

**Instead:** Think through the approach in Chat. Build in Code. Code has your full codebase context, can run tests, and follows your CLAUDE.md patterns.

### Don't ideate in Terminal

**What happens:** You open Claude Code and start brainstorming a feature. Claude Code wants to take action — create files, run commands. You spend the session saying "no, not yet, I'm just thinking."

**Instead:** Ideate in Chat where there's no action bias. Move to Code when you're ready to build.

### Don't manually do what Scheduled Tasks can automate

**What happens:** Every morning you open Claude Code, review open PRs, check CI status, scan for dependency updates. It takes 30 minutes and you sometimes skip it when you're busy.

**Instead:** Schedule these as recurring tasks. They run whether you remember or not. You review the output, not the raw data.

### Don't use Code for non-code file processing

**What happens:** You ask Claude Code to process a folder of invoices. It can technically do it, but it's fighting against its own tooling — git wants to track everything, the terminal environment adds overhead.

**Instead:** Use Cowork. It's purpose-built for file processing, document generation, and non-code operations.

### Don't use Dispatch for interactive work

**What happens:** You assign a complex task via Dispatch, then keep checking your phone for updates, wishing you could steer the direction.

**Instead:** If the task needs interactive guidance, wait until you're at your desk and use Claude Code directly. Dispatch is for well-defined tasks with clear acceptance criteria.

### Don't skip the plan step in Code

**What happens:** You tell Claude Code to "build the user profile feature" without reviewing a plan first. It makes architectural decisions you disagree with and you have to undo half the work.

**Instead:** Always use the plan → approve → execute pattern. Review the plan before any code is written. This is especially important when you're building trust with the tooling.

### Don't use VS Code Extension as your primary surface

**What happens:** You try to do all your coding through the VS Code Extension sidebar. It works for small edits, but for multi-file features or command execution, you keep hitting limitations.

**Instead:** Use the Terminal CLI as your primary coding surface. The VS Code Extension is best for targeted edits, reviewing inline diffs, and using @-mentions for file-scoped context.

### Don't schedule tasks without testing the prompt first

**What happens:** You write a scheduled task prompt, set it to daily, and forget about it. A week later you discover it's been posting unhelpful PR comments or missing obvious issues.

**Instead:** Run the exact prompt interactively in Claude Code first. Validate the output quality. Only schedule it once you trust the results.

---

## Surface Capabilities Quick Reference

A compact lookup for what each surface can and cannot do.

| Capability | Chat | Cowork | Code CLI | Code VS Code | Code Web | Scheduled Tasks | Dispatch | Remote Control |
|---|---|---|---|---|---|---|---|---|
| Read codebase | — | — | Yes | Yes | Yes | Yes | Yes | Yes |
| Write/edit files | — | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Run CLI commands | — | — | Yes | Yes | Yes | Yes | Yes | Yes |
| Git operations | — | — | Yes | Yes | Yes | Yes | Yes | Yes |
| MCP integrations | — | — | Yes | Yes | — | — | Yes | Yes |
| Process PDFs/images | Yes | Yes | — | — | — | — | — | — |
| Long conversations | Yes | — | Yes | Yes | Yes | — | — | — |
| Runs unattended | — | — | — | — | — | Yes | Yes | — |
| Works from mobile | Yes | — | — | — | — | — | Yes | Yes |
| Projects (persistent context) | Yes | — | — | — | — | — | — | — |
| Hooks support | — | — | Yes | Yes | — | — | — | — |

---

## Getting Started

If you're new to the Claude stack, start here:

1. **Set up Claude Code CLI** — install, authenticate, run `claude` in your repo. This is your primary tool.
2. **Write your CLAUDE.md** — use `claude-config/CLAUDE.md.template` as a starting point. This is how Claude understands your project.
3. **Try one feature cycle** — follow `docs/guides/feature-workflow.md` end to end. Get comfortable with plan → approve → execute.
4. **Add Chat for ideation** — next time you start a new feature, brainstorm in Chat first. Notice how it changes the quality of your specs.
5. **Schedule your first task** — set up daily PR review. This is the highest-ROI scheduled task.
6. **Explore Cowork** — if you have non-code operational tasks, try pointing Cowork at a folder.

Build familiarity incrementally. Don't try to use every surface on day one.

---

*This guide is referenced by all other workflow guides in this repository. When in doubt about which surface to use, return here.*
