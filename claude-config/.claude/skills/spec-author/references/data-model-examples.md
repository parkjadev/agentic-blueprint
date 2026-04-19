# Data-model spec — worked examples

Short excerpts for `docs/templates/data-model-spec.md`.

## Table entry — good

```
### examples

Stores generic project records owned by a user. No domain-specific semantics (Hard Rule #2).

| Column | Type | Constraints | Notes |
|---|---|---|---|
| id | uuid | PK, default gen_random_uuid() | |
| owner_id | uuid | FK → users(id), not null | cascade delete on owner removal |
| name | text | not null, length 1–120 | |
| status | text | not null, check (status in ('active','archived','deleted')) | |
| created_at | timestamptz | not null, default now() | |
| updated_at | timestamptz | not null, default now() | trigger: set on update |

**Indexes:** `(owner_id)`, `(status)` where status != 'deleted'

**RLS policies:**
- `read_own`: auth.uid() = owner_id
- `write_own`: auth.uid() = owner_id

**Migration file:** `supabase/migrations/<timestamp>_create_examples.sql`
```

**Why it's good:** every column has type + constraints + meaning; indexes and RLS are explicit; migration file is named.

## Table entry — bad

```
### examples

- id
- name
- data
```

**Why it's bad:** no types, no constraints, no RLS, no indexes, soft-typed `data` blob.
