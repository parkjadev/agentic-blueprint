# Memory sync rules

The detailed policy behind `memory-sync/scripts/sync.sh`. Load on demand when the script flags something unfamiliar.

## Plan files (`docs/plans/`)

- **Never deleted.** Plan files are the audit trail of what the team planned to build and when.
- **Status markers update over time.** Valid values in the plan's `status:` frontmatter:
  - `draft` — authored, not yet approved
  - `approved` — ready for `/build`
  - `in_progress` — actively being built
  - `shipped` — merged to `main`
  - `abandoned` — explicitly decided not to ship (include a reason note)
- The `update-plan-status.sh` helper sets these based on the related PR state.

## Research briefs (`docs/research/`)

- **Keep while actively referenced.** A brief is actively referenced if any current plan, spec, or open PR links to it.
- **Archive after 180 days of no references.** Move to `docs/research/_archive/`. Archived briefs are still searchable — just out of the way.
- Do not delete briefs. They may be the only record of why a decision was made.

## Specs (`docs/specs/<slug>/`)

- **Frontmatter `status:`** mirrors the plan: `draft | approved | shipped | abandoned`.
- **Shipped specs stay on disk.** They describe the contract at merge time and are reference material for later feature work.
- If a shipped spec is superseded, note that in its own frontmatter (`superseded_by: docs/specs/<new-slug>/`), don't delete it.

## CHANGELOG

- **Released sections are immutable.** Don't re-order, re-word, or "tidy up" entries under a released version number.
- **`[Unreleased]`** is the only mutable section; it gets cut into a new version on release (a human operation).
- Use the `changelog-entry` skill to add entries, not ad-hoc edits.

## Cross-reference invariants

- Every plan file should mention its specs folder path.
- Every `CHANGELOG.md [Unreleased]` entry should link either a PR (`(#n)`) or a plan file.
- Every shipped spec should have a plan file with `status: shipped`.

## When sync produces noise

- If the script archives a brief you think is still relevant — move it back, and either add a reference to it from a current plan or update its mtime via `touch` before the next sync run.
- If a plan's status didn't update — check that the PR merge commit references the plan path.
