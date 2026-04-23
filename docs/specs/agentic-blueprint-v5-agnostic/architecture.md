# Architecture — Agentic Blueprint v5 (Platform-Agnostic Redesign)

**Author:** solo maintainer
**Date:** 2026-04-23
**Status:** Draft

---

## System Overview

The agentic-blueprint is a repo-native framework, not a runtime application. It has no servers, no database, no deployment pipeline of its own. It ships a bundle of configuration files, document templates, and workflow guides that wire up an AI-collaboration harness inside a repository.

v5.0's scope is narrower than the research brief suggested. With a single user (me) and no active pilot project, v5.0 ships just the structural pivots needed to make the blueprint stack-agnostic. Broader-adopter concerns (plugin packs, AGENTS.md emission, v4 migration) are deferred to v5.x contingent on real demand.

```
┌─────────────────────────────────────────────────────────────┐
│  Repository using agentic-blueprint                          │
│                                                              │
│  ┌─────────────────┐   ┌──────────────────────────────────┐ │
│  │  .claude/        │   │  docs/                           │ │
│  │  ├── commands/   │   │  ├── specs/<slug>/               │ │
│  │  ├── agents/     │   │  ├── research/<slug>-brief.md    │ │
│  │  ├── skills/     │   │  ├── templates/ (sacred)         │ │
│  │  ├── hooks/      │   │  ├── contracts/ (NEW in v5.0)    │ │
│  │  └── settings.json│  │  ├── guides/                     │ │
│  └─────────────────┘   │  └── principles/                 │ │
│                         └──────────────────────────────────┘ │
│                                                              │
│  CLAUDE.md  (harness config, fenced block)                   │
│  claude-config/VERSION  (semver, for /beat update)           │
└─────────────────────────────────────────────────────────────┘
         │
         │ (Hard Rules gate runs on every commit + in CI)
         ▼
    GitHub Actions — hard-rules-check workflow
```

---

## Component Map

