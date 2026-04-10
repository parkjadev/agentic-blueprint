# Agentic Workflow — Master Reference

The full lifecycle for building products with Claude as your primary collaborator. This is the master reference that all other workflow guides feed into.

**Surfaces:** All — Claude Desktop Chat, Claude Code (Terminal, VS Code, Web), Scheduled Tasks, Cowork, Dispatch, Remote Control
**Related:** `claude-surfaces.md` (surface decision tree), individual workflow guides for each phase
**Branching model:** [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow). One long-lived branch (`main`), short-lived branches per issue, preview deploy per PR. **No `staging` branch** — see `feature-workflow.md` for why.

---

## Philosophy

Claude is a senior engineer and strategic advisor who needs context to perform. The quality of Claude's output is directly proportional to the context you provide — CLAUDE.md, specs, schemas, commit history, and clear instructions.

The operating model:

1. **Think** in Claude Desktop Chat — ideation, strategy, critical assessment
2. **Document** in Claude Code — specs, schemas, architecture decisions committed to the repo
3. **Build** in Claude Code — feature branches, test suites, CI pipelines
4. **Deploy** in Claude Code + MCP — preview-per-PR, production on merge, monitoring
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

Hard rule: **issue before branch**. Every piece of work — feature, fix, chore, docs — starts as a GitHub issue. Use the issue templates shipped in `claude-config/github/ISSUE_TEMPLATE/`.

| Step | Action | Output |
|---|---|---|
| 3.1 | Create GitHub issue with acceptance criteria | Issue with linked specs |
| 3.2 | Apply labels (`type:*`, `scope:*`), assignee, project board | Tracked and visible |
| 3.3 | Link to specs and PRD | Full traceability |

```bash
# Via Claude Code
> Create a GitHub issue for [feature] using the Feature template.
> Link to the specs in docs/specs/[feature-name]/. Apply labels: type:feature, scope:[area].
> Include acceptance criteria and a checklist of implementation steps.
```

**Exit criteria:** GitHub issue exists, labelled, and on the project board

### Phase 4: Branch

**Surface:** Claude Code (Terminal)
**Guide:** `feature-workflow.md`

| Step | Action | Output |
|---|---|---|
| 4.1 | Pull latest `main` | Local up to date |
| 4.2 | Create branch from `main` using `<type>/<issue-number>-<slug>` | `feat/42-user-profile` branch |

```bash
# Via Claude Code
> Pull main, then create a branch called feat/42-user-profile from main
```

**Exit criteria:** Clean branch created from latest `main`, name encodes the issue number

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

#### Plan-mode patterns

Three patterns separate cheap plans from expensive ones. The first two come from the auto-memory system but apply to plans the same way; the third is plan-specific:

1. **Pre-flight existence checks.** Every line in the plan that says *"X is missing"* or *"needs Y"* must be confirmed by a `Read` against the actual file before it enters the plan. Plans built from memory and assumption are 50% wrong on average — half the items downgrade once you actually read the current state. The fix is cheap: read the files first. See also Hard Rule #8 ("verify file existence before recommending it from memory") in `CLAUDE.md.template`.
2. **Reference files by full path.** Every file the plan touches gets named by its repo-relative path (`src/lib/auth/get-auth.ts`), not by description (`the auth helper`). Implementation phase shouldn't have to re-grep to find the file the plan was talking about.
3. **Reference the issue templates and label vocabulary.** When the plan calls for filing implementation issues, it should already know the type/scope label for each one rather than re-discovering them. The label set is in `CLAUDE.md.template` Labels section; the issue templates are in `claude-config/github/ISSUE_TEMPLATE/`. A plan that says "file `feat/profile` issue with `type:feature, scope:dashboard`" is ready to execute; "file an issue for the profile feature" is not.

Every approved plan should also include a **"What's already in place (excluded from this plan)"** section near the top — see the `docs/templates/technical-spec.md` template. This section saves the implementation phase from re-exploring the same code the plan author already read, and prevents the LLM from re-suggesting work that's already done.

