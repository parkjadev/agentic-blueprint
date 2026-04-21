# Migration — v3 → v4

v4 rebuilds the Agentic Blueprint as a **three-beat lifecycle** (Spec → Ship → Signal). v3 was five stages; v4 collapses Plan → Build → Ship because Claude Code now handles the whole middle in one continuous motion. The spec IS the plan.

This doc is for **adopters** — people who have a repo running the v3 blueprint and want to upgrade to v4. If you're new, skip straight to [README.md](./README.md).

---

## What changed (at a glance)

| Surface | v3 | v4 |
|---|---|---|
| Lifecycle | 5 stages (Research & Think → Plan → Build → Ship → Run) | **3 beats** (Spec → Ship → Signal) |
| Slash commands | 7 (`/research`, `/plan`, `/build`, `/ship`, `/run`, `/stage`, `/new-feature`) | **4** (`/spec`, `/ship`, `/signal`, `/beat`) — with sub-verbs |
| Subagents | 5 (`researcher`, `spec-writer`, `spec-reviewer`, `starter-verifier`, `docs-inspector`) | **2** (`spec-researcher`, `spec-author`) |
| Skills | 5 (`australian-spelling`, `hard-rules-check`, `memory-sync`, `changelog-entry`, `spec-author`) | **4** (`australian-spelling`, `hard-rules-check`, `signal-sync`, `starter-verify`) |
| Hooks | 5 | **6** (added `pre-commit-secret-scan.sh`) |
| Hard Rules | 9 enforced + 3 meta = 12 | **5 enforced + 3 meta = 8** |
| Templates | 12 | **9** active + 5 archived under `_archive/` |
| Platform profiles | 3 (Claude-native, Cursor+Perplexity, OutSystems ODC) | **2** (Claude-native, OutSystems ODC) |
| `--no-verify` | sledgehammer | replaced with tagged prefixes — `[release]`, `[infra]`, `[docs]`, `[bulk]` |

Net primitive reduction: ~36 → ~22. Every surviving primitive earns its slot.

## Command rename table

| v3 command | v4 command | Notes |
|---|---|---|
| `/research <topic>` | `/spec <idea\|epic\|feature\|fix\|chore> <slug>` | Research is now a step inside `/spec idea` and `/spec feature` (if no parent brief exists) |
| `/plan <slug>` | `/spec <scope> <slug>` | Plan collapsed into Spec — the spec IS the plan |
| `/new-feature <slug>` | `/spec feature <slug>` | Sub-verb replaces dedicated command |
| `/build` | `/ship` | Ship subsumes Build; same loop, idempotent, resumable |
| `/ship` | `/ship` | Same name; expanded scope (build + test + deploy + release) |
| `/run <task>` | `/signal <init\|sync\|audit\|status>` | Signal gives Run a first-class name + sub-verbs |
| `/stage` | `/beat <status\|install\|update>` | Status reporter + new install/update for adopters |

## Subagent rename table

| v3 agent | v4 agent | Notes |
|---|---|---|
| `researcher` | `spec-researcher` | Rename only; adds write-first protocol for stream-timeout survival |
| `spec-writer` | `spec-author` (merged) | Two-pass agent: draft + self-review |
| `spec-reviewer` | `spec-author` (merged) | Second pass is internal to spec-author now |
| `starter-verifier` | *skill: `starter-verify`* | Demoted — isolated procedural run, not multi-turn reasoning |
| `docs-inspector` | *skill: `signal-sync` (merged)* | Demoted; drift + cross-reference audit is now part of signal-sync |

## Skill rename table

| v3 skill | v4 skill | Notes |
|---|---|---|
| `australian-spelling` | `australian-spelling` | Unchanged |
| `hard-rules-check` | `hard-rules-check` | Drops v3 Rule 4 (Zod); renumbers to 1–5; parses `[release]`/`[infra]`/`[docs]` prefixes |
| `memory-sync` | `signal-sync` (merged) | Absorbs memory-sync + changelog-entry + docs-inspector logic |
| `changelog-entry` | `signal-sync` (merged) | `signal-sync/scripts/append-changelog.sh` is the direct descendant |
| `spec-author` | *absorbed by `spec-author` subagent* | Skill content is now inside the subagent's prompt |
| *(new)* | `starter-verify` | Demoted from starter-verifier agent |

## Hard Rule rename table

| v3 rule | v4 rule | Change |
|---|---|---|
| 1. Australian spelling | 1. Australian spelling | Unchanged |
| 2. No domain logic in starters | 2. Starters stay generic and boot clean | Merged with v3 #3 |
| 3. Starters boot clean | 2. (merged) | — |
| 4. Optional services (Zod) | *retired to `starters/nextjs/CLAUDE.md`* | Next-specific; moved to starter-local convention |
| 5. Spec-driven | 3. Spec-before-Ship | Merged with v3 #6 |
| 6. Plan-before-code | 3. (merged) | — |
| 7. Templates are sacred | 4. Templates versioned, not edited in flight | Kept; gains `[release]` commit prefix + `_archive/` + env-var escapes |
| 8. Tool-agnostic framing | 5. Descriptive profiles, not prescriptive | Merged with v3 #9 |
| 9. Platform profiles descriptive | 5. (merged) | — |
| 10. Progressive disclosure | 6. Progressive disclosure | Unchanged semantics; renumbered |
| 11. Context economy | 7. Context economy | Unchanged semantics; renumbered |
| 12. Gates over guidance | 8. Gates over guidance | Unchanged semantics; renumbered |

