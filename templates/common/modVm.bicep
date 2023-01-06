
param vmName string 

param subnetId string


@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
//param dnsLabelPrefix string = toLower('${vmName}}')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id)}')

@description('Location for all resources.')
param location string = resourceGroup().location

param installNginx bool = false

param publicIp bool = false


var vmSize = 'Standard_B2s'
var osDiskType = 'Standard_LRS'
var publisher = 'Canonical'
var offer = '0001-com-ubuntu-server-focal-daily'
var sku = '20_04-daily-lts-gen2'
var version = 'latest'

var adminUsername = 'azureadmn'
var adminPassword = 'Azureadmn1234.'

var networkSecurityGroupName = 'nsg-${vmName}'
var publicIPAddressName = 'ip-${vmName}'
var networkInterfaceName = 'nic-${vmName}'
var installDockerNginxCommands = 'sudo apt update -y 2>/dev/null  && sudo apt upgrade -y 2>/dev/null && sudo apt-get install curl apt-transport-https ca-certificates software-properties-common -y 2>/dev/null && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && sudo apt install docker-ce -y && sudo systemctl enable docker && sudo docker run -d -p 80:80 nginx '
//var installDockerNginxCommands = 'sudo snap install docker && sudo docker run -d -p 80:80 nginx'

resource publicIpResource 'Microsoft.Network/publicIPAddresses@2021-05-01' = if (publicIp)  {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
    idleTimeoutInMinutes: 4
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      (publicIp) ? {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: (publicIp) ? {
            id: publicIpResource.id
          } : { }
        }
      }:{
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: publisher
        offer: offer
        sku: sku
        version: version
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
}



// custom script extensin install docker + nginx and start
resource vmName_install_apache 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = if (installNginx) {
  parent: vm
  name: 'install_docker_nginx'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: false
    }
    protectedSettings: {
      commandToExecute: installDockerNginxCommands
    }
  }
}


output adminUsername string = adminUsername
output hostname string = ( publicIp ) ?  publicIpResource.properties.dnsSettings.fqdn : ''
output sshCommand string = ( publicIp ) ? 'ssh ${adminUsername}@${publicIpResource.properties.dnsSettings.fqdn}' : ''
