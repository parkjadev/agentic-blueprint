# Remote Workflow

Mobile supervision and async task delegation using Remote Control and Dispatch. Built for solo founders who need to step away mid-build without losing momentum.

**Primary surfaces:** Remote Control (Claude mobile app), Dispatch (Claude mobile app)
**Related:** `feature-workflow.md` (the work being supervised), `mcp-setup.md` (Dispatch setup)

---

## Overview

Two mobile capabilities let you stay productive away from your desk:

| Capability | What It Does | Best For |
|---|---|---|
| **Remote Control** | Monitor and control an active Claude Code session from your phone | Supervising long-running builds, approving actions while away |
| **Dispatch** | Assign a new task from your phone — Claude works on your desktop | Capturing work while you're away, delegating well-defined tasks |

### The Key Difference

- **Remote Control** = you're watching and steering an active session
- **Dispatch** = you're assigning work and walking away

---

## Remote Control

### When to Use

- You've started a long feature build and need to step away (meeting, lunch, errand)
- You want to monitor a deployment or CI run from your phone
- You need to approve Claude Code actions without being at your desk

### Setup

1. **Start a Claude Code session on your desktop** with a clear plan
2. **Open the Claude mobile app** on your phone
3. **Navigate to Remote Control** — you'll see your active desktop sessions
4. **Select the session** to start monitoring

### Step-by-Step: Supervised Feature Build

#### 1. Start the Session at Your Desk

**Surface:** Claude Code (Terminal) — desktop

Give Claude a detailed plan before you leave:

```
> Read the specs at docs/specs/[feature]/. Here's the implementation plan:
>
> 1. Add the new schema to src/lib/db/schema.ts
> 2. Create the API routes at src/app/api/[resource]/
> 3. Add auth checks following the dual-mode pattern
> 4. Write unit tests for the new endpoints
> 5. Run pnpm type-check && pnpm lint && pnpm test:ci
>
> Execute this plan step by step. I'll be monitoring via Remote Control.
```

The more specific the plan, the less you'll need to intervene from your phone.

#### 2. Switch to Mobile

**Surface:** Remote Control (Claude mobile app)

Open the Claude mobile app → Remote Control → select your session.

You can now:

- **Read output** — see what Claude is doing, what files it's editing, what commands it's running
- **Approve actions** — Claude Code prompts for approval on file writes and commands. Tap to approve or deny.
- **Send instructions** — type messages to steer Claude's direction

#### 3. Monitor and Approve

Most of the time, you're just approving predictable actions:

- "Write to src/lib/db/schema.ts" → Approve
- "Run pnpm type-check" → Approve
- "Create file src/app/api/projects/route.ts" → Approve

If Claude proposes something unexpected, you can:

- **Deny** the action and send a correction
- **Pause** to think about it
- **Send new instructions** to change direction

#### 4. Return to Desktop

When you're back at your desk, the full session history is there. Review what was done, check the diffs, and continue from where Claude left off.

### Tips for Remote Control

- **Front-load the plan.** The quality of remote supervision depends on the quality of the initial plan. Spend extra time getting the plan right before you leave.
- **Batch approvals.** Don't check your phone every 30 seconds. Claude will queue actions for approval. Check every 10–15 minutes and batch-approve predictable actions.
- **Know when to wait.** If Claude hits a problem that needs deep thought, don't try to debug from your phone. Send "pause, I'll look at this when I'm back" and pick it up at your desk.
- **Best for the middle of a plan.** Remote Control is most useful when the plan is already approved and Claude is executing predictable steps. Don't start a new plan from your phone.

---

## Dispatch

### When to Use

- You think of something that needs doing while you're away from your desk
- You want Claude to work on a well-defined task while you do something else
- You need a PR ready for review when you return to your desk

### Setup

1. **Claude Code must be available on your desktop** — either an active session or daemon mode
2. **Claude mobile app** installed and signed in
3. **The target repo must be accessible** on your desktop

### Step-by-Step: Async Task Delegation

#### 1. Define the Task Clearly

**Surface:** Dispatch (Claude mobile app)

The task description is everything. Claude will work autonomously — no back-and-forth. Be specific:

**Good task descriptions:**

> In parkjadev/agentic-blueprint, create a PR that adds a post-deploy health check pattern to docs/guides/release-workflow.md. Add a new section after "Verify Production" that describes hitting /api/health and checking response time. Follow the writing style of the existing guide.

