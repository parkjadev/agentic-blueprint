# Agentic Blueprint

An opinionated, full-lifecycle accelerator for building products with Claude as your primary collaborator. Extracted from production patterns at [ARK360](https://github.com/parkjadev).

This isn't just a template repo. It's an **operating system for building products with Claude** — covering every stage from ideation through deployment and ongoing operations, mapped to every surface in the Claude stack.

> **Click "Use this template" to bootstrap a new project that starts at week 6 instead of day 1.**

---

## Philosophy

Claude is treated as a senior engineer and strategic advisor who needs context to perform. The quality of output is directly proportional to the context you provide — CLAUDE.md, specs, schemas, commit history, and clear instructions.

1. **Think** in Claude Desktop — ideation, strategy, critical assessment, PRD drafting
2. **Document** in Claude Code — specs, schemas, architecture decisions committed to the repo
3. **Build** in Claude Code — feature branches, test suites, CI pipelines
4. **Deploy** in Claude Code + MCP — preview-per-PR, production on merge to `main`, monitoring
5. **Maintain** with Scheduled Tasks — recurring automation, PR triage, dependency audits
6. **Operate** with Cowork — non-code admin, document processing, research

Every minute invested in Claude's ecosystem compounds across all projects.

---

## Quickstart

### 1. Create Your Repo

Click **"Use this template"** on GitHub → create a new repository.

### 2. File Issue #1 Before You Touch Anything

Hard Rule #2 ("issue before branch") applies to the very first scaffold commit, not just to feature work. The bootstrap issue gives every subsequent commit something to reference and demonstrates the workflow from line 1.

```bash
gh issue create \
  --title "chore: initial scaffold" \
  --label "type:chore" \
  --body "Bootstrapping a new project from agentic-blueprint. This issue tracks the initial scaffold commits and is closed by the first PR that lands the starter."
```

> If `setup-labels.sh` hasn't been run yet (you'll do that in step 5), the `--label` flag will fail because `type:chore` doesn't exist on the repo. Either drop the flag and add the label after running the script, or run `setup-labels.sh` first and circle back. Both orders work.

### 3. Copy the Starter

```bash
# For a web project — copy the Next.js starter to root
cp -r starters/nextjs/* .
cp starters/nextjs/.env.example .
cp starters/nextjs/.eslintrc.json .
cp -r starters/nextjs/.github .

# For a mobile companion — copy alongside
cp -r starters/flutter/ mobile/
```

### 4. Configure Required Services

```bash
cp .env.example .env.local
```

