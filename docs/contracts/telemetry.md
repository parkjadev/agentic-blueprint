# Contract — Telemetry

**Status:** Stable
**Last revised:** 2026-04-23

---

## Purpose

Defines a uniform envelope for two categories of observability output:

- **Structured logs** — per-request or per-job records, emitted continuously, queried ad hoc.
- **Events** — discrete product/user actions (`user.signed_up`, `invoice.paid`, `feature.toggled`) emitted sparingly for analytics and lifecycle automation.

A shared envelope makes it possible to ship logs to one sink and events to another without rewriting producers, and makes correlation (one `traceId` links a log line to the event it produced) trivial.

---

## Shape

### Structured log

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "LogRecord",
  "type": "object",
  "required": ["timestamp", "severity", "message", "traceId"],
  "properties": {
    "timestamp": { "type": "string", "format": "date-time", "description": "ISO 8601 with millisecond precision" },
    "severity":  { "type": "string", "enum": ["debug", "info", "warn", "error", "fatal"] },
    "message":   { "type": "string", "description": "Human-readable summary; no interpolated secrets" },
    "traceId":   { "type": "string", "description": "Request or job trace identifier" },
    "spanId":    { "type": "string", "description": "Span within the trace; optional" },
    "userId":    { "type": "string", "description": "Authenticated user id if available" },
    "requestId": { "type": "string", "description": "Per-request id; matches traceId when not distributed" },
    "featureFlags": { "type": "array", "items": { "type": "string" } },
    "error":     {
      "type": "object",
      "properties": {
        "code":    { "type": "string" },
        "message": { "type": "string" },
        "stack":   { "type": "string", "description": "Full stack trace; server-side only" }
      }
    },
    "attrs":     { "type": "object", "description": "Free-form structured context (bounded cardinality)" }
  }
}
```

### Event

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Event",
  "type": "object",
  "required": ["timestamp", "name", "traceId"],
  "properties": {
    "timestamp": { "type": "string", "format": "date-time" },
    "name":      { "type": "string", "pattern": "^[a-z][a-z0-9_]*\\.[a-z][a-z0-9_]*$", "description": "domain.action — e.g. user.signed_up" },
    "traceId":   { "type": "string" },
    "userId":    { "type": "string" },
    "sessionId": { "type": "string" },
    "source":    { "type": "string", "enum": ["web", "mobile", "server", "job", "webhook"] },
    "properties": { "type": "object", "description": "Event-specific payload; finite keyset per event name" }
  }
}
```

---

## Behaviour

1. **`traceId` is the universal correlation key.** A request-scoped `traceId` is generated at the edge (load balancer or entrypoint), threaded through every log and event the request produces, and returned to the client via the `x-trace-id` response header. A job-scoped `traceId` is minted when the job is scheduled.
2. **Severity levels have sharp meanings.** `debug` is for development only, stripped in production. `info` is expected traffic. `warn` is unexpected-but-handled. `error` is unexpected-and-a-user-saw-degraded-service. `fatal` is unrecoverable — the process dies.
3. **No secrets in logs.** Passwords, tokens, API keys, full credit-card numbers, and session cookies must never appear in `message`, `attrs`, or `properties`. Redact with `"***"` if a value must be referenced structurally.
4. **Events are named `<domain>.<action>`** with snake-case action verbs. Domains are nouns (`user`, `invoice`). Actions are past-tense verbs (`signed_up`, `paid`). This convention is enforced in the regex.
5. **Event `properties` schemas are per-event**, not part of this contract. Projects maintain an event catalogue. The envelope fields (timestamp, name, traceId, etc.) are universal.
6. **Log cardinality is bounded.** Avoid putting unbounded values (user ids, urls with path params) into `severity` or as dynamic log message templates. Structured `attrs` absorb cardinality without exploding the log index.

---

## Examples

Info log for a completed request:

```json
{
  "timestamp": "2026-04-23T02:45:12.478Z",
  "severity": "info",
  "message": "POST /api/workspaces completed",
  "traceId": "trace_01HK7GR4Z8P...",
  "userId": "u_01HK7GQR9N3Z...",
  "requestId": "req_01HK7GR4ZA...",
  "attrs": {
    "method": "POST",
    "path": "/api/workspaces",
    "statusCode": 201,
    "durationMs": 47
  }
}
```

Event for a user signing up:

```json
{
  "timestamp": "2026-04-23T02:45:12.462Z",
  "name": "user.signed_up",
  "traceId": "trace_01HK7GR4Z8P...",
  "userId": "u_01HK7GQR9N3Z...",
  "sessionId": "sess_01HK7GR4ZB...",
  "source": "web",
  "properties": {
    "signupMethod": "email",
    "referralSource": "google_ads"
  }
}
```

---

## References

- [`api-response.md`](./api-response.md) — `error.code` values appear inside `error.code` in log records
- [`error-taxonomy.md`](./error-taxonomy.md) — canonical error codes referenced from log `error.code`
- OpenTelemetry `traceparent` convention — compatible with this contract's `traceId` if projects adopt OTel
