// identity.bicep — user-assigned managed identity used by the Container App
// to authenticate to the database, pull from ACR, and emit telemetry to
// Application Insights.
//
// No passwords, no client secrets. Workload identity federation for CI
// deploys is a separate configuration (see .github/workflows/dotnet-azure-deploy.yml).

targetScope = 'resourceGroup'

param baseName string
param location string
param tags object

resource apiIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: 'id-${baseName}-api'
  location: location
  tags: tags
}

output id string = apiIdentity.id
output name string = apiIdentity.name
output principalId string = apiIdentity.properties.principalId
output clientId string = apiIdentity.properties.clientId
