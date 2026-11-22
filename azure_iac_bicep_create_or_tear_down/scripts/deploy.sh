#!/usr/bin/env bash
# Version: 1.1.0
# Description: Creates dedicated Resource Groups and deploys mysql01, zabbix01, and zabbix02 via Bicep.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCATION="swedencentral"

export SUB_ID
SUB_ID=$(az account show --query "id" --output tsv)

if [ -z "${VM_ADMIN_PASSWORD:-}" ]; then
    read -rsp "Enter admin password for VMs: " VM_ADMIN_PASSWORD
    echo ""
    export VM_ADMIN_PASSWORD
fi

TARGETS=(
    "Rg-swc-mysql-01:mysql01.bicepparam"
    "Rg-swc-zabbix-01:zabbix01.bicepparam"
    "Rg-swc-zabbix-02:zabbix02.bicepparam"
)

for ENTRY in "${TARGETS[@]}"; do
    RG_NAME="${ENTRY%%:*}"
    PARAM_FILE="${ENTRY##*:}"

    echo "Creating Resource Group: $RG_NAME"
    az group create \
        --subscription "$SUB_ID" \
        --name "$RG_NAME" \
        --location "$LOCATION" \
        --output none

    echo "Deploying $PARAM_FILE into $RG_NAME..."
    az deployment group create \
        --subscription "$SUB_ID" \
        --resource-group "$RG_NAME" \
        --template-file "$BASE_DIR/bicep/vm.bicep" \
        --parameters "$BASE_DIR/params/$PARAM_FILE" \
        --output table
done

echo "All VM deployments completed."