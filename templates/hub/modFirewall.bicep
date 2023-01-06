

param location string = resourceGroup().location

var firewallPolicyName = 'fp-${location}-hub'
var firewallName = 'fp-${location}-hub'
var firewallTier = 'Standard'
var hubVnetName = 'vnet-${location}-hub'

resource hubVnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing  = {
  name: hubVnetName
}

resource firewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: 'AzureFirewallSubnet'
  parent: hubVnet

}

resource resFirewallpublicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'ip-fw-${location}-hub'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: ' Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: 'vpn-${location}-hub-${uniqueString(firewallSubnet.id)}'
    }
    idleTimeoutInMinutes: 4
  }
}

resource resFirewallPolicies 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: firewallPolicyName
  location: location
  properties: {
    dnsSettings: {
      enableProxy: false
    }
    sku: {
      tier: firewallTier
    }
  }

  resource resDefaultRuleCollectionGroup 'ruleCollectionGroups@2022-05-01' = {
    name: 'DefaultNetworkRuleCollectionGroup'
    properties: {
      priority: 65000
      ruleCollections: [
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          action: {
            type: 'Allow'
          }
          name: 'PeeringRules'
          priority: 65000
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'AllowEverything'
              ipProtocols: [
                'Any'
              ]
              sourceAddresses: [
                '*'
              ]
              sourceIpGroups: []
              destinationAddresses: [
                '*'
              ]
              destinationIpGroups: []
              destinationFqdns: []
              destinationPorts: [
                '*'
              ]
            }
          ]
        }
      ]
    }
  }

}

// AzureFirewall
resource resAzureFirewall 'Microsoft.Network/azureFirewalls@2021-08-01' = {
  name: firewallName
  location: location
  zones: []
  properties: {
    ipConfigurations: [
      {
        name: 'public-ip'
        properties: {
          subnet: {
            id: firewallSubnet.id
          }
          publicIPAddress: {
            id: resFirewallpublicIP.id
          }
        }
      }
    ]
    sku: {
      name: 'AZFW_VNet'
      tier: firewallTier
    }
    firewallPolicy: {
      id: resFirewallPolicies.id
    }
  }
}


output firewallIp string = resFirewallpublicIP.id
