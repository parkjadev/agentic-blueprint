import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { afterSignInUrl } from '@/lib/auth-routing';

/**
 * Post-auth routing hub.
 * After sign-up (or sign-in when additional routing is needed),
 * users land here and are redirected based on their role or onboarding status.
 *
 * Customise this for your app:
 * - Check if onboarding is complete → redirect to onboarding
 * - Check user role → redirect to role-specific dashboard
 * - Check organisation membership → redirect to org setup
 */
export default async function PostAuthPage() {
  const { userId } = await auth();

  if (!userId) {
    redirect('/sign-in');
  }

  // TODO: Add role-based or onboarding-based routing here
  // Example:
  // const user = await db.query.users.findFirst({ where: eq(users.clerkId, userId) });
  // if (!user?.onboardingComplete) redirect('/onboarding');
  // if (user?.role === 'admin') redirect('/admin');

  redirect(afterSignInUrl);
}
