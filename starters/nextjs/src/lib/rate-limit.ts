/**
 * In-memory sliding window rate limiter.
 *
 * Suitable for development and single-instance deployments. For production at
 * scale, upgrade to a distributed solution:
 *
 * - Upstash Redis (@upstash/ratelimit) — serverless, analytics, sliding window
 * - Vercel WAF rate limiting — zero-code, edge-based
 * - Supabase Edge Functions with Deno KV
 *
 * Note: In serverless environments (Vercel), the in-memory store resets on
 * each cold start. This means rate limiting is per-instance and approximate.
 */

type RateLimiterConfig = {
  maxRequests: number;
  windowMs: number;
};

type RateLimiter = {
  readonly config: RateLimiterConfig;
};

// Store: identifier -> array of request timestamps
const store = new Map<string, number[]>();

// Inline eviction: every N calls, purge expired entries to prevent unbounded growth.
let callCount = 0;
const EVICT_EVERY = 100;
const MAX_WINDOW_MS = 900_000; // longest window (login limiter: 15 min)

function maybeEvict() {
  callCount++;
  if (callCount < EVICT_EVERY) return;
  callCount = 0;
  const cutoff = Date.now() - MAX_WINDOW_MS;
  for (const [key, timestamps] of store) {
    if (timestamps[timestamps.length - 1]! <= cutoff) {
      store.delete(key);
    }
  }
}

function createLimiter(maxRequests: number, windowMs: number): RateLimiter {
  return { config: { maxRequests, windowMs } };
}

// Default rate limit: 100 requests per 60 seconds
export const rateLimiter = createLimiter(100, 60_000);

// Stricter limit for write operations: 10 requests per 60 seconds
export const writeRateLimiter = createLimiter(10, 60_000);

// Public endpoint limit: 20 requests per 60 seconds
export const publicRateLimiter = createLimiter(20, 60_000);

// Login / auth attempt limit: 5 requests per 15 minutes per IP.
// Intentionally much stricter — brute-force protection.
export const loginRateLimiter = createLimiter(5, 900_000);

export async function checkRateLimit(
  identifier: string,
  limiter: RateLimiter = rateLimiter,
): Promise<{ success: boolean; remaining: number }> {
  maybeEvict();

  const { maxRequests, windowMs } = limiter.config;
  const now = Date.now();
  const windowStart = now - windowMs;

  // Get existing timestamps, filter to current window
  const timestamps = (store.get(identifier) ?? []).filter((t) => t > windowStart);

  if (timestamps.length >= maxRequests) {
    store.set(identifier, timestamps);
    return { success: false, remaining: 0 };
  }

  timestamps.push(now);
  store.set(identifier, timestamps);

  return { success: true, remaining: maxRequests - timestamps.length };
}
