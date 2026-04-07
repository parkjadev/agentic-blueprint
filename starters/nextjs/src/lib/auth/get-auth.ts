import { auth } from '@clerk/nextjs/server';
import { headers } from 'next/headers';
import { eq } from 'drizzle-orm';
import { db } from '@/lib/db';
import { users } from '@/lib/db/schema';
import { verifyMobileJwt } from '@/lib/mobile-jwt';
import { services } from '@/env';
import type { AuthUser } from '@/types';

/**
 * Dual-mode authentication resolver.
 *
 * 1. Checks for a Clerk session (web) — resolved via cookie
 * 2. Falls back to mobile JWT (Bearer token) — if configured
 * 3. Returns null if neither is present
 *
 * This is the single entry point for auth across all API routes.
 */
export async function getAuth(): Promise<AuthUser | null> {
  // Try Clerk session first (web)
  const { userId: clerkId } = await auth();

  if (clerkId) {
    const user = await db.query.users.findFirst({
      where: eq(users.clerkId, clerkId),
    });

    if (!user || user.status !== 'active') {
      return null;
    }

    return {
      id: user.id,
      clerkId: user.clerkId,
      email: user.email,
      name: user.name,
      role: user.role,
      status: user.status,
    };
  }

  // Try mobile JWT (Bearer token)
  if (services.mobileJwt) {
    const headersList = await headers();
    const authHeader = headersList.get('authorization');

    if (authHeader?.startsWith('Bearer ')) {
      const token = authHeader.slice(7);

      try {
        const payload = await verifyMobileJwt(token);
        const user = await db.query.users.findFirst({
          where: eq(users.id, payload.userId),
        });

        if (!user || user.status !== 'active') {
          return null;
        }

        return {
          id: user.id,
          clerkId: user.clerkId,
          email: user.email,
          name: user.name,
          role: user.role,
          status: user.status,
        };
      } catch {
        // Invalid token — fall through to return null
      }
    }
  }

  return null;
}

/**
 * Require authentication — throws if not authenticated.
 * Use in route handlers where auth is mandatory.
 */
export async function requireAuth(): Promise<AuthUser> {
  const user = await getAuth();
  if (!user) {
    throw new Error('Unauthenticated');
  }
  return user;
}
