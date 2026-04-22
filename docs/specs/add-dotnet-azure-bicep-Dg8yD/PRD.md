# Product Requirements Document — .NET + Azure Bicep Starter

**Author:** Claude (spec-author)
**Date:** 2026-04-22
**Status:** Draft
**Scope:** feature
**Parent:** (none)

> **Scope-aware sections.** This is a `scope: feature` PRD. *Vision*, *Success Metrics*, *Non-Goals*, and *Feature Matrix* are rendered because they are applicable to this standalone feature. *Child features* is omitted — no sub-features are defined at this level.

---

## Problem Statement

Adopters choosing Azure as their Profile A deployment target currently have no working reference implementation in this repository. `docs/guides/tool-reference.md` already names "Azure via Bicep + `az` CLI" as a common Ship-beat deployment option under Profile A, but ships nothing concrete alongside that mention.

Every Azure-targeting team must independently re-discover:

- OIDC federation wiring between GitHub Actions and an Azure subscription (avoiding client secrets in the repository).
- Bicep module conventions for Container Apps, managed identity, Log Analytics, and Application Insights.
- How to connect an ASP.NET Core API to Azure Database for PostgreSQL Flexible Server using Entra-authenticated managed identity (no password in the connection string).
- How `Microsoft.Identity.Web` JWT bearer validation integrates with a minimal APIs project.
- How the blueprint's three-beat lifecycle (Spec → Ship → Signal) maps to Azure-native Ship mechanics.

The two existing starters (`starters/nextjs/` and `starters/flutter/`) demonstrate the lifecycle on Supabase + Vercel and on Flutter mobile, respectively. There is no starter demonstrating the lifecycle on a .NET + Azure-native stack. This feature adds `starters/dotnet-azure/` to close that gap.

## Target Users

| User Segment | Description | Priority |
|---|---|---|
| Azure-targeting pro-code teams | Engineering teams adopting the blueprint whose platform is Azure — regulated industries, Microsoft-stack enterprises, and organisations with existing Azure commitments. Comfortable with .NET and Azure tooling; want a working scaffold rather than authoring Bicep and OIDC wiring from scratch. | Primary |
| Existing blueprint adopters adding a .NET service | Teams already running the Next.js starter who need a second service for a compute-heavy workload in .NET. They want to reuse the Bicep module pattern at a different resource-group scope without duplicating infrastructure definitions. | Secondary |
| Blueprint contributors and evaluators | Developers assessing whether the blueprint covers their stack before committing to adoption. A working .NET + Azure starter signals professional breadth and confirms the lifecycle is not locked to any single cloud. | Tertiary |

## User Journeys

### Journey 1: New adopter deploys a working API to Azure in under 30 minutes

**Trigger:** An engineer at an Azure-first organisation reads the Profile A documentation in `tool-reference.md`, sees the `.NET + Azure` starter listed, and wants to confirm it works before committing their team.

1. Engineer clones or forks the repo and reads `starters/dotnet-azure/README.md`.
2. They create an Entra app registration for the API and a client app registration for local testing, following the README quickstart.
3. They copy `infra/parameters/dev.bicepparam.example` to `dev.bicepparam` and fill in their subscription ID, tenant ID, and resource-group name.
4. They configure OIDC federation between their GitHub repository and their Azure subscription.
5. They push a branch; the GitHub Actions workflow runs `az deployment sub create`, provisions all Azure resources, builds and pushes the container image to ACR, and deploys the Container App.
6. The smoke-test step `curl`s `GET /health` on the deployed revision and confirms HTTP 200.
7. Engineer calls `GET /api/widgets` with a JWT from the Entra client app and receives `{ "success": true, "data": [] }`.

**Outcome:** The engineer has a fully deployed, Entra-authenticated .NET API on Azure Container Apps with Postgres and Application Insights wired — in under 30 minutes, without writing any infrastructure code.

### Journey 2: Existing Next.js adopter adds a second .NET service

