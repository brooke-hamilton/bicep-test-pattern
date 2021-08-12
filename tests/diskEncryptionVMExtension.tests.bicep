@secure()
param windowsAdminPassword string
var keyVaultName = 'vm-encryption-test-v10'
var diskEncryptionKeyName = 'testkey'
var vnetName = 'vm-encryption-test-vnet'
var vmName = 'vm-crypt-tst-vm'

module vmVnet '../modules/vnet.bicep' = {
  name: 'vmVnetDeploy'
  params: {
    name: vnetName
    location: resourceGroup().location
  }
}

module vmModule '../modules/vm.bicep' = {
  name: 'vmTestDeploy'
  params:{
    name: vmName
    subnetId: vmVnet.outputs.vm_subnet_id
    adminPassword: windowsAdminPassword
  }
}

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

module diskEncryptionVMExtensionModule '../modules/diskEncryptionVMExtension.bicep' = {
  name: 'diskEncryptionVMExtensionDeployment'
  params: {
    vmName: vmModule.outputs.vm_name
    keyVaultName: keyVaultModule.outputs.keyvault_name
    encryptionKeyName: diskEncryptionKeyModule.outputs.disk_encryption_key_name
  }
}
