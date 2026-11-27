// Version: 1.0.2
// Description: Bicep parameters for zabbix01 with static IP 10.68.68.5 on iDMZ.

using '../bicep/vm.bicep'

var subId = readEnvironmentVariable('SUB_ID', '00000000-0000-0000-0000-000000000000')

param vmName = 'zabbix01'
param location = 'swedencentral'
param vmSize = 'Standard_B2s'
param adminUsername = 'azureuser'
param adminPassword = readEnvironmentVariable('VM_ADMIN_PASSWORD', '')
param subnetId = '/subscriptions/${subId}/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/virtualNetworks/vnet_swc_01/subnets/iDMZ'
param privateIpAddress = '10.68.68.5'
