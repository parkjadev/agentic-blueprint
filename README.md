# Agentic Blueprint

A framework for building products with AI — covering the parts that agentic coding tools skip.

> Coding tools solve the middle. This Blueprint solves the bookends: framing what good looks like before you build, and closing the loop after you ship.

---

## The Three Beats

```
Spec → Ship → Signal
 ↑                │
 └── feedback ────┘
```

Every product follows three beats. Most agentic tools only help with the middle one.

| Beat | What | Why tools alone can't do it |
|---|---|---|
| **Spec** | Frame the problem, define done, produce the spec artefacts | No thinking surface; no spec discipline; no scope-aware templates |
| **Ship** | Build + test + deploy + release as one PR-driven loop | Every agentic tool helps here — the Blueprint adds gates + idempotence |
| **Signal** | Run + monitor + learn + scheduled automation; feeds Spec | No scheduled automation, no peer-review substitute, no durable learnings log |

v4 collapses the previous five-stage model (Research & Think → Plan → Build → Ship → Run) because Claude Code now handles Plan → Build → Ship in one continuous motion. The framework is still tool-agnostic — the beats describe the work, not the tool.

---

## Quickstart

### Option A — New project from a starter

1. Click **"Use this template"** on GitHub.
2. Copy the Next.js starter (or Flutter — same flow):
   ```bash
   cp -r starters/nextjs/* .
   cp starters/nextjs/.env.example .
   cp -r starters/nextjs/.github .
   ```
3. Configure Supabase (the only required service):
   ```bash
   cp .env.example .env.local
   # Fill in: DATABASE_URL, NEXT_PUBLIC_SUPABASE_URL,
   # NEXT_PUBLIC_SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY
   ```
4. Install the Blueprint harness:
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

### Option B — Adopt into an existing codebase

The Blueprint ports into an existing repo without touching source code:

```bash
# From inside your repo, using Claude Code:
/beat install
```

`/beat install` detects your layout, dry-runs, then copies the `.claude/` bundle, merges your existing `CLAUDE.md` via a fenced block (your content stays intact), installs the GitHub Actions hard-rules wrapper, and writes `claude-config/VERSION` so future `/beat update` runs can reason about drift.

### Option C — Framework only (bring your own stack)

1. Copy `docs/templates/` into your repo
2. Copy `claude-config/CLAUDE.md.template` and customise
3. Read the three beat guides in `docs/guides/`
4. Follow the loop: Spec → Ship → Signal

No starter code required.

---

## Guides

| Guide | What it covers |
|---|---|
| [Spec](docs/guides/beat-spec.md) | Sub-verbs (idea / epic / feature / fix / chore), spec-researcher, spec-author, parent-linkage cascade |
| [Ship](docs/guides/beat-ship.md) | Idempotent PR loop, GitHub Flow default, starter-verify, preview smoke-test, verify |
| [Signal](docs/guides/beat-signal.md) | Scheduled-task manifest, `/signal audit` peer-review substitute, feedback into Spec |
| [Tool Reference](docs/guides/tool-reference.md) | Role mapping and the 2-profile × 3-beat matrix (Claude-native + OutSystems ODC) |

---

## Templates

Spec-driven development templates. Every feature starts as a spec before any code is written. v4 ships **9 active templates** (down from 12 in v3) — api-spec, data-model-spec, and auth-spec were absorbed into `technical-spec.md`; deployment + release-strategy were merged into `delivery.md`.

| Template | Beat | Structure |
|---|---|---|
| [Research Brief](docs/templates/research-brief.md) | Spec | Questions, findings, market landscape, implications |
| [PRD](docs/templates/PRD.md) | Spec | `scope: product \| epic \| feature` — Problem → Users → Journeys → Feature matrix (product only) → Metrics |
| [Technical Spec](docs/templates/technical-spec.md) | Spec | `scope: epic \| feature \| fix` — Overview → Data model → API → Auth → Testing → Rollout |
| [Architecture](docs/templates/architecture.md) | Spec | System diagram, component map, data flow, integrations |
| [API Reference](docs/templates/api-reference.md) | Ship | Full endpoint catalogue with response envelope and error codes |
| [Delivery](docs/templates/delivery.md) | Ship | Release profile → environments → branch strategy → CI/CD → flags → rollback |
| [Incident Runbook](docs/templates/incident-runbook.md) | Signal | Trigger → severity → mitigation → rollback ladder → post-mortem → learnings |
| [Changelog](docs/templates/CHANGELOG.md) | Signal | keepachangelog format with examples |
| [README](docs/templates/README.md) | Project-level | Per-project README template |

