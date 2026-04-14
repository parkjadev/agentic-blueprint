# Stage 2: Plan

> Decompose the PRD into technical specs, create a GitHub issue with acceptance criteria, and set up the feature branch — all before writing a single line of product code.

## Why this stage exists

The gap between a PRD and working code is where most AI-assisted projects go
off the rails. A PRD says *what* to build; specs say *how* to build it. Without
specs, an AI coder makes its own architectural decisions on the fly — decisions
that may contradict your stack conventions, ignore auth requirements, or create
a data model that cannot scale.

Replit Agent has no concept of a spec workflow: you describe a feature in plain
English and it starts generating code immediately. Cursor supports
`.cursorrules` for style preferences, but provides no templates for data-model
design, API contracts, or authorisation flows. Neither tool enforces the
discipline of thinking through dependencies, sequencing work, or documenting
decisions before implementation begins.

The Blueprint fills this gap with structured templates and a repeatable process.
By the end of this stage you have versioned specs that any AI coder can follow,
a GitHub issue that tracks the work, and a feature branch ready for
implementation. The upfront cost is small; the downstream savings —
fewer rewrites, clearer code review, predictable scope — are substantial.

## What you need

| Role | Recommended | Alternatives |
| --- | --- | --- |
| Agentic coder | Claude Code (terminal) | Cursor Agent, any AI coder with filesystem access |

## How it works

### 1. Bootstrap repo from the Blueprint template

Use **Use this template → Create a new repository** on GitHub to create a fresh
repo from the Blueprint template. Clone it locally and open it in your agentic
coder.

### 2. Run setup scripts

Run the repository setup scripts to configure GitHub labels and branch
protection:

```
./setup-labels.sh
./setup-branch-protection.sh
```

### 3. File issue #1

Create the first GitHub issue — `chore: initial scaffold` — per the hard rule
that every piece of work starts with a tracked issue.

### 4. Commit research brief to `docs/research/`

Copy the research brief you saved in Stage 1 into the repo:

```
> Commit docs/research/[topic].md with message "docs: add [topic] research brief"
```

### 5. Commit PRD to `docs/prd/`

Copy the PRD you saved in Stage 1 into the repo:

```
> Commit docs/prd/[feature-name].md with message "docs: add [feature] PRD"
```

### 6. Review the PRD

Open your agentic coder in the repo and load the PRD:

> "Read docs/prd/[feature-name].md and summarise the P0 scope, user journeys,
> and non-functional requirements."

Confirm the summary matches your intent before proceeding. If anything is
ambiguous, update the PRD now — it is cheaper to fix a paragraph than to
refactor code.

### 7. Identify components

Ask the coder to decompose the PRD into technical components:

> "Decompose this PRD into technical work. Identify: data model changes, API
> endpoints, auth requirements, background jobs, UI components, and external
> integrations."

You are building a mental map of the feature's surface area. A typical
decomposition surfaces:

- **Data model** — new tables, columns, enums, relationships
- **API** — new routes, modified routes, request/response schemas
- **Auth & authorisation** — new roles, permissions, ownership checks
- **Background jobs** — async processing, scheduled work, event-driven tasks
- **UI** — pages, forms, interactive elements
- **Integrations** — third-party APIs, webhooks, external services

### 8. Decide spec granularity

Not every component needs its own spec file. Use these rules of thumb:

| Component | Dedicated spec when… | Otherwise… |
| --- | --- | --- |
| Data model | More than 2 new tables, or modifying core tables | Cover in `technical-spec.md` |
| API | More than 3 new endpoints | Cover in `technical-spec.md` |
| Auth | Introducing new roles or changing auth flows | Cover in `technical-spec.md` |
| Jobs, UI, integrations | — | Always cover in `technical-spec.md` |

When in doubt, start with a single `technical-spec.md`. You can extract a
dedicated spec later if a section grows unwieldy.

### 9. Draft specs in `docs/specs/[name]/`

Tell the coder to create the spec files using the templates:

> "Create docs/specs/[feature-name]/technical-spec.md using the template at
> docs/templates/technical-spec.md. Fill in every section based on the PRD.
> Here is the approach we agreed on: [paste summary of decisions]."

For dedicated specs:

