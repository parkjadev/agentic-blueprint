# Technical Spec — .NET + Azure Bicep Starter

**Author:** Claude (spec-author)
**Date:** 2026-04-22
**Status:** Draft
**Scope:** feature
**Parent:** (none)
**PRD:** `docs/specs/add-dotnet-azure-bicep-Dg8yD/PRD.md`
**Issue:** (to be filed when this spec is approved)

> **Scope-aware sections.** This is a `scope: feature` spec. All default sections are rendered. `scope: fix`-only sections (Root Cause, Regression Test) are not applicable.

---

## Overview

This spec defines the implementation of `starters/dotnet-azure/` — a third reference starter alongside `starters/nextjs/` and `starters/flutter/`. The starter demonstrates how the blueprint's three-beat lifecycle (Spec → Ship → Signal) operates on a .NET 9 + Azure-native stack.

The deliverable is a generic, domain-free scaffold — not a product. It demonstrates: Microsoft Entra ID authentication, a `Widget` CRUD resource, PostgreSQL via EF Core 9 + managed identity, a modular Bicep IaC package (five child modules + one `main.bicep` orchestrator), and a GitHub Actions deploy workflow using OIDC federation. The existing `docs/guides/tool-reference.md` already references Azure Bicep + `az` CLI as a valid Profile A Ship-beat target; this starter is the concrete implementation behind that reference.

The starter is deliberately framed as "a reference implementation of Profile A on Azure" — one option, not a prescription. It coexists with the other two starters without displacing them.

## What's Already in Place (excluded from this plan)

| Capability | Where it lives | Notes |
|---|---|---|
| Sibling starter pattern: clean-boot contract, `CLAUDE.md` layout, `ApiResponse<T>` envelope convention | `starters/nextjs/CLAUDE.md` | Defines the clean-boot commands (`pnpm type-check`, `pnpm lint`, `pnpm test:ci`), the `{ success, data }` / `{ success, error }` envelope, and the `CLAUDE.md` structure this starter mirrors for .NET |
| Sibling starter pattern: project layout, feature folders, `ExampleProject` domain-neutral resource | `starters/flutter/CLAUDE.md` | `ExampleProject` is the direct analogue for the `Widget` resource in this starter; both are neutral CRUD examples with id, name, description, ownerId, status, timestamps |
| Profile A matrix referencing Azure Bicep + `az` CLI | `docs/guides/tool-reference.md` (Ship row, Profile A column) | States "Azure via Bicep + `az` CLI" as a common deployment option; this starter is the concrete implementation. Phase 4 of this spec adds a cross-reference back to this guide. |
| Hard Rules enforcement: Australian spelling, generic starters, templates protected | `CLAUDE.md` (root), `.claude/hooks/pre-commit-gate.sh` | Pre-commit gate runs `hard-rules-check`; any spec or starter file must pass AU-spelling and domain-logic checks. This spec is already subject to those checks. |
| `starter-verify` skill entry point | `.claude/skills/starter-verify/` (referenced in `CLAUDE.md`) | The `/ship` flow invokes this skill to verify the clean-boot contract on each starter. The .NET starter's clean-boot commands (`dotnet build`, `dotnet test`, `dotnet format --verify-no-changes`) will need to be registered in this skill's configuration during Phase 1. |
| Beat-aware prompts and subagent dispatch | `.claude/agents/spec-author`, `.claude/commands/` | Existing harness; no changes needed. This spec is authored via the standard `/spec feature` flow. |

**Excluded from scope:** modifications to `starters/nextjs/`, `starters/flutter/`, any `docs/templates/` file, the root `CLAUDE.md`, or existing hook scripts. Changes to `docs/guides/tool-reference.md` are limited to Phase 4 and consist of adding one cross-reference sentence only.

## Data Model Changes

The starter introduces one EF Core entity and its corresponding database migration.

