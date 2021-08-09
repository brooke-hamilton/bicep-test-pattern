
var name = 'testkv-corpnet'

module kvModule '../modules/keyvault.bicep' = {
  name: 'kv-module-test'
  params: {
    name: name
    location: resourceGroup().location
    enableSoftDelete:false
    //diskEncryptionKeyName: 'diskencryptionkey'
  }
}
