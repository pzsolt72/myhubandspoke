param location string = resourceGroup().location

param gateway object = {
  name: 'vpn-${location}-hub'
  gatewayType: 'Vpn'
  sku: 'VpnGw1'
  vpnType: 'RouteBased'
  generation: 'Generation1'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  asn: 65515
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: 65515
    bgpPeeringAddress: ''
    peerWeight: 5
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'ip-vpn-${location}-hub'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: 'vpn-${location}-hub'
    }
    idleTimeoutInMinutes: 4
  }
}

resource resGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' =  {
  name: gateway.name
  location: location
  dependsOn: [

  ]
  tags: {}
  properties: {
    activeActive: gateway.activeActive
    enableBgp: gateway.enableBgp
    enableBgpRouteTranslationForNat: gateway.enableBgpRouteTranslationForNat
    enableDnsForwarding: gateway.enableDnsForwarding
    bgpSettings: (gateway.enableBgp) ? gateway.bgpSettings : null
    gatewayType: gateway.gatewayType
    vpnGatewayGeneration: (gateway.gatewayType == 'VPN') ? gateway.generation : 'None'
    vpnType: gateway.vpnType
    sku: {
      name: gateway.sku
      tier: gateway.sku
    }

    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks/subnets', 'vnet-${location}-hub', 'GatewaySubnet')
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]

    vpnClientConfiguration: {
      vpnAuthenticationTypes: [
        'Certificate'
      ]
      vpnClientAddressPool: {
        addressPrefixes: [
          '192.168.100.0/24'
        ]
      }
      vpnClientProtocols: [
        'OpenVPN'
        'IkeV2'
      ]
      vpnClientRootCertificates: [
        {
          name: 'p2siteroot'
          properties: {
            publicCertData: 'MIIC5zCCAc+gAwIBAgIQQHsjDGAF9otO1dRGrdzJSDANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDDAtQMlNSb290Q2VydDAeFw0yMjExMjkwODQwMjJaFw0yMzExMjkwOTAwMjJaMBYxFDASBgNVBAMMC1AyU1Jvb3RDZXJ0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv9W2v3byH53kwGJVkbV6F8O5iv/3p1rCCYTaZ7rRM0ap71Pc9xC3cB6UojKau1yw7a81AfryMpYJawUdQxr3tLXyvm1Bog2xFrQxCvxRmQWcmCMbsNnLZR3ePfOfOLK0lCu30TR5cxWk7qrZ8GEg/cad905VEBQ/UKxlBV3xR9nffW4suMNmhKIWz9of3dI8knFGFadwJmnUhZe0I5uwbMX/hOITYPZRNcK+4JedjpDq0iLz37n0yi/xe84etOPHc3ERKhWCkZtdTPr/WHy7YFRU3w6qudtzyPit0Kq6UN+hScHXL6p/lckJzXnRig+lwE2fDSwz2BevFD/jZbWktQIDAQABozEwLzAOBgNVHQ8BAf8EBAMCAgQwHQYDVR0OBBYEFNCJ1kqm8bfmuNjQ0lugv+AK0pW7MA0GCSqGSIb3DQEBCwUAA4IBAQAhaUuNvbv+5Qo5BhF0dt33SZjzOEUPTZ3mrHr0zFUmYYlgBC1IJnB2czCE3R0yjT/wzfJ0OpVV1JuG1X623vFiMB8j2ZFPFHwVElWLSSgYARq/kEd+pW3rVseOV0lbDop8U2lOTIqMJlFBpD2jpG7Xqt3v4HN1Ztx7FvzTytAOFpxfL53hOgG3/Dj+EB09Gf9KyEGs/GxJ8TM0Fsleu6/xrwCPHFWr5bjwVuSnXfIQayE+5hgjscUb1ILTfQ4ZVVChPV3wTg0g1/4YDXB5DI3CmhYI/PV57sQSjgqNv0BICy3Wph08q6Iyxif3CrSgaBYzBQCWmkDOemycGoRXMxIc'
          }
        }
      ]
    }



  }
}