Retired templates are preserved in `docs/templates/_archive/` with redirect stubs for provenance.

---

## Starters (optional)

Opinionated reference implementations. Use them if the stack fits; ignore them if you're bringing your own.

### Next.js Starter (`starters/nextjs/`)

Full-stack starter with Supabase (PostgreSQL, Auth, Storage), Drizzle ORM, and opt-in services (Stripe, Inngest, Resend). Includes example CRUD API, auth pages, rate limiting, and CI pipeline. Starter-local conventions (like the optional-services Zod pattern) live in `starters/nextjs/CLAUDE.md`.

### Flutter Starter (`starters/flutter/`)

Mobile companion with Supabase Auth (via `supabase_flutter`), Riverpod state management, GoRouter navigation, and Dio HTTP client matching the Next.js API envelope.

### Claude Config (`claude-config/`)

Copy-ready bundle for any project using Claude Code: `CLAUDE.md` template, permission settings, memory guidelines, hook patterns, issue/PR templates, bootstrap scripts, and `VERSION` pin.

---

## Platform Profiles

The Blueprint is documented for two platform profiles:

| Profile | Build Tool | Best For |
|---|---|---|
| **Claude-native** | Claude Code | Solo founders and small teams, pro-code SaaS + mobile |
| **OutSystems ODC** | Mentor + Enterprise Context Graph | Enterprise teams on OutSystems Developer Cloud |

Spec and Signal artefacts are identical across profiles; only Ship mechanics diverge. See [Tool Reference](docs/guides/tool-reference.md) for the full beat × profile matrix.

---

## Philosophy

AI is treated as a senior collaborator who needs context to perform. Output quality is directly proportional to the context provided — project guides, specs, schemas, clear instructions.

1. **Spec** before you build — every feature starts as a document.
2. **Gates** beat guidance — if a rule matters, wire a hook; if you can't, drop the rule or scope it differently.
3. **Flexibility has named escapes** — tagged commit prefixes (`[release]`, `[infra]`, `[docs]`, `[bulk]`) replace `--no-verify`.
4. **Context compounds** — `docs/signal/learnings.md` accumulates durable insights across cycles; every future `/spec idea` reads it.
5. **One operator, one framework** — v4 is sized for a solo developer running multiple products. Adopt-in-place via `/beat install` keeps it portable.

---

## Repo Structure

```
agentic-blueprint/
├── .claude/                    # Claude Code harness — commands, agents, skills, hooks
├── docs/
│   ├── templates/              # 9 spec-driven templates (the IP) + _archive/
│   ├── guides/                 # 3 beat guides + 1 tool reference
│   ├── principles/             # 5 Hard Rules + 3 meta-principles
│   ├── operations/             # Signal-beat runbooks (incident response, post-mortems)
│   ├── research/               # Research briefs (Spec-beat output)
│   ├── specs/                  # Filled-in specs (Spec-beat output)
│   └── signal/                 # Accumulating logs: learnings, agent-log, dependencies, spend
├── starters/
│   ├── nextjs/                 # Optional: Next.js reference implementation
│   └── flutter/                # Optional: Flutter reference implementation
├── claude-config/              # Copy-ready bundle for /beat install
├── CLAUDE.md                   # Primitive map for this repo
├── CHANGELOG.md
└── README.md
```

---

## Verification

```bash
# Hard Rules (all 5 pass on a clean clone)
bash .claude/skills/hard-rules-check/scripts/check-all.sh

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
