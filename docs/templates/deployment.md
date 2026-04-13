# Deployment — [Project Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved

> **Branching model:** [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow) — one long-lived branch (`main`), one Vercel preview deployment per PR, production auto-deploys on merge to `main`. There is no `staging` branch. If you need a shared QA environment, use a Vercel preview alias — never a long-lived branch.

> **Placeholders to replace:** `{{database}}`, `{{auth}}`, `{{hardware}}`, `{{domain}}`, `{{region}}`. The defaults below assume Supabase + a hardware integration; replace as needed.

---

## Environment Matrix

Every environment, what it's for, and how it gets keys/data.

| Environment | Trigger | URL | {{database}} | {{auth}} | {{hardware}} | Auto-deploy |
|---|---|---|---|---|---|---|
| Local development | `pnpm dev` | `http://localhost:3000` | Supabase local or dev project | Supabase Auth (dev project) | Mock / sandbox | — |
| Vercel preview (per PR) | PR opened against `main` | `<project>-<pr>.vercel.app` | Supabase dev project (shared across previews) | Supabase Auth (dev project) | Mock / sandbox | Yes (on PR push) |
| Production | Squash-merge to `main` | `{{domain}}` | Supabase production project | Supabase Auth (production project) | Real / live | Yes (on merge) |

TODO: Replace `{{domain}}` with your real domain. Add a "QA preview alias" row only if you actually need a stable URL for stakeholder review — and use a Vercel preview alias, not a new branch.

## Branch Strategy

```
issue #N
  └─ branch: <type>/<N>-<slug>     (from main; type ∈ feat|fix|chore|docs)
       └─ PR → main                ──▶ Vercel preview deploy
            └─ smoke-test the preview
                 └─ squash-merge   ──▶ production auto-deploys
                      └─ branch auto-deletes, issue auto-closes via "Closes #N"
```

> **Always squash-merge.** Never use "Rebase and merge" in the GitHub UI — it rewrites commit SHAs. With one long-lived branch this is harmless, but it's the trap that breaks any two-tier flow.

### Branch Rules

| Branch | Protection | Merge requirements |
|---|---|---|
| `main` | Protected | PR required, CI green, 1 approval, conversation resolution required, linear history, **enforce_admins=true** |
| Short-lived branches (`feat/*`, `fix/*`, `chore/*`, `docs/*`) | None | Auto-deleted on merge |

The exact branch protection settings are configured by `claude-config/scripts/setup-branch-protection.sh`.

> **`enforce_admins=true` is non-negotiable.** If you genuinely need to push past protection for a one-off emergency, run `claude-config/scripts/unblock-protection.sh` — it temporarily disables enforce_admins, prints a 60-second countdown, and auto-restores. Never set `enforce_admins=false` permanently; that's how branches end up unprotected for months.

## DNS & Domains

| Domain | Points to | Purpose |
|---|---|---|
| `{{domain}}` | Vercel production | Production |
| `*.vercel.app` | Vercel preview | Per-PR previews |
| (optional) `qa.{{domain}}` | Vercel preview alias | Long-lived preview alias for stakeholder review — **alias only, not a branch** |

TODO: Update domains for your project. Delete the QA row if you don't need one.

## Environment Isolation Matrix

Which credentials, services, and data live where. Anything in the "Production only" column is the blast-radius surface — protect those keys hardest.

| Concern | Local dev | Preview (per PR) | Production |
|---|---|---|---|
| {{database}} | Supabase local or dev project | Supabase dev project (shared across previews) | Supabase production project (PITR enabled) |
| {{auth}} | Supabase Auth (dev project) | Supabase Auth (dev project) | Supabase Auth (production project) |
| {{hardware}} integration | Mock / sandbox endpoint | Mock / sandbox endpoint | **Live device endpoints** |
| Stripe | Test mode keys | Test mode keys | Live mode keys (separate webhook secret) |
| Email (Resend) | Logs to console | Logs to console / sandbox domain | Sends real email from `{{domain}}` |
| Object storage (Supabase Storage) | Local or dev bucket | Dev project bucket | Production bucket with lifecycle rules |
| Background jobs (Inngest) | Inngest dev server | Inngest dev environment | Inngest production environment |
| Rate limit store | In-memory | In-memory | In-memory (upgrade to Upstash Redis for distributed) |
| Secret rotation | Local `.env.local` | Vercel project env (Preview scope) | Vercel project env (Production scope) |

> **Rule:** never let preview deployments touch production data, production webhooks, or live hardware. Every external integration gets a dev/sandbox tier; preview deploys talk only to that tier.

## Environment Variables

Names only — never commit values. See `src/env.ts` for the Zod schema and `claude-config/CLAUDE.md.template` for the optional-services pattern.

### Required

| Variable | Description | Where it's set |
|---|---|---|
| `DATABASE_URL` | Supabase PostgreSQL connection string (via Supavisor pooler) | Vercel + `.env.local` |
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL | Vercel + `.env.local` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous (public) key | Vercel + `.env.local` |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (server-side only) | Vercel + `.env.local` |

### Optional (gracefully skip when missing)

