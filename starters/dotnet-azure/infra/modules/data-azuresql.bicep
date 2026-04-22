// data-azuresql.bicep — Azure SQL Database variant.
//
// Same contract as data.bicep (Postgres): Entra-only auth, managed-identity
// access for the API. Selected by setting `dataProvider = 'azuresql'` in
// main.bicep.
//
// Swap cost when moving between providers:
//   - EF provider package flips (`Npgsql.EntityFrameworkCore.PostgreSQL`
//     → `Microsoft.EntityFrameworkCore.SqlServer`) in Phase 3.
//   - Connection string format changes; ConnectionStrings__AppDb env var
//     in compute.bicep is what the API reads.

targetScope = 'resourceGroup'

param baseName string
param location string
param tags object

@description('Object ID of the Entra principal set as the SQL administrator.')
param administratorPrincipalId string

@description('Display name of the Entra administrator principal.')
param administratorPrincipalName string

@description('Principal ID of the API\'s user-assigned managed identity.')
param apiIdentityPrincipalId string

@description('Display name of the API\'s managed identity.')
param apiIdentityPrincipalName string

@description('Application database name.')
param databaseName string = 'appdb'

@description('SKU for the SQL Database.')
param databaseSku object = {
  name: 'GP_S_Gen5_1'
  tier: 'GeneralPurpose'
  family: 'Gen5'
  capacity: 1
}

resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: 'sql-${baseName}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Disabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: administratorPrincipalName
      principalType: 'User'
      sid: administratorPrincipalId
      tenantId: subscription().tenantId
    }
  }
}

resource appDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags
  sku: databaseSku
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    autoPauseDelay: 60
    minCapacity: json('0.5')
    zoneRedundant: false
  }
}

// Register the API identity as an Entra-authenticated user inside the database
// via a post-deployment script is a Phase 3 concern (adds a tangential
// Microsoft.Resources/deploymentScripts resource). For now, operators grant
// the role manually via T-SQL after first deploy — documented in README.

output fqdn string = sqlServer.properties.fullyQualifiedDomainName
output databaseName string = appDatabase.name
output serverName string = sqlServer.name
#disable-next-line BCP318
output apiIdentityPrincipalHint string = '${apiIdentityPrincipalName}:${apiIdentityPrincipalId}'
