# 7. Templates are sacred

> Hard Rule. Enforced by `.claude/hooks/template-guard.sh` (blocks Write/Edit
> inside `docs/templates/`) and the pre-commit gate.

## The rule

The spec templates in `docs/templates/` are the blueprint's core IP.
Edit them for clarity, never remove sections. Never bundle template
changes into a feature PR.

## Why

Every downstream spec inherits the template's structure. If a template
loses its "Risks / Mitigations" header, every new spec silently loses
that section too — and the habit of thinking about risks leaks out of
the process. Templates are the skeleton; once bone is lost, it doesn't
grow back without effort.

## In practice

- Template changes live in their own PR, labelled `docs:` or
  `templates:`, and require explicit reviewer approval.
- `spec-writer` and the `/plan` workflow treat templates as read-only.
- Downstream specs copy a template then fill in the blanks; they do
  not start from an empty file.
- If a template section is genuinely not applicable to a specific
  feature, the spec keeps the header and writes "Not applicable —
  <one-sentence reason>". Never delete.

## When it fails

- The `template-guard.sh` hook blocks Write/Edit attempts inside
  `docs/templates/` with a clear error message.
- The pre-commit gate runs `git diff --name-only main...HEAD` and
  fails if any path under `docs/templates/` is in the diff.
- Fix: revert the template change and re-open it as a dedicated PR.

## Related

- `template-guard.sh` — `.claude/hooks/template-guard.sh`.
- `docs/templates/README.md` — the template catalogue.
