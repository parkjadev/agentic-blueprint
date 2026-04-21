# CLAUDE.md — Next.js starter

Starter-specific guidance. The framework-wide principles (Hard Rules
1–5 + meta-principles 6–8) live in the parent repo; read those first:

- Parent primitive map — [`/CLAUDE.md`](../../CLAUDE.md)
- Hard Rules — [`/docs/principles/`](../../docs/principles/)

This file captures what's specific to **this starter**.

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Framework | Next.js 15 (App Router) | React 19 |
| Language | TypeScript 5.7 | strict mode |
| Auth | Supabase Auth (via `@supabase/ssr`) | browser + server clients |
| Database | Postgres (Supabase) via Drizzle ORM | `@supabase/ssr` for session persistence |
| Env validation | `@t3-oss/env-nextjs` + Zod | see `src/env.ts` |
| Background jobs | Inngest (optional) | gated on `INNGEST_*` env vars |
| Payments | Stripe (optional) | gated on `STRIPE_*` env vars |
| Email | Resend (optional) | gated on `RESEND_API_KEY` |
| Styling | Tailwind CSS 3 | `tailwind-merge` + `clsx` for conditional classes |
| Testing | Vitest (unit) + Playwright (e2e) | `pnpm test:ci`, `pnpm test:e2e` |

## Project structure

```
starters/nextjs/
├── src/
│   ├── env.ts                # Zod-validated env (starter-local optional-services convention)
│   ├── middleware.ts         # Supabase session refresh + auth gate
│   ├── app/
│   │   ├── (auth)/           # Login, register, password reset
│   │   ├── (dashboard)/      # Authenticated routes
│   │   ├── (marketing)/      # Public pages
│   │   ├── api/              # Route handlers (REST endpoints)
│   │   ├── auth/             # OAuth callback, email confirm
│   │   └── layout.tsx        # Root layout, providers
│   ├── lib/
│   │   ├── api-response.ts   # ApiResponse<T> envelope — never bypass
│   │   ├── auth/             # get-auth, role checks
│   │   ├── db/               # Drizzle schema + client
│   │   ├── supabase/         # server + browser + middleware clients
│   │   ├── stripe/           # optional — guarded by env
│   │   ├── jobs/             # Inngest — optional, guarded by env
│   │   ├── email/            # Resend — optional, guarded by env
│   │   ├── storage/          # Supabase Storage helpers
│   │   ├── validations/      # Zod schemas for request bodies
│   │   ├── rate-limit.ts     # per-user limiter (Supabase-backed)
│   │   ├── logger.ts         # structured logger
│   │   └── request-context.ts # per-request context (trace id, user)
│   ├── types/                # shared types
│   └── test/                 # unit test helpers
├── supabase/                 # migrations + seed data
├── scripts/                  # maintenance scripts
└── .claude/                  # starter-local Claude Code config
```

## Starter-specific conventions

1. **Every API route returns `ApiResponse<T>`.** Success: `{ success: true, data }`. Failure: `{ success: false, error: { code, message } }`. Defined in `src/lib/api-response.ts`. Never return raw payloads.
2. **Auth resolution goes through `get-auth.ts`.** Never call `supabase.auth.getUser()` directly in a route — always go through the helper so the internal `users` row is resolved and cached for the request.
3. **Request validation is Zod-first.** Schemas live in `src/lib/validations/`; the route handler parses, the handler body receives a typed object.
4. **Optional services check their env var at call time.** Before calling Stripe / Inngest / Resend, test `if (!env.STRIPE_SECRET_KEY) return { success: false, error: … }`. Don't let a missing key take down the route. `src/env.ts` wraps non-essential vars in `.optional()` via Zod so services skip gracefully when unconfigured. *(This is a starter-local convention — absorbed from the v3 Hard Rule #4, which was retired in v4 because it didn't generalise beyond Next.js.)*
5. **Rate limits are per-user.** `rate-limit.ts` uses the authenticated `users.id`; unauthenticated routes use the IP. Default: 60 req/min.
6. **Australian spelling** in all prose, comments, error messages, and UI copy. Enforced by the repo-wide rule check (Hard Rule 1).

## Clean-boot contract (Hard Rule 2)

The starter must pass all four commands with zero errors, from a clean
`pnpm install`:

```bash
pnpm type-check
pnpm lint
pnpm test:ci
pnpm check:all   # runs the three above in sequence
```

If any command fails on `main`, the starter is broken — fix before
merging anything else.

## Do NOT touch without review

| File | Why |
|---|---|
| `src/lib/api-response.ts` | Defines the API contract. Changing this breaks every route. |
| `src/lib/auth/get-auth.ts` | Auth resolution. Breaking this breaks the entire app. |
| `src/middleware.ts` | Supabase session refresh + auth gate. Wrong logic here silently logs everyone out. |
| `src/env.ts` | Env validation. Starter-local convention: wrap non-essential services in `.optional()` so they skip gracefully. |
| `drizzle.config.ts` + `supabase/migrations/` | Migration ordering matters; never reorder committed migrations. |

## Common tasks

- **Add a new env var** → declare in `src/env.ts` (mark `.optional()` unless essential), document in `.env.example`.
- **Add a new API route** → create `src/app/api/<path>/route.ts`, define request schema in `src/lib/validations/`, return via `api-response.ts`.
- **Add a new table** → update `src/lib/db/schema/`, run `pnpm db:generate`, commit the generated SQL, never edit a migration after it lands.
- **Add a background job** → add an Inngest function under `src/lib/jobs/`, guard with an env check.
