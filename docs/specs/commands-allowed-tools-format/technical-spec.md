---
scope: fix
status: Draft
---

# Fix — `allowed-tools` frontmatter format on command files (v5.0.3)

## Problem

All four slash-command definitions (`/spec`, `/ship`, `/signal`, `/beat`) carry `allowed-tools` frontmatter in comma-separated form:

```yaml
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
```

Claude Code's command-loader does not parse comma-separated values as a list of individual tool names — it reads the literal string. The effect is that every slash command loads with a malformed allow-list, and tool use inside those commands is subject to the broader permission prompt instead of the intended allow-list.

Symptom surfaced after a fresh bootstrap install in an adopter repo: slash commands ran but triggered permission prompts for tools that the `allowed-tools` frontmatter should have granted.

## Root cause

The comma-separated form is a human-readable convenience but not a valid YAML list. Claude Code's frontmatter parser expects either:

- **Space-separated**: `allowed-tools: Bash Read Write Edit Glob Grep` (treated as whitespace-split tokens)
- **YAML list**: block form with `- Tool` items

The blueprint shipped comma-separated in both the live `.claude/commands/` and the bundle mirror at `claude-config/.claude/commands/`, so every adopter inherits the same bug.

## Fix

Convert to space-separated form across all 8 files (4 live + 4 bundle mirror). Space-separated was chosen over YAML block form because it's one line, preserving the existing frontmatter density.

## Changes

| Path | Change |
|---|---|
| `.claude/commands/spec.md` | `allowed-tools: Bash, Read, Write, Edit, Glob, Grep` → `allowed-tools: Bash Read Write Edit Glob Grep` |
| `.claude/commands/ship.md` | Same |
| `.claude/commands/signal.md` | Same |
| `.claude/commands/beat.md` | Same |
| `claude-config/.claude/commands/spec.md` | Same (bundle mirror) |
| `claude-config/.claude/commands/ship.md` | Same |
| `claude-config/.claude/commands/signal.md` | Same |
| `claude-config/.claude/commands/beat.md` | Same |
| `claude-config/VERSION` | `5.0.2` → `5.0.3` |
| `CHANGELOG.md` | `[5.0.3]` entry |

## Regression test

Re-run the bootstrap in an adopter repo; verify slash commands no longer trigger permission prompts for tools in the allow-list.

## Acceptance criteria

- [x] All 8 command files use space-separated `allowed-tools`
- [x] No `allowed-tools: Bash, Read` style remains anywhere in the repo
- [x] `claude-config/VERSION` reads `5.0.3`
- [x] Hard Rules CI passes

## Out of scope

- Agent definitions (`spec-author.md`, `spec-researcher.md`) — their frontmatter uses `tools: Read, Write, Edit, Glob, Grep` in comma form too, but subagent definitions follow a different parser (not the command loader). Verify separately if/when the same symptom shows up on subagent runs; not changing pre-emptively.

## References

- Bug surfaced in a real adopter install during v5.0.2 verification
