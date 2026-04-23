# Architecture — Agentic Blueprint v5 (Platform-Agnostic Redesign)

**Author:** spec-author subagent
**Date:** 2026-04-23
**Status:** Draft
**Scope:** product
**Parent:** none

---

## System Overview

The agentic-blueprint is a repo-native framework, not a runtime application. It has no servers, no database, and no deployment pipeline of its own. It ships a bundle of configuration files, document templates, and workflow guides that wire up an AI-collaboration harness inside an adopter's repository.

The framework is installed via `/beat install`, which copies the bundle into the adopter's repo and leaves their source code untouched. Once installed, the harness runs entirely through Claude Code slash commands, hooks, and subagents — all of which execute inside the adopter's local or CI environment.

```
┌──────────────────────────────────────────────────────────┐
│  Adopter repository                                       │
│                                                           │
│  ┌─────────────────┐   ┌──────────────────────────────┐  │
│  │  .claude/        │   │  docs/                       │  │
│  │  ├── commands/   │   │  ├── specs/<slug>/           │  │
│  │  ├── agents/     │   │  ├── research/<slug>-brief   │  │
│  │  ├── skills/     │   │  ├── templates/ (sacred)     │  │
│  │  ├── hooks/      │   │  ├── contracts/ (NEW v5)     │  │
│  │  └── settings.json│  │  ├── guides/                 │  │
│  └─────────────────┘   │  └── principles/              │  │
│                         └──────────────────────────────┘  │
│  ┌─────────────────┐   ┌──────────────────────────────┐  │
│  │  CLAUDE.md       │   │  AGENTS.md  (NEW v5)         │  │
│  │  (fenced merge)  │   │  (emitted by /beat install)  │  │
│  └─────────────────┘   └──────────────────────────────┘  │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  .github/workflows/hard-rules.yml  (CI gate)        │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
         │                            │
         ▼                            ▼
┌─────────────────┐        ┌─────────────────────────────┐
│  Claude Code     │        │  Claude Code Marketplace     │
│  (local agent)   │        │  plugin packs (per-stack)    │
└─────────────────┘        └─────────────────────────────┘
```

The framework has one external integration point at install time (copying from `claude-config/` in the blueprint repo) and one at runtime (the Claude Code Marketplace for optional plugin packs). Everything else is local to the adopter's repo.

---

## Component Map

