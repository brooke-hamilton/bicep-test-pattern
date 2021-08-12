param vmName string
param keyVaultName string
param encryptionKeyName string

var extensionName = 'AzureDiskEncryption'
var extensionVersion = '2.2'
var encryptionOperation = 'EnableEncryption'
var keyEncryptionAlgorithm = 'RSA-OAEP'

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

resource keyVaultKey 'Microsoft.KeyVault/vaults/keys@2019-09-01' existing = {
  name: encryptionKeyName
}

output keyvault_resource_id string = keyVault.id
output keyvault_key_resource_id string = keyVaultKey.id

resource diskEncryptionVMExtensionResource 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: '${vmName}/${extensionName}'
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    settings: {
      EncryptionOperation: encryptionOperation
      KeyVaultURL: keyVault.properties.vaultUri
      KeyVaultResourceId: keyVault.id
      KeyEncryptionKeyURL: keyVaultKey.properties.keyUriWithVersion
      KekVaultResourceId: keyVault.id // Surprsingly, KekVaultResourceId requires the KeyVault ResourceId rather than the KeyVaultKey ResourceId.
      KeyEncryptionAlgorithm: keyEncryptionAlgorithm
      VolumeType: 'All'
      ResizeOSDisk: false
    }
  }
}
