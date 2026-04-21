# 4. Templates are versioned, not edited in flight

> Hard Rule. Enforced by `.claude/hooks/template-guard.sh` (blocks Write/Edit inside `docs/templates/`) and the pre-commit gate (scans the full commit range for template touches).

## The rule

The spec templates in `docs/templates/` are the blueprint's core IP. Feature PRs never touch them. Template edits land only during an explicit release rebuild — identified by one of three escapes:

1. `AGENTIC_BLUEPRINT_RELEASE=1` session env var.
2. Commit subject starting with `[release]` (per-commit audit trail).
3. A dedicated `docs/*` or `templates/*` branch (legacy v3 escape).

The `_archive/` subfolder is always writable — retiring a template by moving it to `_archive/` is not an edit to the active contract.

## Why

Every downstream spec inherits the template's structure. If `technical-spec.md` loses its *Risks / Mitigations* header, every new spec silently loses it too — and the habit of thinking about risks leaks out of the process. Templates are the skeleton; once bone is lost, it doesn't grow back without effort.

Explicit release-rebuild escapes (rather than `--no-verify`) keep the discipline honest: every template change is traceable to a named commit in the git log.

## In practice

- Template changes group into a single `[release]`-tagged commit (or a series of them) rather than scattering across feature PRs.
- `spec-author` treats templates as read-only — it copies and fills, never edits the source.
- If a template section is genuinely not applicable to a specific feature, the filled spec keeps the header and writes "Not applicable — <one-sentence reason>". Never delete the header.
- Retirement flow: `git mv old.md _archive/old.md`, then prepend a 3-line redirect stub pointing at the new home. The commit subject still needs `[release]` for auditability.

## When it fails

- `template-guard.sh` (live hook) blocks Write/Edit with a clear error naming the three escapes.
- The pre-commit gate's Rule 4 (was Rule 7 in v3) walks every commit in `base_ref..HEAD` that touches a non-archive template path and requires each one to carry `[release]`.
- Fix: re-commit with the `[release]` subject prefix or set the env var for an interactive session.

## Related

- `template-guard.sh` hook.
- `docs/templates/README.md` — the current template catalogue.
- `docs/templates/_archive/` — retired templates with redirect stubs.
