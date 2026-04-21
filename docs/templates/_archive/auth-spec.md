> **Archived in v4.** This template was retired when `technical-spec.md` absorbed feature-level auth.
> New home: `docs/templates/technical-spec.md` § Auth & Authorisation
> Historical content preserved below.

---

# Auth Spec — [Feature / Flow Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved
**Auth Provider:** Supabase Auth (unified web + mobile)

---

## Overview

<!-- Describe the authentication and authorisation requirements for this feature.
     Reference the system-wide auth architecture — this spec covers feature-specific auth. -->

TODO: Describe auth requirements for this feature

## Auth Architecture

<!-- The starter uses Supabase Auth for both web and mobile:
     1. Web: @supabase/ssr reads session cookie, supabase.auth.getUser() resolves user
     2. Mobile: supabase_flutter sends Bearer token, same getUser() call validates

     Both modes resolve to the same Supabase Auth user (users.id IS the Auth UUID).
     This section documents which modes apply to this feature. -->

### Supported Auth Modes

| Mode | Mechanism | Resolved By |
|---|---|---|
| Web | Session cookie | `@supabase/ssr` reads cookie → `supabase.auth.getUser()` |
| Mobile | `Authorization: Bearer <token>` | `supabase_flutter` sends token → same `supabase.auth.getUser()` |

### Auth Resolution Flow

```
Request arrives
  ├─ Has Supabase session cookie? (web)
  │   └─ Yes → @supabase/ssr reads cookie → supabase.auth.getUser()
  ├─ Has Authorization: Bearer header? (mobile)
  │   └─ Yes → supabase.auth.getUser() validates token
  └─ Neither?
      └─ Return 401 Unauthenticated
```

## Role Matrix

<!-- Define which roles can perform which actions. Roles are stored on the user record
     and synced via database trigger on auth.users INSERT. -->

| Action | Public | User | Admin | Notes |
|---|---|---|---|---|
| TODO: List action | | | | |

<!-- Example:
| View public content | Yes | Yes | Yes | No auth required |
| Create resource | — | Yes | Yes | Any authenticated user |
| View own resources | — | Yes | Yes | Ownership check: ownerId === currentUser.id |
| View all resources | — | — | Yes | Admin only |
| Delete any resource | — | — | Yes | Admin only, soft delete |
-->

## Session Management

<!-- How are sessions created, maintained, and revoked?
     Supabase Auth handles sessions for both web and mobile. Document any feature-specific session behaviour. -->

### Web Sessions (Supabase Auth)

- **Creation:** Supabase sign-in/sign-up flow → session cookie set via `@supabase/ssr`
- **Duration:** Managed by Supabase Auth (configurable in Supabase dashboard)
- **Refresh:** Supabase session refresh middleware automatically refreshes expired sessions
- **Revocation:** Sign out via Supabase Auth, or admin revocation via Supabase dashboard
- **Post-auth routing:** `src/app/auth/post-auth/page.tsx` handles role-based redirects

### Mobile Sessions (Supabase Auth)

- **Creation:** `supabase_flutter` SDK handles sign-in/sign-up natively
- **Duration:** Managed by Supabase Auth (access token + refresh token)
- **Refresh:** `supabase_flutter` handles token refresh automatically
- **Storage:** `supabase_flutter` manages session persistence internally
- **Revocation:** Sign out via SDK, token expiry, or user record deactivation

## Webhook Sync

<!-- A PostgreSQL trigger on auth.users INSERT keeps the local user table in sync
     with Supabase Auth. No external webhook endpoint is needed. -->

| Auth Event | Action | Handler |
|---|---|---|
| New user signs up | Create local user record | PostgreSQL trigger `handle_new_user` on `auth.users` INSERT |
| User updates profile | Sync email, name, role changes | Application-level update (or additional trigger if needed) |
| User deleted | Soft-delete local user record | Application-level or trigger on `auth.users` DELETE |

<!-- users.id IS the Supabase Auth UUID — no separate clerkId column needed. -->

TODO: List additional trigger actions or write "Standard trigger handling only"

## Middleware Configuration

<!-- Which routes are public, which require auth, which require specific roles?
     This maps to src/middleware.ts configuration (Supabase session refresh middleware). -->

### Route Protection

| Route Pattern | Auth Required | Role Required | Notes |
|---|---|---|---|
| `/api/health` | No | — | Always public |
| `/api/[resource]` GET | TODO | TODO | |
| `/api/[resource]` POST | Yes | Any | |
| `/api/[resource]/[id]` | Yes | Owner or Admin | |
| `/(dashboard)/**` | Yes | Any | Supabase session refresh middleware redirect |
| `/(marketing)/**` | No | — | Public pages |

## Security Considerations

<!-- Feature-specific security concerns. The starter handles CSRF, rate limiting,
     and CSP at the infrastructure level. Document anything additional here. -->

- TODO: List security considerations

<!-- Example:
- Ownership checks must happen at the database query level, not just in middleware
- Admin endpoints should be rate-limited more aggressively (10 req/min)
- File upload endpoints need size limits and content-type validation
- Sensitive fields must never appear in API responses
-->

## Testing Auth Flows

<!-- How to test auth in development, CI, and on PR previews. -->

| Environment | Auth Setup |
|---|---|
| Development | Supabase local or dev project, test users in seed data |
| CI | Mock auth via test helpers (`src/test/helpers.ts`) |
| Vercel preview (per PR) | Supabase dev project, preview admin seeder runs as part of the build |
| Production | Supabase production project |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