**Trigger:** A team running the Next.js starter needs a compute-heavy backend service. They want to deploy it to the same Azure subscription with its own resource group, reusing the established Bicep module pattern.

1. Developer copies `starters/dotnet-azure/infra/` into their new service's repository.
2. They author a new `infra/parameters/prod.bicepparam` pointing at a separate resource group.
3. They add or reuse an OIDC federated credential for this service.
4. They adjust Container App environment variables for the new service's API scope.
5. They run `az deployment sub create` targeting the new resource group; Bicep provisions the new environment and container app without touching the existing Next.js deployment.

**Outcome:** The team ships a second service without duplicating Bicep logic, introducing new infrastructure patterns, or affecting the existing deployment.

### Journey 3: Contributor verifies the starter locally

**Trigger:** A contributor to the blueprint repository wants to confirm the starter boots clean and the widget CRUD flow works before raising a PR.

1. Contributor runs `docker compose up -d` in `starters/dotnet-azure/` to start a local Postgres instance.
2. They run `dotnet ef database update` to apply the EF Core migration.
3. They run `dotnet run --project src/DotnetAzure.Api/` and confirm the API starts on port 5000.
4. They call `GET /health` and receive `{ "status": "healthy" }`.
5. They obtain a local bearer token (the README describes using the Entra dev client app or the test JWT helper in `src/DotnetAzure.Tests/`).
6. They call `POST /api/widgets` with a valid payload and receive a `201` with the `ApiResponse<T>` envelope.
7. They cycle through `GET /api/widgets`, `GET /api/widgets/{id}`, `PATCH /api/widgets/{id}`, and `DELETE /api/widgets/{id}`.
8. They run `dotnet test` — all tests pass in under 60 seconds.
9. They run `dotnet format --verify-no-changes` — exits zero.
10. They run `dotnet build` — exits zero.

**Outcome:** Contributor has confirmed the clean-boot contract and the widget CRUD + auth flow end-to-end, ready to raise a PR.

## Feature Matrix

