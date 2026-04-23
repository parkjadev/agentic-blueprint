# Contract — API Response Envelope

**Status:** Stable
**Last revised:** 2026-04-23

---

## Purpose

Every API endpoint that a project under the agentic-blueprint exposes — REST, RPC, or in-process — returns a response wrapped in a discriminated-union envelope. The envelope makes success and failure structurally distinct, so clients never need to guess from HTTP status codes, and makes the shape of errors uniform across the system.

Inherited from the retired v4 Next.js starter (`starters/nextjs/src/lib/api-response.ts`), generalised here to be stack-agnostic.

---

## Shape

Pseudo-type signature:

```
ApiResponse<T> =
  | { success: true;  data: T }
  | { success: false; error: { code: string; message: string; details?: object } }
```

JSON Schema (draft 2020-12):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ApiResponse",
  "oneOf": [
    {
      "type": "object",
      "required": ["success", "data"],
      "properties": {
        "success": { "const": true },
        "data":    {}
      },
      "additionalProperties": false
    },
    {
      "type": "object",
      "required": ["success", "error"],
      "properties": {
        "success": { "const": false },
        "error": {
          "type": "object",
          "required": ["code", "message"],
          "properties": {
            "code":    { "type": "string" },
            "message": { "type": "string" },
            "details": { "type": "object" }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  ]
}
```

- `data` is the feature-specific payload. Schema is defined per endpoint, not in this contract.
- `error.code` is one of the values defined in [`error-taxonomy.md`](./error-taxonomy.md). Not a free-form string.
- `error.message` is a human-readable explanation. Safe to show to an end user; no PII, no stack traces.
- `error.details` is optional structured context (validation failures, retry-after hints, etc.).

---

## Behaviour

1. **Never bypass the envelope.** Returning a raw payload on success and an envelope on failure defeats the type safety and forces clients to handle two shapes. If a framework emits raw payloads by default, wrap every handler.
2. **HTTP status codes still matter**, but the envelope is the source of truth. The recommended mapping:
   - `success: true` → HTTP 200, 201, or 204 (2xx)
   - `success: false, code: "UNAUTHENTICATED"` → HTTP 401
   - `success: false, code: "FORBIDDEN"` → HTTP 403
   - `success: false, code: "NOT_FOUND"` → HTTP 404
   - `success: false, code: "VALIDATION_ERROR"` → HTTP 400 or 422
   - `success: false, code: "RATE_LIMITED"` → HTTP 429
   - `success: false, code: "INTERNAL_ERROR"` → HTTP 500
3. **Exceptions become `INTERNAL_ERROR` responses**, not HTTP 500 with a bare error message. A handler's top-level `catch` returns an envelope with a redacted `message` and logs the full exception server-side.
4. **The client unwraps**: branches on `success`, type-narrows `data` or `error`, never reads both.

---

## Examples

Success case (user fetch):

```json
{
  "success": true,
  "data": {
    "id": "u_01HK7GQR9N3Z4A7V5YXM8D2F1B",
    "email": "alex@example.com",
    "displayName": "Alex"
  }
}
```

Validation failure:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The email address is not in a valid format.",
    "details": {
      "fieldErrors": {
        "email": ["Must be a valid email address."]
      }
    }
  }
}
```

---

## References

- [`error-taxonomy.md`](./error-taxonomy.md) — canonical `error.code` values
- [`auth-token.md`](./auth-token.md) — `UNAUTHENTICATED` / `FORBIDDEN` context
- Retired source: `git show 3bb4c27:starters/nextjs/src/lib/api-response.ts`
- Related principle: `docs/principles/05-descriptive-profiles.md` — this contract describes structure, not implementation
