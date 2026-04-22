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

## Project structure (current — Phase 1)

```
starters/dotnet-azure/
├── DotnetAzure.sln
├── global.json                         # SDK pin + roll-forward policy
├── .editorconfig                       # formatter and analyser settings
├── .gitignore                          # excludes bin/obj, secrets, *.bicepparam
├── src/
│   └── DotnetAzure.Api/
│       ├── DotnetAzure.Api.csproj
│       ├── Program.cs                  # minimal API — `GET /health`
│       ├── ApiResponse.cs              # envelope — never bypass
│       ├── appsettings.json
│       ├── appsettings.Development.json
│       └── Properties/launchSettings.json
└── tests/
    └── DotnetAzure.Tests/
        ├── DotnetAzure.Tests.csproj
        └── HealthEndpointTests.cs
```

Subsequent phases add (in order): `infra/` with Bicep modules (Phase 2),
`src/DotnetAzure.Api/Widgets/` + EF Core entity + auth wiring + widget tests
(Phase 3), `Dockerfile` + `docker-compose.yml` + `README.md` quickstart
(Phase 4).

## Starter-specific conventions

These complement the parent Hard Rules; they're .NET-only concerns.

1. **Every endpoint returns `ApiResponse<T>`.** Success: `Results.Ok(ApiResponse.Ok(data))` — `T` is inferred from the argument. Failure: `Results.Json(ApiResponse.Fail(code, message), statusCode: 400)` (or 401/403/404). Factory helpers live on the non-generic `ApiResponse` static class (CA1000); the record type remains `ApiResponse<T>`. Never return raw payloads — the envelope matches what the Next.js and Flutter clients expect.
2. **Minimal APIs, not MVC controllers.** Endpoints are declared with `app.MapGet` / `MapPost` / etc. Group related endpoints via `app.MapGroup("/api/widgets")` once there's more than one resource.
3. **Records over classes for DTOs.** `public sealed record` with positional parameters; `Nullable` is enabled and warnings are errors, so nullability must be expressed at declaration.
4. **No Supabase, no Drizzle, no Node runtime.** This starter is Azure-native. Cross-starter parity is at the API contract, not the runtime.
5. **Secrets flow through Container App environment variables.** `appsettings.json` holds placeholder strings only. Real values live in gitignored `.env` (local) or are injected by the Bicep-provisioned Container App env block (production).
6. **Australian spelling** in all prose, comments, error messages, and user-visible strings. Enforced by the repo-wide rule check (Hard Rule 1).

## Clean-boot contract (Hard Rule 2)

The starter must pass all three commands with zero errors, from a clean
checkout with the .NET 9 SDK installed:

```bash
dotnet build
dotnet test
dotnet format --verify-no-changes
```

Use `/check` (see `.claude/commands/check.md`) to run the sequence.

If any command fails on `main`, the starter is broken — fix before
merging anything else. The `dotnet-starter-check` GitHub Actions workflow
enforces the same sequence on every PR that touches `starters/dotnet-azure/`.

## Do NOT touch without review

| File | Why |
|---|---|
| `src/DotnetAzure.Api/ApiResponse.cs` | Defines the API contract. Changing this breaks every endpoint and drifts from the sibling starters. |
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

- **Phase 2** — `infra/` with `main.bicep` + child modules (`network`, `identity`, `data`, `data-azuresql`, `compute`, `observability`), `.bicepparam.example` placeholders, GitHub Actions deploy workflow with OIDC federation.
- **Phase 3** — Entra ID JWT bearer wiring, EF Core + `Widget` entity (`InitialCreate` migration), widget CRUD endpoints, integration tests via Testcontainers.
- **Phase 4** — multi-stage `Dockerfile`, `docker-compose.yml` for local Postgres, OpenTelemetry → Application Insights, `README.md` quickstart, cross-reference added to `docs/guides/tool-reference.md`.

Full phase detail lives in the spec at `docs/specs/add-dotnet-azure-bicep-Dg8yD/technical-spec.md`.
