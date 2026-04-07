import type { UserRole } from '@/types';

// Route definitions for auth-based routing
// Customise these for your application

/** Routes that require no authentication */
export const publicRoutes = [
  '/',
  '/api/health',
  '/api/webhooks/(.*)',
];

/** Routes that are part of the auth flow */
export const authRoutes = [
  '/sign-in(.*)',
  '/sign-up(.*)',
  '/auth/(.*)',
];

/** Where to redirect after sign-in */
export const afterSignInUrl = '/dashboard';

/** Where to redirect after sign-up */
export const afterSignUpUrl = '/auth/post-auth';

/** Role-based route access */
export const roleRoutes: Record<string, UserRole[]> = {
  '/admin(.*)': ['admin'],
  // TODO: Add role-restricted routes
};

/**
 * Check if a user role has access to a given path.
 */
export function hasRouteAccess(path: string, role: UserRole): boolean {
  for (const [pattern, allowedRoles] of Object.entries(roleRoutes)) {
    if (new RegExp(`^${pattern}$`).test(path)) {
      return allowedRoles.includes(role);
    }
  }
  // No role restriction found — allow access
  return true;
}
