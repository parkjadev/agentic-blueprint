---
scope: feature
parent: agentic-blueprint-v5-agnostic
status: Draft
---

# Feature — Retire Hard Rule 2

## Problem

Rule 2 ("Starters stay generic and boot clean") has been vacuously passing since PR #109 retired `starters/`. The v5 PRD (#115) resolved the retire-vs-reframe question as **retire** — the reframe ("plugin must boot clean") would still be vacuous without plugin packs, and an always-passing rule corrodes the hard-rules contract.

## Solution

Move the principle file to `_archive/`, delete the Rule 2 check from `check-all.sh`, and update every enumeration of "5 Hard Rules" to "4". Principles reduce to 4 Hard Rules (1, 3, 4, 5) + 3 meta-principles (6, 7, 8).

If plugin packs land in v5.x, Rule 2 can be reinstated with a concrete enforcement mechanism and the archived file rebuilt from its own content.

## Changes

| Path | Change |
|---|---|
| `docs/principles/02-starters-generic-boot-clean.md` | Moved to `docs/principles/_archive/02-starters-generic-boot-clean.md` with a retirement note prepended. |
| `docs/principles/README.md` | Rule 2 line removed; section heading updated to "4 Hard Rules". |
| `CLAUDE.md` | Rule 2 line removed; "Five enforced Hard Rules" → "Four enforced Hard Rules". |
| `.claude/skills/hard-rules-check/scripts/check-all.sh` | Rule 2 block (lines 92–114) removed; header comment + tagged-exception summary updated. |
| `.claude/skills/hard-rules-check/SKILL.md` | Description rewritten — it was still enumerating the pre-v4 "9 Hard Rules" wording. Aligned to v5's 4 rules. |
| `.claude/commands/ship.md` | "5 Hard Rules" / "all 5 rules" → 4 (two sites). |
| `docs/guides/beat-ship.md` | "5 v4 Hard Rules" → 4 (one site). |
| `docs/guides/README.md` | "5 Hard Rules (1–5)" → "4 Hard Rules (1, 3, 4, 5)". |

## Explicitly NOT in this PR

- `starter-verify` skill removal — that's Feature 4 (`/beat install` cleanup). Leaving the skill intact for one PR cycle is semantically odd (a skill with no rule to enforce) but avoids cross-feature coupling.
- `docs/guides/beat-ship.md` line 112 ("Skip the starter-verify step | Breaks Rule 2 silently") — this row becomes stale when starter-verify is removed in Feature 4. Keeping for now to limit this PR's blast radius.
- `CLAUDE.md` line 25 mention of "dormant `starter-verify`" — accurate description of intermediate state; stays.

## Testing

- Manual: run `bash .claude/skills/hard-rules-check/scripts/check-all.sh` locally. Output should show only 4 `header` blocks (Rules 1, 3, 4, 5); no Rule 2 section.
- CI: Hard Rules workflow passes on this PR (confirms the removed block doesn't break the script).

## Acceptance criteria

- [x] `docs/principles/02-starters-generic-boot-clean.md` no longer in live principles list
- [x] `docs/principles/_archive/02-starters-generic-boot-clean.md` exists with retirement header
- [x] `check-all.sh` has no Rule 2 block
- [x] Every "5 Hard Rules" enumeration reads "4 Hard Rules"
- [x] CI passes

## References

- v5 PRD (#115) Feature Matrix row 3 + Resolved Decisions row 2
- Research brief Finding 5 (Hard Rules audit): `docs/research/agentic-blueprint-v5-agnostic-brief.md`
- Retirement commit of `starters/`: PR #109 (`a53f0ff`)
