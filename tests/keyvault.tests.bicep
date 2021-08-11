var name = 'bastion-test-vault'

module kvModule '../modules/keyvault.bicep' = {
  name: 'kv-module-test'
  params: {
    name: name
    location: resourceGroup().location
    enableSoftDelete:false
  }
}
