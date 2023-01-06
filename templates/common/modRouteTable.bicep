param location string
param name string
param disableBgb bool = true

param region object


resource spokeRouteTable 'Microsoft.Network/routeTables@2022-05-01' = {
  name: 'rt2-${location}-${name}'
  location: location
  properties: {
    disableBgpRoutePropagation: disableBgb
    routes: []
  }
}

@batchSize(1)
resource spokeRoutes 'Microsoft.Network/routeTables/routes@2022-05-01' =  [for spoke in region.spokes: if (spoke.name!=name)  {
  name: 'to-vnet-${location}-${spoke.name}'
  parent: spokeRouteTable
  properties: {
    addressPrefix: spoke.networkSpoke
    hasBgpOverride: true
    nextHopType: 'VirtualNetworkGateway'
  }
}]

resource p2sRoute 'Microsoft.Network/routeTables/routes@2022-05-01' =  if ( contains(region,'vpn') && contains(region.vpn,'p2sAddressPrefix') ) {
  name: 'to-p2s-${location}-hub'
  dependsOn: [
    spokeRoutes
  ]
  parent: spokeRouteTable
  properties: {
    addressPrefix: region.vpn.p2sAddressPrefix
    hasBgpOverride: true
    nextHopType: 'VirtualNetworkGateway'
  }
}

output routeTableId string = spokeRouteTable.id
