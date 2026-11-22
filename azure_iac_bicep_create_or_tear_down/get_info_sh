#!/usr/bin/env bash
# Version: 1.0.0
# Description: Queries VNet, subnet, and full VM/NIC specifications for zabbix01, zabbix02, and mysql01 using SUB_ID.

set -euo pipefail

SUB_ID=$(az account show --query "id" --output tsv)

echo "=== 1. VNETS AND SUBNETS ==="
az network vnet list --subscription "$SUB_ID" --query "[].{
  VNetName:name,
  ResourceGroup:resourceGroup,
  Location:location,
  AddressPrefixes:addressSpace.addressPrefixes,
  Subnets:subnets[].{
    Name:name,
    Prefix:addressPrefix,
    NsgId:networkSecurityGroup.id,
    Id:id
  }
}" --output json | sed "s/$SUB_ID/<SUB_ID>/g"

echo "=== 2. ALL VM NAMES IN SUBSCRIPTION (SANITY CHECK) ==="
az vm list --subscription "$SUB_ID" --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location}" --output table

echo "=== 3. TARGET VM SPECIFICATIONS ==="
az vm list --subscription "$SUB_ID" --query "[?contains(['zabbix01','zabix01','zabbix02','mysql01'], to_lower(name))].{
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

echo "=== 4. TARGET VM NIC DETAILS ==="
NIC_IDS=$(az vm list --subscription "$SUB_ID" --query "[?contains(['zabbix01','zabix01','zabbix02','mysql01'], to_lower(name))].networkProfile.networkInterfaces[].id" --output tsv)

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