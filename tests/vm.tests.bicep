@secure()
param windowsAdminPassword string

module vmVnet '../modules/vnet.bicep' = {
  name: 'vmVnetDeploy'
  params: {
    name: 'vm-test-subnet'
    location: resourceGroup().location
  }
}

module vmModule '../modules/vm.bicep' = {
  name: 'vmTestDeploy'
  params:{
    name: 'bicep-test-vm'
    subnetId: vmVnet.outputs.vm_subnet_id
    adminPassword: windowsAdminPassword
  }
}