| Feature | Description | Priority | Journey |
|---|---|---|---|
| ASP.NET Core project skeleton | .NET 9 solution with `DotnetAzure.Api` and `DotnetAzure.Tests` projects, minimal APIs wiring, and a starter-local `CLAUDE.md` | P0 | 3 |
| `GET /health` endpoint | Returns `{ "status": "healthy" }` with HTTP 200. No auth required. Used by Container Apps liveness probe and GHA smoke test. | P0 | 1, 3 |
| Widget CRUD endpoints | `GET /api/widgets`, `POST /api/widgets`, `GET /api/widgets/{id}`, `PATCH /api/widgets/{id}`, `DELETE /api/widgets/{id}`. All require an Entra JWT. Returns `ApiResponse<T>` envelope. | P0 | 3 |
| Entra ID auth wiring | `Microsoft.Identity.Web` JWT bearer validation. Tenant ID and API scope configured in `appsettings.json`. All non-health endpoints require a valid bearer token. | P0 | 1, 2, 3 |
| EF Core 9 + Npgsql + managed identity | `Widget` entity, EF Core 9 with Npgsql provider, `InitialCreate` migration. On Azure: Entra-authenticated managed identity (no password). Local: Docker Compose Postgres via user-secrets or environment variable. | P0 | 1, 3 |
| Bicep main orchestrator (`main.bicep`) | Top-level deployment file. Accepts environment, subscription, resource-group, and image-tag parameters. Calls all child modules in dependency order. | P0 | 1, 2 |
| Bicep module: `network.bicep` | Virtual network and subnet for Container Apps Environment VNET integration (recommended for production; can be omitted in dev parameter set). | P0 | 1, 2 |
| Bicep module: `identity.bicep` | User-assigned managed identity. Assigns `AcrPull` role on ACR and Entra admin role on Postgres Flexible Server. | P0 | 1, 2 |
| Bicep module: `data.bicep` | Azure Database for PostgreSQL Flexible Server with Entra authentication enabled. Managed-identity-based access — no password in deployment parameters. | P0 | 1, 2 |
| Bicep module: `compute.bicep` | Container Apps Environment + Container App. Wires managed identity, sets liveness probe to `/health`, injects Application Insights connection string as environment variable. | P0 | 1, 2 |
| Bicep module: `observability.bicep` | Log Analytics Workspace + Application Insights. Outputs connection string for injection into the Container App. | P0 | 1, 2 |
| `parameters/` for dev / staging / prod | `dev.bicepparam`, `staging.bicepparam`, `prod.bicepparam` plus `*.bicepparam.example` files safe to commit. Real parameter files are `.gitignore`d. | P0 | 1, 2 |
| GitHub Actions deploy workflow (OIDC) | `.github/workflows/deploy.yml`. Uses `azure/login` with OIDC (`client-id`, `tenant-id`, `subscription-id`). Steps: build image → push to ACR → `az deployment sub create` → smoke test. | P0 | 1, 2 |
| `ApiResponse<T>` envelope | `{ "success": true, "data": ... }` / `{ "success": false, "error": { "code": "...", "message": "..." } }` matching the sibling starters. Defined in `src/DotnetAzure.Api/ApiResponse.cs`. | P0 | 3 |
| Starter-local `CLAUDE.md` | Stack table, project structure, conventions, clean-boot contract, and common tasks. Mirrors the pattern in `starters/nextjs/CLAUDE.md` and `starters/flutter/CLAUDE.md`. | P0 | 3 |
| Starter README with quickstart | `starters/dotnet-azure/README.md`. Guides an adopter from clone to first deployment in under 30 minutes. Covers prerequisites, Entra app registration, OIDC federation, parameter configuration, and deploy command. | P0 | 1 |
| Clean-boot contract | `dotnet build`, `dotnet test`, `dotnet format --verify-no-changes` all pass from a clean checkout with no external services required (unit tests use mocked or in-memory dependencies). | P0 | 3 |
| Dockerfile (multi-stage) | `sdk` layer for build and test, `runtime` layer on `mcr.microsoft.com/dotnet/aspnet:9.0-alpine`. Target image < 150 MB compressed. | P1 | 1 |
| Local `docker compose` for Postgres | `docker-compose.yml` starts a local Postgres instance on port 5432 for `dotnet run` and integration tests. No Azure subscription required for local development. | P1 | 3 |
| Seed script | `scripts/seed.sh` (or `dotnet run --project tools/Seed`) creates example widget records for local development and manual testing. | P1 | 3 |
| OpenTelemetry traces to Application Insights | `Azure.Monitor.OpenTelemetry.AspNetCore` package. Exports traces to Application Insights when `APPLICATIONINSIGHTS_CONNECTION_STRING` is set; falls back to console exporter when not set. | P1 | 1 |
| Dapr sidecar example | Optional sidecar configuration demonstrating service-to-service invocation. Provided as a commented-out Bicep block and a companion `docker-compose.dapr.yml`. Off by default. | P2 | — |
| Azure Front Door module | `infra/modules/frontdoor.bicep` for edge-layer CDN + WAF in front of Container Apps. | P2 | — |
| Blue/green revision strategy | Bicep + GHA workflow variant demonstrating Container Apps traffic splitting for zero-downtime revision promotion. | P2 | — |

## Non-Functional Requirements

