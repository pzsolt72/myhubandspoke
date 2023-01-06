param vnet1 string
param vnet2 string

param vnet2Rg string

param allowVirtualNetworkAccess bool = true
param allowForwardedTraffic bool = true
param allowGatewayTransit bool = false
param useRemoteGateways bool = false
param doNotVerifyRemoteGateways bool = true

//This creates a peering from vnet1 to vnet2
resource peer1 'microsoft.network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: '${vnet1}/peering-to-${vnet2}'
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    doNotVerifyRemoteGateways: doNotVerifyRemoteGateways
    remoteVirtualNetwork: {
      id: resourceId(vnet2Rg, 'Microsoft.Network/virtualNetworks', vnet2)
    }
  }
}

