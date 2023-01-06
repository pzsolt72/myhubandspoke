targetScope = 'subscription'

param region object 
param spoke object
param location string 

param privateDnsZoneRg string = 'rg-myhubandspoke-common'


var varRgName = 'rg-${location}-${spoke.name}'
var varVnetName = 'vnet-${location}-${spoke.name}'

// routes in this region
module modRouteTable '../common/modRouteTable.bicep' = {
  name: 'rt-${spoke.name}'
  scope: resourceGroup(varRgName)
  params: {
    location: location
    name: spoke.name
    region: region
  }

}


// create vnets
module modSpokeNetwork '../common/modVnet.bicep' =  {
  name: varVnetName
  scope: resourceGroup(varRgName)
  dependsOn: [
    modRouteTable
  ]
  params: {
    vnetName: varVnetName
    location: location
    netrange: spoke.networkSpoke
    subnets: spoke.subnets
    routeTableId: modRouteTable.outputs.routeTableId
  }
}

// link
module modDnsZoneLink '../common/modVnetDnsZoneLink.bicep' = {
  name: 'link-vnet-${location}-${spoke.name}-2-${location}-hub'
  scope: resourceGroup(privateDnsZoneRg)
  dependsOn: [ 
    modSpokeNetwork
  ]
  params: {
    vnetName: modSpokeNetwork.outputs.vnetName
    vnetId: modSpokeNetwork.outputs.vnetId
    privateDnsZoneName: region.privateDnsZoneName
  }

}


// create peer from hub
module modPeerFromHub '../common/modPeering.bicep' = {
  name: 'vnet-${location}-${spoke.name}-2-${location}-hub'
  scope: resourceGroup('rg-${location}-hub')
  dependsOn: [ 
    modSpokeNetwork
  ]
  params: {
    vnet1: 'vnet-${location}-hub' 
    vnet2: varVnetName
    vnet2Rg: varRgName
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}

// create peer to hub
module modPeerToHub '../common/modPeering.bicep' = {
  name: 'vnet-${location}-${spoke.name}-2-${location}-hub'
  scope: resourceGroup(varRgName)
  dependsOn: [ 
    modSpokeNetwork
    modPeerFromHub
  ]
  params: {
    vnet1: varVnetName
    vnet2: 'vnet-${location}-hub'
    vnet2Rg: 'rg-${location}-hub'   
    allowGatewayTransit: false
    useRemoteGateways: true
  }
}

// create test vms
module modSpokeVms '../common/modVms.bicep' = [for subnet in spoke.subnets: if ( subnet.name != 'GatewaySubnet' && subnet.name != 'AzureFirewallSubnet' && contains(subnet,'vms') && !empty(subnet.vms) ) {
  name: 'vms-${subnet.name}'
  scope: resourceGroup(varRgName)
  dependsOn: [ 
    modSpokeNetwork
  ]
  params: {
    vnet: varVnetName
    subnet: subnet
    location: location
  }
}]

