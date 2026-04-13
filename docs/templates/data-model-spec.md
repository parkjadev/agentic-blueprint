# Data Model Spec — [Feature / Domain Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved
**ORM:** Drizzle + Supabase PostgreSQL (connection via Supavisor pooler)

---

## Overview

<!-- What data does this feature manage? How does it relate to existing tables?
     Include a brief description of the domain model and its purpose. -->

TODO: Describe the data domain

## Enums

<!-- Define Postgres enums used by the tables below. Use pgEnum from Drizzle. -->

```typescript
// Example
export const projectStatusEnum = pgEnum('project_status', [
  'active',
  'archived',
  'deleted',
]);
```

TODO: Define enums or write "No new enums"

## Tables

<!-- One section per table. Include all columns, types, constraints, and defaults.
     Use Drizzle schema syntax — this should be copy-pasteable into schema.ts. -->

### `[table_name]`

<!-- Describe the table's purpose in one line. -->

```typescript
export const tableName = pgTable('table_name', {
  // Primary key — always UUID with defaultRandom()
  id: uuid('id').primaryKey().defaultRandom(),

  // Foreign keys — reference parent tables explicitly
  ownerId: uuid('owner_id')
    .notNull()
    .references(() => users.id),

  // Data columns
  name: varchar('name', { length: 255 }).notNull(),
  description: text('description'),
  status: statusEnum('status').notNull().default('active'),

  // Timestamps — always include both
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});
```

**Column Notes:**

| Column | Constraints | Notes |
|---|---|---|
| `id` | PK, UUID, auto-generated | Never user-supplied |
| `ownerId` | FK → users.id, NOT NULL | Cascade delete: TODO (cascade / set null / restrict) |
| `name` | NOT NULL, max 255 | Unique per owner? TODO |
| `status` | NOT NULL, default 'active' | Enum — see above |

## Relationships

<!-- Describe how tables relate to each other. Include cardinality and join patterns. -->

```
users 1 ──── * tableName     (user owns many records)
```

<!-- Drizzle relations definition: -->

```typescript
export const tableNameRelations = relations(tableName, ({ one }) => ({
  owner: one(users, {
    fields: [tableName.ownerId],
    references: [users.id],
  }),
}));
```

TODO: Define all relationships

## Indexes

<!-- Indexes beyond primary keys. Consider: foreign keys, sort columns, unique constraints,
     and any columns used in WHERE clauses. -->

```typescript
// Example
export const tableNameIndexes = {
  ownerIdx: index('table_name_owner_idx').on(tableName.ownerId),
  statusIdx: index('table_name_status_idx').on(tableName.status),
  // Composite unique constraint
  uniqueNamePerOwner: uniqueIndex('table_name_unique_name_owner')
    .on(tableName.ownerId, tableName.name),
};
```

TODO: Define indexes

## Constraints

<!-- Business-level constraints beyond what the schema enforces.
     These may need application-level validation or database triggers. -->

- TODO: List constraints

<!-- Example:
- Users cannot have more than 50 active projects (enforced in application layer)
- Project names must be unique per owner (enforced by database unique index)
- Deleted projects are soft-deleted (status = 'deleted') — never hard-deleted
-->

## Migration Plan

<!-- How will this migration be applied? Order matters for foreign key dependencies. -->

### Steps

1. Create enum(s)
2. Create table(s) — order by dependency (parent tables first)
3. Create indexes
4. Backfill data (if modifying existing tables)

### Rollback

<!-- What does rolling back look like? Can we drop the table cleanly or are there dependencies? -->

- [ ] Migration is additive only (safe to roll back by dropping new objects)
- [ ] No existing data is modified
- [ ] Tested on Supabase dev project

## Seed Data

<!-- Example data for development and testing. Used by scripts/reset-db.ts and test helpers. -->

```typescript
// Example seed
const seedProjects = [
  { name: 'My First Project', ownerId: seedUsers[0].id, status: 'active' },
  { name: 'Archived Project', ownerId: seedUsers[0].id, status: 'archived' },
];
```

TODO: Define seed data

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
