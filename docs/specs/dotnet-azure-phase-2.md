# .NET + Azure Bicep Starter — Phase 2

**Parent:** [`add-dotnet-azure-bicep-Dg8yD`](./add-dotnet-azure-bicep-Dg8yD/)
**Phase:** 2 of 4 — Bicep modules + deploy workflow
**Branch:** `claude/dotnet-azure-phase-2`
**Status:** In flight

---

This is an index marker for Phase 2. The full scope lives in the parent spec's rollout plan ([`technical-spec.md` — Phase 2](./add-dotnet-azure-bicep-Dg8yD/technical-spec.md#phase-2-bicep-modules-and-deploy-workflow--status-pending-)); this flat file exists so the `/ship` pre-commit gate can match the branch slug without colliding with the parent spec's folder layout.

## Phase 2 scope (copied from the parent technical-spec, not authoritative)

- Bicep orchestrator (`main.bicep`, subscription-scoped) that selects the data module via a `dataProvider` parameter (`'postgres'` default, `'azuresql'` alternative).
- Child modules under `starters/dotnet-azure/infra/modules/`: `network`, `identity`, `observability`, `data` (Postgres Flexible Server), `data-azuresql` (Azure SQL), `compute` (ACR + Container Apps Environment + Container App).
- VNET-integrated Container Apps in dev — no dev/prod topology divergence (per decision 2 in the parent PRD's resolved open questions).
- Entra-only database authentication via user-assigned managed identity — no passwords in connection strings (per decision 5 in the parent spec).
- Parameter example files (`dev`/`staging`/`prod` `.bicepparam.example`) in-tree; real `.bicepparam` files gitignored (per decision 3).
- GitHub Actions workflows:
  - `.github/workflows/dotnet-azure-bicep-validate.yml` — runs `bicep build` on PRs that touch `starters/dotnet-azure/infra/**`.
  - `.github/workflows/dotnet-azure-deploy.yml` — `workflow_dispatch` deploy with OIDC federation and `/health` smoke test; requires adopter to configure `AZURE_CLIENT_ID` / `AZURE_TENANT_ID` / `AZURE_SUBSCRIPTION_ID` / `BICEPPARAM_CONTENT_<env>` secrets.

## Not in this phase

- Dockerfile + real container image (Phase 4)
- Entra auth wiring, EF Core + `Widget` entity, widget CRUD endpoints (Phase 3)
- OpenTelemetry traces to Application Insights (Phase 4)
- `docs/guides/tool-reference.md` cross-reference (Phase 4)

## Acceptance

- `bicep build main.bicep` exits zero
- `bicep build` for every child module exits zero
- Every parameter `.bicepparam.example` passes `bicep build-params`

Full acceptance (including `az deployment sub what-if` against a real subscription and idempotency verification) lives with the adopter — the repo itself has no subscription to deploy against.
