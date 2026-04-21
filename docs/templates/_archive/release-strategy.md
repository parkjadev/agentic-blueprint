> **Archived in v4.** Release-strategy and deployment merged into one unified template.
> New home: `docs/templates/delivery.md` (release profile, flags, migrations, rollback ladder)
> Historical content preserved below.

---

# Release Strategy — [Project Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved

---

## Chosen Release Profile

<!-- Which profile does this project follow? Pick one of the blueprint's named
     profiles (see docs/guides/tool-reference.md) or describe a custom variant.
     State the profile and a one-paragraph rationale: why this shape fits the
     team's size, risk appetite, compliance context, and deployment cadence.
     If this is a custom variant, name the nearest blueprint profile and list
     the deliberate deviations. Do not name specific vendors here — that belongs
     in the environment matrix below. -->

TODO: Name the profile (e.g. "Simplified / GitHub Flow" or "Multi-environment
/ GitFlow") and explain why it suits this project.

## Precondition Verification

<!-- The chosen profile has preconditions. Confirm each is in place before
     shipping to production. See docs/guides/stage-4-ship.md for the full list
     per profile. A failed precondition is a signal to either meet it or pick
     a different profile, not to ship anyway. -->

- [ ] TODO: Observability covers error rate, latency, and deployment markers
- [ ] TODO: Automated tests gate the merge-to-main path
- [ ] TODO: A rollback lever exists and has been exercised at least once
- [ ] TODO: Feature-flag mechanism is in place (if the profile assumes it)
- [ ] TODO: Database migration tooling supports expand-migrate-contract
- [ ] TODO: Branch-protection rules match the chosen profile
- [ ] TODO: On-call and incident-response procedure is documented

## Branch Model and Environment Mapping

<!-- Which branches are long-lived, which are short-lived, and which
     environment each maps to. Describe the deployment trigger for each
     environment (PR open, merge to main, tag, manual). Keep the table
     concrete — one row per environment. -->

| Branch | Lifecycle | Environment | Deploy trigger | Notes |
|---|---|---|---|---|
| TODO: `main` | Long-lived | Production | TODO: e.g. squash-merge | TODO: the canonical shipping branch |
| TODO: `feat/<slug>` | Short-lived (per-PR) | Preview | TODO: e.g. PR open | TODO: auto-deletes on merge |
| TODO: *(add more rows only if the profile requires them)* | | | | |

Describe the merge discipline: squash, merge-commit, or rebase. State which
is used and why. Call out any exceptions (e.g. release-tag commits).

## Preview-Environment Approach

<!-- How does this project provide a per-PR preview environment? Describe the
     role (ephemeral per-PR URL, seeded with non-production data), not the
     vendor. Record which platform fills that role as a footnote at the end —
     the role stays stable across platform switches. Preview environments are
     the "staging" of a trunk-based flow; never use a long-lived shared branch
     for this. -->

TODO: Describe the per-PR preview environment — URL shape, data strategy
(shared dev dataset vs per-PR seed), lifecycle (torn down on merge), and which
service fills the role for this project.

## Feature Flag Implementation

<!-- Runtime activation control is what lets risky changes ship behind a dark
     launch. Capture: which mechanism provides flags (role, not vendor);
     who owns the flag lifecycle; what the rollout ladder looks like (e.g.
     internal → 1% → 10% → 100%); and the cleanup policy for stale flags.
     A flag that outlives its feature becomes dead weight. See
     docs/principles/04-optional-services.md for the role-vs-vendor framing. -->

| Dimension | This project |
|---|---|
| Mechanism | TODO: role description (e.g. hosted flag service, in-code boolean, config file) |
| Owner | TODO: which individual or role owns the flag catalogue |
| Rollout ladder | TODO: the staged-exposure steps used for risky features |
| Default for new flags | TODO: off by default; on by default; environment-scoped |
| Cleanup policy | TODO: stale flags retired within N weeks of 100% rollout |
| Audit cadence | TODO: how often the flag catalogue is reviewed |

## Schema Migration Methodology

<!-- Database changes are the riskiest part of most releases. State the
     project's discipline explicitly. Default position for any project with
     real users: expand-migrate-contract across multiple PRs for destructive
     changes. Pre-launch projects can reseed freely — note which regime this
     project is in and the exact trigger for switching. -->

- **Regime:** TODO: pre-launch (reseed freely) or live (expand-migrate-contract).
- **Trigger to tighten:** TODO: e.g. first external user, first regulated data, first payment.
- **Destructive change procedure:** TODO: describe the expand → migrate → contract
  split. Each phase lands in a separate PR and is observed in production before
  the next phase begins.
- **Dry-run requirement:** TODO: where migrations are rehearsed before production
  (preview, shadow copy, staging database).
- **Rollback:** TODO: how to reverse a migration; what is not reversible and how
  that is guarded.
- **Observability:** TODO: metrics or log events that confirm a migration has
  completed and applied to live traffic.

## Approval and CAB Workflow

<!-- Does this project require human approval before a production change
     ships? For regulated domains (health, finance, government, safety) a
     Change Advisory Board (CAB) or equivalent gate is often mandatory. For
     most early-stage projects it is not — write "N/A" with a sentence
     explaining why. If a gate applies, describe the approver role, the
     artefacts required, and the expected turnaround. -->

TODO: Describe the approval gate (approver role, artefacts required, SLA),
or write "N/A — no approval gate beyond PR review. Revisit on first regulated
deployment."

## Rollback Procedures

<!-- What levers exist to reverse a bad release, in the order they should be
     tried? Each lever should be runnable under incident pressure — linked
     runbook, unambiguous command, known side-effects. Include who has
     authority to pull each lever. See docs/operations/incident-response.md
     for the surrounding incident workflow. -->

| Order | Lever | How to run | Side-effects | Authority |
|---|---|---|---|---|
| 1 | TODO: Disable feature flag | TODO: link to flag console + flag name | TODO: instant, reversible | TODO: on-call |
| 2 | TODO: Promote previous deployment | TODO: platform command or UI step | TODO: seconds of downtime | TODO: on-call |
| 3 | TODO: Revert the offending commit | TODO: `git revert` on `main`, fast-forward deploy | TODO: standard deploy time | TODO: on-call with lead approval |
| 4 | TODO: Restore database from snapshot | TODO: platform runbook link | TODO: possible data loss since snapshot | TODO: lead only |

Document the decision tree: when to escalate between levers, and when to
declare an incident rather than continue rolling back.

## Unresolved Questions

<!-- Open questions about the release strategy that remain to be answered.
     Keep this list short and actionable. Prefer closing questions over
     carrying them. Link to tickets where work is tracked. -->

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | TODO: Open question | TODO: Name or role | TODO: YYYY-MM-DD |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
