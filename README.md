# Agentic Blueprint

A framework for building products with AI — covering the stages that agentic coding tools skip.

> Cursor and Replit solve coding. This Blueprint solves everything around it: the research before you build, the discipline while you build, and the automation after you ship.

---

## The Five Stages

```
Research & Think → Plan → Build → Ship → Run
       ↑                                    │
       └────────── feedback loop ───────────┘
```

Every product follows five stages. Most agentic tools only cover one of them.

| Stage | What | Why tools alone can't do it |
|---|---|---|
| **1. Research & Think** | Understand the problem, write the PRD | No thinking surface, no persistent context |
| **2. Plan** | Specs, architecture, issues, branches | No spec discipline, no templates |
| **3. Build** | Code, test, PR | Every tool covers this |
| **4. Ship** | Deploy, verify, clean up | Limited deployment flexibility |
| **5. Run** | Automated maintenance, ops | No scheduled automation, no ops layer |

The framework is tool-agnostic. The starters and tool recommendations are opinionated — use what works for your team.

---

## Quickstart

### Option A: Use the starter (opinionated stack)

1. Click **"Use this template"** on GitHub
2. Copy the starter into your repo root:
   ```bash
   cp -r starters/nextjs/* .
   cp starters/nextjs/.env.example .
   cp starters/nextjs/.eslintrc.json .
   cp -r starters/nextjs/.github .
   ```
3. Configure Supabase (the only required service):
   ```bash
   cp .env.example .env.local
   # Fill in: DATABASE_URL, NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY
   ```
4. Set up Claude Code + GitHub:
   ```bash
   cp claude-config/CLAUDE.md.template CLAUDE.md
   mkdir -p .claude
   cp claude-config/settings.local.json.template .claude/settings.local.json
   cp -R claude-config/github/. .github/
   ./claude-config/scripts/setup-labels.sh
   ./claude-config/scripts/setup-branch-protection.sh
   ```
5. Boot:
   ```bash
   pnpm install && pnpm db:push && pnpm dev
   curl http://localhost:3000/api/health
   ```

### Option B: Bring your own stack (framework only)

1. Copy `docs/templates/` into your repo
2. Copy `claude-config/CLAUDE.md.template` and customise for your project
3. Read the five stage guides in `docs/guides/`
4. Follow the loop: Research & Think → Plan → Build → Ship → Run

No starter code required. The templates and guides work with any tech stack.

---

## Guides

| Guide | What It Covers |
|---|---|
| [Stage 1: Research & Think](docs/guides/stage-1-research-and-think.md) | Market research, problem exploration, PRD |
| [Stage 2: Plan](docs/guides/stage-2-plan.md) | Specs, architecture, issues, branches |
| [Stage 3: Build](docs/guides/stage-3-build.md) | Code, test, PR — the discipline layer |
| [Stage 4: Ship](docs/guides/stage-4-ship.md) | Deploy, verify, rollback, mobile supervision |
| [Stage 5: Run](docs/guides/stage-5-run.md) | Scheduled automation, ops, maintenance |
| [Tool Reference](docs/guides/tool-reference.md) | Role mapping, decision tree, platform profiles (Claude, Cursor, OutSystems ODC) |

---

## Templates

Spec-driven development templates. Every feature starts as a spec before any code is written.

| Template | Structure |
|---|---|
| [Research Brief](docs/templates/research-brief.md) | Questions, findings, market landscape, implications |
| [PRD](docs/templates/PRD.md) | Problem → Users → Journeys → Feature matrix → NFRs → Metrics |
| [Technical Spec](docs/templates/technical-spec.md) | Overview → Data model → API → Auth → Jobs → Testing → Rollout |
| [API Spec](docs/templates/api-spec.md) | Per-endpoint: method, path, auth, role, request/response schemas |
| [Data Model Spec](docs/templates/data-model-spec.md) | Drizzle schema, relationships, indexes, constraints, migration plan |
| [Auth Spec](docs/templates/auth-spec.md) | Flows, role matrix, session management, user sync |
| [Architecture](docs/templates/architecture.md) | System diagram, component map, data flow, integrations |
| [Deployment](docs/templates/deployment.md) | Environments, branch strategy, CI/CD, env vars, rollback |
| [API Reference](docs/templates/api-reference.md) | Full endpoint catalogue with response envelope and error codes |
| [Changelog](docs/templates/CHANGELOG.md) | Keepachangelog format with examples |

