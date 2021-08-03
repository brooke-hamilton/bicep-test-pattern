targetScope='resourceGroup'

module vnetModule 'vnet.bicep' = {
  name: 'vnet-test'
  params: {
    name: 'vnet-test'
    location: resourceGroup().location
  }
}
