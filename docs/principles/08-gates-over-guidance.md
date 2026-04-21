# 8. Gates over guidance

> Meta-principle. Justifies every enforcement hook in `.claude/hooks/`.

## The rule

Discipline the harness can enforce automatically beats discipline written in a guide and hoped for. If a rule matters, wire a gate. If a gate isn't feasible, pick a different rule or scope it differently.

## Why

Guidelines in prose are optional at 2am. Gates in hooks are not. When the pre-commit gate blocks a spelling violation, the author fixes it in 30 seconds; when the guide says "please use Australian spelling" and no gate exists, the author ships the commit and someone else corrects it three weeks later in a drive-by PR.

v4's tagged-exception prefixes (`[release]`, `[infra]`, `[docs]`, `[bulk]`) are a *refinement* of this principle, not a contradiction: rigor is the default, legitimate exceptions have named, auditable escapes, and nothing relies on human goodwill to hold the line.

## In practice

- Every Hard Rule (1–5) has a hook or script that enforces it. Rules 6–8 are meta and shape how the harness is built, not what it blocks.
- Gates are cheap: a bash regex beats a 500-word guide section on spelling.
- The gate's error message explains *why* and offers a concrete fix — never just "denied".
- When introducing a new rule, ask first: "what's the gate?" If the answer is "documentation", the rule isn't ready. Either design the gate or drop the rule.

## When it fails

- Symptom: the same violation lands repeatedly across PRs.
- Diagnosis: the rule exists only as prose. The guide isn't moving the behaviour.
- Fix: either wire an enforcement hook, or accept that the rule is aspirational and stop calling it a rule.

## Related

- `.claude/hooks/pre-commit-gate.sh` — the umbrella gate.
- `.claude/skills/hard-rules-check/scripts/check-all.sh` — the actual rule logic.
- All other principle files — each names its gate in the header.
