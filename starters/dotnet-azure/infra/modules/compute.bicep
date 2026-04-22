// compute.bicep — Azure Container Registry + Container Apps Environment +
// Container App, bound to the user-assigned managed identity from identity.bicep.
//
// Defaults:
//   - Consumption workload profile (scale to zero)
//   - Ingress external on port 8080 (ASP.NET Core default)
//   - Managed-identity ACR pull (no admin user, no passwords)
//   - Env vars wire the container to Entra, App Insights, and the database

targetScope = 'resourceGroup'

param baseName string
param location string
param tags object

param containerImage string
param apiIdentityId string
param apiIdentityClientId string
param apiIdentityPrincipalId string
param environmentSubnetId string

param logAnalyticsWorkspaceId string
param logAnalyticsWorkspaceCustomerId string
@secure()
param logAnalyticsWorkspaceSharedKey string
@secure()
param applicationInsightsConnectionString string

param entraTenantId string
param apiClientId string

@allowed([ 'postgres', 'azuresql' ])
param dataProvider string
param databaseFqdn string
param databaseName string

@description('Minimum replicas. Set to 0 for scale-to-zero.')
@minValue(0)
param minReplicas int = 0

@description('Maximum replicas.')
@minValue(1)
param maxReplicas int = 3

@description('Container CPU request (cores).')
param cpu string = '0.5'

@description('Container memory request.')
param memory string = '1.0Gi'

var connectionString = dataProvider == 'postgres'
  ? 'Host=${databaseFqdn};Port=5432;Database=${databaseName};Username=${apiIdentityClientId};SslMode=Require'
  : 'Server=tcp:${databaseFqdn},1433;Initial Catalog=${databaseName};Authentication=Active Directory Default;Encrypt=True;'

// ─── Azure Container Registry ────────────────────────────────────────────────

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: 'acr${replace(baseName, '-', '')}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: acr
  name: guid(acr.id, apiIdentityPrincipalId, acrPullRoleId)
  properties: {
    roleDefinitionId: acrPullRoleId
    principalId: apiIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// ─── Container Apps environment ──────────────────────────────────────────────

resource environmentResource 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'cae-${baseName}'
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspaceCustomerId
        sharedKey: logAnalyticsWorkspaceSharedKey
      }
    }
    vnetConfiguration: {
      infrastructureSubnetId: environmentSubnetId
      internal: false
    }
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    zoneRedundant: false
  }
}

// ─── Container App ───────────────────────────────────────────────────────────

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'ca-${baseName}'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${apiIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: environmentResource.id
    workloadProfileName: 'Consumption'
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
        allowInsecure: false
      }
      registries: [
        {
          server: acr.properties.loginServer
          identity: apiIdentityId
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'api'
          image: containerImage
          resources: {
            cpu: json(cpu)
            memory: memory
          }
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Production'
            }
            {
              name: 'ASPNETCORE_URLS'
              value: 'http://+:8080'
            }
            {
              name: 'AzureAd__TenantId'
              value: entraTenantId
            }
            {
              name: 'AzureAd__ClientId'
              value: apiClientId
            }
            {
              name: 'AzureAd__Audience'
              value: 'api://${apiClientId}'
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: apiIdentityClientId
            }
            {
              name: 'ConnectionStrings__AppDb'
              value: connectionString
            }
            {
              name: 'ApplicationInsights__ConnectionString'
              value: applicationInsightsConnectionString
            }
          ]
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                path: '/health'
                port: 8080
              }
              initialDelaySeconds: 10
              periodSeconds: 30
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/health'
                port: 8080
              }
              initialDelaySeconds: 5
              periodSeconds: 10
            }
          ]
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
  dependsOn: [
    acrPullAssignment
  ]
}

output acrLoginServer string = acr.properties.loginServer
output environmentId string = environmentResource.id
output ingressFqdn string = containerApp.properties.configuration.ingress.fqdn
output latestRevisionName string = containerApp.properties.latestRevisionName
