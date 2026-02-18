#!/bin/bash
# =============================================================================
# get-all-addon-values.sh - Master script to gather all values for addons
# =============================================================================
# Runs discovery and outputs a summary of everything needed to configure addons.
# For new devs: run this first, then fill env.local.sh from the output.
#
# Run: ./addons/scripts/get-all-addon-values.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$(dirname "$SCRIPT_DIR")/docs"

echo "=============================================="
echo "  Addons Azure Values - Full Discovery"
echo "=============================================="
echo ""

# 1. Discover resource names
echo ">>> Step 1: Discovering resource names..."
bash "$SCRIPT_DIR/get-resource-names.sh"
echo ""

# 2. Load env for subsequent steps
if [ -f "$DOCS_DIR/env.local.sh" ]; then
  source "$DOCS_DIR/env.local.sh"
  echo ">>> Loaded env.local.sh"
else
  echo ">>> No env.local.sh found. Create from template: cp addons/docs/env.sh addons/docs/env.local.sh"
  echo ">>> Fill in RESOURCE_GROUP_NAME, KEYVAULT_NAME, etc. from Step 1 output, then re-run."
  exit 0
fi

# 3. Key Vault
if [ -n "$KEYVAULT_NAME" ]; then
  echo ""
  echo ">>> Step 2: Key Vault secrets..."
  bash "$SCRIPT_DIR/get-keyvault-secrets.sh"
fi

# 4. NFS
echo ""
echo ">>> Step 3: NFS storage values..."
bash "$SCRIPT_DIR/get-nfs-storage-values.sh"

# 5. AKS
if [ -n "$AKS_CLUSTER_NAME" ]; then
  echo ""
  echo ">>> Step 4: AKS credentials..."
  bash "$SCRIPT_DIR/get-aks-credentials.sh"
fi

echo ""
echo "=============================================="
echo "  Done. Use these values in addon YAML files."
echo "=============================================="
