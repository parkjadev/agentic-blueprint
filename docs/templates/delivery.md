# Delivery — [Project Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved
**Scope:** product | epic | feature

> **Purpose.** One document covers both release **policy** (which profile, which gates, which rollback levers) and release **mechanics** (environments, branches, CI/CD, observability). In v4 these used to be two templates (`deployment.md` + `release-strategy.md`); they're merged because the policy and the mechanics answer the same question — *how does code reach production safely?*

> **Placeholders:** `{{database}}`, `{{auth}}`, `{{domain}}`, `{{region}}`. Replace on fill-in.

---

## 1. Release Profile

<!-- Which profile does this project follow? Pick one and explain why it fits the
     team's size, risk appetite, compliance context, and deployment cadence. -->

- [ ] **Profile A — Simplified / GitHub Flow.** One long-lived branch (`main`); per-PR preview; squash-merge to `main` auto-deploys production; feature flags for risky changes. Fits: startups, solo developers, SaaS without regulated data.
- [ ] **Profile B — Multi-environment / GitFlow.** `main` + `develop` + release branches; shared staging; human approval gate before production. Fits: regulated domains, enterprise change control, teams with external QA.
- [ ] **Custom variant.** Name nearest profile and list deviations. Do not invent a third long-lived branch without a written reason.

**Rationale (1 paragraph):** TODO — why this shape fits this project.

## 2. Precondition Verification

Each profile has preconditions. Confirm each before shipping to production.

- [ ] Observability covers error rate, latency, deployment markers
- [ ] Automated tests gate the merge-to-main path
- [ ] Rollback lever exists and has been exercised at least once
- [ ] Feature-flag mechanism is in place (required for Profile A; optional for B)
- [ ] Database migration tooling supports expand-migrate-contract
- [ ] Branch-protection rules match the chosen profile
- [ ] Incident response procedure is documented (`docs/operations/incident-response.md`)
- [ ] Secret hygiene — `.env*` gitignored, secrets in platform secret store

A failed precondition is a signal to either meet it or change profile, not to ship anyway.

## 3. Environment Matrix

Every environment, what it's for, how it gets keys/data.

| Environment | Trigger | URL | {{database}} | {{auth}} | Auto-deploy |
|---|---|---|---|---|---|
| Local development | `pnpm dev` / `flutter run` | `http://localhost:3000` | Dev project | Dev project | — |
| Preview (per PR) | PR opened against `main` | `<project>-<pr>.<platform>.app` | Shared dev project | Dev project | Yes (on PR push) |
| Production | Squash-merge to `main` | `{{domain}}` | Production project (PITR on) | Production project | Yes (on merge) |

> **Rule:** preview deployments never touch production data, production webhooks, or live hardware. Every external integration has a dev/sandbox tier; previews talk only to that tier.

## 4. Branch Strategy

```
issue #N
  └─ branch: <type>/<N>-<slug>     (from main; type ∈ feat|fix|chore|docs)
       └─ PR → main                ──▶ preview deploy
            └─ smoke-test the preview
                 └─ squash-merge   ──▶ production auto-deploys
                      └─ branch auto-deletes, issue auto-closes via "Closes #N"
```

> **Always squash-merge.** Never "Rebase and merge" in the UI — it rewrites commit SHAs. With one long-lived branch this is harmless; with any multi-tier flow it's the trap that breaks promotion.

### Branch Rules

| Branch | Protection | Merge requirements |
|---|---|---|
| `main` | Protected | PR required, CI green, 1 approval, conversation resolution required, linear history, **enforce_admins=true** |
| Short-lived (`feat/*`, `fix/*`, `chore/*`, `docs/*`) | None | Auto-deleted on merge |

> `enforce_admins=true` is non-negotiable. Temporary override is via a documented `unblock` script with a 60-second auto-restore — never via manual setting change.

## 5. CI/CD Pipeline

### On every PR

```yaml
# .github/workflows/ci.yml (adopter-specific names)
steps:
  - install dependencies (cached)
  - type-check
  - lint
  - test (CI config)
```

### On merge to `main`

1. CI re-runs against `main` (gating production).
2. Platform builds and deploys to `{{domain}}`.
3. Migrations run against the production database project.
4. Post-deploy verification (below).

### Post-Deploy Verification

Must pass before the deploy is "live":

- Health check returns 200 within 5 s.
- Critical-path smoke test green.
- Runtime error rate within baseline for 15 minutes.

A scheduled task in the **Signal** beat re-runs these checks every 15 minutes and creates a labelled issue on threshold breach.

## 6. Feature Flags

| Dimension | This project |
|---|---|
| Mechanism | TODO: role description (hosted flag service, in-code boolean, config file) |
| Owner | TODO: individual/role owning the flag catalogue |
| Rollout ladder | TODO: internal → 1% → 10% → 100% |
| Default for new flags | TODO: off by default; on by default; environment-scoped |
| Cleanup policy | TODO: stale flags retired within N weeks of 100% rollout |
| Audit cadence | TODO: how often the flag catalogue is reviewed |

## 7. Schema Migration Methodology

Database changes are the riskiest part of most releases.

- **Regime:** pre-launch (reseed freely) OR live (expand-migrate-contract).
- **Trigger to tighten:** first external user, first regulated data, first payment.
- **Destructive change procedure:** expand → migrate → contract across separate PRs. Each phase observed in production before the next begins.
- **Dry-run requirement:** where migrations are rehearsed before production.
- **Rollback:** how to reverse a migration; what's not reversible and how that's guarded.
- **Observability:** metrics/log events that confirm a migration has completed.

## 8. Rollback Procedures

Four levers, in increasing order of pain. Document who can pull each.

| Order | Lever | How to run | Side-effects | Authority |
|---|---|---|---|---|
| 1 | Disable feature flag | Flag console + flag name | Instant, reversible | On-call |
| 2 | Platform promote (previous deployment) | Platform UI / CLI | Seconds of latency | On-call |
| 3 | Revert the offending commit | `git revert` on `main`, fast-forward deploy | Standard deploy time | On-call with lead approval |
| 4 | Restore database from snapshot | Platform PITR runbook | Possible data loss since snapshot | Lead only |

Decision tree: when to escalate between levers, and when to declare an incident rather than continue rolling back. Cross-link: `docs/templates/incident-runbook.md`.

## 9. Monitoring

| Signal | Where | Threshold | Action |
|---|---|---|---|
| App health | `GET /api/health` | Any non-200 | Lever 2 (platform promote) |
| Error rate | Runtime logs / APM | > 1% over 5 min | Investigate, rollback if not fixable in <15 min |
| Response time (P95) | APM | > 2× baseline | Investigate, possible rollback |
| {{database}} | Provider dashboard | Connection saturation, slow queries | Provider alerts → on-call |
| External integrations | Custom dashboard / logs | Failed calls > 5% | Investigate (often network) |

## 10. Approval Gates (optional — for Profile B or regulated domains)

| Gate | Artefacts required | Approver role | SLA |
|---|---|---|---|
| TODO | TODO | TODO | TODO |

Write "N/A — no approval gate beyond PR review" if unused.

## 11. Unresolved Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | TODO | TODO | YYYY-MM-DD |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