## Tagged-exception prefixes (the flexibility layer)

The pre-commit gate reads the commit message first. These prefixes replace `--no-verify`:

| Prefix | Skips | When to use |
|---|---|---|
| `[release]` | Rule 4 | Explicit template rebuilds (like this v4 migration itself) |
| `[infra]` | Rule 3 | CI configs, hooks, dependency bumps, harness-level changes |
| `[docs]` | Rule 3 | Doc-only commits (README edits, principle clarifications) |
| `[bulk]` | >50-file runaway guard | Genuine bulk updates (mass renames, sweep PRs) |

Rules 1, 2, 5 are **never skippable**. Every skip lands in the git log for audit.

## Migration runbook (for v3 adopters)

### Option A — Clean reinstall (recommended for small repos)

```bash
# 1. Back up your existing .claude/ bundle.
mv .claude .claude.v3-backup

# 2. Update the source blueprint repo (or pull claude-config/ from your fork).
git -C /path/to/agentic-blueprint pull

# 3. Run /beat install from Claude Code in your repo.
/beat install
```

`/beat install` detects existing `CLAUDE.md`, `.claude/`, CI platform, and dry-runs before writing. It merges `CLAUDE.md` via a fenced `<!-- agentic-blueprint:begin/end -->` block — your user content stays untouched.

### Option B — Manual sed pass (for large forks with customisations)

```bash
# Rename stage terminology in your own docs.
find . -type f \( -name '*.md' -o -name '*.sh' -o -name '*.yml' \) \
  -not -path './.git/*' -not -path './node_modules/*' -not -path './_archive/*' \
  -exec sed -i \
    -e 's|Stage 1 (Research & Think)|Spec|g' \
    -e 's|Stage 2 (Plan)|Spec|g' \
    -e 's|Stage 3 (Build)|Ship|g' \
    -e 's|Stage 4 (Ship)|Ship|g' \
    -e 's|Stage 5 (Run)|Signal|g' \
    -e 's|/research|/spec|g' \
    -e 's|/plan\b|/spec|g' \
    -e 's|/build\b|/ship|g' \
    -e 's|/run\b|/signal|g' \
    -e 's|/stage\b|/beat|g' \
    -e 's|/new-feature\b|/spec feature|g' \
    {} +
```

Review the diff — automated renames miss nuance (e.g., "run tests" becomes "signal tests"; use `\b` boundaries and inspect).

### Option C — Aliased cutover (rejected by v4 plan; included for awareness)

The v4 plan explicitly rejects running v3 + v4 side by side. Aliasing creates a two-frame repo where half the docs say "stage" and half say "beat". Pick a cutover date, flip on that date, don't straddle.

## Downstream adopter checklist

After running `/beat install` or Option B:

- [ ] All 5 v4 Hard Rules pass (`bash .claude/skills/hard-rules-check/scripts/check-all.sh`)
- [ ] `CLAUDE.md` contains the `<!-- agentic-blueprint:begin/end -->` fenced block
- [ ] `docs/templates/` has the 9 v4 templates; archived v3 templates live under `_archive/`
- [ ] `docs/principles/` has 8 files (Rules 1–5 + meta 6–8)
- [ ] `.claude/commands/` has 4 files (`spec.md`, `ship.md`, `signal.md`, `beat.md`)
- [ ] `.claude/agents/` has 2 files (`spec-researcher.md`, `spec-author.md`)
- [ ] `.claude/skills/` has 4 dirs (`australian-spelling`, `hard-rules-check`, `signal-sync`, `starter-verify`)
- [ ] `.claude/hooks/` has 6 files (includes new `pre-commit-secret-scan.sh`)
- [ ] `.claude/settings.json` references `beat-aware-prompt.sh`, not `stage-aware-prompt.sh`
- [ ] `claude-config/VERSION` reads `4.0.0` (or a newer v4.x)
- [ ] `claude-config/scheduled-tasks.yaml` is present — run `/signal init` to wire it
- [ ] `.github/workflows/hard-rules-check.yml` present; CI passes on a throwaway PR
- [ ] Your existing open PRs still pass the v4 gate (they'll need `[infra]`/`[docs]` prefixes if they were relying on lenient v3 behaviour)

## Rollback

If v4 breaks something critical:

```bash
# Find the v4-beats merge commit (or the first v4 commit on your branch).
git log --oneline | grep v4-beats

# Revert it — preserves everything in a single cohesive undo commit.
git revert -m 1 <merge-sha>
```

Retired v3 files live in `docs/templates/_archive/` and `docs/research/_archive/` — content is recoverable without git archaeology.

## Open questions (called out in the v4 research brief)

- **MCP server**: `agentic-os-mcp` is explicitly deferred to v4.1. Not shipping in v4.0.
- **OutSystems Profile C completeness**: Profile C (now the OutSystems-only profile in v4) covers all three beats, but the adoption story for ODC-only teams is thinner than Claude-native. Feedback welcomed.
- **Multi-project CLI**: A global `agentic-os` CLI rolling up status across several adopted repos is v4.1 scope.

---

*Migration questions? File an issue under the `blueprint-feedback` template in `.github/ISSUE_TEMPLATE/` (or copy `claude-config/github/ISSUE_TEMPLATE/` into your fork's root `.github/`).*