**Exit criteria:** Plan reviewed and approved, all "missing/needs" claims verified by `Read`, all critical files referenced by full path

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
| 8.1 | Open PR to `main` using the PR template | PR with description |
| 8.2 | Link to GitHub issue (`Closes #N`) | Traceability + auto-close |
| 8.3 | Wait for CI to pass | Green checks |
| 8.4 | Wait for Vercel preview | Preview URL posted on PR |

```bash
# Via Claude Code
> Open a PR from this branch to main. Use the PR template.
> Body should include "Closes #[number]" so the issue auto-closes on merge.
```

**Exit criteria:** PR open, CI green, preview URL ready for review

### Phase 9: Deploy

**Surface:** Claude Code + Vercel MCP
**Guide:** `feature-workflow.md`

| Step | Action | Output |
|---|---|---|
| 9.1 | Smoke test the Vercel preview URL | Verified in real environment |
| 9.2 | Squash-merge PR to `main` | Production auto-deploys |
| 9.3 | Verify production health | `/api/health` returns 200 |
| 9.4 | Check Vercel runtime logs | No new errors |

> **Watch out:** use **squash merge**, not "Rebase and merge". GitHub's rebase merge rewrites commit SHAs and is the reason this blueprint no longer uses a long-lived `staging` branch.

**Exit criteria:** Feature live in production, health check passing

### Phase 10: Clean Up

**Surface:** Claude Code (Terminal)

| Step | Action | Output |
|---|---|---|
| 10.1 | Close the GitHub issue (auto-closes via `Closes #N`) | Issue closed |
| 10.2 | Delete the branch (local + remote) | Branch cleaned up |
| 10.3 | Pull `main` locally, prune stale remotes | Local up to date |
| 10.4 | Update CHANGELOG.md under `[Unreleased]` | Change documented |
| 10.5 | Run the doc-sweep checklist (below) if the change touched anything user-visible | All docs in sync |

```bash
# Via Claude Code
> Confirm issue #[number] auto-closed. Delete the branch (local + remote).
> Pull main and prune. Add an entry to CHANGELOG.md under [Unreleased].
```

#### Doc Sweep Checklist

The Repo About section, README badges, and CHANGELOG all drift silently. If the change you just shipped touches anything user-visible (a new feature, a renamed endpoint, a stack swap, a deprecated module), walk this list **before closing the loop**:

- [ ] **README** — does the headline still describe what the project does? Does the quickstart still work as written?
- [ ] **CHANGELOG.md** — is the change under `[Unreleased]` with the issue number?
- [ ] **GitHub repo description** — `gh repo view --json description --jq .description`. Still accurate?
- [ ] **GitHub repo topics** — `gh repo view --json repositoryTopics --jq '.repositoryTopics[].name'`. Still reflect the stack?
- [ ] **GitHub About URL** — `gh repo view --json homepageUrl --jq .homepageUrl`. Points at a live deployment?
- [ ] **Architecture diagram** — if `docs/templates/architecture.md` references components that just moved, did you update it?
- [ ] **CLAUDE.md.template** — did you change a Hard Rule, file path, or pattern that the template documents?

> **Update GitHub-side metadata via the CLI**, not the web UI, so the change is scriptable: `gh repo edit --description "…" --add-topic foo --homepage https://…`. The web UI is the easiest place to forget.

**Exit criteria:** Issue closed, branch deleted, changelog updated, local `main` current, doc sweep clean

### Phase 11: Maintain

**Surface:** Scheduled Tasks
**Guide:** `scheduled-tasks.md` (v2.0 guide)

Automated recurring tasks handle ongoing maintenance:

| Task | Schedule | Action |
|---|---|---|
| PR review triage | Daily 07:00 AEST | Review open PRs, flag issues, approve clean ones |
| CI failure monitor | Every 2 hours | Diagnose failures, attempt auto-fix, escalate |
| Dependency audit | Weekly Monday 06:00 | Scan for vulnerabilities, create update PRs |
| Doc sync | Post-merge to main | Update docs if API/schema/auth changed |

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
