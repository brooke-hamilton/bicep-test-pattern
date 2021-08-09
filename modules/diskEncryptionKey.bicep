
param keyVaultName string
param diskEncryptionKeyName string

resource kvDiskEncryptionKeyResource 'Microsoft.KeyVault/vaults/keys@2019-09-01' = {
  name: '${keyVaultName}/${diskEncryptionKeyName}'
  properties:{
    curveName: null
    keySize: 2048
    kty: 'RSA'
      attributes: {
          enabled: true
          exp: null
          nbf: null
      }
  }
}
