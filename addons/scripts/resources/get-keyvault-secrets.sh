#!/bin/bash
# =============================================================================
# get-keyvault-secrets.sh - Retrieve Key Vault secrets needed by addons
# =============================================================================
# Used for: External Secrets (ClusterSecretStore), Mattermost database, license
#
# Prerequisites: KEYVAULT_NAME and RESOURCE_GROUP_NAME set (source env.local.sh)
# Run: source addons/docs/env.local.sh && ./addons/scripts/resources/get-keyvault-secrets.sh
#
# Output: Secret values (use carefully - do not log or commit)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$(dirname "$SCRIPT_DIR")/../docs"

if [ -f "$DOCS_DIR/env.local.sh" ]; then
  source "$DOCS_DIR/env.local.sh"
fi

if [ -z "$KEYVAULT_NAME" ]; then
  echo "ERROR: KEYVAULT_NAME not set. Source env.local.sh or export KEYVAULT_NAME=your-vault-name"
  exit 1
fi

echo "=== Key Vault Secrets for Addons ==="
echo "Vault: $KEYVAULT_NAME"
echo ""

echo "--- Listing all secrets ---"
az keyvault secret list --vault-name "$KEYVAULT_NAME" --query "[].name" -o tsv 2>/dev/null || { echo "Failed to list. Check access."; exit 1; }
echo ""

echo "--- Secrets used by addons ---"
for SECRET in postgres-connection-string postgres-internal-password postgresinternaluser mattermost-license-store; do
  if az keyvault secret show --vault-name "$KEYVAULT_NAME" --name "$SECRET" &>/dev/null; then
    echo "[OK] $SECRET exists"
  else
    echo "[--] $SECRET not found"
  fi
done

echo ""
echo "To retrieve a secret value (use with caution):"
echo "  az keyvault secret show --vault-name $KEYVAULT_NAME --name <secret-name> --query value -o tsv"
