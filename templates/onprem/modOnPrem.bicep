targetScope = 'subscription'

param parOnPrem object 
var varRgName = 'rg-onprem'
var varVnetName = 'vnet-onprem'

// create resource group
resource resourceGroupOnprem 'Microsoft.Resources/resourceGroups@2021-04-01' =  {
  name: varRgName
  location: parOnPrem.location
}


// create vnets
module modOnpremNetwork '../common/modVnet.bicep' =  {
  name: varVnetName
  scope: resourceGroup(varRgName)
  dependsOn: [
    resourceGroupOnprem
  ]
  params: {
    vnetName: varVnetName
    location: parOnPrem.location
    netrange: parOnPrem.networkOnprem
    subnets: parOnPrem.subnets
  }
}

// create test vms
module modOnpremVms '../common/modVms.bicep' = [for subnet in parOnPrem.subnets: if ( subnet.name != 'GatewaySubnet' && subnet.name != 'AzureFirewallSubnet' && contains(subnet,'vms') && !empty(subnet.vms) ) {
  name: 'vms-${subnet.name}'
  scope: resourceGroup(varRgName)
  dependsOn: [ 
    modOnpremNetwork
   ]
  params: {
    vnet: varVnetName
    subnet: subnet
    location: parOnPrem.location
  }
}]
