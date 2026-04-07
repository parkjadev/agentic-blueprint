# API Reference — [Project Name]

**Last Updated:** [YYYY-MM-DD]
**Base URL:** `https://example.com/api`

<!-- This is the full API catalogue. It should list every endpoint in the system,
     grouped by domain. Keep it up to date as endpoints are added or changed.

     For detailed specs on a specific feature's endpoints, see the feature's api-spec.md.
     This document is the single source of truth for "what endpoints exist". -->

---

## Authentication

All authenticated endpoints accept one of:

| Method | Mechanism | Header |
|---|---|---|
| Web (Clerk) | Session cookie | Automatic (set by Clerk) |
| Mobile (JWT) | Bearer token | `Authorization: Bearer <token>` |

Unauthenticated requests to protected endpoints return `401`.

## Response Envelope

All responses follow a consistent envelope:

**Success:**
```json
{
  "success": true,
  "data": { ... }
}
```

**Paginated:**
```json
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 42,
    "totalPages": 3
  }
}
```

**Error:**
```json
{
  "success": false,
  "error": {
    "message": "Human-readable error message",
    "code": "OPTIONAL_ERROR_CODE"
  }
}
```

---

## System

### `GET /api/health`

Health check endpoint. Always public, no auth required.

**Response (200):**
```json
{
  "status": "ok",
  "timestamp": "ISO8601"
}
```

---

## Auth (Mobile)

<!-- Endpoints for mobile JWT authentication. Web auth is handled entirely by Clerk. -->

### `POST /api/auth/mobile/login`

**Auth:** Public
**Description:** Authenticate a mobile user and return a signed JWT.

### `POST /api/auth/mobile/refresh`

**Auth:** Bearer token (expired OK)
**Description:** Refresh an expired JWT.

TODO: Add mobile auth endpoints when implemented

---

## Webhooks

### `POST /api/webhooks/clerk`

**Auth:** Webhook signature (svix)
**Description:** Receives Clerk user lifecycle events. Keeps local user table in sync.

**Events handled:** `user.created`, `user.updated`, `user.deleted`

TODO: Add additional webhook endpoints (Stripe, Inngest, etc.)

---

## [Domain Name]

<!-- Group endpoints by domain. Copy this section for each domain in your application. -->

### `GET /api/[resource]`

**Auth:** TODO (Public | Required)
**Description:** List resources (paginated)

| Param | Type | Default | Description |
|---|---|---|---|
| `page` | integer | 1 | Page number |
| `pageSize` | integer | 20 | Items per page (max 100) |

### `GET /api/[resource]/[id]`

**Auth:** Required
**Description:** Get a single resource by ID

### `POST /api/[resource]`

**Auth:** Required
**Description:** Create a new resource

### `PUT /api/[resource]/[id]`

**Auth:** Required (Owner or Admin)
**Description:** Update an existing resource

### `DELETE /api/[resource]/[id]`

**Auth:** Required (Owner or Admin)
**Description:** Delete a resource

---

<!-- Copy the domain section above for each resource in your application.
     Keep this document as the index — detailed request/response schemas
     belong in the feature's api-spec.md. -->

## Error Codes

<!-- Standardised error codes used across all endpoints. -->

| HTTP Status | Code | Meaning |
|---|---|---|
| 400 | `VALIDATION_ERROR` | Request body or params failed Zod validation |
| 401 | `UNAUTHENTICATED` | No valid session or token |
| 403 | `FORBIDDEN` | Authenticated but lacking required role or ownership |
| 404 | `NOT_FOUND` | Resource does not exist |
| 409 | `CONFLICT` | Duplicate or state conflict |
| 422 | `UNPROCESSABLE` | Valid syntax but semantically incorrect |
| 429 | `RATE_LIMITED` | Too many requests — retry after cooldown |
| 500 | `INTERNAL_ERROR` | Unexpected server error |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
