#!/bin/bash
# =============================================================================
# get-resource-names.sh - Discover Azure resource names and write to env.local.sh
# =============================================================================
# Use this when you're a new dev and only know:
#   - The resource group name, OR
#   - Partial names like "mattermost" or "tfstate"
#
# Discovers resources and writes them to addons/docs/env.local.sh
#
# Run: ./addons/scripts/get-resource-names.sh
# Or with env: RESOURCE_GROUP_NAME=my-rg ./addons/scripts/get-resource-names.sh
# =============================================================================

set -e

# Resolve addons/docs path - use readlink -f for canonical path (avoids pushd/env pollution)
_script_path="${BASH_SOURCE[0]}"
if [[ "$_script_path" != */* ]]; then
  echo "ERROR: Run with a path, e.g.: ./addons/scripts/get-resource-names.sh" >&2
  exit 1
fi
if command -v readlink >/dev/null 2>&1 && readlink -f "$_script_path" >/dev/null 2>&1; then
  _script_abs="$(readlink -f "$_script_path")"
else
  [[ "$_script_path" != /* ]] && _script_path="$(pwd)/$_script_path"
  _script_abs="$(cd "$(dirname "$_script_path")" && pwd)/$(basename "$_script_path")"
fi
SCRIPT_DIR="$(dirname "$_script_abs")"
DOCS_DIR="$(dirname "$SCRIPT_DIR")/docs"
ENV_LOCAL="$DOCS_DIR/env.local.sh"

if [[ "$DOCS_DIR" != *"/addons/docs" ]] && [[ "$DOCS_DIR" != *"addons/docs" ]]; then
  echo "ERROR: Expected addons/docs in path, got: $DOCS_DIR" >&2
  exit 1
fi

# Load env AFTER path resolution (do not source before - can overwrite DOCS_DIR/ENV_LOCAL)
if [ -f "$ENV_LOCAL" ]; then
  source "$ENV_LOCAL"
fi

echo "=== Azure Resource Discovery for Addons ==="
echo ""

# Get subscription and tenant
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null || true)
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv 2>/dev/null || true)

if [ -z "$AZURE_SUBSCRIPTION_ID" ]; then
  echo "WARNING: Not logged in to Azure. Run: az login"
  exit 1
fi
echo "Subscription ID: $AZURE_SUBSCRIPTION_ID"
echo ""

# If no resource group, try to find one
if [ -z "$RESOURCE_GROUP_NAME" ]; then
  echo "RESOURCE_GROUP_NAME not set. Searching for resource groups containing 'mattermost' or 'tfstate'..."
  RESOURCE_GROUPS=$(az group list --query "[?contains(name, 'mattermost') || contains(name, 'tfstate')].name" -o tsv 2>/dev/null || true)
  if [ -n "$RESOURCE_GROUPS" ]; then
    echo "Found: $RESOURCE_GROUPS"
    RESOURCE_GROUP_NAME=$(echo "$RESOURCE_GROUPS" | head -1)
    echo "Using: $RESOURCE_GROUP_NAME"
  else
    echo "No matching resource groups. Set RESOURCE_GROUP_NAME and re-run."
    exit 1
  fi
fi
echo ""

# Discover resources
echo "Discovering resources..."

# Prefer key vault with 'pgs' (postgres), then 'kv', then first found
VAULTS=$(az keyvault list --query "[?resourceGroup=='$RESOURCE_GROUP_NAME'].name" -o tsv 2>/dev/null)
KEYVAULT_NAME=$(echo "$VAULTS" | grep pgs | head -1 || true)
[ -z "$KEYVAULT_NAME" ] && KEYVAULT_NAME=$(echo "$VAULTS" | grep kv | head -1 || true)
[ -z "$KEYVAULT_NAME" ] && KEYVAULT_NAME=$(echo "$VAULTS" | head -1 || true)

AKS_CLUSTER_NAME=$(az aks list --resource-group "$RESOURCE_GROUP_NAME" --query "[].name" -o tsv 2>/dev/null | head -1)

NFS_STORAGE_ACCOUNT=$(az storage account list --resource-group "$RESOURCE_GROUP_NAME" --query "[?contains(name, 'nfs')].name" -o tsv 2>/dev/null | head -1)
NFS_STORAGE_SHARE=""
if [ -n "$NFS_STORAGE_ACCOUNT" ]; then
  NFS_STORAGE_SHARE=$(az storage share list --account-name "$NFS_STORAGE_ACCOUNT" --query "[0].name" -o tsv 2>/dev/null || true)
fi

NFS_PRIVATE_ENDPOINT_NAME=$(az network private-endpoint list --resource-group "$RESOURCE_GROUP_NAME" --query "[?contains(name, 'nfs')].name" -o tsv 2>/dev/null | head -1)

POSTGRES_SERVER_NAME=$(az postgres flexible-server list --resource-group "$RESOURCE_GROUP_NAME" --query "[].name" -o tsv 2>/dev/null | head -1)

VNET_NAME=$(az network vnet list --resource-group "$RESOURCE_GROUP_NAME" --query "[].name" -o tsv 2>/dev/null | head -1)

# Load Balancer - Public IP name and FQDN for Mattermost/envoy-gateway annotations (mattermost-vnet)
# Prefer Mattermost K8s LB PIP (mattermost-*-mattermost-pip), then nlb, then alb
# Annotations: azure-load-balancer-resource-group, azure-pip-name. FQDN for CNAME (DNS instead of IP)
LB_PIP_NAME=$(az network public-ip list --resource-group "$RESOURCE_GROUP_NAME" --query "[?contains(name, 'mattermost-pip')].name" -o tsv 2>/dev/null | head -1 || true)
[ -z "$LB_PIP_NAME" ] && LB_PIP_NAME=$(az network public-ip list --resource-group "$RESOURCE_GROUP_NAME" --query "[?contains(name, 'nlb') || contains(name, 'alb')].name" -o tsv 2>/dev/null | head -1 || true)
LB_FQDN=""
if [ -n "$LB_PIP_NAME" ]; then
  LB_FQDN=$(az network public-ip show --name "$LB_PIP_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query dnsSettings.fqdn -o tsv 2>/dev/null || true)
fi

# External Secrets workload identity (azure.workload.identity/client-id for patches.yaml)
EXTERNAL_SECRETS_IDENTITY_NAME=$(az identity list --resource-group "$RESOURCE_GROUP_NAME" --query "[?contains(name, 'external-secrets')].name" -o tsv 2>/dev/null | head -1 || true)
EXTERNAL_SECRETS_IDENTITY_CLIENT_ID=""
if [ -n "$EXTERNAL_SECRETS_IDENTITY_NAME" ]; then
  EXTERNAL_SECRETS_IDENTITY_CLIENT_ID=$(az identity show --name "$EXTERNAL_SECRETS_IDENTITY_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query clientId -o tsv 2>/dev/null || true)
fi

# Private DNS zone for NFS (common name)
PRIVATE_DNS_ZONE_NAME="privatelink.file.core.windows.net"

# Write env.local.sh
echo ""
mkdir -p "$DOCS_DIR"
echo "Writing to $ENV_LOCAL ..."

{
  echo "# Auto-generated by get-resource-names.sh on $(date '+%Y-%m-%d %H:%M:%S')"
  echo "# Edit as needed. Source: source addons/docs/env.local.sh"
  echo ""
  echo "# -----------------------------------------------------------------------------"
  echo "# Core - Required for most operations"
  echo "# -----------------------------------------------------------------------------"
  echo "export RESOURCE_GROUP_NAME=\"${RESOURCE_GROUP_NAME:-}\""
  echo "export AZURE_SUBSCRIPTION_ID=\"${AZURE_SUBSCRIPTION_ID:-}\""
  echo ""
  echo "# -----------------------------------------------------------------------------"
  echo "# Key Vault - Used by External Secrets for Mattermost DB, license"
  echo "# -----------------------------------------------------------------------------"
  echo "export KEYVAULT_NAME=\"${KEYVAULT_NAME:-}\""
  echo "export KV_SECRET_POSTGRES_CONNECTION_STRING=\"postgres-connection-string\""
  echo "export KV_SECRET_POSTGRES_INTERNAL_PASSWORD=\"postgres-internal-password\""
  echo "export KV_SECRET_POSTGRES_INTERNAL_USER=\"postgresinternaluser\""
  echo "export KV_SECRET_MATTERMOST_LICENSE=\"mattermost-license-store\""
  echo ""
  echo "# -----------------------------------------------------------------------------"
  echo "# NFS Storage - Used by Mattermost PVC for file storage"
  echo "# -----------------------------------------------------------------------------"
  echo "export NFS_STORAGE_ACCOUNT=\"${NFS_STORAGE_ACCOUNT:-}\""
  echo "export NFS_STORAGE_SHARE=\"${NFS_STORAGE_SHARE:-}\""
  echo "export NFS_PRIVATE_ENDPOINT_NAME=\"${NFS_PRIVATE_ENDPOINT_NAME:-}\""
  echo ""
  echo "# -----------------------------------------------------------------------------"
  echo "# AKS Cluster - For kubectl access"
  echo "# -----------------------------------------------------------------------------"
  echo "export AKS_CLUSTER_NAME=\"${AKS_CLUSTER_NAME:-}\""
  echo ""
  echo "# -----------------------------------------------------------------------------"
  echo "# PostgreSQL - For direct DB access (optional)"
  echo "# -----------------------------------------------------------------------------"
  echo "export POSTGRES_SERVER_NAME=\"${POSTGRES_SERVER_NAME:-}\""
  echo ""
  echo "# -----------------------------------------------------------------------------"
  echo "# VNet - For network/DNS verification"
  echo "# -----------------------------------------------------------------------------"
  echo "export VNET_NAME=\"${VNET_NAME:-}\""
  echo "export PRIVATE_DNS_ZONE_NAME=\"${PRIVATE_DNS_ZONE_NAME:-}\""
  echo ""
  echo "# -----------------------------------------------------------------------------"
  echo "# Load Balancer - For envoy-gateway service annotations (envoy-gateway/patches.yaml)"
  echo "#   azure-load-balancer-resource-group: use RESOURCE_GROUP_NAME"
  echo "#   azure-pip-name: use LB_PIP_NAME"
  echo "#   FQDN for CNAME (DNS instead of IP): use LB_FQDN"
  echo "# -----------------------------------------------------------------------------"
  echo "export LB_PIP_NAME=\"${LB_PIP_NAME:-}\""
  echo "export LB_FQDN=\"${LB_FQDN:-}\""
  echo ""
  echo "# -----------------------------------------------------------------------------"
  echo "# Tenant (for ClusterSecretStore - External Secrets)"
  echo "# -----------------------------------------------------------------------------"
  echo "export AZURE_TENANT_ID=\"${AZURE_TENANT_ID:-}\""
  echo ""
  echo "# -----------------------------------------------------------------------------"
  echo "# External Secrets - Workload identity for azure.workload.identity/client-id"
  echo "# Use in addons/clusters/azure/<cluster>/apps/external-secrets/patches.yaml"
  echo "# -----------------------------------------------------------------------------"
  echo "export EXTERNAL_SECRETS_IDENTITY_CLIENT_ID=\"${EXTERNAL_SECRETS_IDENTITY_CLIENT_ID:-}\""
} > "$ENV_LOCAL"

echo "Done."
echo ""
echo "=== Discovered values ==="
echo "RESOURCE_GROUP_NAME:              $RESOURCE_GROUP_NAME"
echo "KEYVAULT_NAME:                    ${KEYVAULT_NAME:-<none>}"
echo "AKS_CLUSTER_NAME:                 ${AKS_CLUSTER_NAME:-<none>}"
echo "NFS_STORAGE_ACCOUNT:              ${NFS_STORAGE_ACCOUNT:-<none>}"
echo "NFS_STORAGE_SHARE:                ${NFS_STORAGE_SHARE:-<none>}"
echo "POSTGRES_SERVER_NAME:             ${POSTGRES_SERVER_NAME:-<none>}"
echo "LB_PIP_NAME (azure-pip-name):     ${LB_PIP_NAME:-<none>}"
echo "LB_FQDN (CNAME target):           ${LB_FQDN:-<none>}"
echo "EXTERNAL_SECRETS_IDENTITY_CLIENT_ID: ${EXTERNAL_SECRETS_IDENTITY_CLIENT_ID:-<none>}"
echo ""
echo "Run: source $ENV_LOCAL"
