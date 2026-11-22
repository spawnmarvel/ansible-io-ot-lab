// Version: 1.0.0
// Description: Deploys an Ubuntu 26.04 VM, NIC with static private IP, NSG, and optional data disk into a dedicated Resource Group.

@description('Name of the virtual machine.')
param vmName string

@description('Azure region for all resources in this Resource Group.')
param location string = 'swedencentral'

@description('Azure VM SKU size.')
param vmSize string = 'Standard_B2s'

@description('Local administrator username.')
param adminUsername string = 'azureuser'

@secure()
@description('Local administrator password.')
param adminPassword string

@description('Full Resource ID of the target subnet in the existing VNet.')
param subnetId string

@description('Static private IPv4 address assigned to the VM NIC.')
param privateIpAddress string

@description('Size in GiB for an optional data disk at LUN 0. Set to 0 to skip creating a data disk.')
param dataDiskSizeGb int = 0

@description('Storage SKU for OS and data managed disks.')
param diskStorageType string = 'StandardSSD_LRS'

var nsgName = '${vmName}-nsg'
var nicName = '${vmName}-nic'
var osDiskName = '${vmName}_OsDisk_1'
var dataDiskName = '${vmName}_DataDisk_0'

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 300
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: nicName
  location: location
  properties: {
    enableAcceleratedNetworking: false
    networkSecurityGroup: {
      id: nsg.id
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: privateIpAddress
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource dataDisk 'Microsoft.Compute/disks@2024-03-02' = if (dataDiskSizeGb > 0) {
  name: dataDiskName
  location: location
  sku: {
    name: diskStorageType
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: dataDiskSizeGb
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: 'ubuntu-26_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        name: osDiskName
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: diskStorageType
        }
        deleteOption: 'Delete'
      }
      dataDisks: dataDiskSizeGb > 0
        ? [
            {
              lun: 0
              name: dataDisk.name
              createOption: 'Attach'
              caching: 'None'
              managedDisk: {
                id: dataDisk.id
              }
              deleteOption: 'Delete'
            }
          ]
        : []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
}

output vmId string = vm.id
output privateIp string = nic.properties.ipConfigurations[0].properties.privateIPAddress
