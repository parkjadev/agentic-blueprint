# Handoff notes — resuming `/spec idea agentic-blueprint-v5-agnostic`

**Written:** 2026-04-22
**Why this file exists:** The previous Claude Code session became context-bloated (~180k tokens, ~600 turns) and started hitting `Stream idle timeout` errors on both subagent runs and main-thread long writes. This file captures everything a fresh session needs to pick up the `/spec idea` flow cleanly. Delete this file once `docs/research/agentic-blueprint-v5-agnostic-brief.md` is written.

## Where we are in the three-beat lifecycle

- Beat: **Spec (idea)** for `agentic-blueprint-v5-agnostic`
- Artefact produced so far: nothing committed (three `spec-researcher` subagent runs timed out)
- Next deliverable: `docs/research/agentic-blueprint-v5-agnostic-brief.md` filled in from `docs/templates/research-brief.md`

## Locked decisions (confirmed by the human)

- **Slug:** `agentic-blueprint-v5-agnostic` (folder `docs/specs/agentic-blueprint-v5-agnostic/` will be created by spec-author later)
- **Scope:** `product` (whole-product redesign, not a feature)
- **Research depth:** full pass (not lean; not skip)
- **Immediate action taken:** all v4 starters scrapped in PR #109 (squash commit `a53f0ff`). Recover retired starter files via `git show 3bb4c27:starters/<name>/CLAUDE.md` where 3bb4c27 is the pre-retirement main tip.

## One-paragraph vision (agreed, verbatim)

> The **agentic-blueprint v5** re-frames the blueprint as a platform- and technology-agnostic framework for shipping AI-collaborated products. Where v4 shipped opinionated reference starters (Next.js, Flutter, .NET + Azure) and a fixed 2-profile × 3-beat matrix, v5 treats stack selection as a first-class research deliverable of the Spec beat: `/spec idea` uses `spec-researcher` to evaluate alternatives against the problem at hand, producing a stack recommendation that the Ship beat then scaffolds dynamically (either by generating a starter tree or by pointing to adopter-curated sources). The blueprint's IP shifts from "a library of opinionated starters" to "a disciplined research + decision + lifecycle framework", making it usable by teams on any cloud, any runtime, any data store. v4's three-beat lifecycle (Spec → Ship → Signal), sacred document templates, and four of the five Hard Rules survive; what's replaced is the assumption that a fixed set of starters represents the "right" way to build — and the supporting infrastructure (starter-verify skill, bootstrap-smoke-test harness, tool-reference matrix) that that assumption required.

## Ten research questions the brief must answer

1. **Market landscape** — who else operates in this space (AI-first project blueprints / spec-driven kits / agentic scaffolds)?
2. **User research proxies** — what did v4 starter adopters actually do? Adopter-spectrum hypothesis: some want scaffold day 1, some want discipline only.
3. **What replaces the retired v4 starters?** Enumerate ≥5 options with pros/cons, recommend one.
4. **`/beat install` in a starter-less world** — what does install deliver?
5. **Hard Rules audit** — survive / reframe / retire for each of rules 1–5 and meta-principles 6–8.
6. **v4 adopter migration** — pin to `a53f0ff`? Compat shim? Migration guide?
7. **`tool-reference.md` evolution** — shopping list? archived? split into roles + inputs?
8. **Business model / IP angle** — what's the sellable IP in v5?
9. **Risks register** — ≥6 genuine risks with likelihood/impact/mitigation.
10. **Recommendations** — 3–5 concrete, opinionated calls the PRD should build on.

## External research findings from the previous session (do NOT re-query)

These are the key WebSearch results we already have. Incorporate them; don't spend budget re-searching.

### Direct competitors / adjacents (April 2026 state)

