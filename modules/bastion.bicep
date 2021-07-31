
param name string
param subnetId string

var pipName = 'bastion-public-ip'

resource publicIpResource 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: pipName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionResource 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIpResource.id
          }
        }
      }
    ]
  }
}
