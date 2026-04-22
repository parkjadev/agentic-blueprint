# .NET + Azure Bicep Starter — Phase 3

**Parent:** [`add-dotnet-azure-bicep-Dg8yD`](./add-dotnet-azure-bicep-Dg8yD/)
**Phase:** 3 of 4 — Widget domain, Entra auth, EF Core, tests
**Branch:** `claude/dotnet-azure-phase-3`
**Status:** In flight

---

Index marker for Phase 3. Full scope lives in the parent spec's rollout plan ([`technical-spec.md` — Phase 3](./add-dotnet-azure-bicep-Dg8yD/technical-spec.md#phase-3-widget-domain-auth-ef-core-and-tests--status-pending-)); this flat file exists so the `/ship` pre-commit gate can match the branch slug without colliding with the parent spec's folder layout.

## Phase 3 scope (copied from the parent technical-spec, not authoritative)

- Wire `Microsoft.Identity.Web` JWT bearer validation. `appsettings.json` holds placeholder TenantId / ClientId / Audience values — real values flow in via Container App env vars.
- Add EF Core 9 + Npgsql provider; define `AppDbContext` and `Widget` entity with `Id`, `Name` (≤255), `Description` (≤1000), `OwnerId` (JWT `sub`), `Status` enum (Active/Archived/Deleted), `CreatedAt`, `UpdatedAt`.
- Ship a hand-authored `InitialCreate` migration (plus `.Designer.cs` and `AppDbContextModelSnapshot.cs`) so adopters can run `dotnet ef database update` against their Postgres without generating the migration themselves.
- Implement five widget endpoints under `/api/widgets` — `GET list`, `POST`, `GET/{id}`, `PATCH/{id}`, `DELETE/{id}`. All require authentication; ownership is enforced by comparing the JWT `sub` (or `oid`) claim against the `OwnerId` column. Responses use the `ApiResponse<T>` envelope.
- Unit tests with `TestAuthHandler` stubbing the JWT via an `X-Test-User` header — exercise happy paths, 401 without token, 403 on cross-owner access, 404 on missing, 400 on validation.
- Integration tests tagged `Category=Integration` — Testcontainers Postgres, `Database.Migrate()` smoke test, full CRUD cycle against real Postgres, ownership enforcement across connections.
- `docker-compose.yml` for local Postgres dev (port 5432, `postgres/dev` credentials for local-only).

## Not in this phase

- Dockerfile + multi-stage build (Phase 4)
- OpenTelemetry traces to Application Insights (Phase 4)
- `docs/guides/tool-reference.md` cross-reference (Phase 4)
- Dapr service-to-service pattern (deferred follow-up, per the PRD's "Still open" Q2)

## Acceptance

- `dotnet test --filter "Category!=Integration"` exits zero (runs in every PR via `dotnet-starter-check.yml`).
- `dotnet test --filter "Category=Integration"` exits zero locally with Docker available — exercises the migration and ownership rules against real Postgres.
- `dotnet format --verify-no-changes` exits zero.
- `GET /health` remains anonymous; `GET /api/widgets` returns 401 without a bearer token.

The CI workflow (`dotnet-starter-check.yml`) runs only the unit suite. Adopters run the integration suite against their own Docker before merging Phase 3 forks.
