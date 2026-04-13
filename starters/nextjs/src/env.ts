import { createEnv } from '@t3-oss/env-nextjs';
import { z } from 'zod';

export const env = createEnv({
  /*
   * Server-side env vars — never exposed to the browser.
   * Validated at build time and on the server at runtime.
   */
  server: {
    // Supabase — database (via Supavisor pooler)
    DATABASE_URL: z.string().url(),

    // Supabase — service role key (bypasses RLS, server-only)
    SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),

    // Stripe — payments (opt-in)
    STRIPE_SECRET_KEY: z.string().optional(),
    STRIPE_WEBHOOK_SECRET: z.string().optional(),

    // Inngest — background jobs (opt-in)
    INNGEST_EVENT_KEY: z.string().optional(),
    INNGEST_SIGNING_KEY: z.string().optional(),

    // Resend — transactional email (opt-in)
    RESEND_API_KEY: z.string().optional(),

    // TODO: Add your server-side env vars here
  },

  /*
   * Client-side env vars — accessible in both server and browser.
   * Must start with NEXT_PUBLIC_ (enforced by @t3-oss/env-nextjs).
   */
  client: {
    NEXT_PUBLIC_SUPABASE_URL: z.string().url(),
    NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
    NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY: z.string().optional(),

    // TODO: Add your client-side env vars here
  },

  /*
   * The actual runtime values. @t3-oss/env-nextjs validates these against the
   * schema above at build time and on the first server-side import.
   *
   * Only variables listed here are available — this is the allowlist.
   */
  runtimeEnv: {
    DATABASE_URL: process.env.DATABASE_URL,
    SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
    STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY,
    STRIPE_WEBHOOK_SECRET: process.env.STRIPE_WEBHOOK_SECRET,
    INNGEST_EVENT_KEY: process.env.INNGEST_EVENT_KEY,
    INNGEST_SIGNING_KEY: process.env.INNGEST_SIGNING_KEY,
    RESEND_API_KEY: process.env.RESEND_API_KEY,
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY:
      process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY,
  },

  /*
   * Skip validation during builds where env vars aren't available
   * (e.g. Docker builds, CI lint-only runs). Set SKIP_ENV_VALIDATION=true.
   */
  skipValidation: !!process.env.SKIP_ENV_VALIDATION,

  /*
   * Fail if a server-side env var is accidentally bundled into client code.
   * @t3-oss/env-nextjs checks this by default; this is the explicit opt-in.
   */
  emptyStringAsUndefined: true,
});

// Helper to check if optional services are configured
export const services = {
  stripe: Boolean(env.STRIPE_SECRET_KEY),
  inngest: Boolean(env.INNGEST_EVENT_KEY),
  resend: Boolean(env.RESEND_API_KEY),
} as const;
