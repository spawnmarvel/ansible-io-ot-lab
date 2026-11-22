#!/usr/bin/env bash
# Version: 1.0.0
# Description: Validates Bicep parameter files and runs az deployment group what-if for all target VMs.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCATION="swedencentral"

export SUB_ID
SUB_ID=$(az account show --query "id" --output tsv)

if [ -z "${VM_ADMIN_PASSWORD:-}" ]; then
    read -rsp "Enter admin password for VMs (used for validation): " VM_ADMIN_PASSWORD
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

    echo "=========================================="
    echo "Checking $PARAM_FILE -> $RG_NAME"
    echo "=========================================="

    az bicep build-params \
        --file "$BASE_DIR/params/$PARAM_FILE" \
        --stdout > /dev/null

    az group create \
        --subscription "$SUB_ID" \
        --name "$RG_NAME" \
        --location "$LOCATION" \
        --output none

    az deployment group what-if \
        --subscription "$SUB_ID" \
        --resource-group "$RG_NAME" \
        --template-file "$BASE_DIR/bicep/vm.bicep" \
        --parameters "$BASE_DIR/params/$PARAM_FILE" \
        --no-pretty-print
done