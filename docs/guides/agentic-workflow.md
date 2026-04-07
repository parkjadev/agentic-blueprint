# Agentic Workflow — Master Reference

The full lifecycle for building products with Claude as your primary collaborator. This is the master reference that all other workflow guides feed into.

**Surfaces:** All — Claude Desktop Chat, Claude Code (Terminal, VS Code, Web), Scheduled Tasks, Cowork, Dispatch, Remote Control
**Related:** `claude-surfaces.md` (surface decision tree), individual workflow guides for each phase

---

## Philosophy

Claude is a senior engineer and strategic advisor who needs context to perform. The quality of Claude's output is directly proportional to the context you provide — CLAUDE.md, specs, schemas, commit history, and clear instructions.

The operating model:

1. **Think** in Claude Desktop Chat — ideation, strategy, critical assessment
2. **Document** in Claude Code — specs, schemas, architecture decisions committed to the repo
3. **Build** in Claude Code — feature branches, test suites, CI pipelines
4. **Deploy** in Claude Code + MCP — staging, production, monitoring
5. **Maintain** with Scheduled Tasks — recurring automation, PR triage, dependency audits
6. **Operate** with Cowork — non-code admin, document processing, research

Every minute invested in Claude's ecosystem (CLAUDE.md, MCP configs, workflow guides) compounds across all projects.

---

## The Full Lifecycle Loop

Every piece of work — features, fixes, improvements — follows this loop. Some steps are skipped for smaller changes, but the sequence never changes.

```
Ideate → Document → Issue → Branch → Plan → Review Plan → Code → Test → PR → Deploy → Maintain → Operate
```

### Phase 1: Ideate

**Surface:** Claude Desktop Chat (Projects)
**Guide:** `idea-to-prd.md`

| Step | Action | Output |
|---|---|---|
| 1.1 | Brainstorm the problem in Chat | Problem statement |
| 1.2 | Map user journeys | 2–4 journey descriptions |
| 1.3 | Define feature matrix with priorities | P0/P1/P2 feature list |
| 1.4 | Stress-test the plan | Risk assessment |
| 1.5 | Structure into PRD template | Completed PRD |

**Exit criteria:** PRD committed to `docs/prd/[feature-name].md`

### Phase 2: Document

**Surface:** Claude Desktop Chat → Claude Code (Terminal)
**Guide:** `prd-to-specs.md`

| Step | Action | Output |
|---|---|---|
| 2.1 | Decompose PRD into technical components (Chat) | Component list |
| 2.2 | Identify dependencies and build sequence (Chat) | Ordered build plan |
| 2.3 | Draft technical approach (Chat) | Approach summary |
| 2.4 | Write specs in Claude Code | Committed spec files |
| 2.5 | Create supporting specs if needed | Data model, API, auth specs |

**Exit criteria:** All specs committed to `docs/specs/[feature-name]/`

### Phase 3: Issue

**Surface:** Claude Code (Terminal)

| Step | Action | Output |
|---|---|---|
| 3.1 | Create GitHub issue with acceptance criteria | Issue with linked specs |
| 3.2 | Add labels, assignee, project board | Tracked and visible |
| 3.3 | Link to specs and PRD | Full traceability |

```bash
# Via Claude Code
> Create a GitHub issue for [feature]. Link to the specs in docs/specs/[feature-name]/.
> Include acceptance criteria and a checklist of implementation steps.
```

**Exit criteria:** GitHub issue exists, labelled, and on the project board

### Phase 4: Branch

**Surface:** Claude Code (Terminal)
**Guide:** `feature-workflow.md`

| Step | Action | Output |
|---|---|---|
| 4.1 | Pull latest master and staging | Up to date |
| 4.2 | Create feature branch from master | `feature/[name]` branch |

```bash
# Via Claude Code
> Pull master and staging, then create a feature branch called feature/[name] from master
```

**Exit criteria:** Clean feature branch created from latest master

### Phase 5: Plan

**Surface:** Claude Code (Terminal)

| Step | Action | Output |
|---|---|---|
| 5.1 | Ask Claude Code to plan the implementation | Step-by-step plan |
| 5.2 | Review the plan against the specs | Validated plan |
| 5.3 | Approve or request changes | Approved plan |

```bash
# Via Claude Code
> Read the specs in docs/specs/[feature-name]/ and plan the implementation.
> Show me the plan before writing any code.
```

**This is the most important step.** Review the plan carefully. Check:

- Does it match the spec?
- Is the order correct (schema → API → auth → jobs → UI)?
- Are there any assumptions you disagree with?
- Is it doing more than what was specified?

**Exit criteria:** Plan reviewed and approved

### Phase 6: Code

**Surface:** Claude Code (Terminal), VS Code Extension for review
**Guide:** `feature-workflow.md`

| Step | Action | Output |
|---|---|---|
| 6.1 | Claude Code executes the approved plan | Code changes |
| 6.2 | Review each change as it's proposed | Approved changes |
| 6.3 | Course-correct if needed | Adjusted implementation |

For long-running feature builds, you can use Remote Control to monitor and approve from your phone.

**Exit criteria:** All code changes implemented and approved

### Phase 7: Test

**Surface:** Claude Code (Terminal)

