# 12. Gates over guidance

> Meta-principle. Shapes how Hard Rules are enforced.

## The idea

Hard Rules are machine-checked gates, not vibe-checked guidelines.
A rule that relies on "the reviewer will notice" will eventually be
broken by a reviewer who is tired, new, or rushed. A rule that is
gated by a pre-commit hook only breaks when the gate itself breaks.

## Why

Discipline under deadline is uneven. The same engineer who writes
clean specs on Tuesday cuts corners on Friday at 5pm. Human process
cannot reliably enforce itself.

Gates move enforcement out of willpower and into the tooling. Once
installed, they fire regardless of the author's mood, the
reviewer's attention, or the deadline pressure. The cost of a gate
is upfront (writing the check); the return compounds on every
subsequent commit.

## In practice

- Every Hard Rule has a corresponding check in
  `.claude/skills/hard-rules-check/scripts/check-all.sh`.
- The pre-commit hook (`.claude/hooks/pre-commit-gate.sh`) runs the
  checker before `git commit` and `git push`. Failure blocks the
  operation with actionable output.
- When a rule is too blunt for a specific case, we either refine
  the check (preferred) or document the exception in the skill's
  reference file. We do not disable the gate.
- `--no-verify` and equivalent bypasses are reserved for genuine
  emergencies and require human sign-off in the PR description.

## Where guidance still belongs

- **Taste.** Prose style, naming, abstraction level — these live in
  principles and reviews, not gates.
- **Novel situations.** A brand-new kind of work (first time we
  ship a CLI, first time we add a GitHub Action) gets guidance
  first; the gate is added once the pattern stabilises.
- **Judgement-heavy trade-offs.** Gates are for bright-line rules.
  "Keep abstractions simple" is not a gate.

## Anti-patterns

- Adding a gate the team routinely bypasses — that's a broken gate,
  not discipline.
- A gate with no "how to fix" output. Gates must tell the author
  exactly what's wrong and where.
- A gate that is slow enough to tempt people to skip it.

## Related

- Rules 1–9 — each has a gate.
- `.claude/hooks/pre-commit-gate.sh` — the runtime.
- `.claude/skills/hard-rules-check/` — the checks.
