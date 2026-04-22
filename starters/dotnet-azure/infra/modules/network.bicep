// network.bicep — VNET + subnets for Container Apps and the database tier.
//
// Dev/prod parity: the starter ships VNET-integrated from day one because
// an adopter who evaluates on a non-VNET dev and then adopts in prod will
// discover integration issues too late. The cost is modest; the parity is
// load-bearing.
//
// Subnet sizing:
//   - Container Apps environment (workload profile mode): /23 minimum
//   - PostgreSQL Flexible Server (delegated):              /28
//   - Private endpoints (for Azure SQL or future additions): /28

targetScope = 'resourceGroup'

param baseName string
param location string
param tags object
@allowed([ 'postgres', 'azuresql' ])
param dataProvider string

var vnetAddressPrefix = '10.40.0.0/20'
var environmentSubnetPrefix = '10.40.0.0/23'
var databaseSubnetPrefix = '10.40.2.0/28'
var privateEndpointSubnetPrefix = '10.40.2.16/28'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-${baseName}'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [ vnetAddressPrefix ]
    }
    subnets: [
      {
        name: 'snet-containerapps'
        properties: {
          addressPrefix: environmentSubnetPrefix
          delegations: [
            {
              name: 'containerapps-delegation'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }
      }
      {
        name: 'snet-postgres'
        properties: {
          addressPrefix: databaseSubnetPrefix
          delegations: [
            {
              name: 'postgres-delegation'
              properties: {
                serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
              }
            }
          ]
        }
      }
      {
        name: 'snet-privateendpoints'
        properties: {
          addressPrefix: privateEndpointSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// Private DNS zone for Postgres. The data.bicep module links this to the
// VNET when dataProvider=postgres; when dataProvider=azuresql the zone is
// still created but unlinked — cheap (cents per month) and keeps the
// module boundary clean.
resource postgresPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (dataProvider == 'postgres') {
  name: 'privatelink.postgres.database.azure.com'
  location: 'global'
  tags: tags
}

resource postgresPrivateDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (dataProvider == 'postgres') {
  parent: postgresPrivateDnsZone
  name: 'vnet-link'
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

output vnetId string = vnet.id
output environmentSubnetId string = '${vnet.id}/subnets/snet-containerapps'
output databaseSubnetId string = '${vnet.id}/subnets/snet-postgres'
output privateEndpointSubnetId string = '${vnet.id}/subnets/snet-privateendpoints'
output postgresPrivateDnsZoneId string = dataProvider == 'postgres' ? postgresPrivateDnsZone!.id : ''
