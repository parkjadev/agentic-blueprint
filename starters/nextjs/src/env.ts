import { z } from 'zod';

// Required services — the app will not start without these
const requiredSchema = z.object({
  // Neon — primary database
  DATABASE_URL: z.string().url(),

  // Clerk — authentication
  NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY: z.string().min(1),
  CLERK_SECRET_KEY: z.string().min(1),
  CLERK_WEBHOOK_SECRET: z.string().min(1),

  // Upstash — rate limiting
  UPSTASH_REDIS_REST_URL: z.string().url(),
  UPSTASH_REDIS_REST_TOKEN: z.string().min(1),
});

// Optional services — gracefully skip when env vars are missing
const optionalSchema = z.object({
  // Stripe — payments (opt-in)
  STRIPE_SECRET_KEY: z.string().optional(),
  STRIPE_WEBHOOK_SECRET: z.string().optional(),
  NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY: z.string().optional(),

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

  // TODO: Add your optional service env vars here
});

const envSchema = requiredSchema.merge(optionalSchema);

export const env = envSchema.parse(process.env);

// Helper to check if optional services are configured
export const services = {
  stripe: Boolean(env.STRIPE_SECRET_KEY),
  r2: Boolean(env.R2_ACCOUNT_ID && env.R2_ACCESS_KEY_ID && env.R2_SECRET_ACCESS_KEY),
  inngest: Boolean(env.INNGEST_EVENT_KEY),
  resend: Boolean(env.RESEND_API_KEY),
  mobileJwt: Boolean(env.MOBILE_JWT_SECRET),
} as const;
