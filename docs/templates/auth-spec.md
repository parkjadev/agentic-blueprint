# Auth Spec — [Feature / Flow Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved
**Auth Provider:** Clerk (web) + JWT (mobile)

---

## Overview

<!-- Describe the authentication and authorisation requirements for this feature.
     Reference the system-wide auth architecture — this spec covers feature-specific auth. -->

TODO: Describe auth requirements for this feature

## Auth Architecture

<!-- The starter uses dual-mode authentication:
     1. Clerk sessions for web (cookie-based, managed by Clerk middleware)
     2. Mobile JWT for native apps (Bearer token in Authorization header)

     Both modes resolve to the same internal user record via get-auth.ts.
     This section documents which modes apply to this feature. -->

### Supported Auth Modes

| Mode | Mechanism | Resolved By |
|---|---|---|
| Web (Clerk) | Session cookie | `auth()` from `@clerk/nextjs/server` |
| Mobile (JWT) | `Authorization: Bearer <token>` | `verifyMobileJwt()` from `src/lib/mobile-jwt.ts` |

### Auth Resolution Flow

```
Request arrives
  ├─ Has Clerk session cookie?
  │   └─ Yes → resolve via Clerk → get internal user by clerkId
  ├─ Has Authorization: Bearer header?
  │   └─ Yes → verify JWT → get internal user by userId from token
  └─ Neither?
      └─ Return 401 Unauthenticated
```

## Role Matrix

<!-- Define which roles can perform which actions. Roles are stored on the user record
     and synced from Clerk via webhook. -->

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
     Clerk handles web sessions. Document any feature-specific session behaviour. -->

### Web Sessions (Clerk)

- **Creation:** Clerk sign-in/sign-up flow → session cookie set automatically
- **Duration:** Managed by Clerk (configurable in Clerk dashboard)
- **Revocation:** Sign out via Clerk, or admin revocation via Clerk dashboard
- **Post-auth routing:** `src/app/auth/post-auth/page.tsx` handles role-based redirects

### Mobile Sessions (JWT)

- **Creation:** `POST /api/auth/mobile/login` → returns signed JWT
- **Duration:** TODO: Define token expiry (e.g., 7 days)
- **Refresh:** TODO: Define refresh strategy (e.g., refresh token rotation)
- **Storage:** `flutter_secure_storage` on device
- **Revocation:** Token expiry or user record deactivation

## Webhook Sync

<!-- Clerk webhooks keep the local user table in sync with Clerk.
     Document which events this feature depends on. -->

| Clerk Event | Action | Handler |
|---|---|---|
| `user.created` | Create local user record | `POST /api/webhooks/clerk` |
| `user.updated` | Sync email, name, role changes | `POST /api/webhooks/clerk` |
| `user.deleted` | Soft-delete local user record | `POST /api/webhooks/clerk` |

<!-- Add feature-specific webhook handling if needed. -->

TODO: List additional webhook events or write "Standard webhook handling only"

## Middleware Configuration

<!-- Which routes are public, which require auth, which require specific roles?
     This maps to src/middleware.ts configuration. -->

### Route Protection

| Route Pattern | Auth Required | Role Required | Notes |
|---|---|---|---|
| `/api/health` | No | — | Always public |
| `/api/[resource]` GET | TODO | TODO | |
| `/api/[resource]` POST | Yes | Any | |
| `/api/[resource]/[id]` | Yes | Owner or Admin | |
| `/(dashboard)/**` | Yes | Any | Clerk middleware redirect |
| `/(marketing)/**` | No | — | Public pages |

## Security Considerations

<!-- Feature-specific security concerns. The starter handles CSRF, rate limiting,
     and CSP at the infrastructure level. Document anything additional here. -->

- TODO: List security considerations

<!-- Example:
- Ownership checks must happen at the database query level, not just in middleware
- Admin endpoints should be rate-limited more aggressively (10 req/min)
- File upload endpoints need size limits and content-type validation
- Sensitive fields (passwordHash) must never appear in API responses
-->

## Testing Auth Flows

<!-- How to test auth in development, CI, and on PR previews. -->

| Environment | Auth Setup |
|---|---|
| Development | Clerk dev instance, test users in seed data |
| CI | Mock auth via test helpers (`src/test/helpers.ts`) |
| Vercel preview (per PR) | Clerk dev instance, preview admin seeder runs as part of the build |
| Production | Clerk production instance |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
