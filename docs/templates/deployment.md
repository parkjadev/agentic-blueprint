# Deployment — [Project Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved

---

## Environment Matrix

<!-- Define every environment, its purpose, and how it's accessed. -->

| Environment | Branch | URL | Database | Auto-Deploy |
|---|---|---|---|---|
| Development | Local | `http://localhost:3000` | Neon dev branch | — |
| Preview | PR branches | `<branch>.vercel.app` | Neon preview branch | Yes (on PR) |
| Staging | `staging` | `staging.example.com` | Neon staging branch | Yes (on push) |
| Production | `master` | `example.com` | Neon main branch | Yes (on merge) |

TODO: Update URLs and branch names for your project

## Branch Strategy

<!-- How code flows from development to production. -->

```
feature/my-feature
  └─ PR → staging (CI runs: type-check + lint + tests)
       └─ Merge → staging auto-deploys to staging environment
            └─ PR → master (manual review required)
                 └─ Merge → master auto-deploys to production
                      └─ Delete feature branch, pull master + staging
```

### Branch Rules

| Branch | Protection | Merge Requirements |
|---|---|---|
| `master` | Protected | PR required, CI must pass, 1 approval |
| `staging` | Protected | PR required, CI must pass |
| Feature branches | None | — |

## DNS & Domains

<!-- Domain configuration. Include registrar and DNS provider if relevant. -->

| Domain | Points To | Purpose |
|---|---|---|
| `example.com` | Vercel production | Production |
| `staging.example.com` | Vercel staging | Staging |
| `*.vercel.app` | Vercel preview | PR previews |

TODO: Update domains for your project

## Environment Variables

<!-- All environment variables required for each environment.
     NEVER include actual values — only names and descriptions. -->

### Required

| Variable | Description | Where |
|---|---|---|
| `DATABASE_URL` | Neon connection string | Vercel + `.env.local` |
| `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` | Clerk public key | Vercel + `.env.local` |
| `CLERK_SECRET_KEY` | Clerk secret key | Vercel + `.env.local` |
| `CLERK_WEBHOOK_SECRET` | Clerk webhook signing secret | Vercel + `.env.local` |
| `UPSTASH_REDIS_REST_URL` | Upstash Redis URL | Vercel + `.env.local` |
| `UPSTASH_REDIS_REST_TOKEN` | Upstash Redis token | Vercel + `.env.local` |

### Optional (gracefully skip when missing)

| Variable | Description | Service |
|---|---|---|
| `STRIPE_SECRET_KEY` | Stripe API key | Stripe |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook secret | Stripe |
| `R2_ACCOUNT_ID` | Cloudflare account ID | R2 Storage |
| `R2_ACCESS_KEY_ID` | R2 access key | R2 Storage |
| `R2_SECRET_ACCESS_KEY` | R2 secret key | R2 Storage |
| `R2_BUCKET_NAME` | R2 bucket name | R2 Storage |
| `INNGEST_EVENT_KEY` | Inngest event key | Inngest |
| `INNGEST_SIGNING_KEY` | Inngest signing key | Inngest |
| `RESEND_API_KEY` | Resend API key | Resend |
| `MOBILE_JWT_SECRET` | JWT signing secret for mobile auth | Mobile JWT |

<!-- See src/env.ts for Zod validation. Optional services use optional() schemas
     and the app starts without them. -->

## CI/CD Pipeline

<!-- Describe what happens on every push, PR, and merge. -->

### On Pull Request (`.github/workflows/ci.yml`)

```yaml
# Triggered: PR opened or updated against staging or master
steps:
  - pnpm install (cached)
  - pnpm type-check        # TypeScript strict mode
  - pnpm lint               # ESLint (no-console, no-any, floating-promises)
  - pnpm test:ci            # Vitest with CI config
```

### On Merge to Staging

1. Vercel builds and deploys to staging URL
2. Database migrations run automatically (`drizzle-kit push`)
3. TODO: Post-deploy smoke test (health check, critical paths)

### On Merge to Master

1. Vercel builds and deploys to production URL
2. Database migrations run against production
3. TODO: Post-deploy verification (health check, error rate monitoring)

## Vercel Configuration

<!-- Project-level Vercel settings. -->

```json
// vercel.json
{
  "regions": ["TODO: your-region"],
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

TODO: Set your preferred Vercel region

## Database Migrations

<!-- How schema changes are applied across environments. -->

| Command | When | Environment |
|---|---|---|
| `pnpm db:push` | During development | Local (Neon dev branch) |
| `pnpm db:push` | On deploy (build step) | Staging, Production |
| `pnpm db:studio` | Debugging | Local |

### Preview Branches (Neon)

Neon supports database branching for PR previews:
1. PR is opened → Neon creates a branch from staging
2. Migrations run against the branch
3. PR is merged or closed → branch is deleted

TODO: Configure Neon GitHub integration for automatic branching

## Rollback Procedure

<!-- How to roll back a bad production deployment. -->

### Quick Rollback (Vercel)

1. Go to Vercel dashboard → Deployments
2. Find the last known good deployment
3. Click "Promote to Production"
4. Verify health check: `curl https://example.com/api/health`

### Database Rollback

<!-- Database rollbacks are harder. Drizzle push is forward-only.
     For critical rollbacks, you may need to restore from Neon point-in-time recovery. -->

1. Identify the point-in-time before the bad migration
2. Use Neon's point-in-time recovery to create a new branch
3. Update `DATABASE_URL` to point to the recovered branch
4. Redeploy

## Monitoring

<!-- How do you know production is healthy? -->

| What | How | Alert |
|---|---|---|
| App health | `GET /api/health` | Scheduled task or uptime monitor |
| Error rate | Vercel Analytics | TODO: Set threshold |
| Response time | Vercel Analytics | TODO: Set threshold |
| Database | Neon dashboard | Neon alerts |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
