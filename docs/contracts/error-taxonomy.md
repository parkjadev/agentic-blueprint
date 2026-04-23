# Contract — Error Taxonomy

**Status:** Stable
**Last revised:** 2026-04-23

---

## Purpose

Defines the canonical set of error codes returned via the `ApiResponse.error.code` field. A fixed vocabulary prevents semantically-equivalent errors from drifting into distinct codes across endpoints and languages. Consumers branch on the code, not on the message.

---

## Shape

`error.code` is a string drawn from this enumeration. New codes require a `[release]` commit and a note in the appropriate `_archive/` pointer if retiring an existing code.

| Code | Semantics | Typical HTTP status |
|---|---|---|
| `UNAUTHENTICATED` | No valid session or token; client must authenticate | 401 |
| `FORBIDDEN` | Authenticated but not authorised for this resource or action | 403 |
| `NOT_FOUND` | Requested resource does not exist (or is hidden to this caller) | 404 |
| `CONFLICT` | Request conflicts with current server state (duplicate create, stale update) | 409 |
| `VALIDATION_ERROR` | Request failed schema or business-rule validation | 400 or 422 |
| `RATE_LIMITED` | Caller has exceeded a rate limit; retry after `details.retryAfter` seconds | 429 |
| `PAYLOAD_TOO_LARGE` | Request body exceeds size limit | 413 |
| `UNSUPPORTED_OPERATION` | The operation is recognised but not implemented in this context | 405 or 501 |
| `EXTERNAL_SERVICE_ERROR` | A required downstream service (payment, email, AI API) failed | 502 or 503 |
| `INTERNAL_ERROR` | Unhandled exception; the client should retry or give up. Server logs full detail. | 500 |

JSON Schema fragment (embeddable inside the ApiResponse error object):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ErrorCode",
  "type": "string",
  "enum": [
    "UNAUTHENTICATED",
    "FORBIDDEN",
    "NOT_FOUND",
    "CONFLICT",
    "VALIDATION_ERROR",
    "RATE_LIMITED",
    "PAYLOAD_TOO_LARGE",
    "UNSUPPORTED_OPERATION",
    "EXTERNAL_SERVICE_ERROR",
    "INTERNAL_ERROR"
  ]
}
```

---

## Behaviour

1. **Distinguish authentication from authorisation.** `UNAUTHENTICATED` is "I don't know who you are"; `FORBIDDEN` is "I know who you are, and you can't do this." These are different failure modes with different remediation.
2. **`NOT_FOUND` is overloaded with `FORBIDDEN` on purpose** for resources the caller shouldn't know exist. A public-facing API that leaks "resource X exists but you can't see it" via `FORBIDDEN` may prefer `NOT_FOUND` as the safer leak-resistant default. Use judgement per endpoint; document the choice in the feature spec.
3. **`VALIDATION_ERROR.details.fieldErrors`** is the canonical shape for field-level validation feedback. Keys are dotted field paths (`"profile.email"`); values are arrays of human-readable messages. Non-field errors use `details.formErrors: string[]`.
4. **`RATE_LIMITED.details`** should include `retryAfter: number` in seconds, and optionally `limit` and `window`.
5. **`INTERNAL_ERROR.message`** is redacted ("An unexpected error occurred. Please try again.") and never contains stack traces, internal identifiers, or dependency names. The full exception is server-side only.

---

## Examples

Authorisation failure with resource context:

```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "You do not have permission to modify this workspace.",
    "details": { "workspaceId": "w_01HK..." }
  }
}
```

Rate-limit response:

```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMITED",
    "message": "Too many requests.",
    "details": { "retryAfter": 30, "limit": 60, "window": "1m" }
  }
}
```

---

## References

- [`api-response.md`](./api-response.md) — the envelope that carries these codes
- [`auth-token.md`](./auth-token.md) — `UNAUTHENTICATED` / `FORBIDDEN` context