| Component | Responsibility | Location | Notes |
|---|---|---|---|
| `/spec` command | Entry point for Spec beat: idea, epic, feature, fix, chore modes | `.claude/commands/spec.md` | Invokes spec-researcher and spec-author subagents |
| `/ship` command | Entry point for Ship beat: idempotent PR loop with gates | `.claude/commands/ship.md` | Invokes pre-commit hooks and CI gate |
| `/signal` command | Entry point for Signal beat: init, sync, audit, status | `.claude/commands/signal.md` | Invokes signal-sync skill |
| `/beat` command | Harness management: status, install, update | `.claude/commands/beat.md` | Install/update runs copy from `claude-config/` |
| `spec-researcher` subagent | Scoped web research for stack alternatives, market analysis, risk identification | `.claude/agents/spec-researcher` | Context-budget guardrail (P0): single WebSearch-or-question per step |
| `spec-author` subagent | Drafts + self-reviews spec documents from templates | `.claude/agents/spec-author` | Two-pass: draft then self-review; chunked-write protocol enforced |
| `australian-spelling` skill | Prose compliance check for Hard Rule 1 | `.claude/skills/australian-spelling/` | Shells out to check script; wordlist at `references/wordlist.md` |
| `hard-rules-check` skill | Verifies all five Hard Rules before risky actions | `.claude/skills/hard-rules-check/` | Calls `check-all.sh`; non-zero exit on violation |
| `signal-sync` skill | Post-merge signal synchronisation, learnings log | `.claude/skills/signal-sync/` | Evolves in v5 to be platform-agnostic (see Open Questions) |
| `starter-verify` skill | v4 legacy — verified starter boot. Retired in v5. | `.claude/skills/starter-verify/` | Removed from `/beat install` v5; shim emits deprecation warning |
| `session-start` hook | Sets up context at session open | `.claude/hooks/session-start` | |
| `beat-aware-prompt` hook | Injects beat-context into the system prompt | `.claude/hooks/beat-aware-prompt` | |
| `template-guard` hook | Prevents edits to `docs/templates/` without `[release]` prefix | `.claude/hooks/template-guard` | Enforces Hard Rule 4 |
| `pre-write-spelling` hook | Checks Australian spelling before file writes | `.claude/hooks/pre-write-spelling` | Enforces Hard Rule 1 |
| `pre-commit-secret-scan` hook | Scans for secrets before commit | `.claude/hooks/pre-commit-secret-scan` | |
| `pre-commit-gate` hook | Runs full hard-rules-check before commit | `.claude/hooks/pre-commit-gate` | Reads commit message prefix for tagged exceptions |
| `prune-merged-branches` hook | Cleans up merged branches post-Ship | `.claude/hooks/prune-merged-branches` | |
| Sacred templates | Nine spec-driven document templates. Rule-4 protected — never edited in a feature PR. | `docs/templates/` | PRD, architecture, technical-spec, research-brief, and others |
| `docs/contracts/` | NEW v5. Stack-agnostic interface contracts (JSON Schema + prose). Rule-4 protected. Replaces opinionated starters as the reference artefact. | `docs/contracts/` | Copied by `/beat install` into adopter repo |
| `docs/principles/` | Long-form rationale for each Hard Rule and meta-principle | `docs/principles/` | Rules 1–8; read-only for agents |
| `docs/guides/` | Long-form beat guides and tool reference | `docs/guides/` | Reframed in v5: tool-reference becomes role + inputs matrix |
| `claude-config/` | Copy-ready bundle for `/beat install` and `/beat update` | `claude-config/` | Contains `VERSION` file for semver tracking |
| `claude-config/VERSION` | Semver version of the installed blueprint bundle | `claude-config/VERSION` | Written/updated by `/beat install` and `/beat update` |
| `.github/workflows/hard-rules.yml` | CI gate running hard-rules-check on every PR | `.github/workflows/` | GitHub Actions; porting notes for GitLab/CircleCI in `docs/guides/` |
| `CLAUDE.md` | Primary harness-configuration file; fenced-merge on install | Root of adopter repo | Always present; never replaced wholesale — fence merge only |
| `AGENTS.md` | NEW v5. Agent-agnostic harness-configuration file emitted by `/beat install`. Enables non-Claude agents to read blueprint conventions. | Root of adopter repo | Emitted fresh on install; opt-in on update |

---

## Data Flow

Three key flows define how the framework operates at runtime.

### Flow 1: `/spec idea` → Research Brief → Spec Documents → Branch + Issue

```
Human: /spec idea <slug>
  │
  ├─▶ spec-researcher subagent
  │     ├── Reads existing research brief if present
  │     ├── Executes scoped web search (single WebSearch per step — budget guardrail)
  │     ├── Evaluates stack alternatives against problem constraints
  │     └── Writes docs/research/<slug>-brief.md
  │
  ├─▶ spec-author subagent
  │     ├── Reads research brief + parent spec (if any)
  │     ├── Reads relevant template(s) from docs/templates/
  │     ├── PASS 1 — Draft
  │     │     ├── Writes docs/specs/<slug>/PRD.md  (chunk 1: Write ≤ 1500 words)
  │     │     ├── Appends remaining sections       (chunks: Edit ≤ 1500 words each)
  │     │     └── Writes docs/specs/<slug>/architecture.md (same chunked protocol)
  │     └── PASS 2 — Self-review
  │           ├── Section completeness check
  │           ├── Hard-rules-check skill
  │           ├── Australian-spelling skill
  │           ├── Internal consistency check (PRD ↔ architecture)
  │           └── Fixes issues in-place before returning
  │
  └─▶ Harness creates GitHub issue + feature branch
```

### Flow 2: `/ship` → PR Loop with Gates → Merge → Verify

