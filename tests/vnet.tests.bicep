module vnetModule '../modules/vnet.bicep' = {
  name: 'vnet-test'
  params: {
    name: 'vnet-test'
    location: resourceGroup().location
  }
}
