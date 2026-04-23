# Contract — Auth Token

**Status:** Stable
**Last revised:** 2026-04-23

---

## Purpose

Defines the shape of access and refresh tokens issued by a project's auth provider and carried between clients and the server. Stack-agnostic — works for JWT-based systems (most common), opaque-token + introspection systems, and Supabase/Auth0/Cognito-style providers that already issue JWTs.

Not a specification of how tokens are signed, rotated, or revoked — those are provider-specific and belong in the consuming project's auth spec.

---

## Shape

### Token pair

Every authenticated session holds two tokens:

| Token | Lifetime | Use |
|---|---|---|
| **Access token** | Short (5–60 minutes) | Presented on every API request; carries identity + permissions claims |
| **Refresh token** | Long (days–weeks) | Presented only to the auth endpoint to mint a new access token; never sent to general API endpoints |

### Access token — required claims

Access tokens that conform to this contract are JWTs (RFC 7519) with, at minimum, the following claims:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "AccessTokenClaims",
  "type": "object",
  "required": ["sub", "iat", "exp", "aud", "iss"],
  "properties": {
    "sub":   { "type": "string", "description": "Subject — stable user id" },
    "iat":   { "type": "integer", "description": "Issued at (Unix seconds)" },
    "exp":   { "type": "integer", "description": "Expiry (Unix seconds)" },
    "aud":   { "type": "string", "description": "Audience — the API identifier" },
    "iss":   { "type": "string", "description": "Issuer — the auth provider identifier" },
    "sid":   { "type": "string", "description": "Session id; distinguishes concurrent sessions for the same user" },
    "roles": { "type": "array", "items": { "type": "string" }, "description": "Role identifiers (e.g. admin, member)" },
    "scope": { "type": "string", "description": "Space-separated scope list (OAuth2 convention)" }
  }
}
```

- `sub` is the server's internal user id, not the email. Stable across email changes.
- `sid` allows session-level revocation without invalidating every token for a user.
- `roles` and `scope` are both optional — use one consistently per project. `roles` for coarse RBAC, `scope` for OAuth-style capability grants.

### Refresh token

Refresh tokens are opaque to the client. Their internal shape is the auth provider's concern. The contract only specifies the client-side invariants:

- Delivered once, at login or refresh; never re-emitted in response bodies after.
- Stored in an HTTP-only, Secure, SameSite cookie on web; in the OS keychain on mobile. **Never** in `localStorage`, `sessionStorage`, or AsyncStorage.
- Presented only to the `/auth/refresh` endpoint (or its provider equivalent).

---

## Behaviour

1. **Access tokens expire quickly.** The server validates `exp` on every request; an expired token returns `UNAUTHENTICATED` per [error-taxonomy](./error-taxonomy.md).
2. **Refresh is silent and idempotent.** When the client detects a 401 on an API call, it hits the refresh endpoint, retries the original request, and retains the user session. If refresh itself fails, the session is dead and the user re-authenticates.
3. **Revocation is session-id based.** Logout invalidates the `sid`; subsequent access tokens with that sid return `UNAUTHENTICATED` even before natural expiry. Revocation data is server-side — the token itself does not carry a revoked flag.
4. **Role and scope claims are advisory only.** The server re-validates authorisation against the current user record on every request. A stale `roles: ["admin"]` claim in a token does not grant access if the user has since been demoted.
5. **Rotation on refresh is recommended but optional.** Projects that need refresh-token rotation replace the refresh token on every refresh call; projects that accept the replay window keep the same refresh token until expiry. Document the choice in the project's auth spec.

---

## Examples

Decoded access token (header + payload — signature omitted):

```json
// Header
{ "alg": "EdDSA", "kid": "2026-04-key-1", "typ": "JWT" }

// Payload
{
  "sub": "u_01HK7GQR9N3Z4A7V5YXM8D2F1B",
  "iat": 1745366400,
  "exp": 1745370000,
  "aud": "api.example.com",
  "iss": "auth.example.com",
  "sid": "sess_01HK7GR1M8J9...",
  "roles": ["member"]
}
```

Unauthenticated response when the access token is expired:

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Your session has expired. Please sign in again.",
    "details": { "reason": "token_expired" }
  }
}
```

---

## References

- [`api-response.md`](./api-response.md) — envelope for auth-related error responses
- [`error-taxonomy.md`](./error-taxonomy.md) — `UNAUTHENTICATED`, `FORBIDDEN` codes
- RFC 7519 — JSON Web Tokens
- RFC 6749 §1.5 — OAuth 2.0 Refresh Token