```csharp
// starters/dotnet-azure/src/DotnetAzure.Api/Data/Entities/Widget.cs

public enum WidgetStatus
{
    Active,
    Archived,
    Deleted,
}

public sealed class Widget
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [MaxLength(255)]
    [Required]
    public string Name { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Description { get; set; }

    // Populated from the Entra JWT sub claim on creation.
    [Required]
    public string OwnerId { get; set; } = string.Empty;

    public WidgetStatus Status { get; set; } = WidgetStatus.Active;

    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;
}

// DbContext registration (AppDbContext.cs):
public DbSet<Widget> Widgets { get; set; }
// Index on OwnerId for efficient per-user queries.
modelBuilder.Entity<Widget>().HasIndex(w => w.OwnerId);
```

### Migration Strategy

- [ ] **Pre-launch.** This is a new starter with no users and no existing production data. The additive-only ceremony does not apply — the migration may be generated freely.
- [ ] Migration is additive. The `InitialCreate` migration creates the `Widgets` table from scratch; there are no drops, renames, or type changes.
- [ ] Migration file is committed to `starters/dotnet-azure/src/DotnetAzure.Api/Migrations/` and must not be edited after it lands on `main`.
- [ ] Local rollback plan: `dotnet ef database drop --force` + `dotnet ef database update` resets the local dev database.
- [ ] On Azure, the Container App startup sequence runs `dotnet ef database update` (or an equivalent `dbcontext-migrate` approach) before the first request is served, ensuring migrations apply before traffic arrives.

## API Changes

All endpoints use minimal APIs defined in `Program.cs` (or a companion `WidgetEndpoints.cs` mapped via `app.MapGroup`). All non-health endpoints require a valid Entra JWT bearer token.

### `GET /health`

**Auth:** None
**Role:** Public

**Response (200):**
```json
{ "status": "healthy" }
```

Used by: Azure Container Apps liveness probe, GitHub Actions smoke test.

---

### `GET /api/widgets`

**Auth:** Required (Entra JWT bearer)
**Role:** Any authenticated user

Returns all widgets owned by the authenticated user (`OwnerId == currentUser.sub`).

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "description": "string | null",
      "ownerId": "string",
      "status": "Active | Archived | Deleted",
      "createdAt": "ISO8601",
      "updatedAt": "ISO8601"
    }
  ]
}
```

**Errors:** 401 (missing or invalid JWT)

---

### `POST /api/widgets`

**Auth:** Required (Entra JWT bearer)
**Role:** Any authenticated user

**Request:**
```json
{
  "name": "string (required, 1–255 chars)",
  "description": "string (optional, max 1000 chars)"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "description": "string | null",
    "ownerId": "string",
    "status": "Active",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601"
  }
}
```

**Errors:** 400 (validation), 401 (unauthenticated)

---

### `GET /api/widgets/{id}`

**Auth:** Required (Entra JWT bearer)
**Role:** Owner only

**Response (200):** Same shape as a single element in the list response.

**Errors:** 401 (unauthenticated), 403 (not the owner), 404 (not found)

---

### `PATCH /api/widgets/{id}`

**Auth:** Required (Entra JWT bearer)
**Role:** Owner only

**Request:** Any subset of `name`, `description`, `status`.

**Response (200):** Full updated widget in `ApiResponse<T>` envelope.

**Errors:** 400 (validation), 401 (unauthenticated), 403 (not the owner), 404 (not found)

---

### `DELETE /api/widgets/{id}`

**Auth:** Required (Entra JWT bearer)
**Role:** Owner only

Soft-delete: sets `Status = WidgetStatus.Deleted`, does not remove the row.

**Response (200):**
```json
{ "success": true, "data": { "id": "uuid" } }
```

**Errors:** 401 (unauthenticated), 403 (not the owner), 404 (not found)

---

### `ApiResponse<T>` implementation

Defined in `src/DotnetAzure.Api/ApiResponse.cs`. Matches the envelope shape used by the Next.js and Flutter sibling starters:

```csharp
public sealed record ApiResponse<T>(bool Success, T? Data = default, ApiError? Error = null);
public sealed record ApiError(string Code, string Message);

