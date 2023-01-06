targetScope = 'subscription'

param hubs object

// create hub resource groups and networks
module modHub 'modHub.bicep' = [for region in items(hubs): {
  name: 'hub-${region.key}'
  params: {
    location: region.key
    hub: region.value
  }
}]

// create hub global peernings
module modHubPeerings 'modGlobalPeering.bicep' = [for region in items(hubs): {
  name: 'global-hub-peering-${region.key}'
  dependsOn: [
    modHub
  ]
  scope: resourceGroup('rg-${region.key}-hub')
  params: {
    vnetFrom: 'vnet-${region.key}-hub'
    peers: region.value.peers
    
  }
}]
