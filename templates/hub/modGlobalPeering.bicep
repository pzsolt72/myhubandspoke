param vnetFrom string
param peers array


//This creates a peering from vnetFrom to vnetTo
module modHubPeer '../common/modPeering.bicep' = [for peer in peers: {
  name: '${vnetFrom}-peering-to-${peer}'
  params: {
    vnet1: vnetFrom
    vnet2: 'vnet-${peer}-hub'
    vnet2Rg: 'rg-${peer}-hub'
  }
}]


