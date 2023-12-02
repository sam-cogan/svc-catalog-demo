
param aksClusterName string
param aksNodeCount string = '1'
param aksNodeSize string
param aksNodeOSDiskSize string = '32'
param location string = 'westeurope'



resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name:  '${aksClusterName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  name: 'aksSubnet'
  parent: vnet
  properties: {
    addressPrefix: '192.168.0.0/20'
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: aksClusterName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Paid'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: aksClusterName
    oidcIssuerProfile: {
      enabled: true
    }
    enableRBAC: true
    publicNetworkAccess: 'Disabled'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: int(aksNodeOSDiskSize)
        count: int(aksNodeCount)
        vmSize: aksNodeSize
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: subnet.id
      }
    ]
  }
}
