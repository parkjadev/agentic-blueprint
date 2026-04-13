import { createServerClient, type CookieOptions } from '@supabase/ssr';
import { cookies, headers } from 'next/headers';
import { env } from '@/env';

type CookieEntry = { name: string; value: string; options: CookieOptions };

/**
 * Create a Supabase client for use in Server Components, Route Handlers,
 * and Server Actions.
 *
 * Auth is resolved from two sources (checked in order):
 * 1. Cookies — web sessions managed by @supabase/ssr middleware
 * 2. Authorization: Bearer header — mobile sessions via supabase_flutter
 *
 * If a Bearer token is present, it is forwarded as a global header so that
 * supabase.auth.getUser() validates it server-side.
 */
export async function createClient() {
  const cookieStore = await cookies();
  const headerStore = await headers();

  // Extract Bearer token from Authorization header (mobile clients)
  const authHeader = headerStore.get('authorization');
  const bearerToken =
    authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : null;

  return createServerClient(
    env.NEXT_PUBLIC_SUPABASE_URL,
    env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    {
      global: {
        headers: bearerToken ? { Authorization: `Bearer ${bearerToken}` } : {},
      },
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet: CookieEntry[]) {
          try {
            for (const { name, value, options } of cookiesToSet) {
              cookieStore.set(name, value, options);
            }
          } catch {
            // setAll is called from a Server Component where cookies cannot
            // be set. This is safe to ignore — the middleware handles refresh.
          }
        },
      },
    },
  );
}

/**
 * Create a Supabase admin client with the service role key.
 * Bypasses RLS — use only for server-side operations that need full access
 * (e.g. creating users, admin queries).
 */
export function createAdminClient() {
  return createServerClient(
    env.NEXT_PUBLIC_SUPABASE_URL,
    env.SUPABASE_SERVICE_ROLE_KEY,
    {
      cookies: {
        getAll() {
          return [];
        },
        setAll() {
          // Admin client does not manage cookies
        },
      },
    },
  );
}
