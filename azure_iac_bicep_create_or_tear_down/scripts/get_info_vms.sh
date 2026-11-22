#!/usr/bin/env bash
# Version: 1.1.0
# Description: Queries full VM, disk, SSH, and NIC specs for zabbix01, zabbix02, and mysql01 without unsupported JMESPath functions.

set -euo pipefail

SUB_ID=$(az account show --query "id" --output tsv)

echo "=== 1. SUBNET ADDRESS PREFIXES ==="
az network vnet subnet list \
  --subscription "$SUB_ID" \
  --resource-group "NetworkWatcherRG" \
  --vnet-name "vnet_swc_01" \
  --query "[].{Name:name, AddressPrefix:addressPrefix, AddressPrefixes:addressPrefixes, Id:id}" \
  --output json | sed "s/$SUB_ID/<SUB_ID>/g"

echo "=== 2. TARGET VM SPECIFICATIONS ==="
az vm list --subscription "$SUB_ID" --query "[?contains(['zabbix01','zabbix02','mysql01'], name)].{
  Name:name,
  ResourceGroup:resourceGroup,
  Location:location,
  VmSize:hardwareProfile.vmSize,
  AdminUsername:osProfile.adminUsername,
  DisablePasswordAuthentication:osProfile.linuxConfiguration.disablePasswordAuthentication,
  SshPublicKeys:osProfile.linuxConfiguration.ssh.publicKeys[].{Path:path, KeyData:keyData},
  ImageReference:storageProfile.imageReference,
  OsDisk: {
    Name:storageProfile.osDisk.name,
    OsType:storageProfile.osDisk.osType,
    Caching:storageProfile.osDisk.caching,
    DiskSizeGB:storageProfile.osDisk.diskSizeGb,
    StorageType:storageProfile.osDisk.managedDisk.storageAccountType
  },
  DataDisks:storageProfile.dataDisks[].{
    Name:name,
    Lun:lun,
    Caching:caching,
    DiskSizeGB:diskSizeGb,
    StorageType:managedDisk.storageAccountType
  },
  SecurityProfile:securityProfile,
  NicIds:networkProfile.networkInterfaces[].id
}" --output json | sed "s/$SUB_ID/<SUB_ID>/g"

echo "=== 3. TARGET VM NIC DETAILS ==="
NIC_IDS=$(az vm list --subscription "$SUB_ID" --query "[?contains(['zabbix01','zabbix02','mysql01'], name)].networkProfile.networkInterfaces[].id" --output tsv)

for NIC_ID in $NIC_IDS; do
  az network nic show --ids "$NIC_ID" --query "{
    NicName:name,
    ResourceGroup:resourceGroup,
    AttachedVmId:virtualMachine.id,
    EnableAcceleratedNetworking:enableAcceleratedNetworking,
    NetworkSecurityGroupId:networkSecurityGroup.id,
    IpConfigurations:ipConfigurations[].{
      Name:name,
      PrivateIP:privateIPAddress,
      AllocationMethod:privateIPAllocationMethod,
      SubnetId:subnet.id,
      PublicIpId:publicIPAddress.id
    }
  }" --output json | sed "s/$SUB_ID/<SUB_ID>/g"
done