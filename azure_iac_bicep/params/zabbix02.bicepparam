// Version: 1.0.2
// Description: Bicep parameters for zabbix02 with static IP 10.68.20.4 on OT.

using '../bicep/vm.bicep'

var subId = readEnvironmentVariable('SUB_ID', '00000000-0000-0000-0000-000000000000')

param vmName = 'zabbix02'
param location = 'swedencentral'
param vmSize = 'Standard_B2s'
param adminUsername = 'azureuser'
param adminPassword = readEnvironmentVariable('VM_ADMIN_PASSWORD', '')
param subnetId = '/subscriptions/${subId}/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/virtualNetworks/vnet_swc_01/subnets/OT'
param privateIpAddress = '10.68.20.4'
param dataDiskSizeGb = 0
