// main.bicep — subscription-scoped orchestrator for the .NET + Azure starter.
//
// Creates a resource group and composes the child modules (observability,
// network, identity, data, compute). Selects the data provider module via
// the `dataProvider` parameter so the same starter serves Postgres or
// Azure SQL with no other code changes.
//
// Deploy:
//   az deployment sub create \
//     --location <region> \
//     --name dotnet-azure-<env>-$(date +%s) \
//     --template-file main.bicep \
//     --parameters parameters/<env>.bicepparam
//
// Validate only:
//   bicep build main.bicep --stdout > /dev/null

targetScope = 'subscription'

// ─── Parameters ──────────────────────────────────────────────────────────────

@description('Environment label used in resource names and tags.')
@allowed([ 'dev', 'staging', 'prod' ])
param environmentName string

@description('Azure region for all resources.')
param location string

@description('Resource group name (created by this template).')
param resourceGroupName string

@description('Base name used as a prefix for every resource.')
@minLength(3)
@maxLength(12)
param baseName string

@description('Which data-tier module to instantiate. Both are supported; pick one per deployment.')
@allowed([ 'postgres', 'azuresql' ])
param dataProvider string = 'postgres'

@description('Entra tenant ID that issues JWTs the API accepts.')
param entraTenantId string

@description('Application (client) ID of the API app registration in Entra.')
param apiClientId string

@description('Container image reference. Defaults to Azure\'s quickstart image so the infra deploys before Phase 4 ships the real Dockerfile.')
param containerImage string = 'mcr.microsoft.com/k8se/quickstart:latest'

@description('Object ID of the Entra principal (user/group/service principal) set as the database administrator.')
param databaseAdminObjectId string

@description('Display name of the Entra principal set as the database administrator.')
param databaseAdminDisplayName string

@description('Common tags applied to every resource.')
param tags object = {
  environment: environmentName
  starter: 'dotnet-azure'
  managedBy: 'bicep'
}

// ─── Resource group ──────────────────────────────────────────────────────────

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// ─── Modules ─────────────────────────────────────────────────────────────────

module observability 'modules/observability.bicep' = {
  name: 'observability'
  scope: rg
  params: {
    baseName: baseName
    location: location
    tags: tags
  }
}

module network 'modules/network.bicep' = {
  name: 'network'
  scope: rg
  params: {
    baseName: baseName
    location: location
    tags: tags
    dataProvider: dataProvider
  }
}

module identity 'modules/identity.bicep' = {
  name: 'identity'
  scope: rg
  params: {
    baseName: baseName
    location: location
    tags: tags
  }
}

module dataPostgres 'modules/data.bicep' = if (dataProvider == 'postgres') {
  name: 'data-postgres'
  scope: rg
  params: {
    baseName: baseName
    location: location
    tags: tags
    delegatedSubnetId: network.outputs.databaseSubnetId
    privateDnsZoneId: network.outputs.postgresPrivateDnsZoneId
    administratorPrincipalId: databaseAdminObjectId
    administratorPrincipalName: databaseAdminDisplayName
    apiIdentityPrincipalId: identity.outputs.principalId
    apiIdentityPrincipalName: identity.outputs.name
  }
}

module dataSql 'modules/data-azuresql.bicep' = if (dataProvider == 'azuresql') {
  name: 'data-azuresql'
  scope: rg
  params: {
    baseName: baseName
    location: location
    tags: tags
    administratorPrincipalId: databaseAdminObjectId
    administratorPrincipalName: databaseAdminDisplayName
    apiIdentityPrincipalId: identity.outputs.principalId
    apiIdentityPrincipalName: identity.outputs.name
  }
}

module compute 'modules/compute.bicep' = {
  name: 'compute'
  scope: rg
  params: {
    baseName: baseName
    location: location
    tags: tags
    containerImage: containerImage
    apiIdentityId: identity.outputs.id
    apiIdentityClientId: identity.outputs.clientId
    apiIdentityPrincipalId: identity.outputs.principalId
    environmentSubnetId: network.outputs.environmentSubnetId
    logAnalyticsWorkspaceId: observability.outputs.workspaceId
    logAnalyticsWorkspaceCustomerId: observability.outputs.workspaceCustomerId
    logAnalyticsWorkspaceSharedKey: observability.outputs.workspaceSharedKey
    applicationInsightsConnectionString: observability.outputs.applicationInsightsConnectionString
    entraTenantId: entraTenantId
    apiClientId: apiClientId
    dataProvider: dataProvider
    databaseFqdn: dataProvider == 'postgres' ? dataPostgres!.outputs.fqdn : dataSql!.outputs.fqdn
    databaseName: dataProvider == 'postgres' ? dataPostgres!.outputs.databaseName : dataSql!.outputs.databaseName
  }
}

// ─── Outputs ─────────────────────────────────────────────────────────────────

output resourceGroupName string = rg.name
output containerAppFqdn string = compute.outputs.ingressFqdn
output containerAppUrl string = 'https://${compute.outputs.ingressFqdn}'
output apiIdentityClientId string = identity.outputs.clientId
output applicationInsightsConnectionString string = observability.outputs.applicationInsightsConnectionString
