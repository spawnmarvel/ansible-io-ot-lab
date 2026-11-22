#!/usr/bin/env bash
# Version: 1.0.0
# Description: Tears down dedicated VM Resource Groups without touching the VNet or ansiblectr01.

set -euo pipefail

SUB_ID=$(az account show --query "id" --output tsv)

VM_RGS=(
    "Rg-swc-mysql-01"
    "Rg-swc-zabbix-01"
    "Rg-swc-zabbix-02"
)

for RG_NAME in "${VM_RGS[@]}"; do
    if az group exists --subscription "$SUB_ID" --name "$RG_NAME" | grep -q "true"; then
        echo "Deleting Resource Group: $RG_NAME"
        az group delete \
            --subscription "$SUB_ID" \
            --name "$RG_NAME" \
            --yes \
            --no-wait
    else
        echo "Resource Group not found (already deleted): $RG_NAME"
    fi
done

echo "Teardown initiated. VNet vnet_swc_01 in NetworkWatcherRG remains untouched."