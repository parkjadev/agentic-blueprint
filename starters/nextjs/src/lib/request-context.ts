import { headers } from 'next/headers';

export type RequestContext = {
  ip: string;
  userAgent: string;
  requestId: string;
};

/**
 * Extract request context from Next.js headers.
 * Used for rate limiting (IP), logging (user agent), and tracing (request ID).
 */
export async function getRequestContext(): Promise<RequestContext> {
  const headersList = await headers();

  const ip =
    headersList.get('x-forwarded-for')?.split(',')[0]?.trim() ??
    headersList.get('x-real-ip') ??
    'unknown';

  const userAgent = headersList.get('user-agent') ?? 'unknown';
  const requestId =
    headersList.get('x-request-id') ?? crypto.randomUUID();

  return { ip, userAgent, requestId };
}
