targetScope = 'subscription'


param hub object
param location string

var varRgName = 'rg-${location}-hub'
var varVnetName = 'vnet-${location}-hub'


resource resourceGroupHub 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: varRgName
  location: location
}

// create vnets
module modHubNetwork '../common/modVnet.bicep' = {
  name: varVnetName
  scope: resourceGroup(varRgName)
  dependsOn: [
    resourceGroupHub
  ]
  params: {
    vnetName: varVnetName
    location: location
    netrange: hub.networkHub
    subnets: hub.subnets
  }
}

// create vpngw
module modVpnGw 'modVpnGw.bicep' = {
  name: 'vpn-${location}-hub'
  scope: resourceGroup(varRgName)
  dependsOn: [
    resourceGroupHub
    modHubNetwork
  ]
  params: {
    location: location
  }
}


module modFirewall 'modFirewall.bicep' = {
  name: 'fw-${location}-hub'
  scope: resourceGroup(varRgName)
  dependsOn: [
    resourceGroupHub
    modHubNetwork
  ]
  params: {
    location: location
  }
}

// create test vms
module modHubVms '../common/modVms.bicep' = [for subnet in hub.subnets: if ( subnet.name != 'GatewaySubnet' && subnet.name != 'AzureFirewallSubnet' && contains(subnet,'vms') && !empty(subnet.vms) ) {
  name: 'vms-${subnet.name}'
  scope: resourceGroup(varRgName)
  dependsOn: [
    resourceGroupHub
    modHubNetwork
  ]
  params: {
    vnet: varVnetName
    subnet: subnet
    location: location
  }
}]
