targetScope = 'resourceGroup'

param subnet object
param vnet string
param location string = resourceGroup().location


module vms 'modVm.bicep' = [ for vm in subnet.vms: {
  name: 'vm-${location}-${vm.name}'
  scope: resourceGroup()
  params: {
     vmName: 'vm-${location}-${vm.name}' 
     subnetId:  resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks/subnets', vnet, subnet.name)
     location: location
     installNginx: (contains(vm,'installNginx') && vm.installNginx) ? true : false
     publicIp: (contains(vm,'publicIp') && vm.publicIp) ? true : false
  }
}]