| Step | Action | Output |
|---|---|---|
| 7.1 | Run the full check suite | All checks pass |
| 7.2 | Write missing tests | New test files |
| 7.3 | Run checks again | Clean pass |

```bash
# Via Claude Code
> Run pnpm check:all. If anything fails, fix it. Then write tests for the new code and run again.
```

The check suite should include:

- `pnpm type-check` — TypeScript strict mode
- `pnpm lint` — ESLint rules
- `pnpm test:ci` — Vitest unit tests

**Exit criteria:** `pnpm check:all` passes with zero errors

### Phase 8: Pull Request

**Surface:** Claude Code (Terminal)

| Step | Action | Output |
|---|---|---|
| 8.1 | Create PR to staging | PR with description |
| 8.2 | Link to GitHub issue | Traceability |
| 8.3 | Wait for CI to pass | Green checks |

```bash
# Via Claude Code
> Create a PR from this branch to staging. Link to issue #[number].
> Include a summary of what changed and how to test it.
```

**Exit criteria:** PR open, CI green, ready for review

### Phase 9: Deploy

**Surface:** Claude Code + Vercel MCP
**Guide:** `release-workflow.md`

| Step | Action | Output |
|---|---|---|
| 9.1 | Merge PR to staging | Staging auto-deploys |
| 9.2 | Smoke test staging | Verified working |
| 9.3 | Create PR from staging to master | Production PR |
| 9.4 | Review and merge to master | Production auto-deploys |
| 9.5 | Verify production health | `/api/health` returns OK |

**Exit criteria:** Feature live in production, health check passing

### Phase 10: Clean Up

**Surface:** Claude Code (Terminal)

| Step | Action | Output |
|---|---|---|
| 10.1 | Close the GitHub issue | Issue closed |
| 10.2 | Delete the feature branch | Branch cleaned up |
| 10.3 | Pull master and staging locally | Local branches up to date |
| 10.4 | Update CHANGELOG.md | Change documented |

```bash
# Via Claude Code
> Close issue #[number]. Delete the feature branch. Pull master and staging.
> Add an entry to CHANGELOG.md under [Unreleased].
```

**Exit criteria:** Issue closed, branch deleted, changelog updated, local branches current

### Phase 11: Maintain

**Surface:** Scheduled Tasks
**Guide:** `scheduled-tasks.md` (v2.0 guide)

Automated recurring tasks handle ongoing maintenance:

| Task | Schedule | Action |
|---|---|---|
| PR review triage | Daily 07:00 AEST | Review open PRs, flag issues, approve clean ones |
| CI failure monitor | Every 2 hours | Diagnose failures, attempt auto-fix, escalate |
| Dependency audit | Weekly Monday 06:00 | Scan for vulnerabilities, create update PRs |
| Doc sync | Post-merge to master | Update docs if API/schema/auth changed |

### Phase 12: Operate

**Surface:** Cowork
**Guide:** `cowork-ops.md` (v2.0 guide)

Non-code operational tasks that support the product:

- Invoice and expense processing
- Contract review
- Research compilation
- Document generation from templates

---

## Surface Map Summary

| Phase | Primary Surface | Secondary |
|---|---|---|
| Ideate | Claude Desktop Chat | — |
| Document | Chat → Claude Code | — |
| Issue | Claude Code (Terminal) | — |
| Branch | Claude Code (Terminal) | — |
| Plan | Claude Code (Terminal) | — |
| Code | Claude Code (Terminal) | VS Code Extension |
| Test | Claude Code (Terminal) | — |
| PR | Claude Code (Terminal) | — |
| Deploy | Claude Code + Vercel MCP | — |
| Clean up | Claude Code (Terminal) | — |
| Maintain | Scheduled Tasks | Remote Control |
| Operate | Cowork | Chat |

---

## Anti-Patterns

| Anti-Pattern | Why It Fails | Do This Instead |
|---|---|---|
| Coding in Chat | No codebase context, can't test or commit | Think in Chat, build in Code |
| Ideating in Terminal | Claude Code wants to take action, creates friction | Brainstorm in Chat, switch to Code when ready |
| Skipping the plan step | Claude makes architectural decisions you'll disagree with | Always review the plan before any code |
| Skipping specs | Ambiguity compounds — you'll spend more time correcting | Write specs, even brief ones, before coding |
| Not updating CLAUDE.md | Claude loses context on future sessions | Keep CLAUDE.md current as the project evolves |
| Scheduling untested prompts | Poor output quality, wasted automation | Test every prompt interactively before scheduling |
| Doing routine work manually | Inconsistent, easy to skip when busy | Automate with Scheduled Tasks |
| One giant PR | Hard to review, risky to deploy | One feature per branch, one branch per PR |

---

## Quick-Start Checklist

For your first feature using this workflow:

- [ ] CLAUDE.md is written and committed
- [ ] PRD template is in `docs/templates/PRD.md`
- [ ] Spec templates are in `docs/templates/`
- [ ] CI pipeline is configured (`.github/workflows/ci.yml`)
- [ ] Vercel project is connected
- [ ] Clerk, Neon, and Upstash are configured
- [ ] You've read `claude-surfaces.md`

Then follow the loop: Ideate → Document → Issue → Branch → Plan → Code → Test → PR → Deploy → Clean up.

---

*This is the master reference. For step-by-step guides on each phase, see the individual workflow guides in this directory.*
