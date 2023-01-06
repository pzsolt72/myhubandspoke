


resource zone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'myhubandspoke.com'
  scope:  resourceGroup('rg-myhubandspoke-common')
}



output name string = zone.name
output id string = zone.id