```
Human: /ship
  │
  ├─▶ Spec-before-Ship check (Hard Rule 3)
  │     └── docs/specs/<slug>/ must exist; exit non-zero if missing
  │
  ├─▶ Implementation loop
  │     ├── Agent writes / edits source files
  │     ├── pre-write-spelling hook fires on each Write (Hard Rule 1)
  │     └── template-guard hook fires if docs/templates/ is touched (Hard Rule 4)
  │
  ├─▶ pre-commit-gate hook
  │     ├── Reads commit message prefix (tagged exceptions: [release], [infra], [docs], [bulk])
  │     ├── Runs hard-rules-check skill (all five rules)
  │     │     ├── Rule 1: australian-spelling check
  │     │     ├── Rule 2: plugin-pack boot-clean verification (if a pack is present)
  │     │     ├── Rule 3: spec-before-ship check
  │     │     ├── Rule 4: templates not modified
  │     │     └── Rule 5: no prescriptive language in profiles/guides
  │     └── Exit non-zero on any failure — commit blocked
  │
  ├─▶ CI: hard-rules.yml (GitHub Actions)
  │     └── Mirrors pre-commit-gate in CI — prevents bypass via direct push
  │
  ├─▶ PR opens → preview smoke-test → human review
  │
  ├─▶ Squash-merge to main
  │
  └─▶ Post-merge verify + prune-merged-branches hook
```

### Flow 3: `/beat install` into an Existing Repo

```
Human: /beat install  (run inside adopter's repo)
  │
  ├─▶ Dry-run pass
  │     └── Reports: create / merge / skip for each artefact
  │
  ├─▶ Copy .claude/ bundle from claude-config/
  │
  ├─▶ CLAUDE.md fence-merge
  │     ├── If CLAUDE.md exists: insert blueprint content inside
  │     │   <!-- agentic-blueprint:begin/end --> fence block
  │     └── If absent: write CLAUDE.md fresh
  │
  ├─▶ AGENTS.md emission (NEW v5)
  │     ├── If absent: write AGENTS.md with agent-agnostic harness conventions
  │     └── If present: offer to update (opt-in)
  │
  ├─▶ Copy docs/ scaffolding
  │     ├── docs/templates/  (9 sacred templates)
  │     ├── docs/contracts/  (NEW v5 — stack-agnostic interface contracts)
  │     ├── docs/principles/ (Hard Rule rationale)
  │     └── docs/guides/     (beat guides + tool-reference)
  │
  ├─▶ Install CI wrapper
  │     └── .github/workflows/hard-rules.yml
  │         (or print porting notes for GitLab / CircleCI)
  │
  └─▶ Write claude-config/VERSION  (semver of installed bundle)
```

---

## Integrations

| Service | Purpose | Required | Failure Behaviour |
|---|---|---|---|
| **Claude Code** | Primary agent runtime; executes slash commands, subagents, hooks | Yes | Framework non-operational without an agent runtime; AGENTS.md enables fallback to non-Claude agents |
| **Claude Code Marketplace** | Distribution channel for per-stack plugin packs (Option D) | No | Core harness fully functional without any plugin pack installed |
| **GitHub Actions** | CI gate for hard-rules-check on every PR | No (but strongly recommended) | Without CI gate, pre-commit hook is the only enforcement; bypass risk increases |
| **GitLab CI / CircleCI** | Alternative CI platforms; porting notes in `docs/guides/` | No | Not first-class in v5.0; adopters follow porting guide |
| **Non-Claude agents** (Cursor, Copilot Workspace, etc.) | Secondary agent runtimes reading `AGENTS.md` | No | AGENTS.md is advisory; non-Claude agents operate with reduced harness integration |

The blueprint has no database dependency, no network service, and no runtime infrastructure of its own. All state lives in the adopter's git repository.

---

## Key Architecture Decisions

