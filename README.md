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

The three-beat model collapses the older Research & Think → Plan → Build → Ship → Run pipeline because Claude Code now handles Plan → Build → Ship in one continuous motion. The framework stays tool-agnostic — the beats describe the work, not the tool.

---

## Quickstart

### Option A — Adopt into an existing repo

The most common path. The Blueprint ports into an existing codebase without touching source code.

**First-time install** (no `.claude/` in your repo yet) — run `bootstrap.sh` from outside Claude Code:

```bash
# From the target repo's root:
bash <(curl -fsSL https://raw.githubusercontent.com/parkjadev/agentic-blueprint/main/bootstrap.sh) --dry-run
# Review the dry-run output, then re-run without --dry-run:
bash <(curl -fsSL https://raw.githubusercontent.com/parkjadev/agentic-blueprint/main/bootstrap.sh)
```

**Subsequent operations** (after the bundle is in your repo) — use the Claude Code slash commands:

```bash
# From inside your repo, using Claude Code:
/beat update    # pull newer blueprint; respects your customisations
/beat status    # report current beat + next command
```

Both paths run `claude-config/scripts/install.sh` under the hood: detect your layout, dry-run, then copy the `.claude/` bundle, merge your existing `CLAUDE.md` via a fenced block (your content stays intact), copy the templates + contracts, install the GitHub Actions hard-rules wrapper, and write `claude-config/VERSION` so future `/beat update` runs can reason about drift.

### Option B — New project

v5 ships no opinionated starter tree. Start a new project the same way you'd start any other: initialise a repo, then run:

```bash
/beat install
/spec idea <your-product>
```

`/spec idea` evaluates stack alternatives against your problem, produces a research brief with a ranked recommendation, then drafts PRD + architecture. Scaffold the recommended stack manually using the contracts at `docs/contracts/` as the wire-level spec.

### Option C — Framework only (bring your own stack, no harness)

1. Copy `docs/templates/` into your repo
2. Copy `docs/contracts/` for stack-neutral interface definitions
3. Copy `claude-config/CLAUDE.md.template` and customise
4. Read the three beat guides in `docs/guides/`
5. Follow the loop: Spec → Ship → Signal

---

## Guides

| Guide | What it covers |
|---|---|
| [Spec](docs/guides/beat-spec.md) | Sub-verbs (idea / epic / feature / fix / chore), spec-researcher, spec-author, parent-linkage cascade |
| [Ship](docs/guides/beat-ship.md) | Idempotent PR loop, GitHub Flow default, preview smoke-test, verify |
| [Signal](docs/guides/beat-signal.md) | Scheduled-task manifest, `/signal audit` peer-review substitute, feedback into Spec |
| [Tool Reference](docs/guides/tool-reference.md) | Role × inputs matrix. Stack selection is per-project; this describes the roles every project needs to fill. |

---

## Templates

Spec-driven development templates. Every feature starts as a spec before any code is written. The Blueprint ships **9 active templates** — api-spec, data-model-spec, and auth-spec are absorbed into `technical-spec.md`; deployment + release-strategy are merged into `delivery.md`.

| Template | Beat | Structure |
|---|---|---|
| [Research Brief](docs/templates/research-brief.md) | Spec | Questions, findings, market landscape, stack selection (product-scope), implications |
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

## Contracts

Stack-agnostic reference library at `docs/contracts/` — the load-bearing IP from the retired v4 starters, lifted into first-class artefacts protected by Hard Rule 4.

- [`api-response.md`](docs/contracts/api-response.md) — `ApiResponse<T>` envelope (prose + JSON Schema)
- [`error-taxonomy.md`](docs/contracts/error-taxonomy.md) — canonical error codes with HTTP mapping
- [`auth-token.md`](docs/contracts/auth-token.md) — access + refresh token shape, JWT claims
- [`telemetry.md`](docs/contracts/telemetry.md) — structured log + event envelope with `traceId` correlation

Projects using the Blueprint translate these into whatever their stack supports (Zod for TypeScript, Pydantic for Python, freezed for Dart, etc.). Contracts are specification, not a library.

---

## Philosophy

AI is treated as a senior collaborator who needs context to perform. Output quality is directly proportional to the context provided — project guides, specs, schemas, clear instructions.

1. **Spec** before you build — every feature starts as a document.
2. **Gates** beat guidance — if a rule matters, wire a hook; if you can't, drop the rule or scope it differently.
3. **Flexibility has named escapes** — tagged commit prefixes (`[release]`, `[infra]`, `[docs]`, `[bulk]`) replace `--no-verify`.
4. **Context compounds** — `docs/signal/learnings.md` accumulates durable insights across cycles; every future `/spec idea` reads it.
5. **Stack-agnostic by design** — stack selection is an output of the Spec beat, not an input. The blueprint describes the discipline; the stack is chosen per project.

---

## Repo Structure

```
agentic-blueprint/
├── .claude/                    # Claude Code harness — commands, agents, skills, hooks
├── docs/
│   ├── templates/              # 9 spec-driven templates (the IP) + _archive/
│   ├── contracts/              # Stack-agnostic interface library (Rule-4 protected)
│   ├── guides/                 # 3 beat guides + 1 tool reference
│   ├── principles/             # 4 Hard Rules + 3 meta-principles
│   ├── operations/             # Signal-beat runbooks (incident response, post-mortems)
│   ├── research/               # Research briefs (Spec-beat output)
│   ├── specs/                  # Filled-in specs (Spec-beat output)
│   └── signal/                 # Accumulating logs: learnings, agent-log, dependencies, spend
├── claude-config/              # Copy-ready bundle for /beat install
├── CLAUDE.md                   # Primitive map for this repo
├── CHANGELOG.md
└── README.md
```

---

## Verification

```bash
# Hard Rules (all 4 pass on a clean clone)
bash .claude/skills/hard-rules-check/scripts/check-all.sh
```

Four Hard Rules (1, 3, 4, 5) + three meta-principles (6, 7, 8). Rule 2 was retired in v5.0; archived at `docs/principles/_archive/02-starters-generic-boot-clean.md`. Numbering preserved so downstream references to Rules 3/4/5 don't silently shift.

---

## Licence

MIT

---

Built with Claude by [ARK360](https://github.com/parkjadev).
