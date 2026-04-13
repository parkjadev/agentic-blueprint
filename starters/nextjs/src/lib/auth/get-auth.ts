import { eq } from 'drizzle-orm';
import { db } from '@/lib/db';
import { users } from '@/lib/db/schema';
import { createClient } from '@/lib/supabase/server';
import type { AuthUser } from '@/types';

/**
 * Unified authentication resolver.
 *
 * Works for both web (cookie) and mobile (Bearer token) — Supabase handles
 * both transparently via @supabase/ssr.
 *
 * This is the single entry point for auth across all API routes and server actions.
 */
export async function getAuth(): Promise<AuthUser | null> {
  const supabase = await createClient();
  const {
    data: { user: authUser },
  } = await supabase.auth.getUser();

  if (!authUser) {
    return null;
  }

  // Look up the application profile (roles, status, etc.)
  const user = await db.query.users.findFirst({
    where: eq(users.id, authUser.id),
  });

  if (!user || user.status !== 'active') {
    return null;
  }

  return {
    id: user.id,
    email: user.email,
    name: user.name,
    role: user.role,
    status: user.status,
  };
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
