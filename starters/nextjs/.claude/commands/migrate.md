---
description: Generate a new Drizzle migration for a schema change and review it.
argument-hint: <short name — e.g. add-billing-usage>
allowed-tools: Bash, Read, Edit, Glob
---

# /migrate — Generate a Drizzle migration

Generates the SQL migration for the current `src/lib/db/schema/` diff
against the last committed migration.

## Arguments

- `$ARGUMENTS` — a short, hyphenated name describing the change
  (e.g. `add-billing-usage`, `backfill-user-status`).

## Steps

1. **Verify schema changes exist.** Run `git diff --name-only src/lib/db/schema/`.
   If empty, abort: there's nothing to migrate.
2. **Run drizzle-kit generate:**

   ```bash
   pnpm db:generate --name "$ARGUMENTS"
   ```

3. **Read the generated SQL** at `supabase/migrations/<timestamp>_<name>.sql`.
   Surface anything dangerous to the user:
   - `DROP TABLE`, `DROP COLUMN`
   - `ALTER TABLE ... NOT NULL` without a default on a table with
     existing rows
   - Index changes on large tables
4. **Never apply the migration automatically.** The human runs
   `pnpm db:push` when they're ready.
5. **Suggest a commit** — the generated SQL + the schema change belong
   in one commit.

## Don't

- Don't edit the generated migration by hand. If it's wrong, fix the
  schema and regenerate.
- Don't reorder or rewrite committed migrations — new changes go in
  new files.
- Don't run `pnpm db:push` against remote Supabase without explicit
  confirmation.
