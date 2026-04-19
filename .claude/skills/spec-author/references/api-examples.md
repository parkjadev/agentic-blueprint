# API spec — worked examples

Short excerpts for `docs/templates/api-spec.md`.

## Response envelope

All API endpoints return the standard envelope. Keep the two shapes mutually exclusive — never mix `data` and `error` in one response.

```json
// Success
{ "success": true, "data": { "id": "abc", "name": "example" } }

// Failure
{ "success": false, "error": { "code": "NOT_FOUND", "message": "Example not found" } }
```

## Endpoint entry — good

```
### GET /api/examples/:id

**Auth:** required (Bearer token)
**Rate limit:** 60/min per user
**Response 200:** ApiResponse<Example>
**Response 401:** ApiResponse<AuthError>
**Response 404:** ApiResponse<NotFoundError>

**Example (success):**
{ "success": true, "data": { "id": "abc", "name": "Example", "ownerId": "usr_123" } }
```

**Why it's good:** auth + rate limit + every documented status code + a concrete example.

## Endpoint entry — bad

```
GET /api/examples/:id — gets an example
```

**Why it's bad:** no auth, no rate limit, no error responses, no shape.

## Validation

- Every request body and every query-param shape must be defined as a Zod schema in the corresponding technical-spec.
- Error codes are enumerated — never free-form strings.
