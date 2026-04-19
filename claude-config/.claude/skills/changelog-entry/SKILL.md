---
name: changelog-entry
description: Use when a feature, fix, or change is about to land and CHANGELOG.md needs an Unreleased entry. Appends a keepachangelog-formatted entry via scripts/append-entry.sh using assets/entry.tmpl. Keywords — changelog, release notes, keepachangelog, Unreleased, version bump, changelog entry, append changelog.
allowed-tools: Read, Edit, Bash
model: haiku
---

# Changelog entry

The repo uses [keep a changelog](https://keepachangelog.com/en/1.1.0/). Every feature/fix/chore gets an entry under `## [Unreleased]` before the PR merges.

## When to reach for this skill

- During `/ship`, before the PR opens
- Asked anything about "changelog", "release notes", "unreleased", "add entry"
- After a merge if the previous author forgot (Stage 5 / `/run memory-sync`)

## How to use it

1. **Determine the category.** One of: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
2. **Run the append script:**

   ```bash
   bash .claude/skills/changelog-entry/scripts/append-entry.sh \
     --category <Added|Changed|Deprecated|Removed|Fixed|Security> \
     --message "<one-line summary, sentence case, ending in a period.>" \
     --pr <pr-number>
   ```

   The script places the entry under the right subheader in `## [Unreleased]`, creating the subheader if needed.
3. **Review the diff.** The script prints the line it inserted. Check casing, spelling, and that the subheader landed correctly.
4. **Don't edit the script** just to skip a rule — rework the message to satisfy the template.

## Entry conventions

- Start with a verb in past tense where possible: "Added `/stage` command…", "Fixed race in rate-limit counter…".
- One line per entry. If you need more detail, link to the PR or the plan.
- Always include the PR number in parentheses at the end: `… (#123)`.
- Australian spelling — reach for the `australian-spelling` skill if unsure.

## Do NOT

- Edit past released sections (they're immutable history)
- Open a release (version cut) from this skill — that's a human operation
- Bundle unrelated changes into one entry
