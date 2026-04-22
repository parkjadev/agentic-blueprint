// data.bicep — PostgreSQL Flexible Server with Entra authentication only.
//
// Authentication model:
//   - Password authentication is DISABLED.
//   - An Entra principal (user, group, or service principal) is designated
//     as the database administrator. Operators connect as that identity.
//   - The API's user-assigned managed identity is also registered as an
//     Entra admin so the running container can obtain an access token and
//     connect to Postgres without a password in any connection string.
//
// Networking: private-access via VNET integration + private DNS zone
// linking handled by network.bicep.

targetScope = 'resourceGroup'

param baseName string
param location string
param tags object

@description('Subnet ID delegated to Microsoft.DBforPostgreSQL/flexibleServers.')
param delegatedSubnetId string

@description('Private DNS zone ID for privatelink.postgres.database.azure.com.')
param privateDnsZoneId string

@description('Object ID of the Entra principal set as the primary database administrator.')
param administratorPrincipalId string

@description('Display name of the Entra administrator principal.')
param administratorPrincipalName string

@description('Principal ID of the API\'s user-assigned managed identity.')
param apiIdentityPrincipalId string

@description('Display name of the API\'s managed identity (typically the identity resource name).')
param apiIdentityPrincipalName string

@description('Postgres major version.')
param postgresVersion string = '16'

@description('SKU tier + name for the Flexible Server.')
param skuName string = 'Standard_B2s'

@description('SKU tier (Burstable / GeneralPurpose / MemoryOptimized).')
param skuTier string = 'Burstable'

@description('Storage size in GB.')
@minValue(32)
param storageSizeGB int = 32

@description('Application database name.')
param databaseName string = 'appdb'

resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: 'psql-${baseName}'
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    version: postgresVersion
    storage: {
      storageSizeGB: storageSizeGB
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: subscription().tenantId
    }
    network: {
      delegatedSubnetResourceId: delegatedSubnetId
      privateDnsZoneArmResourceId: privateDnsZoneId
    }
  }
}

resource appDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2024-08-01' = {
  parent: postgres
  name: databaseName
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

resource administratorPrincipal 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2024-08-01' = {
  parent: postgres
  name: administratorPrincipalId
  properties: {
    principalType: 'User'
    principalName: administratorPrincipalName
    tenantId: subscription().tenantId
  }
}

resource apiIdentityAdministrator 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2024-08-01' = {
  parent: postgres
  name: apiIdentityPrincipalId
  properties: {
    principalType: 'ServicePrincipal'
    principalName: apiIdentityPrincipalName
    tenantId: subscription().tenantId
  }
  dependsOn: [
    administratorPrincipal
  ]
}

output fqdn string = postgres.properties.fullyQualifiedDomainName
output databaseName string = appDatabase.name
output serverName string = postgres.name
