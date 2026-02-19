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

# Always resolve from script location - never use SCRIPT_DIR/DOCS_DIR from environment
_script="${BASH_SOURCE[0]}"
if [[ "$_script" != */* ]]; then
  echo "ERROR: Run with a path, e.g.: ./addons/scripts/get-all-addon-values.sh" >&2
  exit 1
fi
if command -v readlink >/dev/null 2>&1 && readlink -f "$_script" >/dev/null 2>&1; then
  _script_abs="$(readlink -f "$_script")"
else
  [[ "$_script" != /* ]] && _script="$(pwd)/$_script"
  _script_abs="$(cd "$(dirname "$_script")" && pwd)/$(basename "$_script")"
fi
SCRIPT_DIR="$(dirname "$_script_abs")"
DOCS_DIR="$(dirname "$SCRIPT_DIR")/docs"

echo "=============================================="
echo "  Addons Azure Values - Full Discovery"
echo "=============================================="
echo ""

# 1. Discover resource names (run with clean path vars - child must resolve its own paths)
echo ">>> Step 1: Discovering resource names..."
env -u SCRIPT_DIR -u DOCS_DIR -u ENV_LOCAL -u REPO_ROOT bash "$SCRIPT_DIR/get-resource-names.sh"
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