| Decision | Choice | Alternatives Considered | Rationale |
|---|---|---|---|
| Starter replacement model | Two-layer: `docs/contracts/` in core (Option C) + per-stack plugin packs on Marketplace (Option D) | Option A (AI generator, deferred to v5.x); Option B (keep starters); Option E (no replacement) | Option C gives all personas access to reference contracts without imposing stack opinions. Option D re-serves the reference-code-reader persona via Marketplace without polluting the core repo. |
| AGENTS.md emission | Separate file emitted alongside CLAUDE.md; agent-agnostic prose | Symlink from AGENTS.md → CLAUDE.md; single merged file; no AGENTS.md | Separate file allows agent-agnostic framing without duplicating or diluting CLAUDE.md. Symlink risks VCS issues on some platforms. |
| Hard Rule 2 disposition | Reframe: "any stack-pack plugin must boot clean via its own declared verification harness" | Retire Rule 2 entirely; keep Rule 2 unchanged (vacuously passing) | Retiring a Hard Rule weakens the gates-over-guidance principle. Keeping it unchanged leaves a permanently dormant rule. Reframing preserves the intent and gives it real teeth in the plugin-pack context. |
| Migration strategy | Pin-to-commit (`3bb4c27`) + two-release deprecation shim + migration guide | Hard cut (no shim); automatic migration script | Hard cut would break known v4 adopters. Automatic script is complex and error-prone for diverse repo structures. Pin + shim + guide balances continuity with a clear migration path. |
| Research-budget guardrail | Single WebSearch-or-question constraint encoded in spec-researcher + research-brief template | No constraint; post-hoc token-count check; separate rate-limiting layer | Constraint must be structural (in the agent definition and template) not advisory, to prevent the stream-idle-timeout class of incidents (Risk R6). PRs #113/#114 validated this approach. |
| spec-author large-output protocol | First Write ≤ 1500 words; subsequent sections via Edit ≤ 1500 words each | Single Write for full document; streaming without chunking | Single Write of a full spec risks truncation and context-window exhaustion. Chunked Edit protocol ensures the document lands completely and the file is always in a valid state for self-review. |
| `docs/contracts/` Rule protection | Rule-4 protected (template-guard hook; `[release]` tag required to modify) | Rule-3 protection only; no special protection; freely editable | Contracts are the reference artefact in v5. Unrestricted edits would cause them to drift toward opinionated starters over time (Risk R7). Rule-4 treatment gives contracts the same versioning discipline as sacred templates. |

---

## Environment Architecture

The agentic-blueprint has no dev/staging/production environments of its own. It is a framework installed into adopters' repositories.

| Context | Description | Notes |
|---|---|---|
| Blueprint repo itself | Canonical source of the `claude-config/` bundle, templates, and guides | Developed under the same three-beat lifecycle it prescribes; hard-rules CI gate on every PR |
| Adopter repo — local | Adopter runs slash commands locally via Claude Code or another agent runtime | No blueprint-specific server; all state in git |
| Adopter repo — CI | Adopter's CI runs `hard-rules.yml` on every PR | Blueprint provides the workflow file; CI infrastructure is the adopter's own |
| Plugin-pack development | Plugin-pack author develops against `docs/contracts/` and publishes to Claude Code Marketplace | Pack's own CI must include a boot-clean verification harness (reframed Hard Rule 2) |

There is no long-lived staging branch for the blueprint itself. Squash-merge to `main` is the only promotion path — consistent with the Ship beat the blueprint prescribes.

---

## Security Architecture

The blueprint's security posture is repo-hygiene focused. There is no network service to secure.

- **Secret scanning:** `pre-commit-secret-scan` hook fires on every commit; blocks secrets from entering the git history.
- **Template protection:** `template-guard` hook prevents edits to `docs/templates/` in feature PRs (Hard Rule 4). The `[release]` commit-message prefix is required to bypass — creating an auditable exception in the git log.
- **Contracts protection:** `docs/contracts/` carries the same Rule-4 protection as sacred templates (template-guard hook applies to both paths).
- **Australian-spelling enforcement:** `pre-write-spelling` hook fires on every file write (Hard Rule 1). Non-compliant prose is blocked before it reaches git.
- **Hard-rules CI gate:** `.github/workflows/hard-rules.yml` mirrors the pre-commit gate in CI. Direct push cannot bypass the rules.
- **No secrets in the blueprint:** The framework contains no API keys, credentials, or environment-specific configuration. `claude-config/` carries only structural files.
- **Commit-message audit trail:** Tagged exceptions (`[release]`, `[infra]`, `[docs]`, `[bulk]`) are recorded in the git log. Rules 1, 2, and 5 are never skippable via any tag.
- **Plugin-pack supply chain:** Plugin packs distribute via Claude Code Marketplace. The governance document (P1) will define the minimum verification harness required for a pack to claim Rule-2 compliance.

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
