# API Spec — [Feature / Domain Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved
**Base Path:** `/api/[resource]`

---

## Overview

<!-- Brief description of this API domain. What resources does it manage?
     What are the key business rules? -->

TODO: Describe the API domain

## Authentication

<!-- Which auth methods does this API accept? Supabase Auth handles both web and mobile. -->

| Method | Header | Use Case |
|---|---|---|
| Supabase Session | Cookie (automatic via `@supabase/ssr`) | Web application |
| Supabase Auth | `Authorization: Bearer <token>` (via `supabase_flutter`) | Mobile application |

## Endpoints

<!-- One section per endpoint. Include method, path, auth, roles, request/response schemas,
     error cases, and any business rules.

     Standard response envelope:
     - Success: { success: true, data: T }
     - Paginated: { success: true, data: T[], pagination: { page, pageSize, total, totalPages } }
     - Error: { success: false, error: { message: string, code?: string } }
-->

### `GET /api/[resource]`

**Description:** List all resources (paginated)
**Auth:** Required | Optional | Public
**Roles:** Any | Admin | Owner

**Query Parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| `page` | integer | 1 | Page number (1-indexed) |
| `pageSize` | integer | 20 | Items per page (max 100) |
| `sort` | string | `createdAt` | Sort field |
| `order` | string | `desc` | Sort direction: `asc` or `desc` |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "createdAt": "ISO8601",
      "updatedAt": "ISO8601"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 42,
    "totalPages": 3
  }
}
```

**Errors:**
| Status | Condition |
|---|---|
| 401 | Not authenticated (when auth required) |
| 422 | Invalid query parameters |

---

### `GET /api/[resource]/[id]`

**Description:** Get a single resource by ID
**Auth:** Required
**Roles:** Owner or Admin

**Path Parameters:**

| Param | Type | Description |
|---|---|---|
| `id` | uuid | Resource identifier |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601"
  }
}
```

**Errors:**
| Status | Condition |
|---|---|
| 401 | Not authenticated |
| 403 | Not owner and not admin |
| 404 | Resource not found |

---

### `POST /api/[resource]`

**Description:** Create a new resource
**Auth:** Required
**Roles:** Any authenticated

**Request Body:**
```json
{
  "name": "string (required, 1-255 chars)"
}
```

<!-- Validate with Zod. Schema should live in src/lib/validations/. -->

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "ownerId": "uuid",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601"
  }
}
```

**Errors:**
| Status | Condition |
|---|---|
| 400 | Validation failed |
| 401 | Not authenticated |
| 409 | Duplicate (if uniqueness constraint) |

---

### `PUT /api/[resource]/[id]`

**Description:** Update an existing resource
**Auth:** Required
**Roles:** Owner or Admin

**Request Body:**
```json
{
  "name": "string (optional, 1-255 chars)"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string (updated)",
    "updatedAt": "ISO8601 (updated)"
  }
}
```

**Errors:**
| Status | Condition |
|---|---|
| 400 | Validation failed |
| 401 | Not authenticated |
| 403 | Not owner and not admin |
| 404 | Resource not found |

---

### `DELETE /api/[resource]/[id]`

**Description:** Delete a resource
**Auth:** Required
**Roles:** Owner or Admin

**Response (204):** No content

**Errors:**
| Status | Condition |
|---|---|
| 401 | Not authenticated |
| 403 | Not owner and not admin |
| 404 | Resource not found |

---

## Rate Limiting

<!-- Define rate limits per endpoint or per group. Uses in-memory rate limiter
     (upgrade to Upstash Redis for distributed rate limiting if needed). -->

| Scope | Limit | Window |
|---|---|---|
| Authenticated (default) | 100 requests | 60 seconds |
| Public endpoints | 20 requests | 60 seconds |
| Write operations | 10 requests | 60 seconds |

## Business Rules

<!-- Domain-specific rules that affect API behaviour. List as bullet points. -->

- TODO: List business rules

<!-- Example:
- Users can only create up to 50 projects on the free plan
- Soft delete: records are marked as `deleted` rather than removed from the database
- Name must be unique per owner (not globally unique)
-->

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
