# 6. Plan-before-code

> Hard Rule. Enforced by the pre-commit gate's check for `docs/plans/<slug>.md`.

## The rule

Every feature has a plan file at `docs/plans/<slug>.md` before any
implementation begins. Reviewers (human or agent) read the plan
before they read the diff. No Auto Mode.

## Why

A diff answers "what changed". A plan answers "why this sequence, why
now, what could go wrong". Without a plan, every code review starts
from zero, and the feature's assumptions stay tacit in the head of
whoever wrote it.

The plan is also the resumability contract — if work pauses for a
day (or a week), the plan is what lets anyone pick it back up.

## In practice

- `/plan <slug>` produces the plan alongside the specs.
- Plan files include: goal, specs referenced, implementation sequence,
  risks, and status markers per step.
- Plans are living documents during Build. Tick off steps as they
  land. Update risks as new ones emerge.
- After merge, `/run memory-sync` updates the plan's status to
  `shipped` and leaves it on disk as an audit trail.

## When it fails

- Rule 6 fails when a feature branch has no `docs/plans/<slug>.md`.
- Fix: author the plan before the next commit. If the plan would be
  trivially short (e.g. a one-line typo fix), the pre-commit gate
  exempts `fix:` / `docs:` commits with empty `docs/plans/` directory.

## Related

- Rule 5 (spec-driven) — plans reference specs, not the other way round.
- `memory-sync` skill — closes the loop by updating plan status after merge.
