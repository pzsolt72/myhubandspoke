targetScope = 'subscription'

param parOnPrem object = {
  location: 'uksouth'
  networkOnprem: '172.16.0.0/24'
  subnets: [
    {
      name: 'GatewaySubnet'
      networkRange: '172.16.0.0/27'
    }
    {
      name: 'onprem'
      networkRange: '172.16.0.32/27'
      vms: [
         {
           name: 'onprem-1'
         }
         {
           name: 'onprem-2'
         }
      ]
    }
  ]
}

param parTopology object = {

  privateDnsZones: [
    {
      name: 'myhubandspoke.com'
    }
  ]

  hubs: {
    northeurope: {
      networkHub: '10.20.0.0/16'
      privateDnsZoneName: 'myhubandspoke.com'
      vpn: {
        p2sAddressPrefix: '192.168.100.0/24'
      }
      peers: [
       // 'westeurope' 
      ]
      subnets: [
        {
          name: 'GatewaySubnet'
          networkRange: '10.20.1.0/24' }
        {
          name: 'AzureFirewallSubnet'
          networkRange: '10.20.2.0/24'
        }
        {
          name: 'hub-subnet1'
          networkRange: '10.20.3.0/24'
          vms: [
            {
              name: 'hub-01'
              publicIp: true
            }
          ]
        }
      ]
      spokes: [
        {
          name: 'spoke-01'
          networkSpoke: '10.200.0.0/16'
          subnets: [
            {
              name: 'sub1'
              networkRange: '10.200.1.0/24'
              vms: [
                {
                  name: 'spoke-01-1'
                  installNginx: true
                }
              ]
            }
          ]
        }
        {
          name: 'spoke-02'
          networkSpoke: '10.201.0.0/16'
          subnets: [
            {
              name: 'sub1'
              networkRange: '10.201.1.0/24'
              vms: [
                {
                  name: 'spoke-02-1'
                  installNginx: true
                }
              ]
            }
          ]
        }
      ]
    }
    
    // westeurope: {
    //   networkHub: '10.10.0.0/16'
    //   privateDnsZoneName: 'myhubandspoke.com'
    //   peers: [
    //     'northeurope' 
    //   ]
    //   subnets : [
    //     {
    //       name: 'GatewaySubnet'
    //       networkRange: '10.10.1.0/24'
    //     }
    //     {
    //       name: 'AzureFirewallSubnet'
    //       networkRange: '10.10.2.0/24'
    //     }
    //     {
    //       name: 'hub-subnet1'
    //       networkRange: '10.10.3.0/24'
    //       vms: [
    //         {
    //           name: 'test'
    //         }
    //       ]
    //     }      
    //   ]
    //   spokes: [
    //     {
    //       name: 'spoke-01'
    //       networkSpoke: '10.100.0.0/16'
    //       subnets : [
    //         {
    //           name: 'sub1'
    //           networkRange: '10.100.1.0/24'      
    //           vms: [
    //             {
    //               name: 'spoke-01-1'
    //             }
    //           ]
    //         }
    //       ]
    //     }
    //   ]
    // }
    
    }
}

// create onprem ( simulated on azure! )
module modOnprem 'onprem/modOnPrem.bicep' = {
  name: 'onprem' 
  params: {
    parOnPrem: parOnPrem
  }
}

// create hubs from the topology
module modHubs 'hub/modHubs.bicep' = {
  name: 'hubs'
  params: {
    hubs: parTopology.hubs
  }
}

// create private dnszone
resource resourceGroupCommon 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-myhubandspoke-common'
  location: 'northeurope'
}
module modPrivateDns 'common/modPrivateDnsZone.bicep' = [ for dns in parTopology.privateDnsZones: {
  name: 'mhs-${replace(dns.name,'.','-')}private-dns'
  scope: resourceGroup('rg-myhubandspoke-common')
  params: {
    dnsZone: dns.name
  }
}]

// create spokes from topology
module modSpokes 'spoke/modSpokes.bicep' = [for region in items(parTopology.hubs) : {
  name: 'spoke-${region.key}'
  dependsOn: [
    modHubs
  ]
  params: {
    location: region.key
    region: region.value
  }
}]
