# Research Brief — Agentic Blueprint v4 (Spec → Ship → Signal)

**Date:** 2026-04-21
**Researcher:** Claude (main-context synthesis during Stage 1 pivot)
**Tool:** Repo analysis + three parallel Explore passes + plan-mode Phase-2 design
**Confidence:** Medium-High — repo primitive counts verified directly; external-citation pass deferred to PR 2 (citations are needed for the principle rewrites, not for the structural pivot).

> **Supersession note.** The earlier brief at this path argued an incremental v4 inside the five-stage frame. That premise is wrong — the v4 pivot collapses the lifecycle to three beats. The old body is archived at `docs/research/_archive/agentic-os-v4-brief-incremental.md` for provenance.

---

## Research Questions

1. Does the five-stage lifecycle (Research & Think → Plan → Build → Ship → Run) still match how Claude Code actually delivers work in 2026, or has the tool collapsed several stages into one motion?
2. What is the smallest primitive set that still enforces spec-before-code, handles an idea through to a shipped feature, and stays usable by a solo developer running multiple SaaS and mobile products?
3. How should the framework support the **full scope range** — from a raw product idea down to a one-line chore — without growing separate scaffolding for each?
4. How does v4 port into an **existing** codebase (adopt-in-place) without touching the adopter's source code, and stay updatable without clobbering customisations?
5. What's the flexibility-rigor balance — which rules stay strict, and where do legitimate overrides need a named escape instead of `--no-verify`?

---

## Key Findings

### Finding 1 — Five stages no longer match tool reality

Claude Code in 2026 collapses Plan → Build → Ship into one continuous motion: a PR is the unit of delivery, not a journey through three stages. The human-led work concentrates at the bookends (framing what good looks like, interpreting what came back after ship); the middle is an automated loop with gates, not discrete handoffs. Maintaining the five-stage mental model creates PR-spanning friction and encodes a handoff-era assumption that no longer holds.

The three-beat model **Spec → Ship → Signal** matches the actual shape of the work:

- **Spec** — research + plan collapsed. Frame the problem, define done.
- **Ship** — build + test + deploy + release as one PR-driven loop with automated gates.
- **Signal** — run + monitor + learn + scheduled automation. Feeds back into Spec.

The advisory story is sharper too: *Spec and Signal are identical across platforms; only Ship mechanics diverge*. That's where the sellable IP concentrates.

### Finding 2 — The v3 harness is overgrown for a solo operator

Verified directly from the repo: 7 slash commands, 5 subagents, 5 skills, 5 hooks, 12 principles, 12 templates, 3 platform profiles (Claude-native, Cursor+Perplexity, OutSystems ODC). Half of those primitives either duplicate each other or encode a five-stage assumption the user no longer believes in.

Concretely redundant:
- `spec-writer` + `spec-reviewer` are two passes by the same persona; merge to one `spec-author`.
- `starter-verifier` and `docs-inspector` are isolated procedural runs (Bash/Grep), not multi-turn reasoning — they fit the skill profile better than the agent profile.
- `deployment.md` + `release-strategy.md` cover mechanics and policy of the same question — `delivery.md` merges them.
- `api-spec`, `data-model-spec`, and `auth-spec` templates are subsumed by sections that already exist inside `technical-spec.md`.
- Hard Rule #4 (Zod optional services) is Next.js-specific — it doesn't generalise to Flutter or OutSystems, so it's a starter-local convention, not a blueprint-wide rule.

### Finding 3 — The full scope range needs explicit sub-verbs

The blueprint must handle **seven operational contexts**, not just feature-by-feature: greenfield install, adopt-in-place install, idea, epic, feature, fix, chore. A single `/spec` command with sub-verbs (`idea | epic | feature | fix | chore`) keeps the top-level surface at four commands while differentiating spec weight: an idea gets a product PRD + architecture + milestone + feature backlog; a fix gets a minimal Problem/Root-cause/Fix/Regression-test spec; a chore gets just a branch and issue.

Cascade via `parent:` YAML frontmatter — `/spec feature <slug>` auto-detects and links to an existing epic or idea. Signal learnings feed back through `/spec idea --revise <product>`. No template growth required: `PRD.md` and `technical-spec.md` accept a `scope:` field that toggles scope-conditional sections.

### Finding 4 — Adoption into an existing repo is where v4 earns production use

`/beat install` in an existing repo must:
- Detect layout (monorepo / single app, existing `CLAUDE.md`, existing `.claude/`, CI platform)
- Dry-run first, report what it will create / merge / skip
- Never edit source code
- Merge existing `CLAUDE.md` via a fenced `<!-- agentic-blueprint:begin/end -->` block — user content below is preserved untouched
- Install the GitHub Action wrapper (or print GitLab/CircleCI porting notes)
- Write `claude-config/VERSION` (semver) so `/beat update` can reason about drift

`/beat update` touches only blueprint-owned files inside the fence; user extensions (custom commands/agents/skills/hooks) survive untouched. If an adopter edits a blueprint file, update logs a warning and skips — manual merge required. This is the customisation contract.

### Finding 5 — Flexibility via tagged commit prefixes, not `--no-verify`

The current pre-commit gate is all-or-nothing. v4 reads the commit message first:

