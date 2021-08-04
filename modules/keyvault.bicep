
param name string
param location string
param encryptionKeyName string

resource kvResource 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    enableRbacAuthorization: false
    accessPolicies: [
    ]
  }
}

resource kvDiskEncryptionKeyResource 'Microsoft.KeyVault/vaults/keys@2019-09-01' = {
  name: encryptionKeyName
  parent: kvResource
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

output keyvault_name string = kvResource.name
output keyvault_uri string = kvResource.properties.vaultUri
