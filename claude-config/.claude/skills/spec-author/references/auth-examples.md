# Auth spec — worked examples

Short excerpts for `docs/templates/auth-spec.md`.

## Flow — good

```
### Login (email + password)

1. Client calls `supabase.auth.signInWithPassword({ email, password })`
2. Supabase returns a session (access + refresh tokens)
3. supabase-js (web) or supabase_flutter (mobile) persists the session
4. Client calls `/api/auth/me` with `Authorization: Bearer <access_token>`
5. Server validates the token via `supabase.auth.getUser(token)` and resolves to the internal `users` row via `get-auth.ts`

**Failure modes:**
- Invalid credentials → 401 `AUTH_INVALID_CREDENTIALS`
- Rate-limited → 429 `AUTH_RATE_LIMITED`
- Email not verified → 403 `AUTH_EMAIL_NOT_VERIFIED`
```

**Why it's good:** names the exact APIs; shows who persists the session; enumerates the failure modes with the error codes from the api-spec.

## Permissions — good

```
### Role matrix

| Action | anonymous | user | admin |
|---|---|---|---|
| GET /api/examples/:id (own) | ❌ | ✅ | ✅ |
| GET /api/examples/:id (other) | ❌ | ❌ | ✅ |
| DELETE /api/examples/:id | ❌ | own only | any |

Enforcement: RLS policies (see data-model-spec) + `get-auth.ts` role check.
```

**Why it's good:** roles, actions, and enforcement mechanism all visible in one table.

## Flow — bad

> Users can log in.

**Why it's bad:** no mechanism, no failure modes, no enforcement.
