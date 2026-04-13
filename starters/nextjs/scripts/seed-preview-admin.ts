/**
 * Seed a preview admin user for Vercel preview deployments.
 * Creates (or updates) a single admin user that can be used for testing.
 *
 * Usage: pnpm tsx scripts/seed-preview-admin.ts
 *
 * Set PREVIEW_ADMIN_AUTH_ID in your environment to match a real Supabase Auth
 * user in your Supabase project (the same project preview deploys talk to).
 */

import postgres from 'postgres';
import { drizzle } from 'drizzle-orm/postgres-js';
import { eq } from 'drizzle-orm';
import * as schema from '../src/lib/db/schema';

const PREVIEW_ADMIN = {
  id: process.env.PREVIEW_ADMIN_AUTH_ID ?? '00000000-0000-0000-0000-000000000099',
  email: process.env.PREVIEW_ADMIN_EMAIL ?? 'admin@preview.example.com',
  name: 'Preview Admin',
  role: 'admin' as const,
  status: 'active' as const,
};

async function main() {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    throw new Error('DATABASE_URL is required');
  }

  const client = postgres(databaseUrl);
  const db = drizzle(client, { schema });

  // Check if admin already exists
  const existing = await db.query.users.findFirst({
    where: eq(schema.users.id, PREVIEW_ADMIN.id),
  });

  if (existing) {
    // Update existing admin
    await db
      .update(schema.users)
      .set({
        email: PREVIEW_ADMIN.email,
        name: PREVIEW_ADMIN.name,
        role: PREVIEW_ADMIN.role,
        status: PREVIEW_ADMIN.status,
        updatedAt: new Date(),
      })
      .where(eq(schema.users.id, PREVIEW_ADMIN.id));

    // eslint-disable-next-line no-console
    console.log(`Updated preview admin: ${PREVIEW_ADMIN.email}`);
  } else {
    // Create new admin
    await db.insert(schema.users).values(PREVIEW_ADMIN);

    // eslint-disable-next-line no-console
    console.log(`Created preview admin: ${PREVIEW_ADMIN.email}`);
  }

  await client.end();
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error('Seed failed:', error);
  process.exit(1);
});
