# Technical Spec — [Feature Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved
**Scope:** epic | feature | fix
**Parent:** [slug of parent PRD; omit if this is a standalone feature]
**PRD:** [Link to PRD]
**Issue:** [Link to GitHub issue]

> **Scope-aware sections.** `scope: fix` renders only *Problem*, *Root Cause*, *Fix*, and *Regression Test* sections — skip the rest. `scope: epic` renders all sections at system level with feature-level decomposition. `scope: feature` is the default full template.

---

## Overview

<!-- One paragraph summary: what are we building, why, and what's the expected outcome?
     Reference the PRD for full context — don't repeat it here. -->

TODO: Brief description of the feature and its purpose

## What's Already in Place (excluded from this plan)

<!-- The most expensive plan is one that re-discovers existing code. Before
     filling out the rest of this spec, read the relevant src/lib/* modules
     and list what's already built so the implementation phase doesn't
     re-explore. Every line below should be backed by a Read of an actual
     file — not a memory recall. See docs/principles/06-plan-before-code.md
     for the rationale and docs/guides/stage-2-plan.md for the workflow. -->

| Capability | Where it lives | Notes |
|---|---|---|
| TODO: e.g. Supabase Auth | `src/lib/auth/get-auth.ts:1-80` | Already handles web + mobile via supabase.auth.getUser() — no work needed |
| TODO: e.g. Rate limit factory | `src/lib/rate-limit.ts:15-60` | Has 3 limiters, need to add a 4th for this feature |

**Excluded from scope:** TODO: list capabilities that look related but are explicitly *not* being touched in this plan.

## Data Model Changes

<!-- New tables, columns, enums, indexes, or constraints.
     Use the exact Drizzle schema syntax you'll implement.
     If no data model changes, write "None" and explain why. -->

```typescript
// Example: new table
export const projects = pgTable('projects', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: varchar('name', { length: 255 }).notNull(),
  ownerId: uuid('owner_id').notNull().references(() => users.id),
  status: projectStatusEnum('status').notNull().default('active'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});
```

### Migration Strategy

<!-- How will the migration be applied? Any data backfill needed?
     Consider: zero-downtime deployment, rollback plan, preview branch testing.
     Destructive changes (drop/rename/type-change/NOT NULL) MUST follow expand-migrate-contract
     across multiple PRs — see CLAUDE.md Hard Rules. -->

- [ ] **Pre-launch?** If yes, the next three boxes don't apply — reseed the dev DB freely. The ceremony kicks in once you have users you can't safely lose.
- [ ] Migration is additive (no column drops, renames, or type changes)
- [ ] If destructive: split into expand → migrate → contract PRs
- [ ] Tested on the Supabase dev project before merging to `main`
- [ ] Rollback plan documented

## API Changes

<!-- New or modified endpoints. For each, specify method, path, auth requirements,
     request/response shapes. Reference api-spec.md for the full format. -->

### `POST /api/example`

**Auth:** Required (Supabase Auth session)
**Role:** Any authenticated user

**Request:**
```json
{
  "name": "string (required, 1-255 chars)"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "ownerId": "uuid",
    "createdAt": "ISO8601"
  }
}
```

**Errors:** 400 (validation), 401 (unauthenticated), 403 (forbidden)

## Auth & Authorisation

<!-- How does auth work for this feature? Which roles can access what?
     Reference auth-spec.md for the full auth architecture. -->

| Action | Required Role | Ownership Check |
|---|---|---|
| Create | Any authenticated | — |
| Read (own) | Any authenticated | `ownerId === currentUser.id` |
| Read (all) | Admin | — |
| Update | Any authenticated | `ownerId === currentUser.id` |
| Delete | Any authenticated | `ownerId === currentUser.id` |

## Background Jobs

<!-- Inngest functions triggered by this feature. If none, write "None".
     Include: event name, trigger, retry policy, expected duration. -->

TODO: List background jobs or write "None"

<!-- Example:
### `app/project.created`
**Trigger:** After successful project creation
**Action:** Send welcome email via Resend, create default project settings
**Retry:** 3 attempts, exponential backoff
**Duration:** < 5s
-->

## UI Changes

<!-- Describe page/component changes at a high level. Not a design doc —
     focus on what components are needed and where they fit in the app shell. -->

TODO: Describe UI changes or write "No UI changes"

## Testing Strategy

<!-- What tests will you write? Be specific about coverage boundaries. -->

### Unit Tests
- [ ] TODO: API route handler tests (happy path + error cases)

### Integration Tests
- [ ] TODO: Database operations with Supabase dev project

### E2E Tests
- [ ] TODO: Full user journey (if applicable)

## Rollout Plan

<!-- How will this be deployed? Feature flag? Staged rollout? Big bang?
     Include: preview verification steps, production monitoring, rollback trigger.
     Reminder: GitHub Flow — preview-per-PR is your "staging environment".

     Each phase below ends with an inline status marker: <!-- status: pending -->
     When the PR for that phase lands, run:
       claude-config/scripts/update-plan-status.sh <this-file> "Phase N" <pr-number>
     and the marker becomes <!-- status: shipped (#PR) -->.
     This is how the spec stays in sync with what's actually been built.
     See claude-config/hooks/post-merge.md for the hook config. -->

### Phase 1: Schema and types <!-- status: pending -->

- TODO: data model migration
- TODO: shared TypeScript types

### Phase 2: API <!-- status: pending -->

- TODO: route handlers
- TODO: Zod validation
- TODO: rate limiting

### Phase 3: UI <!-- status: pending -->

- TODO: pages and components

### Production rollout

1. **Preview:** PR opens → Vercel builds preview → run smoke tests against the preview URL
2. **Production:** Squash-merge to `main` → Vercel auto-deploys → verify `/api/health` and key endpoints
3. **Rollback trigger:** Error rate > 1% or P0 bug reported within 24h → Vercel "Promote previous deployment"

## Dependencies

<!-- External services, other features, or team decisions this spec depends on. -->

- TODO: List dependencies or write "None"

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | TODO: Open question | Name | YYYY-MM-DD |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
