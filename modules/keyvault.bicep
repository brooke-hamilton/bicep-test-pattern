
param name string = 'kv-${toLower(uniqueString(utcNow()))}'
param location string = 'eastus'

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

output keyvault_name string = kvResource.name
output keyvault_uri string = kvResource.properties.vaultUri