---

## Starters (Optional)

The starters are opinionated reference implementations. Use them if the stack fits; ignore them if you're bringing your own.

### Next.js Starter (`starters/nextjs/`)

Full-stack starter with Supabase (PostgreSQL, Auth, Storage), Drizzle ORM, and opt-in services (Stripe, Inngest, Resend). Includes example CRUD API, auth pages, rate limiting, and CI pipeline.

### Flutter Starter (`starters/flutter/`)

Mobile companion with Supabase Auth (via `supabase_flutter`), Riverpod state management, GoRouter navigation, and Dio HTTP client matching the Next.js API envelope.

### Stack Decisions

These apply to the starters. If you're using your own stack, skip this section.

| Choice | Rationale |
|---|---|
| **Supabase** | Single platform for PostgreSQL, auth, and storage. Unified auth for web and mobile. |
| **Drizzle** | Type-safe ORM with schema-as-code and `db:push` for rapid iteration. |
| **Inngest** | Event-driven background jobs without managing queues. Opt-in. |
| **Vercel** | Zero-config Next.js hosting with preview deploys per PR. |
| **Riverpod** | Compile-safe Flutter state management with async and dependency injection. |
| **GoRouter** | Declarative Flutter routing with typed parameters and auth redirects. |

### Optional Services

| Service | Env Vars | Purpose |
|---|---|---|
| **Stripe** | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` | Payments |
| **Inngest** | `INNGEST_EVENT_KEY`, `INNGEST_SIGNING_KEY` | Background jobs |
| **Resend** | `RESEND_API_KEY` | Transactional email |

### Claude Config (`claude-config/`)

Drop-in configuration for any project using Claude Code: CLAUDE.md template with Hard Rules, permission settings, memory guidelines, hook patterns, issue/PR templates, and bootstrap scripts.

---

## Platform Compatibility

The Blueprint is tested and documented for three platform profiles:

| Profile | Build Tool | Best For |
|---|---|---|
| **Claude-native** | Claude Code | Solo founders, full-stack web/mobile |
| **Cursor + Perplexity** | Cursor Agent | Teams wanting parallel agents, multi-vendor |
| **OutSystems ODC** | Mentor + Context Graph | Enterprise low-code delivery |

See [Tool Reference](docs/guides/tool-reference.md) for the full role-to-tool mapping for each profile.

---

## Philosophy

AI is treated as a senior collaborator who needs context to perform. The quality of AI output is directly proportional to the context you provide — project guides, specs, schemas, and clear instructions.

1. **Research** before you ideate — don't build solutions to problems that don't exist
2. **Think** before you code — a thinking partner with persistent context beats a prompt box
3. **Spec** before you build — every feature starts as a document, not a code change
4. **Automate** after you ship — maintenance that doesn't run doesn't happen
5. **Context compounds** — every minute invested in documentation pays dividends across every future session

The framework applies equally to code-first teams (Next.js, Flutter), AI-native editors (Cursor, Claude Code), and low-code platforms (OutSystems ODC). The stages are universal. The tools are interchangeable.

---

## Repo Structure

```
agentic-blueprint/
├── .claude/                    # Claude Code harness — commands, agents, skills, hooks
├── docs/
│   ├── templates/              # 10 spec-driven development templates (the IP)
│   ├── guides/                 # 5 stage guides + 1 tool reference
│   ├── principles/             # 9 Hard Rules + 3 meta-principles
│   ├── operations/             # Stage 5 runbooks (incident response, postmortems)
│   └── research/               # Research briefs (Stage 1 output)
├── starters/
│   ├── nextjs/                 # Optional: Next.js reference implementation
│   └── flutter/                # Optional: Flutter reference implementation
├── claude-config/              # Copy-ready bundle: CLAUDE.md template, .claude/ mirror, scripts
├── CLAUDE.md                   # Primitive map for this repo
├── CHANGELOG.md
└── README.md
```

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

---

## Licence

MIT

---

Built with Claude by [ARK360](https://github.com/parkjadev).
