targetScope = 'subscription'

param region object 
param location string 


resource resourceGroupSpoke 'Microsoft.Resources/resourceGroups@2021-04-01' = [for spoke in region.spokes : {
  name: 'rg-${location}-${spoke.name}'
  location: location
}]


// create vnets
module modSpoke 'modSpoke.bicep' = [for spoke in region.spokes : {
  name: 'vnet-${location}-${spoke.name}'
  dependsOn: [
    resourceGroupSpoke
  ]
  params: {
    region: region
    location: location
    spoke: spoke
  }
}]