// Success helper:
ApiResponse<T>.Ok(T data) => new(true, data);
// Error helper:
ApiResponse<object>.Fail(string code, string message) => new(false, Error: new(code, message));
```

## Auth & Authorisation

Authentication uses `Microsoft.Identity.Web` JWT bearer validation. The API validates tokens issued by the adopter's Entra tenant; no Supabase dependency.

**App registration requirements (adopters must create in their tenant):**

1. **API app registration** — Expose an API scope (e.g. `api://<client-id>/widgets.readwrite`). Record the Application (client) ID and tenant ID for `appsettings.json`.
2. **Client app registration** — Grants the API scope. Used for local testing and by first-party consumers. Not required for the API itself.
3. **Managed identity** (Entra service principal) — Provisioned by `identity.bicep`; used by the Container App to access Postgres and ACR. No interactive auth.

**`appsettings.json` configuration:**
```json
{
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "TenantId": "PLACEHOLDER — set via environment variable AZURE_TENANT_ID",
    "ClientId": "PLACEHOLDER — set via environment variable AZURE_CLIENT_ID",
    "Audience": "api://<client-id>"
  }
}
```

Real values are injected as Container App environment variables; the placeholder strings in `appsettings.json` are safe to commit.

**Authorisation table:**

| Action | Requirement | Ownership Check |
|---|---|---|
| `GET /health` | No auth | — |
| `GET /api/widgets` | Authenticated | Returns only widgets where `OwnerId == currentUser.sub` |
| `POST /api/widgets` | Authenticated | `OwnerId` set to `currentUser.sub` on creation |
| `GET /api/widgets/{id}` | Authenticated | `OwnerId == currentUser.sub`; 403 otherwise |
| `PATCH /api/widgets/{id}` | Authenticated | `OwnerId == currentUser.sub`; 403 otherwise |
| `DELETE /api/widgets/{id}` | Authenticated | `OwnerId == currentUser.sub`; 403 otherwise |

`currentUser.sub` is the Entra Object ID extracted from the `sub` claim of the validated JWT.

## Background Jobs

None in v1.

A Container Apps Job or Azure Function could be introduced in a future iteration for workloads such as scheduled widget archival or async processing. The Bicep module set is designed to accommodate a `jobs.bicep` module addition without changes to the existing modules.

## UI Changes

No UI changes — this starter is API-only. Web and mobile clients consume the API directly. The `starters/nextjs/` and `starters/flutter/` starters are the appropriate UI counterparts.

## Testing Strategy

### Unit Tests

All unit tests live in `starters/dotnet-azure/src/DotnetAzure.Tests/`. They must run without any external services (no database, no Azure, no network) so the clean-boot contract holds from a plain checkout.

- [ ] Handler tests for each of the six widget endpoints: happy path + each error case (401, 403, 404, 400 validation).
- [ ] `ApiResponse<T>` helpers: confirm the `Ok` and `Fail` factory methods serialise to the expected JSON shape.
- [ ] `WidgetStatus` enum serialisation: confirm `System.Text.Json` serialises enum values as strings.
- [ ] Auth middleware bypass: `GET /health` must return 200 without a bearer token; all other endpoints must return 401 without one.

Unit tests use `WebApplicationFactory<Program>` with the authentication handler replaced by a `TestAuthHandler` (injects a configurable test identity without requiring Entra).

### Integration Tests

- [ ] Widget CRUD happy path against a real Postgres instance using Testcontainers (`Testcontainers.PostgreSql` NuGet package). These tests start a Docker container, apply the EF Core migration, run the CRUD cycle, and assert persistence.
- [ ] EF Core migration smoke test: `dotnet ef database update` on a fresh Testcontainers Postgres database exits zero.
- [ ] Ownership enforcement: confirm that a request authenticated as user A cannot read, update, or delete a widget owned by user B.

