param vnetName string
param location string
param netrange string
param subnets array
param routeTableId string = ''

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        netrange
      ]
    }
    subnets: [for subnet in subnets : {
        name: subnet.name
        properties: ( routeTableId != '' ) ? {
          addressPrefix: subnet.networkRange
          routeTable:  {
            id: routeTableId
          } 
        } : { 
          addressPrefix: subnet.networkRange
        }
    }]
  }
}

output vnetId string = virtualNetwork.id
output vnetName string = virtualNetwork.name
