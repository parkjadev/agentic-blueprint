---
scope: feature
parent: agentic-blueprint-v5-agnostic
status: Draft
---

# Feature — Profile sweep + `tool-reference.md` reframe

## Problem

v4 shipped two platform profiles (Claude-native, OutSystems ODC) as a first-class concept: beat × profile matrix, Profile A/B sections, platform notes embedded in every beat guide. Per the v5 PRD (#115) resolved decision #3, profiles are dropped — the blueprint is agnostic by design and only one profile is in active use (Claude Code + GitHub Actions).

`docs/guides/tool-reference.md` still reads as a shopping list of tool recommendations per profile. v5 PRD Feature Matrix row 5 calls for reframing it as a role + inputs matrix — describe the role an agent plays and the inputs that role needs, with specific tools as examples not prescriptions. Same Rule-5 reframe, applied to tool choice.

## Solution

Single pass across four guide files:

1. **`docs/guides/tool-reference.md`** — rewrite. Drop Profile A and Profile B sections. Drop the two-column Beat × profile matrix. Keep the role model (7 roles), enhance with an "inputs" column. Keep MCP integrations + doc-sweep checklist. Target ≤ 80 lines (was 122).
2. **`docs/guides/beat-spec.md`** — remove the "Platform notes" block (Claude-native + OutSystems ODC bullets).
3. **`docs/guides/beat-ship.md`** — remove the "Why GitHub Flow (Profile A)" framing from the header; drop the Claude-native / OutSystems ODC bullets in the platform-notes block.
4. **`docs/guides/beat-signal.md`** — remove the Claude-native + OutSystems ODC platform-notes bullets.
5. **`docs/guides/README.md`** — drop "platform notes (Claude-native / OutSystems ODC)" and "beat × profile matrix across Claude-native and OutSystems ODC" from the guide descriptions.

Rule 5 principle (`docs/principles/05-descriptive-profiles.md`) is untouched — the discipline "describe, don't prescribe" survives; the specific two-profile enumeration was always descriptive of v4's state, and v5's state is one profile.

## Changes

| Path | Change |
|---|---|
| `docs/guides/tool-reference.md` | Rewritten. Roles + inputs matrix as the central artefact; MCP + doc-sweep sections preserved; profile sections removed. |
| `docs/guides/beat-spec.md` | "Platform notes" section removed. |
| `docs/guides/beat-ship.md` | "Why GitHub Flow (Profile A)" header retitled; platform-notes block removed. |
| `docs/guides/beat-signal.md` | Platform-notes block removed. |
| `docs/guides/README.md` | Guide descriptions no longer reference the two-profile split. |

## Technical notes

- **Single profile is reality, not a choice.** v5.0's solo maintainer is on Claude Code + GitHub Actions. Documenting hypothetical future profiles before a second adopter exists distorts the docs (v5 PRD "multi-profile documentation" out-of-scope entry).
- **Roles × inputs framing preserved.** The *seven roles* table already exists in tool-reference.md; this PR enhances it by adding an "Inputs" column and promoting it to the main artefact. Each role entry lists what the role does plus what inputs (repo context, web search, CI output, etc.) it needs, with 1–2 tool *examples* at most.
- **MCP integrations section stays descriptive.** It lists MCP servers as options, not mandates — already Rule-5-compliant.
- **Starter-verify lingering mention** in tool-reference.md (flagged in PR #120) — removed as part of the rewrite.

## Testing

- Local hard-rules-check passes (Rule 5 greps for prescriptive language; the rewrite must not introduce any).
- Manual: read-through confirms no "use X because it's best" / "required to use Y" phrasing.
- CI Hard Rules passes.

## Acceptance criteria

- [x] `tool-reference.md` has no Profile A/B sections and no two-column Beat × profile matrix
- [x] Role model table present with "Inputs" column
- [x] `tool-reference.md` under 100 lines
- [x] Profile-split mentions removed from beat-{spec,ship,signal}.md and guides/README.md
- [x] Rule 5 passes
- [x] Australian spelling passes
- [x] All four beat guides read coherently without the profile scaffolding

## Out of scope

- Adding new roles or renaming existing roles (7-role model survives as-is)
- Reframing `docs/principles/05-descriptive-profiles.md` (the principle stands; only the examples-of-profiles material is affected)
- Tool-choice recommendations for specific stacks (Python, Go, Rails, etc.) — reintroduce as plugin packs in v5.x if demand arrives

## References

- v5 PRD (#115) Feature Matrix row 5 + Resolved Decisions row 3
- Research brief Finding 7 ("`tool-reference.md` evolution — reframe as role + inputs matrix, not shopping list")
- Rule 5 principle: `docs/principles/05-descriptive-profiles.md`
