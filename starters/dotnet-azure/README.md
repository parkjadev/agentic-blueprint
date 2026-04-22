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

### Prerequisites

- .NET 9 SDK (`dotnet --version` should report `9.x`)
- Docker, for local Postgres (`docker compose up db`) and integration tests (Testcontainers)
- An Entra tenant with an API app registration (for anything past `/health`)

### Run the starter locally

```bash
cd starters/dotnet-azure

# 1. Start the local Postgres service.
docker compose up -d db

# 2. Fill in tenant values. Real `.env` is gitignored.
cp .env.example .env
$EDITOR .env

# 3. Apply the initial migration.
set -a; source .env; set +a
dotnet ef database update --project src/DotnetAzure.Api

# 4. Run the API.
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

Authenticated endpoints (`/api/widgets/*`) require a valid Entra JWT. Use `az account get-access-token --resource api://<your-client-id>` or a dev-token helper to obtain one; pass it as `Authorization: Bearer <token>`.

### Clean-boot contract

```bash
dotnet build
dotnet test --filter "Category!=Integration"
dotnet format --verify-no-changes
```

All three must exit zero on a fresh checkout. Integration tests (tagged `Category=Integration`) spin up a Postgres Testcontainer and run the full CRUD path end-to-end; run them separately once Docker is available:

```bash
dotnet test --filter "Category=Integration"
```

The `dotnet-starter-check` GitHub Actions workflow runs the unit suite on every PR that touches `starters/dotnet-azure/`.

## Phase status

| Phase | Scope | Status |
|---|---|---|
| 1 | Project skeleton — solution, health endpoint, `ApiResponse<T>`, CLAUDE.md, clean-boot contract | shipped (#103) |
| 2 | Bicep modules (`main` + `network`/`identity`/`observability`/`data`/`data-azuresql`/`compute`), parameter examples, GitHub Actions validate + deploy workflows (OIDC-ready) | shipped (#106) |
| 3 | `Widget` entity + `AppDbContext` + `InitialCreate` migration, Entra JWT auth, 5 widget endpoints (`GET list` / `POST` / `GET/{id}` / `PATCH/{id}` / `DELETE/{id}`), unit + Testcontainers integration tests, `docker-compose.yml` for local Postgres | **shipping now** |
| 4 | Dockerfile, Application Insights + OpenTelemetry, full README quickstart, `tool-reference.md` cross-reference | pending |

Tracking spec: [`docs/specs/add-dotnet-azure-bicep-Dg8yD/technical-spec.md`](../../docs/specs/add-dotnet-azure-bicep-Dg8yD/technical-spec.md).

## Configure deploys (Phase 2 adopter setup)

The `dotnet-azure-deploy.yml` workflow is `workflow_dispatch`-only by default — no surprise deploys. To enable it on your fork:

1. **Create the federated credential.** In your Entra tenant, register an app (or reuse an existing one) for GitHub Actions OIDC. Add a federated credential scoped to the repo and branch you deploy from (typically `main`).

   ```bash
   az ad app federated-credential create \
     --id <app-object-id> \
     --parameters '{
       "name": "github-main",
       "issuer": "https://token.actions.githubusercontent.com",
       "subject": "repo:<your-org>/<your-repo>:ref:refs/heads/main",
       "audiences": ["api://AzureADTokenExchange"]
     }'
   ```

2. **Grant the federated identity Contributor on the target subscription** (or narrower scope if you provision the resource group yourself).

3. **Add repository secrets** under Settings → Secrets and variables → Actions:

   | Secret | Value |
   |---|---|
   | `AZURE_CLIENT_ID` | The federated app's Application (client) ID |
   | `AZURE_TENANT_ID` | Your Entra tenant ID |
   | `AZURE_SUBSCRIPTION_ID` | Target subscription ID |
   | `BICEPPARAM_CONTENT_dev` | Contents of your real `dev.bicepparam` (paste the whole file) |
   | `BICEPPARAM_CONTENT_staging` | Contents of your real `staging.bicepparam` |
   | `BICEPPARAM_CONTENT_prod` | Contents of your real `prod.bicepparam` |

4. **Trigger the workflow** from the Actions tab or via `gh workflow run dotnet-azure-deploy.yml -f environment=dev -f dataProvider=postgres`.

   Set `whatIfOnly: true` for a dry run that reports Azure changes without applying them.

## Structure

See [`CLAUDE.md`](./CLAUDE.md) for the current project layout and the conventions this starter enforces.
