#!/bin/bash
# =============================================================================
# check-patches-needed.sh - Check if patches need to be applied to the repo
# =============================================================================
# Compares env.local.sh values with target files. Reports which patches are
# needed (values differ) vs already applied (values match).
#
# Run: ./addons/scripts/patches/check-patches-needed.sh
# Or:  ./addons/scripts/patches/check-patches-needed.sh addons/clusters/azure/dev-chris
# =============================================================================

set -e

unset REPO_ROOT SCRIPT_DIR ENV_LOCAL CLUSTER_PATH

_script_path="${BASH_SOURCE[0]}"
[[ "$_script_path" != */* ]] && _script_path="$(pwd)/$_script_path"
if command -v readlink >/dev/null 2>&1 && readlink -f "$_script_path" >/dev/null 2>&1; then
  _script_abs="$(readlink -f "$_script_path")"
else
  [[ "$_script_path" != /* ]] && _script_path="$(pwd)/$_script_path"
  _script_abs="$(cd "$(dirname "$_script_path")" && pwd)/$(basename "$_script_path")"
fi
SCRIPT_DIR="$(dirname "$_script_abs")"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

ENV_LOCAL="$REPO_ROOT/addons/docs/env.local.sh"
CLUSTER_PATH="${1:-addons/clusters/azure/dev-chris}"

NEEDED=0

echo "=== Patch Status for $CLUSTER_PATH ==="
echo ""

# Load env if exists
if [ -f "$ENV_LOCAL" ]; then
  source "$ENV_LOCAL"
else
  echo "WARNING: $ENV_LOCAL not found. Run get-resource-names.sh first."
  echo "Cannot check patches without env values."
  exit 1
fi

# --- Mattermost LB ---
SERVICE_FILE="$REPO_ROOT/$CLUSTER_PATH/apps/mattermost/service.yaml"
if [ -f "$SERVICE_FILE" ] && [ -n "$LB_PIP_NAME" ] && [ -n "$RESOURCE_GROUP_NAME" ]; then
  CURRENT_RG=$(sed -n 's/.*azure-load-balancer-resource-group: *"\([^"]*\)".*/\1/p' "$SERVICE_FILE" 2>/dev/null | head -1)
  CURRENT_PIP=$(sed -n 's/.*azure-pip-name: *"\([^"]*\)".*/\1/p' "$SERVICE_FILE" 2>/dev/null | head -1)
  if [ "$CURRENT_RG" != "$RESOURCE_GROUP_NAME" ] || [ "$CURRENT_PIP" != "$LB_PIP_NAME" ]; then
    echo "[NEEDED] mattermost-lb: Run ./addons/scripts/patches/patch-mattermost-lb.sh $CLUSTER_PATH"
    [ -n "$CURRENT_RG" ] && echo "         Current RG: $CURRENT_RG  Expected: $RESOURCE_GROUP_NAME"
    [ -n "$CURRENT_PIP" ] && echo "         Current PIP: $CURRENT_PIP  Expected: $LB_PIP_NAME"
    NEEDED=$((NEEDED + 1))
  else
    echo "[OK] mattermost-lb: service.yaml matches env.local.sh"
  fi
else
  [ ! -f "$SERVICE_FILE" ] && echo "[SKIP] mattermost-lb: $SERVICE_FILE not found"
  [ -z "$LB_PIP_NAME" ] && echo "[SKIP] mattermost-lb: LB_PIP_NAME not set in env"
fi
echo ""

# --- Envoy Gateway LB ---
PATCHES_FILE="$REPO_ROOT/$CLUSTER_PATH/apps/envoy-gateway/patches.yaml"
if [ -f "$PATCHES_FILE" ] && [ -n "$LB_PIP_NAME" ] && [ -n "$RESOURCE_GROUP_NAME" ]; then
  HAS_ANNOTATIONS=$(grep -c "azure-pip-name" "$PATCHES_FILE" 2>/dev/null || true)
  CURRENT_PIP=$(sed -n 's/.*azure-pip-name: *"\([^"]*\)".*/\1/p' "$PATCHES_FILE" 2>/dev/null | head -1)
  if [ "${HAS_ANNOTATIONS:-0}" -eq 0 ] || [ "$CURRENT_PIP" != "$LB_PIP_NAME" ]; then
    echo "[NEEDED] envoy-gateway-lb: Run ./addons/scripts/patches/patch-envoy-gateway-lb.sh $CLUSTER_PATH"
    [ -n "$CURRENT_PIP" ] && echo "         Current PIP: $CURRENT_PIP  Expected: $LB_PIP_NAME"
    NEEDED=$((NEEDED + 1))
  else
    echo "[OK] envoy-gateway-lb: patches.yaml matches env.local.sh"
  fi
else
  [ ! -f "$PATCHES_FILE" ] && echo "[SKIP] envoy-gateway-lb: $PATCHES_FILE not found"
  [ -z "$LB_PIP_NAME" ] && echo "[SKIP] envoy-gateway-lb: LB_PIP_NAME not set in env"
fi
echo ""

# --- External Secrets Identity ---
OPERATOR_PATCHES="$REPO_ROOT/$CLUSTER_PATH/apps/external-secrets-operator/patches.yaml"
if [ -f "$OPERATOR_PATCHES" ] && [ -n "$EXTERNAL_SECRETS_IDENTITY_CLIENT_ID" ]; then
  CURRENT_CLIENT=$(sed -n 's/.*azure\.workload.identity\/client-id: *"\([^"]*\)".*/\1/p' "$OPERATOR_PATCHES" 2>/dev/null | head -1)
  if [ "$CURRENT_CLIENT" != "$EXTERNAL_SECRETS_IDENTITY_CLIENT_ID" ]; then
    echo "[NEEDED] external-secrets-identity: Run ./addons/scripts/patches/patch-external-secrets-identity.sh $CLUSTER_PATH"
    [ -n "$CURRENT_CLIENT" ] && echo "         Current client-id: ${CURRENT_CLIENT:0:8}...  Expected: ${EXTERNAL_SECRETS_IDENTITY_CLIENT_ID:0:8}..."
    NEEDED=$((NEEDED + 1))
  else
    echo "[OK] external-secrets-identity: patches.yaml matches env.local.sh"
  fi
else
  [ ! -f "$OPERATOR_PATCHES" ] && echo "[SKIP] external-secrets-identity: $OPERATOR_PATCHES not found"
  [ -z "$EXTERNAL_SECRETS_IDENTITY_CLIENT_ID" ] && echo "[SKIP] external-secrets-identity: EXTERNAL_SECRETS_IDENTITY_CLIENT_ID not set in env"
fi
echo ""

# Summary
if [ $NEEDED -gt 0 ]; then
  echo "--- $NEEDED patch(es) need to be applied ---"
  exit 1
else
  echo "--- All checked patches are up to date ---"
  exit 0
fi
