param name string
param location string

resource vnetResource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
  }
}

resource bastion_subnetResource 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'AzureBastionSubnet'
  parent: vnetResource
  properties: {
    addressPrefix: '10.10.0.0/27'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vm_subnetResource 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'VM_Subnet_1'
  parent: vnetResource
  dependsOn: [
    bastion_subnetResource
  ]
  properties: {
    addressPrefix: '10.10.1.0/24'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

output vnet_Id string = vnetResource.id
output vnet_name string = vnetResource.name
output bastion_subnet_id string = bastion_subnetResource.id
output vm_subnet_id string = vm_subnetResource.id
