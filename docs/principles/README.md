# docs/principles/

The principles that underlie the blueprint. Each file captures one principle
— the what, the why, what compliance looks like in practice, and the common
failure mode.

## Hard Rules (enforced by `.claude/hooks/pre-commit-gate.sh`)

1. [`01-australian-spelling.md`](./01-australian-spelling.md) — Australian English in all prose, comments, and string literals.
2. [`02-no-domain-logic-in-starters.md`](./02-no-domain-logic-in-starters.md) — starters hold only generic patterns.
3. [`03-starters-boot-clean.md`](./03-starters-boot-clean.md) — every starter passes its own check suite.
4. [`04-optional-services.md`](./04-optional-services.md) — optional Zod env schemas so services skip gracefully.
5. [`05-spec-driven.md`](./05-spec-driven.md) — every feature starts as a spec.
6. [`06-plan-before-code.md`](./06-plan-before-code.md) — review the plan before code generation.
7. [`07-templates-are-sacred.md`](./07-templates-are-sacred.md) — `docs/templates/` stays pristine.
8. [`08-tool-agnostic-framing.md`](./08-tool-agnostic-framing.md) — guides recommend, they do not require.
9. [`09-platform-profiles-descriptive.md`](./09-platform-profiles-descriptive.md) — profiles describe toolchains, they don't endorse them.

## Meta-principles (design of the harness)

10. [`10-progressive-disclosure.md`](./10-progressive-disclosure.md) — skills load context on demand, not upfront.
11. [`11-context-economy.md`](./11-context-economy.md) — subagents protect the main conversation from noise.
12. [`12-gates-over-guidance.md`](./12-gates-over-guidance.md) — Hard Rules are hook-gated, not vibe-checked.

## How to read these

Principles are the "why". For "how to fix a violation right now", the
runtime references live next to the enforcement machinery:

- `.claude/skills/hard-rules-check/references/rules-detail.md` — quick remediation playbook
- `.claude/skills/hard-rules-check/scripts/check-all.sh` — the actual gate

Keep principle docs tight. If a principle starts to read like a runbook,
lift the runbook into `docs/operations/` and link back.
