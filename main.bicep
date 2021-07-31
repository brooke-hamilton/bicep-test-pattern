
targetScope = 'resourceGroup'

@secure()
param vm_admin_password string

var vnet_name = 'corpnet_access_vnet'
var kv_name = 'corpnet-${toLower(uniqueString(resourceGroup().id))}'
var bastion_name = 'corpnet-bastion'
var vm_name = 'corpnetvm'

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
    subnet: vnetModule.outputs.vm_subnet_id
    adminPassword: vm_admin_password
  }
}

output resource_group_name string = resourceGroup().name
output vnet_id string = vnetModule.outputs.vnet_Id
output vnet_name string = vnetModule.outputs.vnet_name
output keyvault_name string = kvModule.outputs.keyvault_name
output keyvault_uri string = kvModule.outputs.keyvault_uri
