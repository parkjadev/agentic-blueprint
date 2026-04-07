/**
 * Reset database: truncate all tables and reseed with test data.
 *
 * Usage: pnpm tsx scripts/reset-db.ts
 *
 * WARNING: This destroys all data. Only use in development/preview environments.
 */

import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import { sql } from 'drizzle-orm';
import * as schema from '../src/lib/db/schema';

async function main() {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    throw new Error('DATABASE_URL is required');
  }

  // Safety check: refuse to run against production
  if (databaseUrl.includes('production') || databaseUrl.includes('main')) {
    throw new Error('Refusing to reset a production database. Check DATABASE_URL.');
  }

  const client = neon(databaseUrl);
  const db = drizzle(client, { schema });

  // eslint-disable-next-line no-console
  console.log('Truncating all tables...');

  // Truncate in reverse dependency order
  await db.execute(sql`TRUNCATE TABLE projects CASCADE`);
  await db.execute(sql`TRUNCATE TABLE users CASCADE`);

  // eslint-disable-next-line no-console
  console.log('Seeding test data...');

  // Seed users
  const [adminUser] = await db
    .insert(schema.users)
    .values({
      clerkId: 'clerk_seed_admin',
      email: 'admin@example.com',
      name: 'Admin User',
      role: 'admin',
      status: 'active',
    })
    .returning();

  const [regularUser] = await db
    .insert(schema.users)
    .values({
      clerkId: 'clerk_seed_user',
      email: 'user@example.com',
      name: 'Regular User',
      role: 'user',
      status: 'active',
    })
    .returning();

  // Seed projects
  await db.insert(schema.projects).values([
    {
      name: 'Example Project',
      description: 'A seed project owned by the admin',
      ownerId: adminUser!.id,
      status: 'active',
    },
    {
      name: 'Archived Project',
      description: 'A seed project that has been archived',
      ownerId: adminUser!.id,
      status: 'archived',
    },
    {
      name: 'User Project',
      description: 'A seed project owned by the regular user',
      ownerId: regularUser!.id,
      status: 'active',
    },
  ]);

  // eslint-disable-next-line no-console
  console.log('Done. Seeded 2 users and 3 projects.');
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error('Reset failed:', error);
  process.exit(1);
});
