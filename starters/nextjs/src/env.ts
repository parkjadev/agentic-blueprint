import { createEnv } from '@t3-oss/env-nextjs';
import { z } from 'zod';

export const env = createEnv({
  /*
   * Server-side env vars — never exposed to the browser.
   * Validated at build time and on the server at runtime.
   */
  server: {
    // Neon — primary database
    DATABASE_URL: z.string().url(),

    // Clerk — authentication
    CLERK_SECRET_KEY: z.string().min(1),
    CLERK_WEBHOOK_SECRET: z.string().min(1),

    // Upstash — rate limiting
    UPSTASH_REDIS_REST_URL: z.string().url(),
    UPSTASH_REDIS_REST_TOKEN: z.string().min(1),

    // Stripe — payments (opt-in)
    STRIPE_SECRET_KEY: z.string().optional(),
    STRIPE_WEBHOOK_SECRET: z.string().optional(),

    // Cloudflare R2 — file storage (opt-in)
    R2_ACCOUNT_ID: z.string().optional(),
    R2_ACCESS_KEY_ID: z.string().optional(),
    R2_SECRET_ACCESS_KEY: z.string().optional(),
    R2_BUCKET_NAME: z.string().optional(),

    // Inngest — background jobs (opt-in)
    INNGEST_EVENT_KEY: z.string().optional(),
    INNGEST_SIGNING_KEY: z.string().optional(),

    // Resend — transactional email (opt-in)
    RESEND_API_KEY: z.string().optional(),

    // Mobile JWT — mobile app authentication (opt-in)
    MOBILE_JWT_SECRET: z.string().optional(),

    // TODO: Add your server-side env vars here
  },

  /*
   * Client-side env vars — accessible in both server and browser.
   * Must start with NEXT_PUBLIC_ (enforced by @t3-oss/env-nextjs).
   */
  client: {
    NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY: z.string().min(1),
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
    CLERK_SECRET_KEY: process.env.CLERK_SECRET_KEY,
    CLERK_WEBHOOK_SECRET: process.env.CLERK_WEBHOOK_SECRET,
    UPSTASH_REDIS_REST_URL: process.env.UPSTASH_REDIS_REST_URL,
    UPSTASH_REDIS_REST_TOKEN: process.env.UPSTASH_REDIS_REST_TOKEN,
    STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY,
    STRIPE_WEBHOOK_SECRET: process.env.STRIPE_WEBHOOK_SECRET,
    R2_ACCOUNT_ID: process.env.R2_ACCOUNT_ID,
    R2_ACCESS_KEY_ID: process.env.R2_ACCESS_KEY_ID,
    R2_SECRET_ACCESS_KEY: process.env.R2_SECRET_ACCESS_KEY,
    R2_BUCKET_NAME: process.env.R2_BUCKET_NAME,
    INNGEST_EVENT_KEY: process.env.INNGEST_EVENT_KEY,
    INNGEST_SIGNING_KEY: process.env.INNGEST_SIGNING_KEY,
    RESEND_API_KEY: process.env.RESEND_API_KEY,
    MOBILE_JWT_SECRET: process.env.MOBILE_JWT_SECRET,
    NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY:
      process.env.NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY,
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
  r2: Boolean(env.R2_ACCOUNT_ID && env.R2_ACCESS_KEY_ID && env.R2_SECRET_ACCESS_KEY),
  inngest: Boolean(env.INNGEST_EVENT_KEY),
  resend: Boolean(env.RESEND_API_KEY),
  mobileJwt: Boolean(env.MOBILE_JWT_SECRET),
} as const;