| Component | Responsibility | Location | v5.0 change |
|---|---|---|---|
| Slash commands | Beat entry points (`/spec`, `/ship`, `/signal`, `/beat`) | `.claude/commands/` | No primitive change; `/spec idea` wires stack-selection research |
| Subagents | Isolated workers — `spec-researcher`, `spec-author` | `.claude/agents/` | Chunked-write + context-pack protocols locked as baseline (from #113) |
| Skills | Progressive-disclosure helpers — `australian-spelling`, `hard-rules-check`, `signal-sync` | `.claude/skills/` | `starter-verify` removed (no starters to verify); `hard-rules-check` loses Rule 2 if retired |
| Hooks | `session-start`, `beat-aware-prompt`, `template-guard`, `pre-write-spelling`, `pre-commit-secret-scan`, `pre-commit-gate`, `prune-merged-branches` | `.claude/hooks/` | No change; pre-commit-gate still enforces the remaining rules |
| Sacred templates | Spec-driven document scaffolds (PRD, technical-spec, architecture, research-brief, etc.) | `docs/templates/` | Budget preambles shipped in #114 locked as baseline |
| **Reference contracts** | **NEW.** Stack-agnostic interface definitions — `ApiResponse<T>` envelope, error taxonomy, auth-token shape, telemetry schema. Rule-4 protected. | `docs/contracts/` | **Net-new directory in v5.0** |
| Principles | Hard Rules 1–5 + meta-principles 6–8 as prose | `docs/principles/` | Rule 2 file moves to `_archive/` if retired |
| Guides | Long-form beat guides and tool reference | `docs/guides/` | Profile sweep: drop the v4 three-profile content (Claude-native / Cursor+Perplexity / OutSystems ODC) from `tool-reference.md` and from beat guides; reframe `tool-reference.md` as a role + inputs matrix |
| CI wrapper | GitHub Actions workflow invoking `scripts/check-all.sh` | `.github/workflows/` | No change |
| VERSION file | Semver marker for `/beat update` drift detection | `claude-config/VERSION` | Bump to `5.0.0` at release cut |

Removed in v5.0 transition (already gone from repo post PR #109):

- `starters/` (Next.js, Flutter, .NET + Azure reference trees)
- `.github/workflows/bootstrap-smoke-test.yml`
- `claude-config/scripts/bootstrap-smoke-test.sh`
- `starter-verify` skill

Deferred to v5.x (not built in v5.0):

- AGENTS.md emitter in `/beat install`
- Plugin-pack marketplace integration
- Per-stack plugin packs (Next.js, Flutter, .NET + Azure)
- Migration shim + guide

---

## Data Flow

### Flow 1: `/spec idea` produces a stack recommendation

```
User runs `/spec idea <product>`
  → spec-researcher (subagent)
    → Reads problem statement from prompt
    → Reads prior briefs in docs/research/ (dedup)
    → Writes skeleton brief within 90s (checkpoint)
    → WebSearch — one query per research question (budget: ≤ 10 questions)
    → Appends findings via Edit (≤ 1500 words/chunk)
    → Produces docs/research/<slug>-brief.md with stack recommendation
  → spec-author (subagent)
    → Reads brief + templates
    → Writes PRD skeleton within 3 tool calls (heartbeat)
    → Appends sections via Edit (≤ 1500 words/chunk)
    → Produces docs/specs/<slug>/PRD.md + architecture.md
  → User reviews; may override stack pick; flips status Draft → Approved
  → /ship scaffolds the project manually against docs/contracts/
```

The critical path is the research step. Stack-selection quality gates whether v5.0 delivers on its core promise.

### Flow 2: `/ship` implements a feature with Hard Rules enforcement

```
User runs `/ship`
  → Reads the approved spec (PRD / technical-spec for the slug)
  → Implements feature on a branch
  → On every commit, pre-commit-gate.sh runs:
      - Rule 1 (Australian spelling)
      - Rule 3 (Spec-before-Ship — [docs]/[infra] exceptions)
      - Rule 4 (Templates versioned — [release] exception or templates/* branch)
      - Rule 5 (Descriptive profiles)
      - (Rule 2 — removed in v5.0 if retirement accepted)
  → Opens PR; CI re-runs the same check
  → Squash-merge on green
  → signal-sync skill runs post-merge
```

No stack-specific branching in the Ship flow itself — it runs identically regardless of what `/spec idea` picked.

---

## Integrations

| Service | Purpose | Required | Failure Behaviour |
|---|---|---|---|
| Claude Code (CLI or IDE extension) | Runtime for all slash commands, subagents, hooks | Yes | Blueprint cannot execute; fall back to plain git + manual spec drafting |
| GitHub (git host + Actions) | Remote, PRs, CI gate | Yes for CI | Local pre-commit-gate still fires; PRs/CI not available |
| WebSearch / WebFetch (via Claude Code) | External research in `spec-researcher` | Required during Spec beat | `spec-researcher` produces a lower-confidence brief from repo-internal context alone |

Deferred integrations: Claude Code Plugin Marketplace (for v5.x plugin packs), non-Claude agent runtimes (for AGENTS.md consumers), alternative CI platforms (GitLab, CircleCI).

---

## Key Architecture Decisions

| Decision | Choice | Alternatives Considered | Rationale |
|---|---|---|---|
| Starter replacement | `docs/contracts/` reference library only | (A) Research-derived scaffold generator; (B) Adopter-curated source pointers; (D) Marketplace plugin packs | (A) is complex with no pilot to validate against; (B) loses contract discipline; (D) requires governance infra we don't have. Contracts-only ships the load-bearing IP without overhead. |
| Hard Rule 2 treatment | Retire in v5.0; revisit in v5.x if plugin packs land | Reframe to "plugin must boot clean"; reframe to "scaffolded project must boot clean" | Both reframes are vacuous until Option D or Option A ships. Honest retirement beats a dormant rule. |
| Subagent reliability | Chunked-write + context-pack protocols as agent-definition contract | Main-thread-only drafting; always-inline context | Subagents give context isolation; chunked-write makes them reliable. See #113/#114. |
| Budget enforcement | Template preamble comments (words ≤ 4000 / 4500); operator-observed, not CI-gated in v5.0 | Pre-commit check on word count; CI failure on overrun | Automated word-count gating is v5.x polish; preamble + self-review is enough for solo use. |
| v4 migration surface | No migration support in v5.0 | Pin-to-commit; shim layer; migration guide | No v4 adopters exist. Investing in migration before there's someone to migrate is over-engineering. |
| Multi-agent portability | Deferred (no AGENTS.md emission in v5.0) | Emit AGENTS.md as symlink; emit as separate file | Claude Code is the only runtime in active use. Revisit when a non-Claude agent is in the loop. |
| v4 three-profile docs | Drop (Claude-native / Cursor+Perplexity / OutSystems ODC content removed) | Keep all three as reference; keep but archive | Agnostic by design means profiles aren't needed. Only the Claude Code profile has a real user. Rule 5 principle stays; concrete profiles return in v5.x if multi-agent adopters arrive. |
| v5.0 release cut | Bump `claude-config/VERSION` to `5.0.0` at final Ship epic merge | Wait until pilot project completes its first Spec beat | Don't block a structural release on external demand that may never come. Cut when the code is ready; battle-testing is v5.0's own success metric. |

---

## Environment Architecture

Not applicable for the blueprint itself — it's a static repo bundle, not a deployed service.

For projects *using* the blueprint, environment architecture is a per-project decision recorded in that project's own architecture spec. The blueprint does not prescribe dev / staging / prod topology.

---

## Security Architecture

Blueprint-level security concerns are limited to repo hygiene:

- **Secret-scan pre-commit hook** (`pre-commit-secret-scan.sh`) blocks commits containing likely secrets (API keys, `.env` contents, credentials).
- **Australian-spelling pre-write hook** (`pre-write-spelling.sh`) is a prose gate, not a security gate — included here for completeness.
- **Template-guard hook** (`template-guard.sh`) prevents accidental edits to `docs/templates/` outside `docs/*` / `templates/*` branches or `AGENTIC_BLUEPRINT_RELEASE=1` environment.
- **Hard-rules CI gate** re-runs the local checks on PR to prevent local-gate bypass.

For projects *using* the blueprint, security architecture is captured in that project's own architecture + auth specs. The blueprint does not prescribe runtime security posture.

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
