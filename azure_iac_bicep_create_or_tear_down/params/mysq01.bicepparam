// Version: 1.0.3
// Description: Bicep parameters for mysql01 with static IP 10.68.68.6 on iDMZ and 8 GiB LUN 0 data disk.

using '../bicep/vm.bicep'

var subId = readEnvironmentVariable('SUB_ID', '00000000-0000-0000-0000-000000000000')

param vmName = 'mysql01'
param location = 'swedencentral'
param vmSize = 'Standard_B2s'
param adminUsername = 'azureuser'
param adminPassword = readEnvironmentVariable('VM_ADMIN_PASSWORD', '')
param subnetId = '/subscriptions/${subId}/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/virtualNetworks/vnet_swc_01/subnets/iDMZ'
param privateIpAddress = '10.68.68.6'
param dataDiskSizeGb = 8
param diskStorageType = 'StandardSSD_LRS'