| Service | What You Need | Sign Up |
|---|---|---|
| **Supabase** | `DATABASE_URL`, `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` | [supabase.com](https://supabase.com) |

Supabase is the only required service. It provides PostgreSQL, auth, and storage in one platform.

### 5. Configure Optional Services

These are opt-in — the app starts and runs without them. Enable as needed:

| Service | Env Vars | Purpose |
|---|---|---|
| **Stripe** | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` | Payments and subscriptions |
| **Inngest** | `INNGEST_EVENT_KEY`, `INNGEST_SIGNING_KEY` | Background jobs and event processing |
| **Resend** | `RESEND_API_KEY` | Transactional email |

Optional services use Zod optional schemas in `src/env.ts`. When env vars are missing, the service gracefully skips — no errors, no crashes.

### 6. Set Up Claude Code + GitHub

```bash
cp claude-config/CLAUDE.md.template CLAUDE.md
mkdir -p .claude
cp claude-config/settings.local.json.template .claude/settings.local.json

# Issue templates, PR template, and label/branch-protection bootstrap
cp -R claude-config/github/. .github/
./claude-config/scripts/setup-labels.sh
./claude-config/scripts/setup-branch-protection.sh
```

Customise `CLAUDE.md` for your project — it's the single most important file for Claude Code and is loaded at the start of every session. The two scripts assume you have the `gh` CLI authenticated against the new repo.

### 7. Boot

```bash
pnpm install
pnpm db:push
pnpm dev
```

### 8. Verify

```bash
curl http://localhost:3000/api/health
# Expected: {"status":"ok","timestamp":"..."}
```

---

## The Workflow

Every change follows the same loop:

```
Ideate → Document → Issue → Branch → Plan → Approve → Code → Test → PR → Preview → Merge → Maintain
```

The blueprint uses [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow): one long-lived branch (`main`), one short-lived branch per issue (`<type>/<N>-<slug>`), one Vercel preview deployment per PR, and production auto-deploys on merge to `main`. **Issue before branch** and **squash-merge always** are hard rules — the [Feature Workflow](docs/guides/feature-workflow.md) explains why (short version: GitHub's "Rebase and merge" rewrites SHAs and breaks any two-tier branch flow).

Two key guides anchor the entire workflow:

- **[Claude Surfaces Guide](docs/guides/claude-surfaces.md)** — which Claude surface for which lifecycle stage. Decision tree, handoff patterns, anti-patterns. **Start here.**
- **[Agentic Workflow](docs/guides/agentic-workflow.md)** — master reference covering every phase with step-by-step actions and surface mapping.

### All Guides

| Guide | What It Covers |
|---|---|
| [Claude Surfaces](docs/guides/claude-surfaces.md) | Surface decision tree, handoff patterns, anti-patterns |
| [Idea → PRD](docs/guides/idea-to-prd.md) | Brainstorm → structure → iterate → finalise in Claude Desktop Chat |
| [PRD → Specs](docs/guides/prd-to-specs.md) | Decompose PRD → technical specs → commit (Chat → Code handoff) |
| [Agentic Workflow](docs/guides/agentic-workflow.md) | Full lifecycle master reference — all 12 phases |
| [Feature Workflow](docs/guides/feature-workflow.md) | Spec → issue → plan → code → test → deploy |
| [Fix Workflow](docs/guides/fix-workflow.md) | Bug report → diagnose → fix → regression test → deploy |
| [Release Workflow](docs/guides/release-workflow.md) | Collapsed into Feature Workflow — explains the move to GitHub Flow and covers versioned release cuts |
| [MCP Setup](docs/guides/mcp-setup.md) | Vercel MCP, GitHub CLI, Dispatch, custom MCP servers |
| [Scheduled Tasks](docs/guides/scheduled-tasks.md) | Daily PR review, CI triage, dependency audits, doc sync |
| [Cowork Ops](docs/guides/cowork-ops.md) | Invoices, contracts, research, venture admin |
| [Remote Workflow](docs/guides/remote-workflow.md) | Mobile supervision with Remote Control + Dispatch |

---

## What's Included

### Document Templates (`docs/templates/`)

Spec-driven development templates. Every feature starts as a spec before any code is written.

| Template | Structure |
|---|---|
| [PRD](docs/templates/PRD.md) | Problem → Users → Journeys → Feature matrix → NFRs → Metrics |
| [Technical Spec](docs/templates/technical-spec.md) | Overview → Data model → API → Auth → Jobs → Testing → Rollout |
| [API Spec](docs/templates/api-spec.md) | Per-endpoint: method, path, auth, role, request/response schemas |
| [Data Model Spec](docs/templates/data-model-spec.md) | Drizzle schema, relationships, indexes, constraints, migration plan |
| [Auth Spec](docs/templates/auth-spec.md) | Flows, role matrix, session management, webhook sync |
| [Architecture](docs/templates/architecture.md) | System diagram, component map, data flow, integrations |
| [Deployment](docs/templates/deployment.md) | Environments, branch strategy, CI/CD, env vars, rollback |
| [API Reference](docs/templates/api-reference.md) | Full endpoint catalogue with response envelope and error codes |
| [Changelog](docs/templates/CHANGELOG.md) | Keepachangelog format with examples |

### Next.js Starter (`starters/nextjs/`)

Production-ready full-stack starter with strict TypeScript, Supabase backend, and opt-in services.

**Infrastructure layer** — modules covering logging, rate limiting, request context, Supabase Auth, database (Supabase PostgreSQL + Drizzle), storage (Supabase Storage), email (Resend), payments (Stripe), background jobs (Inngest), server actions, API response envelope, and validations.

**Example API routes** — full CRUD at `/api/example` demonstrating auth, Zod validation, pagination, ownership checks, rate limiting, and soft delete.

**App shell** — root layout, custom auth pages (sign-in, sign-up, post-auth routing), protected dashboard, public marketing page, Supabase session middleware.

**Config** — strict TypeScript, ESLint (no-console, no-any, floating-promises), Vitest, Playwright, Drizzle, Tailwind, security headers, CI pipeline.

**Scripts & tests** — database reset/seed scripts, test factories, example unit test.

### Flutter Starter (`starters/flutter/`)

Mobile companion that pairs with the Next.js backend.

**Core** — Dio HTTP client with `ApiResponse<T>` matching the Next.js envelope, Supabase Auth (via `supabase_flutter`), Riverpod state management, GoRouter with auth guards.

**Features** — login/register screens, home, profile, example CRUD (list + detail). Full Riverpod + repository + API client pattern throughout.

**Shared** — User model, reusable widgets (scaffold, loading, error, form fields), BuildContext extensions.

### Claude Config (`claude-config/`)

Drop-in configuration for any project using Claude Code.

| File | Purpose |
|---|---|
| [CLAUDE.md.template](claude-config/CLAUDE.md.template) | Full project guide — 16 Hard Rules, env matrix, Reusable Infrastructure cheat sheet, plan-mode patterns, labels |
| [settings.local.json.template](claude-config/settings.local.json.template) | Categorised permissions — read, pnpm, git, gh, curl |
| [memory-guidelines.md](claude-config/memory-guidelines.md) | When to save memories, how to keep CLAUDE.md current, anti-patterns |
| [hooks/pre-commit.md](claude-config/hooks/pre-commit.md) | Pre-commit patterns — full check suite, fast lint, auto-format |
| [hooks/post-deploy.md](claude-config/hooks/post-deploy.md) | Post-deploy patterns — health check, smoke test, Vercel MCP status |
| [hooks/post-merge.md](claude-config/hooks/post-merge.md) | Post-merge patterns — plan status marker updates, doc-sweep prompt |
| [github/ISSUE_TEMPLATE/](claude-config/github/ISSUE_TEMPLATE/) | Issue templates: feature, bug, chore, docs (+ blank-issue picker config) |
| [github/pull_request_template.md](claude-config/github/pull_request_template.md) | PR template with linked issue, test plan, schema-change checklist, rollback |
| [github/workflows/auto-label.yml](claude-config/github/workflows/auto-label.yml) | GitHub Action that auto-applies `scope:*` label from the issue form dropdown |
| [scripts/setup-branch-protection.sh](claude-config/scripts/setup-branch-protection.sh) | Locks down `main`: squash-only, required CI, linear history, `enforce_admins=true`. `SOLO=1` for solo devs. |
| [scripts/unblock-protection.sh](claude-config/scripts/unblock-protection.sh) | Temporary `enforce_admins` bypass with 60-second auto-restore — the sanctioned emergency escape hatch |
| [scripts/setup-labels.sh](claude-config/scripts/setup-labels.sh) | Bootstraps the `type:*` / `scope:*` / status label taxonomy |
| [scripts/gh-backfill-issues.sh](claude-config/scripts/gh-backfill-issues.sh) | Retroactive issue creator from a manifest file (for repos that adopted issue-first discipline late) |
| [scripts/update-plan-status.sh](claude-config/scripts/update-plan-status.sh) | Updates inline `<!-- status: pending -->` markers in plan files when a phase ships |
| [scripts/bootstrap-smoke-test.sh](claude-config/scripts/bootstrap-smoke-test.sh) | Dogfooding harness — scaffolds the template into a tmpdir and runs check:all against both starters |

---

## Stack Decisions

| Choice | Rationale |
|---|---|
| **Supabase** | Single platform for PostgreSQL, auth, and storage. Unified auth for web and mobile — no dual-mode hack. Connection pooling via Supavisor. |
| **Drizzle** | Type-safe ORM that generates clean SQL. Schema-as-code with `db:push` for rapid iteration. No migration files to manage during development. |
| **Inngest** | Event-driven background jobs without managing queues or workers. Retries, scheduling, and fan-out built in. Opt-in — zero overhead when not used. |
| **Vercel** | Zero-config Next.js hosting. Preview deploys per PR branch. Built-in analytics and logging. MCP integration for Claude Code. |
| **Riverpod** | Compile-safe state management for Flutter. Better dependency injection than Provider. Supports async, family, and autoDispose patterns natively. |
| **GoRouter** | Declarative routing for Flutter with typed path parameters. Integrates with Riverpod for reactive auth redirects. |

---

## Claude Stack Setup

This blueprint is designed around the full Claude ecosystem. Set up each surface to get the most out of the workflow.

### Claude Desktop (Chat)

**Purpose:** Ideation, PRD drafting, strategic review, critical assessment.

1. Install Claude Desktop (Mac/Windows) or use [claude.ai](https://claude.ai)
2. Create a **Project** for each venture — this gives Claude persistent context across conversations
3. Add project instructions: what the product does, who uses it, key constraints
4. Use for brainstorming, PRD drafting, and reviewing specs before committing them

### Claude Code (Terminal CLI)

**Purpose:** Feature development, debugging, testing, deployment — the primary coding surface.

1. Install: `npm install -g @anthropic-ai/claude-code` (or see [docs](https://docs.anthropic.com/en/docs/claude-code))
2. Run `claude` in your project directory
3. Claude reads `CLAUDE.md` automatically at session start
4. Use the plan → approve → execute pattern for all coding work

### Claude Code (VS Code Extension)

**Purpose:** Inline diffs, @-mentions for file context, targeted edits.

1. Install the Claude Code extension from the VS Code marketplace
2. Use as a secondary surface for reviewing diffs and small edits
3. @-mention files for focused context

### Scheduled Tasks

**Purpose:** Recurring automation that runs on Anthropic's infrastructure.

1. Set up via `/schedule` in Claude Code CLI or at [claude.ai](https://claude.ai)
2. Start with daily PR review triage — highest ROI task
3. Add CI failure monitoring and weekly dependency audits
4. See [docs/guides/scheduled-tasks.md](docs/guides/scheduled-tasks.md) for prompt templates and schedules

### Cowork

**Purpose:** Non-code file operations — invoices, contracts, research.

1. Organise a Cowork folder: `~/Documents/Claude/` with `operations/` and `ventures/` subdirectories
2. Create a `SKILL.md` defining brand voice, processing rules, and output formats
3. Drop files into folders, then tell Cowork what to do with them
4. See [docs/guides/cowork-ops.md](docs/guides/cowork-ops.md) for task patterns

### Dispatch & Remote Control

**Purpose:** Mobile supervision and async task delegation.

- **Dispatch:** Assign tasks from the Claude mobile app → Claude works on your desktop → return to completed PRs
- **Remote Control:** Monitor and approve active Claude Code sessions from your phone
- See [docs/guides/remote-workflow.md](docs/guides/remote-workflow.md) for patterns

---

## MCP Integrations

| Integration | How | Purpose |
|---|---|---|
| **Vercel** | Vercel MCP server | Check deployment status, read build/runtime logs, access preview URLs |
| **GitHub** | `gh` CLI (built-in) | Issues, PRs, CI status, releases — no MCP server needed |
| **Dispatch** | Claude mobile app | Assign tasks remotely |
| **Custom** | Build your own MCP server | Connect to internal APIs, monitoring dashboards, third-party services |

See [docs/guides/mcp-setup.md](docs/guides/mcp-setup.md) for setup instructions, configuration examples, and a custom MCP server skeleton.

---

## Service Setup Checklist

### Required (app will not start without these)

- [ ] **Supabase** — create a project, copy `DATABASE_URL`, project URL, anon key, and service role key

### Optional (enable as needed)

- [ ] **Stripe** — create account, copy secret key, configure webhook for payment events
- [ ] **Inngest** — create account, copy event key + signing key
- [ ] **Resend** — create account, verify domain, copy API key
- [ ] **Vercel** — connect repo, configure environment variables per branch

### Claude Stack

- [ ] **CLAUDE.md** — copy template, customise for your project
- [ ] **Claude Desktop** — create a Project with venture context
- [ ] **Claude Code CLI** — install, authenticate, run in your repo
- [ ] **Scheduled Tasks** — set up daily PR review (start here)
- [ ] **Cowork** — organise folder structure, create SKILL.md

---

## Verification

```bash
# Next.js starter — must pass clean
cd starters/nextjs
pnpm install && pnpm type-check && pnpm lint && pnpm test:ci

# Flutter starter — must pass clean
cd starters/flutter
flutter analyze && flutter test
```

After configuring real services:

```bash
# With live Supabase credentials
cp .env.example .env.local  # Fill in real values
pnpm db:push
pnpm dev
curl http://localhost:3000/api/health
```

---

## Repo Structure

```
agentic-blueprint/
├── docs/
│   ├── templates/              # 9 spec-driven development templates
│   └── guides/                 # 11 full lifecycle workflow guides
├── starters/
│   ├── nextjs/                 # Full-stack Next.js starter
│   │   ├── src/lib/            # Infrastructure layer (16 modules)
│   │   ├── src/app/            # App shell + example API routes
│   │   ├── scripts/            # DB reset and seed scripts
│   │   └── src/test/           # Test helpers and example tests
│   └── flutter/                # Mobile companion starter
│       ├── lib/core/           # API client, auth, router, storage
│       ├── lib/features/       # Auth, home, profile, example CRUD
│       ├── lib/shared/         # Models, widgets, extensions
│       └── test/               # Unit tests
├── claude-config/              # Claude Code configuration + GitHub bootstrap
│   ├── CLAUDE.md.template      # Project guide (16 Hard Rules, Reusable Infrastructure, plan patterns)
│   ├── settings.local.json.template
│   ├── memory-guidelines.md
│   ├── hooks/                  # Pre-commit, post-merge, post-deploy patterns
│   ├── github/                 # Issue + PR templates + auto-label workflow
│   └── scripts/                # 6 bootstrap/operational scripts
├── .github/workflows/          # Meta-CI for the blueprint itself
│   └── bootstrap-smoke-test.yml
└── README.md
```

---

## Licence

MIT

---

Built with Claude by [ARK360](https://github.com/parkjadev).