> In parkjadev/sentinel, fix the 401 error on GET /api/projects when using mobile JWT. The issue is in src/lib/auth/get-auth.ts — the token verification checks the `sub` claim but mobile tokens use `userId`. See issue #42 for details. Include a regression test.

**Bad task descriptions:**

> Fix the auth bug.

> Make the docs better.

> Work on the feature from the last meeting.

#### 2. Assign and Walk Away

Dispatch sends the task to your desktop. Claude starts working. You don't need to monitor — that's what Remote Control is for. Dispatch is fire-and-forget.

#### 3. Return to Results

When you're back at your desk:

1. Check GitHub for new PRs from Claude
2. Review the diff
3. Run the check suite if Claude didn't
4. Merge, request changes, or continue the work interactively

### Task Templates for Dispatch

These are proven patterns that work well as Dispatch tasks:

#### Bug Fix

```
In [repo], fix [specific bug description]. The issue is in [file] — [root cause].
See issue #[number] for full details. Include a regression test.
Create a PR to staging when done.
```

#### Documentation Update

```
In [repo], update [specific doc file] to reflect [specific change].
[What changed and why]. Follow the existing document style.
Create a PR with the changes.
```

#### Test Coverage

```
In [repo], add unit tests for [specific file/module].
Cover: happy path, validation errors, auth failures, edge cases.
Follow the patterns in src/test/. Run pnpm test:ci to verify.
Create a PR with the new tests.
```

#### Dependency Update

```
In [repo], update [package] from [old version] to [new version].
Check the changelog for breaking changes. Update any affected code.
Run pnpm type-check && pnpm lint && pnpm test:ci.
Create a PR if all checks pass.
```

#### Small Feature

```
In [repo], add [specific small feature]. See the spec at [spec path].
Follow existing patterns in [reference file]. Include tests.
Create a PR to staging when done.
```

### Tips for Dispatch

- **One task per dispatch.** Don't bundle "fix the bug AND add that feature AND update the docs." Send three separate dispatches.
- **Include file paths.** "Fix the bug in src/lib/auth/get-auth.ts" is 10x more actionable than "fix the auth bug."
- **Reference issues and specs.** Claude reads them for context. "See issue #42" gives Claude the reproduction steps, expected behaviour, and discussion.
- **Set clear acceptance criteria.** "Include a regression test and all checks should pass" defines done.
- **Don't use for exploration.** If you're not sure what needs to be done, save it for when you're at your desk. Dispatch works best with well-defined tasks.

---

## Choosing Between Remote Control and Dispatch

```
Are you starting from scratch or continuing existing work?
│
├─ Starting new work while away from desk
│  └─ Is the task well-defined with clear acceptance criteria?
│     ├─ Yes → Use Dispatch
│     └─ No → Wait until you're at your desk
│
└─ Continuing or monitoring existing work
   └─ Is there an active Claude Code session running?
      ├─ Yes → Use Remote Control
      └─ No → Use Dispatch to start the task
```

### Combining Both

For large features:

1. **At your desk:** Start the feature build in Claude Code, approve the plan
2. **Stepping away:** Switch to Remote Control to monitor execution
3. **Later that day:** Return to desk, review progress
4. **Next morning:** Use Dispatch for follow-up tasks ("add tests for yesterday's feature, create PR")

---

## Best Practices

### For Solo Founders

- **Use Dispatch for morning prep.** Before your first coffee, dispatch 2–3 well-defined tasks from your phone. By the time you sit down, PRs are ready for review.
- **Use Remote Control for long builds.** Start a feature, switch to Remote Control, do admin work (Cowork) or take meetings. Check back periodically.
- **Don't over-supervise.** The point of these tools is autonomy. If you're checking Remote Control every 2 minutes, you'd be faster at your desk.
- **Build trust incrementally.** Start with small, low-risk Dispatch tasks (docs, tests). As you learn what Claude handles well, increase the scope.

### Security Considerations

- Dispatch and Remote Control use your existing Claude Code permissions. Claude can't do anything from your phone that it couldn't do at your desk.
- Review all PRs created by Dispatch before merging — treat them like PRs from any team member.
- Don't dispatch tasks involving secrets, credentials, or sensitive operations.

---

*See `docs/guides/claude-surfaces.md` for the full surface decision tree.*
*See `docs/guides/agentic-workflow.md` for how mobile supervision fits into the lifecycle.*
