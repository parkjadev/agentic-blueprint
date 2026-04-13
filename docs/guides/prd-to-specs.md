# PRD → Technical Specs

How to decompose a PRD into technical specs, identify data model changes, and sequence the work. This is a two-surface workflow: think in Chat, write in Code.

**Primary surface:** Claude Desktop Chat → Claude Code (Terminal)
**Depends on:** A committed PRD (see `idea-to-prd.md`)
**Templates:** `docs/templates/technical-spec.md`, `docs/templates/data-model-spec.md`, `docs/templates/api-spec.md`, `docs/templates/auth-spec.md`

---

## Prerequisites

- A committed PRD in `docs/prd/[feature-name].md`
- Claude Desktop for the thinking phase
- Claude Code for the writing phase
- Familiarity with the spec templates in `docs/templates/`

---

## Step-by-Step

### 1. Review the PRD in Chat

**Surface:** Claude Desktop Chat (Projects)

Open a new conversation in your venture's project. Upload or paste the PRD:

> "Here's the PRD for [feature]. Help me decompose this into technical work. What are the major components? What order should we build them in?"

You're looking for Claude to identify:

- Data model changes (new tables, columns, enums)
- API endpoints (new routes, modified routes)
- Auth requirements (new roles, permissions, ownership checks)
- Background jobs (async processing, scheduled work)
- UI components (pages, forms, interactive elements)
- External integrations (third-party APIs, webhooks)

### 2. Identify Dependencies and Sequence

**Surface:** Claude Desktop Chat

Not everything can be built in parallel. Ask Claude to sequence the work:

> "What's the dependency order? What must exist before other parts can be built? Give me a build sequence."

A typical sequence:

1. Data model changes (tables, enums, migrations)
2. API endpoints (depends on data model)
3. Auth configuration (depends on API shape)
4. Background jobs (depends on data model + API)
5. UI components (depends on API)
6. Integration tests (depends on everything)

### 3. Decide on Spec Granularity

**Surface:** Claude Desktop Chat

For each major component, decide whether it needs its own spec:

> "Which of these components are complex enough to warrant a dedicated spec? Which can be covered in the main technical spec?"

Rules of thumb:

- **Dedicated data-model-spec.md** if you're adding more than 2 tables or modifying core tables
- **Dedicated api-spec.md** if you're adding more than 3 endpoints
- **Dedicated auth-spec.md** if you're introducing new roles or changing auth flows
- **Everything else** goes in the main `technical-spec.md`

### 4. Draft the Technical Spec in Chat

**Surface:** Claude Desktop Chat

For each spec you need, draft it in Chat first:

> "Let's draft the technical spec for [feature]. Use this structure: Overview, Data Model Changes, API Changes, Auth & Authorisation, Background Jobs, UI Changes, Testing Strategy, Rollout Plan."

Iterate until the approach feels right. Challenge assumptions:

- "What happens if this service is unavailable?"
- "How does this work for mobile users?"
- "What's the rollback plan if this breaks?"

### 5. Switch to Code — Write the Specs

**Surface:** Claude Code (Terminal)

This is the handoff. Open Claude Code in your repo:

> "Create the technical spec for [feature] based on our Chat discussion. Use the template at docs/templates/technical-spec.md. Here's the approach we agreed on: [paste summary from Chat]"

Claude Code will:

1. Read the template
2. Create `docs/specs/[feature-name]/technical-spec.md`
3. Fill in each section based on your summary
4. Use proper Drizzle schema syntax for data model sections
5. Use proper API route patterns for endpoint sections

### 6. Create Supporting Specs

**Surface:** Claude Code (Terminal)

If the feature needs dedicated specs:

> "Also create a data-model-spec.md for the new tables using the template at docs/templates/data-model-spec.md. Include the Drizzle schema, relationships, indexes, and migration plan."

> "Create an api-spec.md for the new endpoints using docs/templates/api-spec.md. Include full request/response schemas with Zod validation."

### 7. Review the Specs

**Surface:** Claude Code (Terminal) or VS Code Extension

Read through each spec in your editor. Check:

- [ ] Data model uses correct Drizzle syntax and follows existing patterns
- [ ] API endpoints follow the `ApiResponse<T>` envelope
- [ ] Auth matches the Supabase Auth pattern
- [ ] Testing strategy covers unit, integration, and E2E where needed
- [ ] Rollout plan includes preview-deploy validation and rollback trigger
- [ ] No domain-specific business logic leaking from other projects

### 8. Commit the Specs

**Surface:** Claude Code (Terminal)

```
> Commit the specs with message "docs: add [feature] technical specs"
```

### 9. Create the GitHub Issue

**Surface:** Claude Code (Terminal)

With specs committed, create the implementation issue:

```
> Create a GitHub issue for implementing [feature]. Reference the specs we just committed.
> Include: acceptance criteria from the PRD, link to the technical spec, estimated scope (S/M/L),
> and a checklist of the major implementation steps.
```

This creates a trackable work item that links the PRD → specs → implementation.

---

## Handoff

Specs are committed and the GitHub issue is created. Next: **implement the feature**.

→ Continue with `docs/guides/feature-workflow.md`

---

## Tips

- **Think in Chat, write in Code.** Chat is for exploring trade-offs and making decisions. Code is for producing version-controlled artefacts. Don't conflate the two.
- **Paste summaries, not transcripts.** When handing off from Chat to Code, paste a concise summary of the decisions — not the entire conversation. Code needs directives, not discussion.
- **Specs are living documents.** Update them as implementation reveals new information. A spec that diverges from reality is worse than no spec.
- **One spec per feature, not per file.** A feature's technical spec covers the whole feature. Only break out dedicated specs (data-model, api, auth) when the component is genuinely complex.

---

*See `docs/guides/claude-surfaces.md` for the full surface decision tree.*
