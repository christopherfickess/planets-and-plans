#!/bin/bash
# =============================================================================
# patch-external-secrets-identity.sh - Update patches.yaml with workload identity client ID
# =============================================================================
# Run get-resource-names.sh first, then this script to update the external-secrets
# patches.yaml with the discovered azure.workload.identity/client-id.
#
# Run: source addons/docs/env.local.sh && ./addons/scripts/patch-external-secrets-identity.sh
# Or:  ./addons/scripts/patch-external-secrets-identity.sh addons/clusters/azure/dev-chris
# =============================================================================

set -e

unset REPO_ROOT SCRIPT_DIR ENV_LOCAL CLUSTER_PATH PATCHES_FILE

_script_path="${BASH_SOURCE[0]}"
[[ "$_script_path" != */* ]] && _script_path="$(pwd)/$_script_path"
if command -v readlink >/dev/null 2>&1 && readlink -f "$_script_path" >/dev/null 2>&1; then
  _script_abs="$(readlink -f "$_script_path")"
else
  [[ "$_script_path" != /* ]] && _script_path="$(pwd)/$_script_path"
  _script_abs="$(cd "$(dirname "$_script_path")" && pwd)/$(basename "$_script_path")"
fi
SCRIPT_DIR="$(dirname "$_script_abs")"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load env
ENV_LOCAL="$REPO_ROOT/addons/docs/env.local.sh"
if [ ! -f "$ENV_LOCAL" ]; then
  echo "ERROR: Run get-resource-names.sh first to create $ENV_LOCAL" >&2
  exit 1
fi
source "$ENV_LOCAL"

if [ -z "$EXTERNAL_SECRETS_IDENTITY_CLIENT_ID" ]; then
  echo "ERROR: EXTERNAL_SECRETS_IDENTITY_CLIENT_ID not set in env.local.sh" >&2
  echo "       Run get-resource-names.sh to discover it." >&2
  exit 1
fi

# Target: addons/clusters/azure/<cluster>/apps/external-secrets/
CLUSTER_PATH="${1:-addons/clusters/azure/dev-chris}"
EXTERNAL_SECRETS_DIR="$REPO_ROOT/$CLUSTER_PATH/apps/external-secrets"
PATCHES_FILE="$EXTERNAL_SECRETS_DIR/patches.yaml"
if [ ! -f "$PATCHES_FILE" ]; then
  echo "ERROR: Patches file not found: $PATCHES_FILE" >&2
  echo "       Usage: $0 [cluster-path]" >&2
  echo "       Example: $0 addons/clusters/azure/dev-chris" >&2
  exit 1
fi

# Update external-secrets-operator patches.yaml (HelmRelease serviceAccount annotations)
OPERATOR_PATCHES="$EXTERNAL_SECRETS_DIR/../external-secrets-operator/patches.yaml"
if [ -f "$OPERATOR_PATCHES" ]; then
  if sed -i.bak "s|azure.workload.identity/client-id:.*|azure.workload.identity/client-id: \"$EXTERNAL_SECRETS_IDENTITY_CLIENT_ID\"|" "$OPERATOR_PATCHES" 2>/dev/null; then
    rm -f "${OPERATOR_PATCHES}.bak"
    echo "Updated $OPERATOR_PATCHES with client-id: $EXTERNAL_SECRETS_IDENTITY_CLIENT_ID"
  else
    echo "WARNING: Failed to patch $OPERATOR_PATCHES" >&2
  fi
fi
