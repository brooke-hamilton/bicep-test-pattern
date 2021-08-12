var keyVaultName = 'testkv-encryptionkey7'
var diskEncryptionKeyName = 'testkey'

module keyVaultModule '../modules/keyvault.bicep' = {
  name:'keyVaultDeployment'
  params:{
    name: keyVaultName
    location: resourceGroup().location
    enableSoftDelete: false
  }
}

module diskEncryptionKeyModule '../modules/diskEncryptionKey.bicep' = {
  name: 'diskEncryptionKeyDeployment'
  params: {
    keyVaultName: keyVaultModule.outputs.keyvault_name
    diskEncryptionKeyName: diskEncryptionKeyName
  }
}