| Prefix | Skips | Use case |
|---|---|---|
| `[release]` | Rule 4 (templates sacred) | Explicit template rebuilds (this v4 migration) |
| `[infra]` | Rule 3 (Spec-before-Ship) | CI, hooks, dependency bumps, harness-level work |
| `[docs]` | Rule 3 (Spec-before-Ship) | Doc-only commits |
| `[bulk]` | >50-file count guard | Genuine bulk updates |

Rules 1, 2, 5–8 are never skippable. Every skip is recorded in the audit trail. Replaces `--no-verify` with named, auditable overrides. CI re-runs `scripts/check-all.sh` on every PR and honours the same prefixes — local gates stop being advisory.

### Finding 6 — Security, cost, and solo-dev ergonomics need first-class surface

Production use demands guardrails the v3 harness doesn't currently encode:

- **Secrets**: a fast regex `pre-commit-secret-scan.sh` blocks obvious API keys/JWTs/private keys; `.env*` patterns appended to `.gitignore` on install; `scheduled-tasks.yaml` references secrets by name only.
- **Cost**: scheduled-task entries accept `max_tokens_per_run`, `max_runs_per_day`, `timeout_ms`; subagents use a write-first protocol so partial output survives stream timeouts (observed twice during this brief's own research pass).
- **Runaway protection**: `pre-commit-gate` refuses >50-file commits without `[bulk]` prefix.
- **Solo-dev ergonomics**: `/beat status` warns on feature branches >7 days old; `/signal audit` is the solo-dev substitute for a peer reviewer; `docs/signal/learnings.md` accumulates durable insights for future `/spec idea` passes to read.

---

## Market Landscape

| Player | Approach | Strengths | Weaknesses |
|---|---|---|---|
| AWS Kiro | Spec-driven agentic IDE (VS Code fork) with Claude + Nova | Specs → code → tests pipeline; agent hooks for automation | AWS/Bedrock lock-in; proprietary spec format; not portable |
| Cursor + Agent Skills | Agentic IDE with parallel background agents | Fast iteration; large ecosystem | No Stage-1 (research) or Stage-5 (ops) surfaces |
| AutoGen / CrewAI scaffolds | Multi-agent Python frameworks | Flexible orchestration patterns | No opinionated delivery lifecycle; no spec discipline |
| OpenHands (All Hands AI) | Open-source agentic coder | Active community; MCP-native | IDE-style rather than lifecycle-style; no spec-driven gates |
| agentic-blueprint v3 | Claude Code harness + sacred templates + five-stage lifecycle | Full lifecycle; discipline gates; composable Anthropic primitives | Heavy for solo operator; three platform profiles bloat guides; five-stage frame no longer matches tool reality |
| agentic-blueprint v4 (this rebuild) | Three-beat lifecycle + scope-aware sub-verbs + adopt-in-place + tagged exceptions | Smallest viable harness with flexibility layer, production-ready adoption flow, solo-dev ergonomics | New — unproven in the wild; migration cost for v3 adopters |

The v4 wedge: **spec-driven, gates-enforced, lifecycle-aware harness** sized for one operator, that ports into existing codebases without touching source, and serves both Claude-native pro-code SaaS/Mobile and OutSystems enterprise delivery with identical Spec and Signal artefacts.

---

## Implications

- **Collapse to three beats** with four top-level commands (`/spec` + sub-verbs, `/ship`, `/signal`, `/beat`). Net primitive reduction: ~36 → ~22.
- **Hard Rules 12 → 8** with named exceptions (`[release]`, `[infra]`, `[docs]`, `[bulk]`). Drop v3 #4 (Zod) to starter-local convention.
- **Two platform profiles** — Claude-native + OutSystems ODC. Drop Cursor+Perplexity. Spec and Signal artefacts identical across profiles; only Ship mechanics differ.
- **Archive five templates** (api-spec, data-model-spec, auth-spec, deployment, release-strategy) with redirect stubs. Add `delivery.md` (merged) and `incident-runbook.md` (new). Net: 12 → 9.
- **`/beat install`** must handle adopt-in-place without touching source code; `/beat update` must respect customisations.
- **Ship production guardrails** for secrets, cost, and runaway protection as part of v4, not as future features.
- **Dogfood the rebuild**: v4 is its own first feature — the six migration PRs ARE the first `/spec → /ship → /signal` cycle under v4 rules.

---

## Open Questions

- **MCP server scope.** An `agentic-os-mcp` server exposing lifecycle state is deferred to v4.1 per the plan. Is that deferral still right, or should a minimal read-only MCP ship in v4 to make the "Anthropic-platform IP" angle tangible at launch?
- **Template scope field rollout.** Adding `scope:` frontmatter to `PRD.md` and `technical-spec.md` is a Rule-4 edit. Does it land in PR 1 alongside the archive pass, or in a later PR once the principles are collapsed?
- **Dual-track naming.** v3 calls them "profiles." Does v4 keep the word "profile" or switch to something clearer now that there are only two? ("Profile" is sensible; "flavour" or "target" might be cleaner — low-stakes, but pick in PR 4 before guide rewrites.)
- **OutSystems ODC concrete coverage.** The plan keeps OutSystems as a peer profile but the current stage guides have only a stub Profile C. Does v4 require completing Profile C across all three beats before tagging v4.0, or is a clearly-labelled "preview" acceptable for the first cut?
- **v3 adopter migration effort.** The `MIGRATION-v3-to-v4.md` includes a `sed` rename script. How aggressive should that script be — cover the 80% mechanical cases, or attempt 100% including CLAUDE.md narrative edits?

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
