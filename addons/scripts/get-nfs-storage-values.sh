#!/bin/bash
# =============================================================================
# get-nfs-storage-values.sh - Get NFS storage values for Mattermost PVC
# =============================================================================
# Used for: addons/clusters/azure/*/apps/mattermost/pvc.yaml
#
# Output: NFS server hostname, path, storage account, share name
# These go into the PersistentVolume nfs.server and nfs.path
#
# Prerequisites: RESOURCE_GROUP_NAME, or NFS_STORAGE_ACCOUNT
# Run: source addons/docs/env.local.sh && ./addons/scripts/get-nfs-storage-values.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$(dirname "$SCRIPT_DIR")/docs"

if [ -f "$DOCS_DIR/env.local.sh" ]; then
  source "$DOCS_DIR/env.local.sh"
fi

echo "=== NFS Storage Values for Mattermost PVC ==="
echo ""

# Find storage account if not set
if [ -z "$NFS_STORAGE_ACCOUNT" ] && [ -n "$RESOURCE_GROUP_NAME" ]; then
  NFS_STORAGE_ACCOUNT=$(az storage account list --resource-group "$RESOURCE_GROUP_NAME" --query "[?contains(name, 'nfs')].name" -o tsv 2>/dev/null | head -1)
fi

if [ -z "$NFS_STORAGE_ACCOUNT" ]; then
  echo "ERROR: NFS_STORAGE_ACCOUNT not set. Set it in env.local.sh or ensure RESOURCE_GROUP_NAME has an NFS storage account."
  exit 1
fi

# Get share name - try share-rm first (works with NFS/FileStorage), then legacy share list
if [ -n "$RESOURCE_GROUP_NAME" ]; then
  NFS_STORAGE_SHARE=$(az storage share-rm list --account-name "$NFS_STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP_NAME" --query "[0].name" -o tsv 2>/dev/null || true)
fi
if [ -z "$NFS_STORAGE_SHARE" ]; then
  NFS_STORAGE_SHARE=$(az storage share-rm list --account-name "$NFS_STORAGE_ACCOUNT" --query "[0].name" -o tsv 2>/dev/null || true)
fi
if [ -z "$NFS_STORAGE_SHARE" ]; then
  NFS_STORAGE_SHARE=$(az storage share list --account-name "$NFS_STORAGE_ACCOUNT" --query "[0].name" -o tsv 2>/dev/null || true)
fi

if [ -z "$NFS_STORAGE_SHARE" ]; then
  echo "WARNING: No file share found in $NFS_STORAGE_ACCOUNT"
  echo "  Try manually: az storage share-rm list --account-name $NFS_STORAGE_ACCOUNT -o table"
  echo "  Or with RG:   az storage share-rm list --account-name $NFS_STORAGE_ACCOUNT --resource-group \$RESOURCE_GROUP_NAME -o table"
else
  echo "Storage account: $NFS_STORAGE_ACCOUNT"
  echo "Share name:      $NFS_STORAGE_SHARE"
  echo ""
  echo "--- Values for pvc.yaml ---"
  echo "nfs.server: $NFS_STORAGE_ACCOUNT.privatelink.file.core.windows.net"
  echo "nfs.path:   /$NFS_STORAGE_ACCOUNT/$NFS_STORAGE_SHARE"
  echo ""
  echo "--- Export for env ---"
  echo "export NFS_STORAGE_ACCOUNT=\"$NFS_STORAGE_ACCOUNT\""
  echo "export NFS_STORAGE_SHARE=\"$NFS_STORAGE_SHARE\""
fi
