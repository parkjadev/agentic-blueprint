---
name: hard-rules-check
description: Use before generating code, opening a PR, or running /ship. Verifies the repo's 9 Hard Rules via scripts/check-all.sh (Australian spelling, no domain logic in starters, clean boot, optional Zod env schemas, spec-first, plan-before-code, templates unmodified, tool-agnostic guides, descriptive profiles). Keywords — hard rules, compliance, pre-commit, lint, CLAUDE.md rules, blueprint rules, rule check.
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
---

# Hard rules check

The blueprint has 9 Hard Rules (see `/CLAUDE.md`). This skill verifies compliance before risky actions.

## When to reach for this skill

- Before a `/ship` — every rule must pass before a PR opens
- Before writing code that touches starters, env config, or `docs/templates/`
- Before a commit that adds a new doc or spec
- Asked anything about "hard rules", "compliance", "pre-commit check", "blueprint rules"

## How to use it

1. **Run the check script:**

   ```bash
   bash .claude/skills/hard-rules-check/scripts/check-all.sh
   ```

   Exit 0 = all rules pass. Non-zero = one or more rules failed; the script prints which rule and why.
2. **Do NOT read the script's source** unless you're debugging a false positive. Execute it; read the output. (Context economy — output costs tokens, source does not.)
3. **If a rule fails**, open `references/rules-detail.md` for the long-form explanation of that specific rule and how to fix the violation.
4. **Never bypass a failure** with `--no-verify` or by commenting out a check. If a rule is wrong for the current situation, raise it with the user — don't silently skip.

## Rule summary (for orientation only — the script is the source of truth)

| # | Rule | Check mechanism |
|---|---|---|
| 1 | Australian spelling throughout | Shells out to `australian-spelling` check |
| 2 | No domain-specific business logic in starters | Greps for forbidden brand strings in `starters/` |
| 3 | All starters must boot clean | `bash claude-config/scripts/smoke-test.sh all` |
| 4 | Optional services (Zod schemas in env.ts) | Greps for optional Zod fields |
| 5 | Spec-driven | Branch has `docs/specs/<slug>/` present |
| 6 | Plan-before-code | Branch has `docs/plans/<slug>.md` |
| 7 | Templates are sacred | `git diff` must not modify `docs/templates/*` |
| 8 | Tool-agnostic framing in guides | Greps for vendor lock-in patterns in `docs/guides/` |
| 9 | Platform profiles descriptive | Greps for prescriptive language in profiles |

## Do NOT

- Skip the script and verify rules by memory — the script is cheap and authoritative
- Edit the rule check to pass a failing case — fix the underlying violation
- Run the script repeatedly in a loop; once per commit is enough
