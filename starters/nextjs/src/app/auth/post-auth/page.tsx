import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { afterSignInUrl } from '@/lib/auth-routing';

/**
 * Post-auth routing hub.
 * After sign-up (or sign-in when additional routing is needed),
 * users land here and are redirected based on their role or onboarding status.
 *
 * Customise this for your app:
 * - Check if onboarding is complete -> redirect to onboarding
 * - Check user role -> redirect to role-specific dashboard
 * - Check organisation membership -> redirect to org setup
 */
export default async function PostAuthPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect('/sign-in');
  }

  // TODO: Add role-based or onboarding-based routing here
  // Example:
  // const profile = await db.query.users.findFirst({ where: eq(users.id, user.id) });
  // if (!profile?.onboardingComplete) redirect('/onboarding');
  // if (profile?.role === 'admin') redirect('/admin');

  redirect(afterSignInUrl);
}
