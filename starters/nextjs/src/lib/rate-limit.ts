import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';
import { env } from '@/env';

// Sliding window rate limiter using Upstash Redis
const redis = new Redis({
  url: env.UPSTASH_REDIS_REST_URL,
  token: env.UPSTASH_REDIS_REST_TOKEN,
});

// Default rate limit: 100 requests per 60 seconds
export const rateLimiter = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(100, '60 s'),
  analytics: true,
  prefix: 'ratelimit',
});

// Stricter limit for write operations: 10 requests per 60 seconds
export const writeRateLimiter = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(10, '60 s'),
  analytics: true,
  prefix: 'ratelimit:write',
});

// Public endpoint limit: 20 requests per 60 seconds
export const publicRateLimiter = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(20, '60 s'),
  analytics: true,
  prefix: 'ratelimit:public',
});

// Login / auth attempt limit: 5 requests per 15 minutes per IP.
// Intentionally much stricter than the general rate limiter — brute-force
// login attempts are the #1 reason to have per-endpoint limits.
export const loginRateLimiter = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(5, '900 s'),
  analytics: true,
  prefix: 'ratelimit:login',
});

export async function checkRateLimit(
  identifier: string,
  limiter: Ratelimit = rateLimiter,
): Promise<{ success: boolean; remaining: number }> {
  const result = await limiter.limit(identifier);
  return { success: result.success, remaining: result.remaining };
}
