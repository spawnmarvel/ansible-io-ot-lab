#!/usr/bin/env bash
# Version: 1.0.0
# Description: Retrieves the provisioned size of mysql01_DataDisk_0 and any custom NSG rules for the target VMs.

set -euo pipefail

SUB_ID=$(az account show --query "id" --output tsv)

echo "=== MYSQL01 DATA DISK SIZE (GiB) ==="
az disk show \
  --subscription "$SUB_ID" \
  --resource-group "Rg-swc-dbs-02" \
  --name "mysql01_DataDisk_0" \
  --query "{Name:name, DiskSizeGB:diskSizeGb, Sku:sku.name}" \
  --output json

echo "=== CUSTOM NSG RULES ==="
for ENTRY in "Rg-swc-dbs-02:mysql01-nsg" "Rg-swc-vms-01:zabbix01-nsg" "Rg-swc-vms-01:zabbix02-nsg"; do
  RG="${ENTRY%%:*}"
  NSG="${ENTRY##*:}"
  echo "--- $NSG ($RG) ---"
  az network nsg rule list \
    --subscription "$SUB_ID" \
    --resource-group "$RG" \
    --nsg-name "$NSG" \
    --query "[].{Name:name, Priority:priority, Direction:direction, Access:access, Protocol:protocol, SourcePortRange:sourcePortRange, DestinationPortRange:destinationPortRange, SourceAddressPrefix:sourceAddressPrefix, DestinationAddressPrefix:destinationAddressPrefix}" \
    --output json
done