---
name: hard-rules-check
description: Use before generating code, opening a PR, or running /ship. Verifies the repo's 4 Hard Rules via scripts/check-all.sh (Australian spelling, spec-before-ship, templates and contracts versioned, descriptive profiles). Keywords — hard rules, compliance, pre-commit, lint, CLAUDE.md rules, blueprint rules, rule check.
allowed-tools: Read Grep Glob Bash
model: sonnet
---

# Hard rules check

The blueprint has 4 Hard Rules + 3 meta-principles (see `/CLAUDE.md`). This skill verifies compliance before risky actions.

## When to reach for this skill

- Before a `/ship` — every rule must pass before a PR opens
- Before writing code that touches `docs/templates/`, `docs/contracts/`, or hook logic
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
| 3 | Spec-before-Ship | Branch has `docs/specs/<slug>/` present, or `[infra]` / `[docs]` tagged commit |
| 4 | Templates + contracts versioned | `git diff` must not modify `docs/templates/*` or `docs/contracts/*` outside `[release]` commits / `docs/*`, `templates/*`, `contracts/*` branches |
| 5 | Descriptive profiles, not prescriptive | Greps for prescriptive language in `docs/guides/` |

Rule 2 ("starters generic and boot clean") was retired in v5.0 — see `docs/principles/_archive/02-starters-generic-boot-clean.md`. Numbering preserved to keep downstream references stable.

## Do NOT

- Skip the script and verify rules by memory — the script is cheap and authoritative
- Edit the rule check to pass a failing case — fix the underlying violation
- Run the script repeatedly in a loop; once per commit is enough