> "Also create data-model-spec.md using docs/templates/data-model-spec.md.
> Include schema definitions, relationships, indexes, and a migration plan."

> "Create api-spec.md using docs/templates/api-spec.md. Include full
> request/response schemas with validation rules."

> "Create auth-spec.md using docs/templates/auth-spec.md. Document roles,
> permissions, and ownership checks."

Iterate until each section is precise. Challenge the coder:

- "What happens if this service is unavailable?"
- "How does this work for mobile clients?"
- "What is the rollback plan if this breaks production?"

### 10. Review specs against checklist

Before committing, verify each spec against this checklist:

- [ ] Data model follows existing patterns and naming conventions
- [ ] API endpoints follow the project's response envelope and error format
- [ ] Auth matches the project's authentication and authorisation patterns
- [ ] Testing strategy covers unit, integration, and E2E where appropriate
- [ ] Rollout plan includes preview-deploy validation and a rollback trigger
- [ ] No domain-specific business logic from other projects has leaked in
- [ ] Open questions from the PRD are resolved or explicitly deferred

Fix any gaps before proceeding. A spec with holes becomes code with holes.

### 11. Create GitHub issue with acceptance criteria

With specs committed, create the implementation issue:

> "Create a GitHub issue for implementing [feature]. Reference the specs we
> just committed. Include: acceptance criteria derived from the PRD, a link to
> the technical spec, estimated scope (S / M / L), and a checklist of the
> major implementation steps."

This creates a trackable work item that links PRD → specs → implementation.

### 12. Create feature branch

Create a branch from `main` for the implementation work:

```
> Create a feature branch named feat/[feature-name] from main
```

The branch is ready. No product code has been written yet, but the foundation
is solid: specs are versioned, the issue is trackable, and the branch is clean.

## Templates

- [Technical Spec](../templates/technical-spec.md) — overview, data model, API, auth, jobs, UI, testing strategy, rollout plan
- [Data Model Spec](../templates/data-model-spec.md) — schema definitions, relationships, indexes, migration plan
- [API Spec](../templates/api-spec.md) — endpoints, request/response schemas, validation, error handling
- [Auth Spec](../templates/auth-spec.md) — roles, permissions, ownership checks, auth flows
- [Architecture](../templates/architecture.md) — system-level design, service boundaries, infrastructure
- [PRD](../templates/PRD.md) — the input document; referenced throughout this stage

## Exit criteria

- Research brief committed to `docs/research/[topic].md`
- PRD committed to `docs/prd/[feature-name].md`
- Specs committed to `docs/specs/[feature-name]/`
- All checklist items from step 10 pass
- GitHub issue created with acceptance criteria and linked specs
- Feature branch created from `main`

## Platform notes

- **Claude-native:** Claude Code reads your codebase and writes spec files directly. Use the plan → approve → execute pattern.
- **Cursor + Perplexity:** Cursor Agent writes specs with codebase context via `.cursorrules`. Agent Skills can encode your spec templates as reusable workflows.
- **OutSystems ODC:** Specs are authored manually or in Claude Code/Chat, then committed to a shared repo or wiki. The architecture template should capture ODC module structure, entity model, service action contracts, and integration topology. Mentor does not generate specs — the discipline must come from the team.

## Anti-patterns

| Anti-pattern | Why it fails | Do this instead |
| --- | --- | --- |
| Skip specs, start coding from the PRD | The AI coder invents architecture on the fly; decisions are inconsistent and hard to review | Always write specs before implementation; they take minutes and save hours |
| One mega-spec for the entire product | Too long for any AI to hold in context; sections contradict each other as scope drifts | One spec set per feature; keep each file focused and under 500 lines |
| Write specs without reading the existing codebase | Specs propose patterns that conflict with what is already built; refactoring ensues | Have the coder read relevant source files before drafting; specs must extend, not contradict |
| No GitHub issue | Work is untraceable; PRs lack context; scope creeps without a boundary | Create an issue with acceptance criteria before the first line of code |
| Start coding during the planning stage | "Just a quick prototype" becomes the production architecture; specs never get written | Finish all specs, commit them, create the issue, *then* move to Stage 3 |

---

*Previous stage: [Stage 1 — Research & Think](stage-1-research-and-think.md)*
*Next stage: Stage 3 — Build (coming soon)*
