# Hard Rules — long form (v4)

Detailed explanation of each rule, the spirit behind it, and how to fix a violation. Loaded on demand by the `hard-rules-check` skill when a rule fails.

**v4 layout:** 5 enforced Hard Rules + 3 meta-principles. See `docs/principles/` for the canonical definitions.

## Tagged-exception prefixes

Pre-commit-gate reads the commit message first. Tagged prefixes selectively skip specific rules:

| Prefix | Skips | Use case |
|---|---|---|
| `[release]` | Rule 4 (templates versioned) | Explicit template rebuilds |
| `[infra]` | Rule 3 (Spec-before-Ship) | CI, hooks, dependency bumps, harness-level work |
| `[docs]` | Rule 3 (Spec-before-Ship) | Doc-only commits |
| `[bulk]` | >50-file count guard | Genuine bulk updates (enforced by pre-commit-gate.sh in PR 3) |

Rules 1, 2, 5 are **never** skippable. Every skip is recorded in the git-log audit trail.

---

## Rule 1 — Australian spelling throughout

**Spirit:** consistent voice across docs, specs, comments, and error messages. Avoids the accidental mix of US and British English that creates search friction and looks unproof-read.

**Fix:** run the `australian-spelling` skill's script against the offending file, then apply the suggested swaps. Keep brand names and code identifiers as-is. Third-party JSON schemas / CSS properties (`color`, `organization`) are exempt — document the exception in a comment.

---

## Rule 2 — Starters stay generic and boot clean

**Spirit:** a starter's job is to let *any* team clone it and have a working foundation on day one. This rule merges v3's two starter rules (no domain logic + boots clean) because they answer the same question.

**Fix (generic):** replace brand-specific strings, logos, or business logic with generic placeholders and a `TODO:` marker. Examples: `"Acme Corp"` → `"TODO: your-company"`; `billing/insurance-claim.ts` → deleted or genericised.

**Fix (clean boot):**
- Next.js: `cd starters/nextjs && pnpm install && pnpm type-check && pnpm lint && pnpm test:ci`
- Flutter: `cd starters/flutter && flutter analyze && flutter test`

Address any failure at the root — don't silence warnings with `@ts-ignore` or `// ignore:` comments.

**Starter-local conventions** (absorbed from v3 Rule #4): the Next.js starter requires optional Zod schemas for non-essential services. Documented in `starters/nextjs/CLAUDE.md`, not as a blueprint-wide rule.

---

## Rule 3 — Spec-before-Ship

**Spirit:** "just start coding" ships the wrong thing fast. The spec is the shared contract between human and agent. v4 merges v3's Rule 5 (spec-driven) and Rule 6 (plan-before-code) because Claude Code now closes the loop from spec to shipped PR in one motion — the spec IS the plan.

**Fix:** stop coding, run `/spec <feature|fix|chore|epic|idea> <slug>`, produce the spec set. Resume `/ship` once the spec exists.

**Exemptions:**
- Branch-level: `main`, `release/*`, `chore/*`.
- Commit-level: any commit in the range with `[infra]` or `[docs]` prefix skips Rule 3.

---

## Rule 4 — Templates versioned, not edited in flight

**Spirit:** templates define every downstream spec's structure. Changes must be deliberate and auditable, not bundled into feature PRs.

**Fix options (any one):**
1. Set `AGENTIC_BLUEPRINT_RELEASE=1` for an interactive release-rebuild session.
2. Prefix the commit subject with `[release]` (per-commit audit trail). Every commit in the range that touches a non-archive template path must carry `[release]`.
3. Work on a branch named `docs/<slug>` or `templates/<slug>` (legacy v3 escape, still honoured).

**Always allowed:** writes under `docs/templates/_archive/` (retirement moves with redirect stubs).

---

## Rule 5 — Descriptive profiles, not prescriptive

**Spirit:** guides describe toolchains; they don't pick winners. v4 merges v3's Rule 8 (tool-agnostic framing) and Rule 9 (platform profiles descriptive) because both say the same thing at different scopes.

**Fix:** reword prescriptive phrasing to observations.
- "you must use Vercel" → "one common choice is Vercel; alternatives include <X>, <Y>"
- "recommended vendor" → "Profile A uses <tool> via <mechanism>"

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

## Historical note — v3 → v4

- v3 Rule 4 (optional services / Zod schemas) was Next.js-specific and did not generalise. Moved to `starters/nextjs/CLAUDE.md` as a starter-local convention. Rule 2 now covers the starter discipline broadly.
- v3 Rule 7 (templates are sacred) → v4 Rule 4 with three named escapes replacing `--no-verify`.
- v3 Rules 8 + 9 merged → v4 Rule 5.
- v3 Rules 5 + 6 merged → v4 Rule 3.
- v3 Rules 10, 11, 12 (meta-principles) → v4 principles 6, 7, 8 (numbering compacted but semantics unchanged).
