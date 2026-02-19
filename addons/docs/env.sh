#!/bin/bash
# =============================================================================
# Addons Deployment - Azure Resource Names
# =============================================================================
# Copy this file to env.local.sh and fill in the values for your deployment.
# Source it before running scripts: source addons/docs/env.local.sh
#
# Get values from:
#   - Terraform outputs (stacks/azure/mattermost-*/)
#   - Azure Portal
#   - addons/scripts/get-resource-names.sh
# =============================================================================

# -----------------------------------------------------------------------------
# Core - Required for most operations
# -----------------------------------------------------------------------------
export RESOURCE_GROUP_NAME=""           # e.g. chrisfickess-tfstate-azk
export AZURE_SUBSCRIPTION_ID=""        # From: az account show --query id -o tsv

# -----------------------------------------------------------------------------
# Key Vault - Used by External Secrets for Mattermost DB, license
# -----------------------------------------------------------------------------
export KEYVAULT_NAME=""                # e.g. mattermost-dev-chris-pgs or mattermost-dev-chris-kv

# Key Vault secret names (used by addons - do not change unless Terraform uses different names)
export KV_SECRET_POSTGRES_CONNECTION_STRING="postgres-connection-string"
export KV_SECRET_POSTGRES_INTERNAL_PASSWORD="postgres-internal-password"
export KV_SECRET_POSTGRES_INTERNAL_USER="postgresinternaluser"
export KV_SECRET_MATTERMOST_LICENSE="mattermost-license-store"

# -----------------------------------------------------------------------------
# NFS Storage - Used by Mattermost PVC for file storage
# -----------------------------------------------------------------------------
export NFS_STORAGE_ACCOUNT=""          # e.g. mattermostdevchrisnfs
export NFS_STORAGE_SHARE=""            # e.g. mattermostdevchrisshare
export NFS_PRIVATE_ENDPOINT_NAME=""    # e.g. mattermost-dev-chris-nfs-pe

# Derived values (used in pvc.yaml)
# NFS_SERVER = ${NFS_STORAGE_ACCOUNT}.privatelink.file.core.windows.net
# NFS_PATH   = /${NFS_STORAGE_ACCOUNT}/${NFS_STORAGE_SHARE}

# -----------------------------------------------------------------------------
# AKS Cluster - For kubectl access
# -----------------------------------------------------------------------------
export AKS_CLUSTER_NAME=""             # e.g. mattermost-dev-chris-aks

# -----------------------------------------------------------------------------
# PostgreSQL - For direct DB access (optional, credentials from Key Vault)
# -----------------------------------------------------------------------------
export POSTGRES_SERVER_NAME=""          # e.g. mattermost-dev-chris-postgres-flex

# -----------------------------------------------------------------------------
# VNet - For network/DNS verification
# -----------------------------------------------------------------------------
export VNET_NAME=""                    # e.g. mattermost-dev-chris-vnet
export PRIVATE_DNS_ZONE_NAME=""        # e.g. privatelink.file.core.windows.net

# -----------------------------------------------------------------------------
# Load Balancer - For envoy-gateway service annotations (envoy-gateway/patches.yaml)
# azure-load-balancer-resource-group: use RESOURCE_GROUP_NAME
# azure-pip-name: use LB_PIP_NAME. LB_FQDN = CNAME target (DNS instead of IP)
# -----------------------------------------------------------------------------
export LB_PIP_NAME=""                  # e.g. mattermost-dev-chris-nlb-pip
export LB_FQDN=""                      # e.g. mattermost-dev-chris-nlb.eastus2.cloudapp.azure.com

# -----------------------------------------------------------------------------
# Tenant (for ClusterSecretStore - External Secrets)
# -----------------------------------------------------------------------------
export AZURE_TENANT_ID=""              # From: az account show --query tenantId -o tsv

# -----------------------------------------------------------------------------
# External Secrets - Workload identity (azure.workload.identity/client-id)
# Used in addons/clusters/azure/<cluster>/apps/external-secrets/patches.yaml
# -----------------------------------------------------------------------------
export EXTERNAL_SECRETS_IDENTITY_CLIENT_ID=""   # From: get-resource-names.sh