| Player | Approach | Where it overlaps v5 | Differentiator |
|---|---|---|---|
| **GitHub Spec Kit** (`github/spec-kit`) | Open-source spec-driven toolkit. Specify → Plan → Tasks → Implement. Agent-agnostic with 30+ supported CLIs/IDEs (Claude Code, Copilot, Gemini CLI, Cursor, Windsurf, Amazon Q). CLI bootstraps per-agent templates. v0.1.4 as of Feb 2026. | Almost exactly the "spec-first, agent-agnostic" positioning v5 wants. This is the most direct competitor. | v5 adds the **Ship** and **Signal** beats — Spec Kit stops at implement. v5 has hard-rule gates, post-merge signal-sync, periodic self-review. |
| **AWS Kiro** | IDE built around spec-driven workflow (Constitution / Specify / Plan / Tasks / Implement / PR). | Full lifecycle model; proprietary IDE surface. | v5 is repo-native and IDE-agnostic. Kiro is paid AWS-flavoured; v5 stays OSS. |
| **OpenSpec / Devika / Tessl / Augment Code** | Spec-driven agentic frameworks with varying autonomy. | Each overlaps somewhere. | v5's distinguishing asset is the disciplined document templates + Hard Rules + three-beat lifecycle, not the agentic autonomy itself. |
| **Claude Code Plugin Marketplace** | Plugin format: slash commands + agents + hooks + MCP servers via `.claude-plugin/marketplace.json`. Community curators: Dan Ávila (DevOps), Seth Hobson (80+ subagents). | Not a competitor — this is the **natural distribution channel** for v5 IP. | v5 should probably ship AS a marketplace plugin; `/beat install` becomes `/plugin install`. |
| **AGENTS.md standard** | Vendor-neutral rule format agreed by Google, OpenAI, Sourcegraph, Cursor, Factory in 2026. Used by n8n (178K ⭐), LangFlow (145K), llama.cpp (97K), Bun (82K). Hierarchical like CLAUDE.md. | Blueprint currently uses CLAUDE.md only. | v5 should probably emit AGENTS.md alongside CLAUDE.md, or symlink, for non-Claude adopters. |
| **Cursor rules (`.cursor/rules/`)** | Path-scoped rules, older than AGENTS.md, largest community contribution base. | Some v4 adopters use Cursor + blueprint templates. | Lower priority than AGENTS.md. |
| **Create-T3-App, degit, Yeoman, Nx, Turborepo** | Pre-AI scaffold generators. | The "scaffold at spec time" direction of v5 echoes these. | v5's scaffold output is informed by research, not a frozen template. |

Medium piece worth citing: *"Spec-Driven Development Is Eating Software Engineering: A Map of 30+ Agentic Coding Frameworks (2026)"* by Vishal Mysore, March 2026.

### Retired v4 starter patterns (evidence for user-research Q)

From `git show 3bb4c27:starters/nextjs/CLAUDE.md`:

- Next.js 15 App Router, TypeScript strict, Supabase Auth + Postgres + Drizzle ORM
- `ApiResponse<T>` envelope convention (`{ success, data }` / `{ success, error }`) — shared contract
- Optional services (Stripe, Inngest, Resend) gated on env vars, skip gracefully when unconfigured
- Clean-boot contract: `pnpm type-check + lint + test:ci`
- "Do NOT touch without review" table for contract files

From `git show 3bb4c27:starters/flutter/CLAUDE.md`:

- Flutter 3.27+, Riverpod state, GoRouter, Dio, Supabase Auth
- Same `ApiResponse<T>` envelope — cross-starter contract discipline
- Feature-based folders, typed exceptions, `const` everywhere, trailing commas enforced
- Models mirror the API contract — changes happen together

**Inference for v5:** the starters baked in a shared contract (the `ApiResponse<T>` envelope) across two runtimes. That contract discipline is the load-bearing IP, not the starter code itself. v5's dynamic scaffolding must preserve the ability to impose cross-starter contracts.

## Five non-negotiable constraints on v5 output

1. **Three-beat lifecycle (Spec → Ship → Signal) survives unchanged** — don't redesign this.
2. **Sacred document templates survive** (PRD, technical-spec, architecture, research-brief, etc.). Hard Rule 4 keeps them protected.
3. **Hard Rule 1 (Australian spelling) and Hard Rule 5 (descriptive profiles) survive unchanged.**
4. **The blueprint stays repo-native** (not an IDE, not a SaaS). Install is "copy `.claude/` + merge `CLAUDE.md`".
5. **No regression on the v4 discipline** — every pattern that worked in v4 has an equivalent in v5 or a deliberate deprecation note.

## Fresh-session instructions

1. First action: `Read` this file, then `Read` `docs/templates/research-brief.md` and `CLAUDE.md` at root.
2. Do NOT spawn `spec-researcher` subagents — the research is already scoped in this file. Just write the brief inline.
3. Write `docs/research/agentic-blueprint-v5-agnostic-brief.md` answering all ten questions. Target 2500–4000 words (not 7000). One `Write` call; no sprawl.
4. Commit with `[docs]` prefix (research brief = doc-only output of the Spec beat). Push to a `chore/<slug>-research-brief` branch. Open a draft PR.
5. Summarise the brief in 3 bullets for the human; ask whether to proceed to `spec-author` for PRD.
6. After human approval, delete this handoff file.

## Housekeeping carried over

- Two stale remote branches need deletion (the session ran into git-proxy flakiness):
  - `origin/claude/dotnet-azure-phase-3` — PR #108 closed without merging
  - `origin/claude/add-release-strategy-example-QPmAW` — status unknown; check if tied to an open PR
- `.claude/worktrees/` is gitignored from PR #110 (`492cfef`). Future subagent worktrees won't pollute `git status`.

## Context you can safely skip reading

- `starters/` — doesn't exist anymore
- `.github/workflows/bootstrap-smoke-test.yml`, `dotnet-*` workflows — deleted in #109
- `claude-config/scripts/bootstrap-smoke-test.sh` — deleted in #109

## One-line summary

Write a research brief that positions v5 as "Spec-Kit-plus-Ship-plus-Signal" with explicit competitor differentiation, a concrete starter-replacement strategy, and a clean migration story for v4 adopters. Everything else is detail.
