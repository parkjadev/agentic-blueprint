# CLAUDE.md — .NET + Azure starter

Starter-specific guidance. The framework-wide principles (Hard Rules 1–5
+ meta-principles 6–8) live in the parent repo; read those first:

- Parent primitive map — [`/CLAUDE.md`](../../CLAUDE.md)
- Hard Rules — [`/docs/principles/`](../../docs/principles/)

This file captures what's specific to **this starter**.

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Runtime | .NET 9 | LTS track; SDK pinned in `global.json` |
| Framework | ASP.NET Core minimal APIs | Phase 1 exposes `GET /health` only |
| Response envelope | `ApiResponse<T>` | `{ success, data }` / `{ success, error }`; mirrors siblings |
| Auth (Phase 3) | Microsoft Entra ID via `Microsoft.Identity.Web` | JWT bearer — not yet wired in Phase 1 |
| Database (Phase 3) | EF Core 9 + Npgsql (default) or `Microsoft.EntityFrameworkCore.SqlServer` (Azure SQL variant) | Managed identity, no password in connection string |
| Testing | xUnit + `Microsoft.AspNetCore.Mvc.Testing` | `WebApplicationFactory<Program>` for integration-style tests |
| Formatting | `dotnet format` | Driven by `.editorconfig`; `--verify-no-changes` enforced in the clean-boot contract |
| Infrastructure (Phase 2) | Bicep + Azure CLI | Ships `data.bicep` (Postgres Flexible Server) and `data-azuresql.bicep` (Azure SQL) variants |
| Deploy pipeline (Phase 2) | GitHub Actions + OIDC federation | No client secrets in repository |

## Project structure (current — Phase 1 + Phase 2 + Phase 3)

```
starters/dotnet-azure/
├── DotnetAzure.sln
├── global.json                         # SDK pin + roll-forward policy
├── .editorconfig                       # formatter and analyser settings
├── .env.example                        # placeholders — real .env gitignored
├── .gitignore                          # excludes bin/obj, secrets, *.bicepparam
├── docker-compose.yml                  # Postgres 16 for local dev
├── infra/                              # see "Infrastructure" section below
├── src/
│   └── DotnetAzure.Api/
│       ├── DotnetAzure.Api.csproj
│       ├── Program.cs                  # minimal API — health + widget CRUD
│       ├── ApiResponse.cs              # envelope — never bypass
│       ├── Data/
│       │   ├── AppDbContext.cs         # EF Core context (Widgets DbSet)
│       │   ├── AppDbContextFactory.cs  # design-time factory for `dotnet ef`
│       │   ├── Entities/
│       │   │   ├── Widget.cs
│       │   │   └── WidgetStatus.cs
│       │   └── Migrations/             # hand-authored InitialCreate
│       ├── Endpoints/
│       │   └── WidgetEndpoints.cs      # 5 routes under /api/widgets
│       ├── Validation/
│       │   └── WidgetRequests.cs       # Create/Update request DTOs
│       ├── appsettings.json
│       ├── appsettings.Development.json
│       └── Properties/launchSettings.json
└── tests/
    └── DotnetAzure.Tests/
        ├── DotnetAzure.Tests.csproj
        ├── Fixtures/
        │   ├── TestAuthHandler.cs      # X-Test-User scheme for unit tests
        │   └── TestWebApplicationFactory.cs
        ├── HealthEndpointTests.cs
        ├── WidgetEndpointsTests.cs     # in-memory DB + TestAuthHandler
        └── WidgetIntegrationTests.cs   # Testcontainers Postgres — Category=Integration
```

Phase 4 adds `Dockerfile`, Application Insights + OpenTelemetry, and the full
adopter quickstart.

## Starter-specific conventions

These complement the parent Hard Rules; they're .NET-only concerns.

1. **Every endpoint returns `ApiResponse<T>`.** Success: `Results.Ok(ApiResponse.Ok(data))` — `T` is inferred from the argument. Failure: `Results.Json(ApiResponse.Fail(code, message), statusCode: 400)` (or 401/403/404). Factory helpers live on the non-generic `ApiResponse` static class (CA1000); the record type remains `ApiResponse<T>`. Never return raw payloads — the envelope matches what the Next.js and Flutter clients expect.
2. **Minimal APIs, not MVC controllers.** Endpoints are declared via `app.MapGet` / `MapPost` / etc. The Widget group lives at `app.MapGroup("/api/widgets").RequireAuthorization()`.
3. **Records over classes for DTOs.** `public sealed record` with positional parameters; `Nullable` is enabled and warnings are errors, so nullability must be expressed at declaration.
4. **No Supabase, no Drizzle, no Node runtime.** This starter is Azure-native. Cross-starter parity is at the API contract, not the runtime.
5. **Secrets flow through Container App environment variables.** `appsettings.json` holds placeholder strings only. Real values live in gitignored `.env` (local) or are injected by the Bicep-provisioned Container App env block (production).
6. **Ownership via JWT claims.** `WidgetEndpoints` resolves the current user via `ClaimTypes.NameIdentifier` / `oid` / `sub` (in that order). `OwnerId == currentUser` is enforced inside each handler — never trust the client to pass an owner.
7. **`/health` is anonymous.** Container Apps liveness probes hit it without a bearer; every other endpoint requires a valid Entra JWT. Don't move the probe path without updating `infra/modules/compute.bicep`.
8. **Australian spelling** in all prose, comments, error messages, and user-visible strings. Enforced by the repo-wide rule check (Hard Rule 1).

