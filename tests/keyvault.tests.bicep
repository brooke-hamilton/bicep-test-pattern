
param name string = 'testkv-${toLower(uniqueString(utcNow()))}'

module kvModule '../modules/keyvault.bicep' = {
  name: 'kv-module-test'
  params: {
    name: name
    location: resourceGroup().location
  }
}
