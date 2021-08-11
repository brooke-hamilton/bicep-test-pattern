var keyVaultName = 'testkv-encryptionkey'
var diskEncryptionKeyName = 'testkey'

module keyVaultModule '../modules/keyvault.bicep' = {
  name:'keyVaultDeployment'
  params:{
    name: keyVaultName
    location: resourceGroup().location
    
  }
}

module diskEncryptionKeyModule '../modules/diskEncryptionKey.bicep' = {
  name: 'diskEncryptionKeyDeployment'
  dependsOn: [
    keyVaultModule
  ]
  params: {
    keyVaultName: keyVaultName
    diskEncryptionKeyName: diskEncryptionKeyName
  }
}