| Variable | Description | Service |
|---|---|---|
| `STRIPE_SECRET_KEY` | Stripe API key | Stripe |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook secret | Stripe |
| `INNGEST_EVENT_KEY` | Inngest event key | Inngest |
| `INNGEST_SIGNING_KEY` | Inngest signing key | Inngest |
| `RESEND_API_KEY` | Resend API key | Resend |
| `{{HARDWARE}}_API_URL` | {{hardware}} integration base URL | TODO |
| `{{HARDWARE}}_API_KEY` | {{hardware}} integration credential | TODO |

In Vercel, scope each variable to **Production**, **Preview**, or **Development** — never share production secrets with preview deploys.

## CI/CD Pipeline

### On every PR (`.github/workflows/ci.yml`)

```yaml
# Triggered: PR opened/updated targeting main, and pushes to main
steps:
  - pnpm install (cached)
  - pnpm type-check        # TypeScript strict mode
  - pnpm lint              # ESLint (no-console, no-any, floating-promises)
  - pnpm test:ci           # Vitest with CI config
```

The CI workflow's job name (`Type Check, Lint & Test` by default) is the **required status check** on `main`. If you rename the job, also update the `REQUIRED_CHECK` in `claude-config/scripts/setup-branch-protection.sh`.

In parallel with CI, Vercel:

1. Builds the PR branch
2. Runs migrations against the Supabase dev project (`drizzle-kit push`)
3. Posts the preview URL on the PR

### On merge to `main`

1. CI re-runs against `main` (gating production)
2. Vercel builds and deploys to `{{domain}}`
3. Migrations run against the Supabase production project (`drizzle-kit push`)
4. Post-deploy verification (see below)

### Post-Deploy Verification

After every production deploy, the following must pass before the deploy is considered "live":

```bash
# 1. Health check (must return 200 within 5s)
curl -fsS https://{{domain}}/api/health

# 2. Critical-path smoke test (replace endpoints with your own)
SMOKE_TEST_URL=https://{{domain}} pnpm tsx scripts/smoke-test.ts

# 3. Recent runtime errors (via Vercel MCP if connected, otherwise dashboard)
# Look for: error rate spike, new exception types, P95 latency > 2× baseline
```

A scheduled task in `docs/guides/scheduled-tasks.md` automates the same checks every 15 minutes against production.

## Vercel Configuration

```json
// vercel.json
{
  "regions": ["{{region}}"],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" }
      ]
    }
  ]
}
```

TODO: Replace `{{region}}` with your preferred Vercel region (e.g. `syd1`, `iad1`).

In the Vercel project settings:

- **Production branch:** `main`
- **Auto-merge previews:** off (we want every preview to come from a real PR)
- **Comments on commits/PRs:** on (so the preview URL lands on the PR automatically)
- **Auto-cancel previous deployments:** on
- **Allow merge methods:** squash only (matches branch protection)

## Database Management ({{database}} = Supabase PostgreSQL)

Supabase projects provide database, auth, and storage in a single platform. Preview deployments share the Supabase dev project; production has its own dedicated project.

| Trigger | Action |
|---|---|
| PR opened | Preview deployment connects to the Supabase dev project |
| Migrations run | `drizzle-kit push` against the dev project as part of the Vercel build |
| PR closed/merged | No database cleanup needed (dev project is shared) |
| Production deploy | `drizzle-kit push` against the Supabase production project (point-in-time recovery is on) |

TODO: create separate Supabase projects for dev and production. Configure `DATABASE_URL` per Vercel environment scope.

> **Schema-change discipline:** destructive changes (column drop, rename, type change) follow the **expand-migrate-contract** Hard Rule in `CLAUDE.md`. Never ship them in a single PR.

## Rollback Procedure

We have three rollback levers, in increasing order of pain.

### 1. Vercel promote (preferred — seconds)

The fastest, safest rollback. No git commits, no migrations, no drama.

1. Open Vercel dashboard → project → **Deployments**
2. Find the last known-good production deployment
3. Click **⋯ → Promote to Production**
4. Verify `curl -fsS https://{{domain}}/api/health`

This rolls back the runtime in seconds. Use it whenever the bad change is code-only.

### 2. Revert commit on `main` (minutes)

If the bad change must come out of `main` itself (e.g. it's blocking other PRs):

```
> Revert the merge commit on main. Push the revert.
> CI re-runs, Vercel re-deploys with the previous code.
> Open a follow-up issue to fix forward.
```

### 3. Database rollback ({{database}} point-in-time recovery — last resort)

Only use this when a migration corrupted data. Schema-only mistakes should be fixed forward with an expand-migrate-contract follow-up, not rolled back.

1. Identify the timestamp before the bad migration
2. Use Supabase's point-in-time recovery to restore to that timestamp
3. Update `DATABASE_URL` in Vercel (Production scope) if a new project was created
4. Redeploy
5. Plan the data reconciliation as a separate, careful piece of work

## Monitoring

| Signal | Where | Threshold | Action |
|---|---|---|---|
| App health | `GET /api/health` | Any non-200 | Vercel promote rollback |
| Error rate | Vercel Analytics / runtime logs | > 1% of requests over 5 min | Investigate, then rollback if not fixable in <15 min |
| Response time | Vercel Analytics | > 2× baseline P95 | Investigate, possible rollback |
| {{database}} | Supabase dashboard | Connection saturation, slow queries | Supabase alerts → on-call |
| {{hardware}} integration | Custom dashboard / logs | Failed device calls > 5% | Investigate (often network, not code) |

A scheduled health-check task lives in `docs/guides/scheduled-tasks.md` and creates a labelled issue on any threshold breach.

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
