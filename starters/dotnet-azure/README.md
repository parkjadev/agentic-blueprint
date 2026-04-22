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
| 1 | Project skeleton — solution, health endpoint, `ApiResponse<T>`, CLAUDE.md, clean-boot contract | shipped (#103) |
| 2 | Bicep modules (`main` + `network`/`identity`/`observability`/`data`/`data-azuresql`/`compute`), parameter examples, GitHub Actions validate + deploy workflows (OIDC-ready) | **shipping now** |
| 3 | Widget domain example, Entra auth wiring, EF Core + migration, integration tests | pending |
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
