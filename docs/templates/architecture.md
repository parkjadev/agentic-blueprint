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
┌─────────────┐     ┌─────────────────┐     ┌───────────────────┐
│  Web Client  │────▶│  Next.js (Vercel)│────▶│  Supabase         │
│  (Browser)   │     │  API + SSR       │     │  PostgreSQL       │
└─────────────┘     └────────┬────────┘     │  Auth             │
                             │              │  Storage          │
┌─────────────┐              │              │  (via Supavisor   │
│ Mobile Client│──────────────┤              │   pooler)         │
│ (Flutter)    │              │              └───────────────────┘
└─────────────┘              │
                    ┌────────▼────────┐
                    │  Inngest (Jobs)  │
                    │  Resend (Email)  │
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
| Auth | Supabase Auth (unified web + mobile) | `src/lib/auth/` | Supabase Auth, @supabase/ssr |
| Database | Data persistence, schema, migrations | `src/lib/db/` | Drizzle ORM, Supabase PostgreSQL (Supavisor pooler) |
| Background jobs | Async processing, scheduled work | `src/lib/jobs/` | Inngest |
| Rate limiting | Request throttling per IP/user | `src/lib/rate-limit.ts` | In-memory (Upstash Redis as upgrade path) |
| Storage | File uploads and media | `src/lib/storage/` | Supabase Storage |
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
  → Next.js Middleware (Supabase session refresh, CSP headers)
    → Route Handler (src/app/api/...)
      → Auth resolution (get-auth.ts — supabase.auth.getUser())
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
User signs up in Supabase Auth
  → PostgreSQL trigger fires on auth.users INSERT (handle_new_user)
    → Create local user record (users.id = Auth UUID)
      → Local user table stays in sync with Supabase Auth
```

TODO: Add flows specific to your application

## Integrations

<!-- External services the system depends on. Include what happens when each is unavailable. -->

| Service | Purpose | Required | Failure Behaviour |
|---|---|---|---|
| **Supabase** | Database, auth, storage | Yes | App down — all reads/writes/auth fail |
| **Inngest** | Background jobs | No | Jobs queued but not processed — eventual consistency delayed |
| **Stripe** | Payments | No | Payment features unavailable — core app still works |
| **Resend** | Email | No | Emails queued but not sent — no user-facing impact |

## Key Architecture Decisions

<!-- Document significant decisions and their rationale. Future you will thank present you. -->

| Decision | Choice | Alternatives Considered | Rationale |
|---|---|---|---|
| TODO: Decision | Choice | Alternatives | Why |

<!-- Example:
| ORM | Drizzle | Prisma, Kysely | Type-safe, generates clean SQL, push migrations for rapid iteration |
| Auth | Supabase Auth | Auth.js, Clerk | Unified web + mobile auth, no separate webhook sync, built-in storage + DB |
| Database | Supabase PostgreSQL | Neon, PlanetScale | Integrated auth + DB + storage, connection pooling via Supavisor |
| Hosting | Vercel | AWS, Fly.io | Zero-config Next.js hosting, preview deploys, built-in analytics |
-->

## Environment Architecture

<!-- How environments relate to each other and what infrastructure each uses. -->

| Environment | Trigger | Database | URL | Purpose |
|---|---|---|---|---|
| Development | Local checkout | Supabase local or dev project | `localhost:3000` | Local development |
| Preview (per PR) | Open PR against `main` | Supabase dev project (shared across previews) | `<project>-<pr>.vercel.app` | PR review, smoke testing, stakeholder demos |
| Production | Squash-merge to `main` | Supabase production project | `example.com` | Live users |

> No long-lived `staging` branch — see `docs/guides/feature-workflow.md` for the rationale.

## Security Architecture

<!-- High-level security posture. Detailed per-feature auth is in auth-spec.md. -->

- **Authentication:** Supabase Auth (unified web + mobile)
- **Authorisation:** Role-based (admin, user) with per-resource ownership checks
- **Transport:** HTTPS everywhere (enforced by Vercel)
- **CSP:** Content Security Policy headers in middleware
- **Rate limiting:** In-memory rate limiter — per-IP and per-user limits (Upstash Redis as documented upgrade path)
- **Input validation:** Zod schemas on every API endpoint
- **Secrets:** Environment variables — never committed to git

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
