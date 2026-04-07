# Architecture — [Project Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved

---

## System Overview

<!-- High-level description of the system. What does it do? Who uses it?
     Include a text-based system diagram showing major components and their relationships.
     Keep it simple — this is for orientation, not exhaustive documentation. -->

```
┌─────────────┐     ┌─────────────────┐     ┌──────────────┐
│  Web Client  │────▶│  Next.js (Vercel)│────▶│  Neon Postgres│
│  (Browser)   │     │  API + SSR       │     │  (Database)   │
└─────────────┘     └────────┬────────┘     └──────────────┘
                             │
┌─────────────┐              │              ┌──────────────┐
│ Mobile Client│──────────────┤              │  Upstash Redis│
│ (Flutter)    │              │              │ (Rate Limit)  │
└─────────────┘              │              └──────────────┘
                             │
                    ┌────────▼────────┐
                    │  Clerk (Auth)    │
                    │  Inngest (Jobs)  │
                    │  Resend (Email)  │
                    │  R2 (Storage)    │
                    │  Stripe (Payments│
                    └─────────────────┘
```

TODO: Customise the diagram for your project

## Component Map

<!-- List every major component, its responsibility, and where it lives. -->

| Component | Responsibility | Location | Technology |
|---|---|---|---|
| Web application | Server-rendered pages + API routes | `src/app/` | Next.js (App Router) |
| API layer | REST endpoints with typed responses | `src/app/api/` | Next.js Route Handlers |
| Auth | Dual-mode: Clerk sessions (web) + JWT (mobile) | `src/lib/auth/` | Clerk, jose |
| Database | Data persistence, schema, migrations | `src/lib/db/` | Drizzle ORM, Neon |
| Background jobs | Async processing, scheduled work | `src/lib/jobs/` | Inngest |
| Rate limiting | Request throttling per IP/user | `src/lib/rate-limit.ts` | Upstash Redis |
| Storage | File uploads and media | `src/lib/storage/` | Cloudflare R2 |
| Email | Transactional email delivery | `src/lib/email/` | Resend |
| Payments | Billing, subscriptions, webhooks | `src/lib/stripe/` | Stripe |
| Mobile app | Native mobile client | `starters/flutter/` | Flutter, Riverpod |
| CI/CD | Automated testing and deployment | `.github/workflows/` | GitHub Actions, Vercel |

TODO: Add or remove components for your project

## Data Flow

<!-- Describe how data moves through the system for key operations.
     Focus on the most important flows — auth, CRUD, and background processing. -->

### Request → Response (API)

```
Client Request
  → Next.js Middleware (Clerk auth, CSP headers)
    → Route Handler (src/app/api/...)
      → Auth resolution (get-auth.ts — Clerk or JWT)
        → Zod validation (request body/params)
          → Database query (Drizzle)
            → API response (handleError/ok/noContent)
              → Client receives typed ApiResponse<T>
```

### Background Job Flow

```
API Route triggers event
  → Inngest receives event
    → Inngest function executes (retry on failure)
      → Database update / email send / external API call
        → Job completes or retries (3 attempts, exponential backoff)
```

### Auth Sync Flow

```
User signs up/updates in Clerk
  → Clerk fires webhook (user.created / user.updated)
    → POST /api/webhooks/clerk
      → Verify webhook signature (svix)
        → Create/update local user record
          → Local user table stays in sync with Clerk
```

TODO: Add flows specific to your application

## Integrations

<!-- External services the system depends on. Include what happens when each is unavailable. -->

| Service | Purpose | Required | Failure Behaviour |
|---|---|---|---|
| **Neon** | Primary database | Yes | App down — all reads/writes fail |
| **Clerk** | Authentication | Yes | Auth fails — users can't sign in |
| **Upstash** | Rate limiting | Yes | Rate limiting disabled — requests pass through |
| **Inngest** | Background jobs | No | Jobs queued but not processed — eventual consistency delayed |
| **Stripe** | Payments | No | Payment features unavailable — core app still works |
| **R2** | File storage | No | Upload/download features unavailable |
| **Resend** | Email | No | Emails queued but not sent — no user-facing impact |

## Key Architecture Decisions

<!-- Document significant decisions and their rationale. Future you will thank present you. -->

| Decision | Choice | Alternatives Considered | Rationale |
|---|---|---|---|
| TODO: Decision | Choice | Alternatives | Why |

<!-- Example:
| ORM | Drizzle | Prisma, Kysely | Type-safe, generates clean SQL, push migrations for rapid iteration |
| Auth | Clerk + JWT | Auth.js, Supabase Auth | Best DX, webhook sync, built-in mobile JWT support |
| Database | Neon | Supabase, PlanetScale | Serverless Postgres, branching for previews, zero cold start on Vercel |
| Hosting | Vercel | AWS, Fly.io | Zero-config Next.js hosting, preview deploys, built-in analytics |
-->

## Environment Architecture

<!-- How environments relate to each other and what infrastructure each uses. -->

| Environment | Branch | Database | URL | Purpose |
|---|---|---|---|---|
| Development | Local | Neon dev branch | `localhost:3000` | Local development |
| Preview | PR branches | Neon preview branch | `*.vercel.app` | PR review |
| Staging | `staging` | Neon staging branch | `staging.example.com` | Pre-production testing |
| Production | `master` | Neon main branch | `example.com` | Live users |

## Security Architecture

<!-- High-level security posture. Detailed per-feature auth is in auth-spec.md. -->

- **Authentication:** Clerk (web sessions) + JWT (mobile tokens)
- **Authorisation:** Role-based (admin, user) with per-resource ownership checks
- **Transport:** HTTPS everywhere (enforced by Vercel)
- **CSP:** Content Security Policy headers in middleware
- **Rate limiting:** Upstash Redis — per-IP and per-user limits
- **Input validation:** Zod schemas on every API endpoint
- **Secrets:** Environment variables — never committed to git

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
