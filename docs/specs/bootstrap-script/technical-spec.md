---
scope: feature
parent: agentic-blueprint-v5-agnostic
status: Draft
---

# Feature — `bootstrap.sh` non-circular install entry point

## Problem

v5.0's documented install path is `/beat install` from inside Claude Code. That slash command lives at `.claude/commands/beat.md` inside the blueprint itself — which means the command is only available *after* the `.claude/` bundle has been copied into the adopter's repo. For a brand-new adopter, the documented path is circular: "run `/beat install` to copy `.claude/` into your repo, but you need `.claude/` already in your repo to have the `/beat install` command."

Workarounds today, both awkward:

1. Clone the blueprint, then open Claude Code with the clone's `.claude/` loaded, then run `/beat install` pointed at the target — works but requires an interactive Claude Code session outside the target repo.
2. Manually copy `.claude/`, `claude-config/`, templates, contracts, CLAUDE.md fence, CI wrapper — essentially re-implement the install by hand per adopter.

Neither is a real entry point for a `curl | bash` experience, and the README's "just run `/beat install`" instruction is broken for the very first invocation.

## Solution

Ship a `bootstrap.sh` at the blueprint repo root. It's the shell-level entry point that `/beat install` assumes already happened. Both end up calling the same underlying `claude-config/scripts/install.sh`; the difference is where they're invoked from.

Three invocation modes, all supported by the same script:

- **From a cloned blueprint** — `bash bootstrap.sh` with the blueprint checkout as CWD-ancestor-unknown; script detects that `claude-config/scripts/install.sh` lives next to it and uses that local copy.
- **From anywhere via curl + process substitution** — `bash <(curl -fsSL https://raw.githubusercontent.com/parkjadev/agentic-blueprint/main/bootstrap.sh)`; script detects no local blueprint, clones to a tmp dir (cleaned on exit), then delegates.
- **From anywhere via pipe** — `curl -fsSL ... | bash`; same behaviour as process substitution.

Target directory is always the current working directory (same contract as `/beat install` and `install.sh`). Forwards `--dry-run` and `--force` flags to `install.sh` unchanged.

## Changes

| Path | Change |
|---|---|
| `bootstrap.sh` | New file at repo root. ~60 lines of shell. Mode 0755. Detects local vs remote source, clones if needed, delegates to `claude-config/scripts/install.sh`. |
| `README.md` | Quickstart — add a zeroth step showing `bash <(curl -fsSL .../bootstrap.sh)` as the first-time adopter path. Keep `/beat install` as the ongoing path for adopters who already have the bundle. |
| `claude-config/VERSION` | Bump `5.0.0` → `5.0.1` (patch release — structural fix, no feature surface change). |
| `CHANGELOG.md` | Add `[5.0.1]` entry below `[Unreleased]`. |
| `MIGRATION-v3-to-v4.md` | **Deleted** — v3→v4 upgrade doc at repo root; no live references. Same "no users to migrate" reasoning that kept v5.0 from shipping a v4 migration guide. Archival context survives inside the v4 research brief (`docs/research/agentic-os-v4-brief.md`). |

## Technical notes

- **No logic duplication.** `bootstrap.sh` is a dispatcher, not a reimplementation. All install behaviour stays in `claude-config/scripts/install.sh`. If install logic changes, only one place updates.
- **Clone is shallow + pinned.** `git clone --depth 1 --branch <ref>`; default ref is `main` but the user can override via `--ref <tag-or-branch>` or `AGENTIC_BLUEPRINT_REF` env var. `--depth 1` keeps the transient clone tiny.
- **Tmp-dir lifecycle.** The cloned tmp dir is `mktemp -d` with a `trap` to rm on exit. No orphaned clones.
- **Self-detection.** The script resolves `${BASH_SOURCE[0]}` to check whether it lives inside a blueprint tree (local clone) or is running from stdin (pipe). The heuristic is: if `claude-config/scripts/install.sh` exists next to `BASH_SOURCE[0]`, use that; otherwise clone.
- **No adopter-facing change for subsequent operations.** Once bootstrap has run once, the adopter has `.claude/` in their repo, and `/beat install` / `/beat update` work as documented. Bootstrap is strictly the first-time entry point.

## Testing

- Local syntax check: `bash -n bootstrap.sh`
- Local-clone path: `bash bootstrap.sh --dry-run` from the blueprint repo itself
- Remote path: verify with `bash <(curl -fsSL https://raw.githubusercontent.com/parkjadev/agentic-blueprint/main/bootstrap.sh) --dry-run` in a fresh repo *after* this PR merges (can't test the raw-github URL before the file exists at HEAD of main)
- Hard Rules CI passes on the PR

## Acceptance criteria

- [x] `bootstrap.sh` exists at repo root and is executable
- [x] `bash bootstrap.sh --help` prints usage
- [x] `bash bootstrap.sh --dry-run` (from the blueprint repo, against a scratch target) runs install.sh in dry mode without touching files
- [x] README documents the new entry point as the first install instruction
- [x] `claude-config/VERSION` reads `5.0.1`
- [x] Australian spelling passes; Hard Rules CI passes

## Out of scope

- **Claude Code Marketplace plugin** (`.claude-plugin/marketplace.json`) — flagged in the v5 research brief as the "natural distribution channel". Still deferred to v5.x. Bigger design (governance, plugin naming, versioning) than a patch release should carry.
- **Installer for non-GitHub hosts.** Bootstrap uses `git clone` which is host-agnostic, but README examples show only the GitHub URL. Downstream forks override via `AGENTIC_BLUEPRINT_URL`.
- **Uninstall / rollback script.** `/beat update` already handles upgrades; full uninstall is not a v5.x concern yet.

## References

- v5 PRD Feature Matrix row 6 (`/beat install` cleanup) — this closes the last bootstrap gap that row's scope deferred
- Research brief Finding 4 (`/beat install` in a starter-less world) + Finding 1 (Marketplace as distribution channel)
- `claude-config/scripts/install.sh` — the existing install logic that `bootstrap.sh` dispatches to