| Requirement | Target | Measurement |
|---|---|---|
| Cold-start time | < 3 seconds on Container Apps with 0.5 vCPU after scale-to-zero | Azure Monitor: Container App first-request duration after idle |
| End-to-end deploy time | < 10 minutes from GitHub Actions trigger to healthy Container App revision | GitHub Actions workflow duration log |
| Bicep idempotency | Second deploy with no parameter changes results in zero resource changes | `az deployment sub what-if` after first deploy; CI post-deploy check |
| Bicep `what-if` warnings | Zero warnings on a clean parameter set | CI step: `az deployment sub what-if --no-prompt` exit code 0 |
| Container image size | < 150 MB compressed | `docker image inspect` after build; checked in GHA |
| CVE scan | No critical or high CVEs on the base image | Trivy scan in GitHub Actions or Microsoft Defender for Containers in ACR |
| `dotnet test` duration | Passes in < 60 seconds locally | `dotnet test` wall-clock time |
| Clean-boot commands | `dotnet build`, `dotnet test`, `dotnet format --verify-no-changes` all exit zero | CI gate step |
| Australian spelling compliance | Zero violations from the `australian-spelling` check script | Pre-commit hook + CI |

## Success Metrics

| Metric | Current | Target | Timeframe |
|---|---|---|---|
| Time-to-first-deploy for a new adopter | No baseline — starter does not exist | < 30 minutes from clone to healthy Container App | Measured on first two external adopters post-merge |
| `dotnet test` pass rate on `main` | N/A | 100% — CI gate blocks merge on failure | Ongoing from Phase 3 merge |
| Bicep re-deploy idempotency | N/A | 100% of re-deploys with no parameter changes report zero changes | Verified in Phase 2 acceptance test and ongoing CI |
| Clean-boot contract compliance | N/A | 100% — all three commands pass on every commit to `main` | Ongoing from Phase 1 merge |

## Out of Scope

- Replacing or deprecating `starters/nextjs/` or `starters/flutter/`. This starter coexists as a third option and is not a replacement.
- Azure SQL as a primary database. Adopters may swap the EF provider and `data.bicep` module; a migration note is included in the technical spec. The starter ships Postgres-first.
- Multi-region failover, geo-redundancy, or availability-zone configuration.
- Terraform or Pulumi alternatives to Bicep.
- Azure Developer CLI (`azd`) integration. The starter uses plain Bicep + `az deployment sub create` for maximum transparency.
- Azure Kubernetes Service (AKS). Container Apps is the compute target.
- A web or mobile UI. This starter is API-only; `starters/nextjs/` and `starters/flutter/` cover the frontend tiers.
- Any domain-specific business logic. The `Widget` resource is a neutral CRUD example with no business meaning, analogous to `ExampleProject` in the Flutter starter.

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | Should the starter ship a second Bicep variant for Azure SQL alongside the Postgres modules, or document the swap path only? Shipping both reduces a future PR but increases initial surface area. | Spec author / adopter feedback | 2026-05-06 |
| 2 | Should the `network.bicep` module be required in the dev parameter set, or optional? VNET integration on Container Apps adds cost and complexity that may deter local evaluation. | Spec author | 2026-05-06 |
| 3 | How should "tenant-specific config" (Entra tenant ID, subscription ID, client ID) be expressed without any real values reaching `git`? Proposed: `.env.example` + `*.bicepparam.example` placeholder files, with real files in `.gitignore`. Confirm this is consistent with the sibling starters' secrets convention. | Spec author | 2026-04-29 |

## Appendix

- `docs/guides/tool-reference.md` — existing reference to "Azure via Bicep + `az` CLI" as a Profile A deployment option (Ship row of the beat × profile matrix). This starter is the concrete implementation.
- `starters/nextjs/CLAUDE.md` — sibling starter: `ApiResponse<T>` envelope definition, clean-boot contract pattern, `CLAUDE.md` structure.
- `starters/flutter/CLAUDE.md` — sibling starter: `ExampleProject` model as the analogue for the `Widget` CRUD resource.
- Microsoft documentation: [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/), [Bicep overview](https://learn.microsoft.com/azure/azure-resource-manager/bicep/), [Microsoft.Identity.Web](https://learn.microsoft.com/azure/active-directory/develop/microsoft-identity-web), [PostgreSQL Flexible Server — Entra authentication](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-azure-ad-authentication).

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
