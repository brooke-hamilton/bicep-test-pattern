var vnet_name = 'bastion-test-instance-vnet'
var bastion_name = 'bastion-test-instance'

module vnetModule '../modules/vnet.bicep' = {
  name: 'vnetDeploy'
  params: {
    name: vnet_name
    location: resourceGroup().location
  }
}

module bastionModule '../modules/bastion.bicep' = {
  name: 'bastionDeploy'
  params: {
    name: bastion_name
    subnetId: vnetModule.outputs.bastion_subnet_id
  }
}
