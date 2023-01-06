
param dnsZone string

resource symbolicname 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZone
  location: 'global'
  properties: {}
}
