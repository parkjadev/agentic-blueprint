# docs/principles/

The principles that underlie the Agentic Blueprint. Each file captures one principle — the what, the why, what compliance looks like in practice, and the common failure mode.

**v4 streamline:** 12 principles → 8. Rules merged where they answered the same question (old #5+#6 → new #3; old #8+#9 → new #5). The Next-specific Zod rule was retired.

**v5.0:** Rule 2 ("starters generic and boot clean") retired to `_archive/` once the v4 starters were removed. The reframe would be vacuous without plugin packs, and an always-passing rule corrodes the hard-rules contract. Hard Rules are now 4 (1, 3, 4, 5).

## Hard Rules (enforced by `.claude/hooks/pre-commit-gate.sh` + `.claude/skills/hard-rules-check/scripts/check-all.sh`)

1. [`01-australian-spelling.md`](./01-australian-spelling.md) — Australian English in all prose, comments, string literals.
3. [`03-spec-before-ship.md`](./03-spec-before-ship.md) — every feature/fix starts as a spec before any code.
4. [`04-templates-versioned.md`](./04-templates-versioned.md) — `docs/templates/` (and `docs/contracts/` from v5.0) edits only during release rebuilds (env var / `[release]` commit / dedicated branch).
5. [`05-descriptive-profiles.md`](./05-descriptive-profiles.md) — guides and platform profiles describe, never prescribe.

Rule 2 is retired ([`_archive/02-starters-generic-boot-clean.md`](./_archive/02-starters-generic-boot-clean.md)); numbering preserved so the enforced rules keep their historical identifiers rather than renumber across downstream references.

## Meta-principles (design of the harness)

6. [`06-progressive-disclosure.md`](./06-progressive-disclosure.md) — skills load context on demand, not upfront.
7. [`07-context-economy.md`](./07-context-economy.md) — subagents protect the main conversation from noise.
8. [`08-gates-over-guidance.md`](./08-gates-over-guidance.md) — if a rule matters, wire a gate.

## Tagged-exception prefixes (flexibility layer)

The pre-commit gate reads the commit message first. These prefixes selectively skip specific rules:

| Prefix | Skips | Use case |
|---|---|---|
| `[release]` | Rule 4 (templates) | Explicit template rebuilds |
| `[infra]` | Rule 3 (Spec-before-Ship) | CI, hooks, dependency bumps, harness-level work |
| `[docs]` | Rule 3 (Spec-before-Ship) | Doc-only commits |
| `[bulk]` | >50-file count guard | Genuine bulk updates (PR 3 will wire this guard) |

Rules 1, 5, and the three meta-principles are never skippable. Every skip is recorded in the audit trail.

## How to read these

Principles are the "why". For "how to fix a violation right now", the runtime references live next to the enforcement machinery:

- `.claude/skills/hard-rules-check/references/rules-detail.md` — quick remediation playbook
- `.claude/skills/hard-rules-check/scripts/check-all.sh` — the actual gate

Keep principle docs tight. If a principle starts to read like a runbook, lift the runbook into `docs/operations/` and link back.
