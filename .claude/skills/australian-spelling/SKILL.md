---
name: australian-spelling
description: Use when reviewing or authoring prose, markdown, comments, or string literals. Enforces Australian English spelling — favour, colour, organisation, behaviour, licence/license, -ise/-yse endings. Runs scripts/check.sh against the wordlist in references/wordlist.md to flag US-English variants. Keywords — spelling, Australian, British English, prose review, -ize to -ise, copy-edit, AU English.
allowed-tools: Read, Edit, Bash
model: haiku
---

# Australian spelling

Repo-wide convention (Hard Rule #1): **Australian English** in all prose, comments, and string literals.

## When to reach for this skill

- Reviewing or writing documentation, PR descriptions, research briefs, specs
- Copy-editing CHANGELOG entries
- Asked anything that mentions "spelling", "proofread", "copy-edit", "US vs British spelling"

## How to use it

1. **Don't read the wordlist unless you need to decide a specific word.** The wordlist is in `references/wordlist.md`. Load it on demand, not by default.
2. **Prefer running the check script over re-deriving rules:**

   ```bash
   bash .claude/skills/australian-spelling/scripts/check.sh <file-or-glob>
   ```

   The script exits 0 if clean, non-zero if it finds US-English variants, and prints offending lines to stdout. **Run it — do not read its source.** The script output is what costs tokens; its source does not.
3. **If the script flags a word you believe is a false positive**, open `references/wordlist.md` and propose an edit. Don't silently override.

## Common swaps (quick reference)

- `-ize` / `-yze` → `-ise` / `-yse` (organise, analyse)
- `color` → `colour`, `favor` → `favour`, `honor` → `honour`
- `center` → `centre`, `meter` → `metre`
- `license` (verb) → `licence` (noun); keep `license` as the verb form
- `defense` → `defence`, `offense` → `offence`
- `traveled` → `travelled`, `canceled` → `cancelled` (double-L before `-ed`/`-ing`)

## Keep in mind

- Code identifiers, package names, and third-party API fields keep their original spelling (e.g. `color` in CSS, `License` in an SPDX identifier). The script's wordlist accounts for these — don't fight it when it ignores a matched string inside code fencing.
- Proper nouns and brand names are never rewritten.
