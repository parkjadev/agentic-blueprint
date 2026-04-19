# 4. Optional services

> Hard Rule. Enforced by convention in `starters/nextjs/src/env.ts` (and
> the equivalent in any future starter).

## The rule

In starters, use optional Zod schemas in `env.ts` so services gracefully
skip when their env vars are missing. Only Supabase (auth + database) is
required; everything else — Stripe, Inngest, Resend, analytics — must
be opt-in.

## Why

New teams adopting the blueprint typically don't have every third-party
account provisioned on day one. Forcing them to stub `STRIPE_SECRET_KEY`
or `RESEND_API_KEY` before the app boots creates friction with no
payoff. A good starter degrades gracefully: no Stripe key → billing
routes return "not configured" instead of crashing on import.

## In practice

```ts
// starters/nextjs/src/env.ts (pattern)
export const env = z.object({
  NEXT_PUBLIC_SUPABASE_URL: z.string().url(),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  STRIPE_SECRET_KEY: z.string().optional(),
  RESEND_API_KEY: z.string().optional(),
}).parse(process.env);
```

- Required vars use `.min(1)` / `.url()` / etc.
- Optional vars use `.optional()`.
- Service modules check for their var at call time:
  `if (!env.STRIPE_SECRET_KEY) return { success: false, error: ... };`

## When it fails

- The `hard-rules-check` script greps `env.ts` for `.optional()`. If
  every field is required, the rule fires.
- Fix: demote non-essential vars to `.optional()` and add a guard at
  the call site.

## Related

- Rule 3 — optional services must not break clean boot.
- `starters/nextjs/src/env.ts` — the canonical example.
