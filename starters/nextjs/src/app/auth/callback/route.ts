import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

/**
 * Auth callback handler for Supabase.
 * Used by OAuth flows (Google, GitHub, etc.) and email confirmation links.
 * Exchanges the auth code for a session, then redirects.
 */
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get('code');
  const next = searchParams.get('next') ?? '/dashboard';

  // Prevent open-redirect attacks — only allow relative paths
  const safePath = next.startsWith('/') ? next : '/dashboard';

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      return NextResponse.redirect(`${origin}${safePath}`);
    }
  }

  // If code exchange fails, redirect to sign-in with an error
  return NextResponse.redirect(`${origin}/sign-in?error=auth_callback_failed`);
}
