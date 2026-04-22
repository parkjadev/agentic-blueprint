# .NET + Azure Starter

Reference implementation of the agentic-blueprint Profile A lifecycle (Spec → Ship → Signal) on a .NET + Azure-native stack.

This starter coexists with `starters/nextjs/` and `starters/flutter/`. It is **one option**, not a prescription — pick whichever stack matches your platform.

## Stack

- **.NET 9** on ASP.NET Core minimal APIs (LTS track, SDK pinned via `global.json`)
- **Microsoft Entra ID** (via `Microsoft.Identity.Web`) — Phase 3
- **EF Core 9** with Npgsql (PostgreSQL) or `Microsoft.EntityFrameworkCore.SqlServer` (Azure SQL) — Phase 3
- **Azure Container Apps** + Log Analytics + Application Insights, provisioned by Bicep — Phase 2
- **GitHub Actions** with OIDC federation to Azure — Phase 2

## Quickstart

The full under-30-minutes adopter quickstart lands in **Phase 4** of the rollout. Until then, this starter ships the project skeleton only — enough to verify the clean-boot contract.

### Prerequisites (Phase 1)

- .NET 9 SDK (`dotnet --version` should report `9.x`)

### Run the starter locally

```bash
cd starters/dotnet-azure
dotnet build
dotnet test
dotnet run --project src/DotnetAzure.Api
```

Then `curl http://localhost:5042/health` — you should see:

```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "checkedAt": "2026-04-22T00:00:00+00:00"
  }
}
```

### Clean-boot contract

```bash
dotnet build
dotnet test
dotnet format --verify-no-changes
```

All three must exit zero on a fresh checkout. The `dotnet-starter-check` GitHub Actions workflow runs the same sequence on every PR that touches `starters/dotnet-azure/`.

## Phase status

| Phase | Scope | Status |
|---|---|---|
| 1 | Project skeleton — solution, health endpoint, `ApiResponse<T>`, CLAUDE.md, clean-boot contract | **shipping now** |
| 2 | Bicep modules (incl. Azure SQL variant), GitHub Actions deploy workflow with OIDC | pending |
| 3 | Widget domain example, Entra auth wiring, EF Core + migration, integration tests | pending |
| 4 | Dockerfile, Application Insights + OpenTelemetry, full README quickstart, `tool-reference.md` cross-reference | pending |

Tracking spec: [`docs/specs/add-dotnet-azure-bicep-Dg8yD/technical-spec.md`](../../docs/specs/add-dotnet-azure-bicep-Dg8yD/technical-spec.md).

## Structure

See [`CLAUDE.md`](./CLAUDE.md) for the current project layout and the conventions this starter enforces.
