# 5. Spec-driven

> Hard Rule. Enforced by the `/plan` workflow and the pre-commit gate.

## The rule

Every feature starts as a spec document before any code is written.
Specs live at `docs/specs/<slug>/` and use the templates in
`docs/templates/`.

## Why

"Just start coding" is how you ship the wrong thing fast. A spec is
cheap to change, cheap to review, and forces the author to name the
problem before hand-waving at the solution. The spec is the shared
contract between human and agent — without it, every review is an
archaeology expedition through diffs.

## In practice

- `/plan <slug>` runs the `spec-writer` subagent, then the
  `spec-reviewer` subagent, to produce the spec set.
- Default spec set: PRD + technical-spec. Add api-spec,
  data-model-spec, auth-spec, or architecture when the feature touches
  those surfaces.
- Specs evolve during Build. When the build reveals a flaw in the
  spec, update the spec, then update the code — not the other way
  around.
- Shipped specs stay on disk. They describe the contract at merge
  time and are reference material for later features.

## When it fails

- The pre-commit gate fails Rule 5 when a feature branch has no
  `docs/specs/<slug>/` directory and no spec changes in the diff.
- Fix: stop coding, run `/plan <slug>`, produce the spec, then resume.

## Related

- `docs/templates/` — the sacred template set (Rule 7).
- `spec-writer`, `spec-reviewer` — `.claude/agents/`.
- `spec-author` skill — `.claude/skills/spec-author/`.
