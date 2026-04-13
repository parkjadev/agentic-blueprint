import { type NextRequest, NextResponse } from 'next/server';
import { updateSession } from '@/lib/supabase/middleware';
import { publicRoutes, authRoutes, afterSignInUrl } from '@/lib/auth-routing';

function matchesPattern(path: string, patterns: string[]): boolean {
  return patterns.some((pattern) => new RegExp(`^${pattern}$`).test(path));
}

export async function middleware(request: NextRequest) {
  const { supabaseResponse, supabase } = await updateSession(request);
  const path = request.nextUrl.pathname;

  // Public routes — no auth required
  if (matchesPattern(path, publicRoutes)) {
    return supabaseResponse;
  }

  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Auth routes (sign-in, sign-up) — redirect to dashboard if already signed in
  if (matchesPattern(path, authRoutes)) {
    if (user) {
      return NextResponse.redirect(new URL(afterSignInUrl, request.url));
    }
    return supabaseResponse;
  }

  // Protected routes — redirect to sign-in if not authenticated
  if (!user) {
    const signInUrl = new URL('/sign-in', request.url);
    signInUrl.searchParams.set('redirect_to', path);
    return NextResponse.redirect(signInUrl);
  }

  return supabaseResponse;
}

export const config = {
  matcher: [
    // Skip Next.js internals and static files
    '/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)',
    // Always run for API routes
    '/(api|trpc)(.*)',
  ],
};
