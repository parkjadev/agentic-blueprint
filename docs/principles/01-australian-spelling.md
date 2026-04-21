# 1. Australian spelling throughout

> Hard Rule. Enforced by `.claude/hooks/pre-write-spelling.sh` (inline block on write) and `.claude/skills/hard-rules-check/scripts/check-all.sh` (pre-commit / CI gate).

## The rule

All prose, markdown, comments, and string literals authored for this repo use Australian English. `favour` / `colour` / `organisation` / `behaviour`; `licence` / `license` per noun/verb rule; `-ise` / `-yse` endings. US variants like `favor`, `color`, `organization`, `organize`, `analyze` are flagged.

## Why

Consistency reads as care. A doc that flips between US and AU spelling tells the reader nobody proof-read it. The rule also avoids the rolling PR churn that happens when an AU maintainer keeps correcting US-spelled contributions.

## In practice

- The `pre-write-spelling` hook runs on every `Write`/`Edit` and blocks US variants inline.
- `australian-spelling` skill runs `scripts/check.sh <files>` against `references/wordlist.md` for manual sweeps.
- Code identifiers (variable names, API routes) are exempt only where a third-party library forces US spelling (`color`, `organization` in CSS/JSON schemas). Document the exception in a comment.

## When it fails

The hook prints the offending word and suggests the AU variant. Fix before the commit — there is no `[skip-spelling]` escape. This rule is cheap to honour and there's no production reason to ship US spelling.

## Related

- `australian-spelling` skill and wordlist.
- `pre-write-spelling.sh` hook.
