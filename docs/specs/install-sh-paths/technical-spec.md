---
scope: fix
status: Draft
---

# Fix — install.sh source-path mismatches (v5.0.2)

## Problem

Running `bootstrap.sh` against a fresh repo clones the blueprint and delegates to `claude-config/scripts/install.sh`. That install script crashes partway through because `SRC_DIR` is computed as `claude-config/` while roughly half its path references assume `SRC_DIR` is the blueprint repo root. Two crashes confirmed on first real use, with several more latent:

| Line | Reference | Resolves to | Actual path |
|---|---|---|---|
| 92, 103 | `$SRC_DIR/CLAUDE.md` | `claude-config/CLAUDE.md` | **`claude-config/CLAUDE.md.template`** (missing crashes `cat` + `cp`) |
| 141 | `$SRC_DIR/.github/workflows/hard-rules-check.yml` | `claude-config/.github/workflows/…` | `.github/workflows/hard-rules-check.yml` (repo root; `claude-config/.github/` doesn't exist) |
| 112, 123 | `$SRC_DIR/docs/templates`, `$SRC_DIR/docs/contracts` | `claude-config/docs/…` | `docs/templates`, `docs/contracts` (repo root; `claude-config/docs/` doesn't exist) |
| 164, 165, 169 | `$SRC_DIR/claude-config/VERSION`, `$SRC_DIR/claude-config/scheduled-tasks.yaml` | `claude-config/claude-config/…` | `claude-config/VERSION`, `claude-config/scheduled-tasks.yaml` |

`--dry-run` didn't catch any of them because it only `echo`'d the commands instead of stat-ing source paths. The install was never tested end-to-end against a clean repo.

## Root cause

`SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"` resolves to `claude-config/` (one level up from `claude-config/scripts/`). The script was written with mixed intent — some references treat `SRC_DIR` as the *bundle root* (`.claude/`, `CLAUDE.md.template`, `VERSION`, `scheduled-tasks.yaml`), others treat it as the *blueprint repo root* (`docs/`, `.github/`). The two readings are incompatible for a directory that's a subtree of the latter.

## Fix

Rewrite `install.sh` with two explicit variables:

- `BUNDLE_DIR` = `claude-config/` (bundle root — contains `.claude/`, `CLAUDE.md.template`, `VERSION`, `scheduled-tasks.yaml`)
- `BLUEPRINT_ROOT` = parent of `BUNDLE_DIR` (repo root — contains `docs/`, `.github/`)

Every reference updated to use the correct variable. No ambiguity, no `$SRC_DIR/..` back-navigation.

Add a **pre-flight stat check** that validates every required source path exists before any write. If anything is missing, fail fast with the full list — no partial installs, no mid-install crashes, no user-hostile "cat: X: No such file or directory" surface.

## Changes

| Path | Change |
|---|---|
| `claude-config/scripts/install.sh` | Rewritten with `BUNDLE_DIR` + `BLUEPRINT_ROOT` semantics. Pre-flight check added. All path references corrected. Preserves existing CLI (`--dry-run`, `--force`) and behaviour when sources are valid. |
| `claude-config/VERSION` | `5.0.1` → `5.0.2`. |
| `CHANGELOG.md` | `[5.0.2]` entry below `[Unreleased]`. |

## Regression test

End-to-end install against a scratch repo:

```bash
mkdir -p /tmp/test-install && cd /tmp/test-install && git init -q
bash /path/to/agentic-blueprint/claude-config/scripts/install.sh --dry-run
bash /path/to/agentic-blueprint/claude-config/scripts/install.sh
```

Expected state after install:
- `.claude/` present with commands, agents, skills, hooks, settings.json
- `CLAUDE.md` written from `CLAUDE.md.template`
- `docs/{templates,contracts,specs,research,operations,signal}/` scaffolded; templates and contracts populated
- `.github/workflows/hard-rules.yml` copied from blueprint's `hard-rules-check.yml`
- `.gitignore` has `.env`, `.env.*`, `!.env.example`, `*.pem`, `*.key`
- `claude-config/VERSION` matches blueprint's `claude-config/VERSION`
- `claude-config/scheduled-tasks.yaml` present

Verified in-session: all of the above.

## Acceptance criteria

- [x] `bash -n install.sh` syntax-clean
- [x] `--dry-run` on a scratch repo completes with no errors
- [x] Real install on a scratch repo produces the expected tree
- [x] Pre-flight check fails with a clear message if a required source is missing (tested by temporarily renaming a source file — not committed)
- [x] `claude-config/VERSION` reads `5.0.2`
- [x] Hard Rules CI passes

## Out of scope

- Re-testing `bootstrap.sh` end-to-end via `bash <(curl ...)` — the clone-to-tmpdir path can't be tested until this PR is on `main` (the raw-GitHub URL needs the file). Post-merge smoke test instead.
- Porting the pre-flight check pattern to `update.sh` — separate chore if that script has the same class of bug.

## References

- Bug report inline in the session 2026-04-23 after running `bash <(curl -fsSL …/bootstrap.sh)` against a real adopter repo (Sentinel OS)
- Prior PR: #126 (shipped `bootstrap.sh`; didn't re-test `install.sh` paths — regression surfaced on first real adopter use)
