# 1. Australian spelling throughout

> Hard Rule. Enforced by `.claude/hooks/pre-commit-gate.sh` → `hard-rules-check` → `australian-spelling`.

## The rule

All prose, comments, and string literals use Australian English spelling.
Third-party code identifiers (CSS `color:`, SPDX `License:`, library APIs)
keep their original form.

## Why

- **Consistent voice.** A repo that mixes `analyze` and `analyse` reads like
  it was written by three uncoordinated people — because it usually was.
- **Searchability.** Grepping for "organisation" and finding half the
  matches is a recurring, silent productivity tax.
- **Signal of care.** If we don't get spelling right, reviewers lose faith
  that we got the harder things right.

## In practice

- Favour `-ise`/`-yse` over `-ize`/`-yze` (organise, analyse).
- `-our` over `-or` (colour, behaviour, favour).
- `-re` over `-er` for measurement (centre, metre).
- Noun `licence` vs. verb `license`.
- Double the consonant before `-ed`/`-ing` when the final syllable takes
  stress or ends in a single vowel + single consonant (travelled, cancelled).

The full wordlist lives at
`.claude/skills/australian-spelling/references/wordlist.md`. The check
script skips fenced code blocks and inline backtick spans — prose is
policed, code identifiers are not.

## When it fails

- Running `bash .claude/skills/australian-spelling/scripts/check.sh <path>`
  prints offending `file:line:content` matches.
- The pre-commit hook blocks the commit with the rule-check summary.
- Fix: apply the swap from the wordlist. If the flag is a false positive
  (e.g. an API field name that must match a third-party schema), wrap the
  identifier in backticks so the checker skips it.

## Related

- Wordlist — `.claude/skills/australian-spelling/references/wordlist.md`
- Checker — `.claude/skills/australian-spelling/scripts/check.sh`
- Skill entry-point — `.claude/skills/australian-spelling/SKILL.md`