## Clean-boot contract (Hard Rule 2)

The starter must pass all three commands with zero errors, from a clean
checkout with the .NET 9 SDK installed:

```bash
dotnet build
dotnet test --filter "Category!=Integration"
dotnet format --verify-no-changes
```

Integration tests (`Category=Integration`) need a Docker daemon for
Testcontainers Postgres and are run separately — locally via
`dotnet test` without the filter, in CI via a dedicated job (wired in
Phase 4 when the compose service plugs into the smoke-test harness).

Use `/check` (see `.claude/commands/check.md`) to run the sequence.

If any command fails on `main`, the starter is broken — fix before
merging anything else. The `dotnet-starter-check` GitHub Actions workflow
enforces the same sequence on every PR that touches `starters/dotnet-azure/`.

## Do NOT touch without review

| File | Why |
|---|---|
| `src/DotnetAzure.Api/ApiResponse.cs` | Defines the API contract. Changing this breaks every endpoint and drifts from the sibling starters. |
| `src/DotnetAzure.Api/Data/AppDbContext.cs` | EF Core model configuration. Changes here must travel with a new migration (never alter a landed migration). |
| `src/DotnetAzure.Api/Data/Migrations/` | Landed migrations are immutable. Add new migrations; don't edit committed ones. |
| `global.json` | Pins the SDK band. Changing it affects every local dev environment and the CI runner. |
| `DotnetAzure.sln` | Project wiring. Do not hand-edit GUIDs or ordering. |
| `.editorconfig` | Formatting and analyser rules. Changes alter what `dotnet format --verify-no-changes` accepts. |
| `tests/DotnetAzure.Tests/DotnetAzure.Tests.csproj` | Pins test SDK and xUnit versions. Keep aligned with the API project's `TargetFramework`. |

## Common tasks

| Task | Do this |
|---|---|
| Add a new endpoint | Declare via `app.MapGet` / `MapPost` in `Program.cs` or a dedicated endpoint class. Return via `ApiResponse<T>`. |
| Add a new settings key | Add to `appsettings.json` with a placeholder; bind via `IOptions<T>`; document the real-value source (env var or Bicep output). |
| Add a NuGet package | `dotnet add src/DotnetAzure.Api package <Name>`. Prefer Microsoft-owned packages when a choice exists. |
| Refresh test SDK | Bump `Microsoft.NET.Test.Sdk` in the test csproj; re-run `dotnet test` locally before committing. |

## What's coming in later phases

- **Phase 4** — multi-stage `Dockerfile`, OpenTelemetry → Application Insights, `README.md` quickstart, cross-reference added to `docs/guides/tool-reference.md`.

Full phase detail lives in the spec at `docs/specs/add-dotnet-azure-bicep-Dg8yD/technical-spec.md`.

## Working with EF Core migrations

The `InitialCreate` migration lives at `src/DotnetAzure.Api/Data/Migrations/`
and is applied via `Database.Migrate()` in integration tests and at
adopter-driven `dotnet ef database update` time. To add a new migration:

```bash
cd starters/dotnet-azure
export ConnectionStrings__AppDb='Host=localhost;Port=5432;Database=appdb;Username=postgres;Password=dev'
dotnet ef migrations add <MigrationName> --project src/DotnetAzure.Api
```

Commit the generated `{timestamp}_<MigrationName>.cs`, `.Designer.cs`, and
the updated `AppDbContextModelSnapshot.cs` together.

## Infrastructure (Phase 2)

```
infra/
├── main.bicep               # subscription-scoped orchestrator
├── modules/
│   ├── network.bicep        # VNET + subnets (Container Apps, Postgres, private endpoints) + private DNS
│   ├── identity.bicep       # user-assigned managed identity
│   ├── observability.bicep  # Log Analytics workspace + Application Insights
│   ├── data.bicep           # PostgreSQL Flexible Server (Entra-only auth, managed-identity access)
│   ├── data-azuresql.bicep  # Azure SQL Database variant (same contract)
│   └── compute.bicep        # ACR + Container Apps Environment + Container App
└── parameters/
    ├── dev.bicepparam.example
    ├── staging.bicepparam.example
    └── prod.bicepparam.example
```

Selecting a data provider: `main.bicep` takes a `dataProvider` parameter with allowed values `'postgres'` (default) or `'azuresql'`. The corresponding module deploys; the other stays dormant. EF provider selection for the running API is a Phase 3 concern.

Secrets handling: real `.bicepparam` files are gitignored (see `.gitignore`). The committed `.example` files hold placeholders only. CI materialises the real file from a GitHub secret (`BICEPPARAM_CONTENT_<env>`) — see `.github/workflows/dotnet-azure-deploy.yml`.
