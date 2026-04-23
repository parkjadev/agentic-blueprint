---
scope: feature
parent: agentic-blueprint-v5-agnostic
status: Draft
---

# Feature — `/beat install` cleanup + starter-verify removal

## Problem

Several primitives still dispatch against the retired `starters/` directory:

- `/beat install --new <project>` prompts the user to scaffold from `starters/nextjs/` or `starters/flutter/` — directories that no longer exist.
- `.claude/skills/starter-verify/` is still shipped — its job is to run Rule 2's boot-clean check, but Rule 2 was retired in PR #119.
- `/ship` step 5 invokes the `starter-verify` skill on any `starters/**` path touch.
- `docs/guides/beat-ship.md` documents the skill in two places.
- `CLAUDE.md` describes `starter-verify` as "dormant pending v5 retirement/rework" — v5.0 retires it.

Removing these is the v5 PRD Feature Matrix row 4 deliverable.

## Solution

Delete `starter-verify` from both the live `.claude/` directory and the `claude-config/.claude/` adopter bundle. Remove the `/beat install --new` sub-verb entirely (greenfield scaffolding deferred to v5.x Option A). Update `/ship`, `beat-ship.md`, and `CLAUDE.md` to reflect the reduced surface.

## Changes

| Path | Change |
|---|---|
| `.claude/skills/starter-verify/` | Deleted (SKILL.md + scripts/verify.sh). |
| `claude-config/.claude/skills/starter-verify/` | Deleted (mirror in the adopter bundle). |
| `.claude/commands/beat.md` | Remove `--new <project>` row from the sub-verbs table; remove the "Steps — `/beat install --new`" section; trim argument-hint. |
| `.claude/commands/ship.md` | Remove step 5 ("Starter check (if touched)") entirely; renumber remaining steps. |
| `docs/guides/beat-ship.md` | Remove section 5 ("Starter check (if touched)"); remove the "Skip the starter-verify step" pitfall row in the common-traps table. |
| `CLAUDE.md` | Skills row no longer mentions `starter-verify`. |
| `claude-config/scripts/update.sh` | Remove `.claude/skills/starter-verify` from the skills-to-copy list. |
| `claude-config/.claude/commands/beat.md` | Same trim as main `.claude/commands/beat.md`. |
| `claude-config/.claude/commands/ship.md` | Same trim as main `.claude/commands/ship.md`. |

## Technical notes

- **No new greenfield flow in v5.0.** Users starting a new project run `/spec idea <product>` in an empty (or near-empty) repo. The Spec beat's stack-selection research (Feature 2) tells them what to build; manual scaffolding follows. Option A (research-derived scaffold generator) is v5.x material.
- **Adopter bundle sync is narrow.** This PR only touches `claude-config/` files directly affected by starter-verify removal. Other drift (hard-rules-check SKILL.md still referencing Rule 2 in the bundle) is out of scope — it's a separate sync job that should get its own PR after v5.0 P0s land.
- **Beat-ship.md line 112** ("Skip the starter-verify step | Breaks Rule 2 silently") was flagged as future work in the Feature 3 commit. This PR removes it.

## Testing

Manual smoke:

1. `bash .claude/skills/hard-rules-check/scripts/check-all.sh` — should still exit 0 (Rule 2 block removed in #119; this PR doesn't touch the hard-rules check logic).
2. `bash claude-config/scripts/update.sh --dry-run` (if the script supports dry-run) — confirm starter-verify is no longer in the copy list.
3. `grep -rn "starter-verify\|starters/" .claude/ docs/guides/ CLAUDE.md` — should return only historical references (research briefs, `_archive/`, transitional notes in CLAUDE.md).

Automated: Hard Rules CI passes.

## Acceptance criteria

- [x] `.claude/skills/starter-verify/` no longer exists
- [x] `claude-config/.claude/skills/starter-verify/` no longer exists
- [x] `/ship` steps renumber (no gap where step 5 used to be)
- [x] `/beat install --new` path removed
- [x] `beat-ship.md` common-traps table has no Rule-2-era row
- [x] Australian spelling passes

## Out of scope

- Broader `claude-config/` sync (hard-rules-check SKILL.md, rules-detail.md, check-all.sh still have Rule 2 residue in the adopter bundle). Handled in a follow-up sync PR.
- Option A scaffold generator (deferred to v5.x)
- CI wrapper portability beyond GitHub Actions (deferred)

## References

- v5 PRD (#115) Feature Matrix row 4
- Rule 2 retirement: PR #119
- Starters retirement: PR #109 (`a53f0ff`)