Integration tests are tagged `[Trait("Category", "Integration")]` and may be excluded from the clean-boot `dotnet test` run if Docker is not available (see `README.md` for the flag). The CI pipeline always runs them.

### Bicep / Infrastructure Tests

- [ ] `bicep build infra/main.bicep` exits zero (schema validation).
- [ ] `az deployment sub what-if` on a test subscription exits zero with no warnings.
- [ ] Second `az deployment sub create` with identical parameters exits zero and reports zero resource changes (idempotency check).

These run as a dedicated CI job in the GitHub Actions workflow; they require an OIDC-federated test subscription.

### Smoke Test

- [ ] After deployment, the GitHub Actions workflow `curl`s `GET /health` on the Container App URL and asserts HTTP 200. Failure blocks the workflow and does not mark the deploy as successful.

## Rollout Plan

Each phase ends with a `<!-- status: pending -->` marker. When the PR for that phase lands, run:

```bash
claude-config/scripts/update-plan-status.sh docs/specs/add-dotnet-azure-bicep-Dg8yD/technical-spec.md "Phase N" <pr-number>
```

The marker becomes `<!-- status: shipped (#PR) -->`, keeping the spec in sync with what has been built.

### Phase 1: Project skeleton <!-- status: pending -->

- Create `starters/dotnet-azure/` directory structure.
- Initialise .NET 9 solution: `DotnetAzure.Api` (minimal APIs) and `DotnetAzure.Tests` (xUnit).
- Add `GET /health` endpoint (no auth, no database).
- Add `ApiResponse<T>` type in `src/DotnetAzure.Api/ApiResponse.cs`.
- Add starter-local `CLAUDE.md` following the pattern in `starters/nextjs/CLAUDE.md`.
- Add `.gitignore` for `*.bicepparam` (real values) and `*.env` local files.
- Register the .NET clean-boot commands (`dotnet build`, `dotnet test`, `dotnet format --verify-no-changes`) with the `starter-verify` skill configuration.
- Acceptance: `dotnet build` exits zero, `dotnet test` exits zero (zero tests is acceptable at this stage), `dotnet format --verify-no-changes` exits zero.

### Phase 2: Bicep modules and deploy workflow <!-- status: pending -->

- Create `starters/dotnet-azure/infra/` with `main.bicep` orchestrator.
- Write the six Bicep modules: `network.bicep`, `identity.bicep`, `data.bicep`, `compute.bicep`, `observability.bicep`.
- Write `infra/parameters/dev.bicepparam.example`, `staging.bicepparam.example`, `prod.bicepparam.example`.
- Write `.github/workflows/deploy.yml` with OIDC federation steps, image build, ACR push, `az deployment sub create`, and `/health` smoke test.
- Acceptance: `bicep build infra/main.bicep` exits zero; `az deployment sub what-if` on the test subscription exits zero with no warnings; second deploy reports zero changes.

### Phase 3: Widget domain, auth, EF Core, and tests <!-- status: pending -->

- Add `Microsoft.Identity.Web` JWT bearer validation; wire `appsettings.json` with placeholder values.
- Add EF Core 9 + Npgsql provider; define `AppDbContext` and `Widget` entity.
- Generate `InitialCreate` migration; commit migration files.
- Implement all six widget endpoints with `ApiResponse<T>` envelope.
- Write unit tests (handler tests + auth bypass checks) and integration tests (Testcontainers Postgres + ownership enforcement).
- Add `docker-compose.yml` for local Postgres.
- Acceptance: `dotnet test` passes (unit + integration); ownership checks pass; `GET /api/widgets` returns 401 without a token.

### Phase 4: Dockerfile, P1 items, and documentation <!-- status: pending -->

