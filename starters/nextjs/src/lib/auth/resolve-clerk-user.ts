import { eq } from 'drizzle-orm';
import { db } from '@/lib/db';
import { users } from '@/lib/db/schema';
import type { AuthUser, UserRole } from '@/types';

type ClerkWebhookUser = {
  id: string;
  email_addresses: Array<{ email_address: string }>;
  first_name: string | null;
  last_name: string | null;
  public_metadata?: {
    role?: UserRole;
  };
};

/**
 * Create or update a local user record from a Clerk webhook event.
 * Called by the Clerk webhook handler on user.created and user.updated events.
 */
export async function resolveClerkUser(clerkUser: ClerkWebhookUser): Promise<AuthUser> {
  const email = clerkUser.email_addresses[0]?.email_address ?? '';
  const name = [clerkUser.first_name, clerkUser.last_name].filter(Boolean).join(' ') || null;
  const role = clerkUser.public_metadata?.role ?? 'user';

  // Upsert: create if new, update if existing
  const existing = await db.query.users.findFirst({
    where: eq(users.clerkId, clerkUser.id),
  });

  if (existing) {
    const [updated] = await db
      .update(users)
      .set({ email, name, role, updatedAt: new Date() })
      .where(eq(users.clerkId, clerkUser.id))
      .returning();

    return {
      id: updated!.id,
      clerkId: updated!.clerkId,
      email: updated!.email,
      name: updated!.name,
      role: updated!.role,
      status: updated!.status,
    };
  }

  const [created] = await db
    .insert(users)
    .values({ clerkId: clerkUser.id, email, name, role })
    .returning();

  return {
    id: created!.id,
    clerkId: created!.clerkId,
    email: created!.email,
    name: created!.name,
    role: created!.role,
    status: created!.status,
  };
}
