# 3. Spec-before-Ship

> Hard Rule. Enforced by the pre-commit gate's check for `docs/specs/<slug>/` (or a flat `docs/specs/<slug>.md` in v4) and the v4 `/spec` command flow.

## The rule

Every feature, epic, fix, or idea starts as a spec before any implementation begins. The spec is the shared contract between the human and the agent. `/spec` produces it; `/ship` honours it.

v4 collapses the old Rules 5 (spec-driven) and 6 (plan-before-code) into one principle because Claude Code now closes the loop from spec to shipped PR in one continuous motion. The spec IS the plan.

## Why

"Just start coding" ships the wrong thing fast. A spec is cheap to change, cheap to review, and forces the author to name the problem before hand-waving at the solution. Without a spec, every review is an archaeology expedition through diffs; with one, the review is against a named contract.

The old two-rule split encoded a Plan → Build handoff that Claude Code no longer has. Merging them into one rule removes the artificial ceremony without losing the discipline.

## In practice

- Spec scope matches the work:
  - `product` — research brief + product PRD + architecture + milestone + feature backlog.
  - `epic` — epic-level PRD + technical-spec referencing a parent product.
  - `feature` — feature PRD + technical-spec linked to a parent epic or idea.
  - `fix` — minimal technical-spec (Problem / Root cause / Fix / Regression test).
  - `chore` — no spec; just a branch and issue. `[infra]` / `[docs]` commit prefixes skip this rule.
- Specs evolve during Ship. When implementation reveals a spec flaw, update the spec first, then the code.
- Shipped specs stay on disk. They describe the contract at merge time and are reference material for later work.
- `/signal audit` periodically re-reads open specs and flags those where reality has drifted.

## When it fails

- The pre-commit gate fails Rule 3 when a feature branch has no `docs/specs/<slug>/` and no spec changes in the diff.
- Fix: stop coding, run `/spec feature <slug>` (or appropriate scope), produce the spec, then resume.
- Legitimate exceptions: `[infra]` commit prefix for harness/CI/dependency bumps; `[docs]` prefix for doc-only commits. Rules 1, 2, 4–8 remain enforced.

## Related

- `docs/templates/PRD.md` + `docs/templates/technical-spec.md` (scope-aware via `scope:` frontmatter).
- `spec-author` subagent — `.claude/agents/spec-author.md`.
- `docs/templates/` (Rule 4).
