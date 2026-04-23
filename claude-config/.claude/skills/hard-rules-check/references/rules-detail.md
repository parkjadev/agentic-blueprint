# Hard Rules — long form

Detailed explanation of each rule, the spirit behind it, and how to fix a violation. Loaded on demand by the `hard-rules-check` skill when a rule fails.

**Current state (v5.0):** 4 enforced Hard Rules + 3 meta-principles. Numbering is preserved across versions so downstream references don't silently shift — Rule 2 was retired in v5.0 (see the archive note near the bottom). See `docs/principles/` for the canonical definitions.

## Tagged-exception prefixes

Pre-commit-gate reads the commit message first. Tagged prefixes selectively skip specific rules:

| Prefix | Skips | Use case |
|---|---|---|
| `[release]` | Rule 4 (sacred paths: templates + contracts) | Explicit template or contract rebuilds |
| `[infra]` | Rule 3 (Spec-before-Ship) | CI, hooks, dependency bumps, harness-level work |
| `[docs]` | Rule 3 (Spec-before-Ship) | Doc-only commits |
| `[bulk]` | >50-file count guard | Genuine bulk updates |

Rules 1 and 5 are **never** skippable. Every skip is recorded in the git-log audit trail.

---

## Rule 1 — Australian spelling throughout

**Spirit:** consistent voice across docs, specs, comments, and error messages. Avoids the accidental mix of US and British English that creates search friction and looks unproof-read.

**Fix:** run the `australian-spelling` skill's script against the offending file, then apply the suggested swaps. Keep brand names and code identifiers as-is. Third-party JSON schemas / CSS properties (`color`, `organization`) are exempt — document the exception in a comment.

---

## Rule 3 — Spec-before-Ship

**Spirit:** "just start coding" ships the wrong thing fast. The spec is the shared contract between human and agent. Rule 3 merges an earlier split between spec-driven and plan-before-code — Claude Code now closes the loop from spec to shipped PR in one motion, so the spec IS the plan.

**Fix:** stop coding, run `/spec <feature|fix|chore|epic|idea> <slug>`, produce the spec set. Resume `/ship` once the spec exists.

**Exemptions:**
- Branch-level: `main`, `release/*`, `chore/*`.
- Commit-level: any commit in the range with `[infra]` or `[docs]` prefix skips Rule 3. First-commit-on-branch is honoured via `PENDING_COMMIT_SUBJECT` in the pre-commit gate.

---

## Rule 4 — Templates + contracts versioned, not edited in flight

**Spirit:** sacred artefacts (`docs/templates/` and `docs/contracts/`) define every downstream spec's structure and every project's wire-level interface. Changes must be deliberate and auditable, not bundled into feature PRs.

**Fix options (any one):**
1. Set `AGENTIC_BLUEPRINT_RELEASE=1` for an interactive release-rebuild session.
2. Prefix the commit subject with `[release]` (per-commit audit trail). Every commit in the range that touches a non-archive sacred path must carry `[release]`.
3. Work on a branch named `docs/<slug>`, `templates/<slug>`, or `contracts/<slug>` (the branch is itself the reviewer-approved release context).

**Always allowed:** writes under `docs/templates/_archive/` or `docs/contracts/_archive/` (retirement moves with redirect stubs).

---

## Rule 5 — Descriptive profiles, not prescriptive

**Spirit:** guides describe toolchains; they don't pick winners. Rule 5 merges an earlier split between tool-agnostic framing and platform-profile-descriptive because both say the same thing at different scopes.

**Fix:** reword prescriptive phrasing to observations.
- "you must use Vercel" → "one common choice is Vercel; alternatives include <X>, <Y>"
- "recommended vendor" → "the canonical example uses <tool> via <mechanism>"

Detected patterns: `you must use`, `required to use`, `only works with`, `recommended vendor`, `the only correct choice`.

---

## Meta-principles (not hook-gated)

### 6 — Progressive disclosure

Skills load context on demand, not upfront. SKILL.md stays tight; reference material lives in `references/` and loads on-demand.

### 7 — Context economy

Subagents protect the main conversation from noise. Write durable outputs to disk; return summaries, not transcripts.

### 8 — Gates over guidance

If a rule matters, wire a gate. If a gate isn't feasible, pick a different rule or scope it differently. Guidelines in prose are optional at 2am; gates in hooks are not.

---

## Retired

### Rule 2 — Starters stay generic and boot clean (retired in v5.0)

Rule 2 was active in v4 when the blueprint shipped Next.js / Flutter / .NET + Azure reference starters. PR #109 retired the starters; PR #119 (v5.0) retired the rule itself — the reframe ("plugin must boot clean") would still be vacuous without plugin packs, and an always-passing rule corrodes the hard-rules contract.

Archived content: `docs/principles/_archive/02-starters-generic-boot-clean.md`. Reinstate if plugin packs land in v5.x.

---

## Historical note — v3 → v4 → v5

- v3 Rule 4 (optional services / Zod schemas) was Next.js-specific; did not generalise. Moved to a starter-local convention and retired with the starters in v5.0.
- v3 Rule 7 (templates are sacred) → v4 Rule 4 with three named escapes replacing `--no-verify`. v5.0 extended the same rule to cover `docs/contracts/`.
- v3 Rules 8 + 9 merged → v4/v5 Rule 5.
- v3 Rules 5 + 6 merged → v4/v5 Rule 3.
- v4 Rule 2 retired → v5.0 has 4 enforced rules, with numbering preserved (no renumber across the remaining rules).
- v3 Rules 10, 11, 12 (meta-principles) → Blueprint principles 6, 7, 8 (numbering compacted but semantics unchanged).