- Add multi-stage `Dockerfile`; confirm compressed image < 150 MB.
- Add P1 OpenTelemetry traces via `Azure.Monitor.OpenTelemetry.AspNetCore`; graceful degradation when connection string is absent.
- Add seed script (`scripts/seed.sh` or `tools/Seed` project).
- Write `starters/dotnet-azure/README.md` with the under-30-minutes quickstart.
- Update `docs/guides/tool-reference.md`: add one sentence cross-referencing `starters/dotnet-azure/` as the concrete Profile A Azure example (no rewrite of the profile description).
- Acceptance: full clean-boot contract passes; Dockerfile builds and passes Trivy scan; README quickstart reviewed by at least one external adopter; `tool-reference.md` diff is additive-only.

### Production rollout

1. **Preview:** Each PR against `starters/dotnet-azure/` triggers the GitHub Actions deploy workflow against a PR-scoped resource group (`rg-dotnet-azure-pr-{pr-number}`). The workflow runs `az deployment sub what-if` first; it runs `bicep build` for schema validation; it deploys and smoke-tests `/health`.
2. **Production:** Squash-merge to `main` triggers the production deploy workflow against the adopter's production subscription and resource group.
3. **Rollback trigger:** If the `/health` smoke test fails post-deploy, or if error rate exceeds 1% within 24 hours, roll back by activating the previous Container App revision:
   ```bash
   az containerapp revision activate \
     --name <container-app-name> \
     --resource-group <resource-group> \
     --revision <previous-revision-name>
   ```
4. **Zero-downtime:** Container Apps keeps the previous revision active until the new revision passes the liveness probe. No requests are dropped during a healthy deploy.

## Dependencies

**External services (required for deployment):**

| Dependency | Purpose | Swap path |
|---|---|---|
| Azure subscription | Hosts all provisioned resources | None — this is an Azure-specific starter |
| Microsoft Entra tenant | Issues JWTs validated by `Microsoft.Identity.Web`; Entra admin for Postgres | None for this starter; a different starter would be required for a non-Entra identity provider |
| GitHub repository with OIDC federated credential | Allows GitHub Actions to authenticate to Azure without client secrets | The Bicep + deploy pattern works with any CI system that supports OIDC; GitHub Actions is the reference |
| Azure Container Registry (provisioned by Bicep) | Stores the container image; pulled by Container Apps using managed identity | Can be swapped for another OCI-compliant registry by editing `identity.bicep` and the GHA workflow |
| Azure Database for PostgreSQL Flexible Server (provisioned by Bicep) | Application database | **Azure SQL swap:** Replace `data.bicep` with a `data-azuresql.bicep` module and swap the EF provider from `Npgsql.EntityFrameworkCore.PostgreSQL` to `Microsoft.EntityFrameworkCore.SqlServer`. The managed-identity auth pattern is identical. |
| Docker (local) | Runs local Postgres via `docker compose` for development | Any OCI-compliant runtime (e.g. Podman) works with the Compose file |
| .NET 9 SDK | Build and test | .NET 8 LTS is a compatible downgrade; change the `TargetFramework` in `.csproj` and the `mcr.microsoft.com/dotnet/sdk:9.0` image tag |

**Hard Rule constraints honoured by this spec:**

- Rule 1 (AU spelling): all prose, comments, log messages, and error strings in the starter use Australian English.
- Rule 2 (generic starter): the `Widget` resource contains no business logic; no real domain names appear in any committed file.
- Rule 5 (descriptive profiles): this starter is described as "a reference implementation of Profile A on Azure" — not "the recommended .NET starter" or "the Azure starter".

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | Should the starter ship a second Bicep variant for Azure SQL (`data-azuresql.bicep`), or keep it Postgres-only and rely on the swap-path note in this spec? | parkjadev | 2026-05-06 |
| 2 | Use Dapr for the service-to-service story (P2 feature), or leave it to a separate spec after the P0/P1 baseline ships? Dapr adds a sidecar and operator dependency that may complicate the "boots clean" story. | parkjadev | 2026-05-06 |
| 3 | Should the `network.bicep` VNET module be required in `dev.bicepparam`, or optional? Making it optional simplifies evaluation but diverges dev from prod topology — a risk for adopters who later find VNET integration breaks their service. | Spec author | 2026-05-06 |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
