targetScope = 'resourceGroup'

@secure()
param vm_admin_password string
param vnet_name string = 'bastion_vm_vnet'
param kv_name string = 'vm-secrets-${toLower(uniqueString(resourceGroup().id))}'
param disk_encryption_keyname string = 'diskencryptionkey'
param bastion_name string = 'bastion-remote-access'
param vm_name string = 'vm-jumpbox'

module vnetModule 'modules/vnet.bicep' = {
  name: 'vnetDeploy'
  params: {
    name: vnet_name
    location: resourceGroup().location
  }
}

module kvModule 'modules/keyvault.bicep' = {
  name: 'kvDeploy'
  params: {
    name: kv_name
    location: resourceGroup().location
  }
}

module diskEncryptionKeyModule 'modules/diskEncryptionKey.bicep' = {
  name: 'diskEncryptionKeyDeploy'
  dependsOn: [
    kvModule
  ]
  params: {
    keyVaultName: kv_name
    diskEncryptionKeyName: disk_encryption_keyname
  }
}

module bastionModule 'modules/bastion.bicep' = {
  name: 'bastionDeploy'
  params: {
    name: bastion_name
    subnetId: vnetModule.outputs.bastion_subnet_id
  }
}

module vmModule 'modules/vm.bicep' = {
  name: 'vmDeploy'
  params: {
    name: vm_name
    subnetId: vnetModule.outputs.vm_subnet_id
    adminPassword: vm_admin_password
  }
}

output resource_group_name string = resourceGroup().name
output vnet_id string = vnetModule.outputs.vnet_Id
output vnet_name string = vnetModule.outputs.vnet_name
output keyvault_name string = kvModule.outputs.keyvault_name
output keyvault_uri string = kvModule.outputs.keyvault_uri
