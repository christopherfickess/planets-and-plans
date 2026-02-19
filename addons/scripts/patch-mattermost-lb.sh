#!/bin/bash
# =============================================================================
# patch-mattermost-lb.sh - Update mattermost service.yaml with LB annotations
# =============================================================================
# Run get-resource-names.sh first, then this script to set Azure load balancer
# annotations on the Mattermost LoadBalancer service. Uses LB_PIP_NAME and
# RESOURCE_GROUP_NAME. LB_FQDN is for CNAME (DNS instead of IP).
#
# Run: ./addons/scripts/patch-mattermost-lb.sh   (sources env.local.sh automatically)
# Or:  ./addons/scripts/patch-mattermost-lb.sh addons/clusters/azure/dev-chris
# Do NOT source this script - run it as ./patch-mattermost-lb.sh
# =============================================================================

set -e

# Isolate from environment (sourcing can inherit polluted REPO_ROOT/ENV_LOCAL)
unset REPO_ROOT SCRIPT_DIR ENV_LOCAL CLUSTER_PATH SERVICE_FILE

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

if [ -z "$LB_PIP_NAME" ] || [ -z "$RESOURCE_GROUP_NAME" ]; then
  echo "ERROR: LB_PIP_NAME and RESOURCE_GROUP_NAME must be set in env.local.sh" >&2
  echo "       Run get-resource-names.sh to discover them." >&2
  exit 1
fi

# Target: addons/clusters/azure/<cluster>/apps/mattermost/service.yaml
CLUSTER_PATH="${1:-addons/clusters/azure/dev-chris}"
SERVICE_FILE="$REPO_ROOT/$CLUSTER_PATH/apps/mattermost/service.yaml"

if [ ! -f "$SERVICE_FILE" ]; then
  echo "ERROR: Service file not found: $SERVICE_FILE" >&2
  echo "       Usage: $0 [cluster-path]" >&2
  exit 1
fi

# Replace placeholder values in the annotations
sed -i.bak \
  -e "s|service.beta.kubernetes.io/azure-load-balancer-resource-group:.*|service.beta.kubernetes.io/azure-load-balancer-resource-group: \"$RESOURCE_GROUP_NAME\"|" \
  -e "s|service.beta.kubernetes.io/azure-pip-name:.*|service.beta.kubernetes.io/azure-pip-name: \"$LB_PIP_NAME\"|" \
  "$SERVICE_FILE" 2>/dev/null

if [ $? -eq 0 ]; then
  rm -f "${SERVICE_FILE}.bak"
  echo "Updated $SERVICE_FILE with LB annotations:"
  echo "  azure-load-balancer-resource-group: $RESOURCE_GROUP_NAME"
  echo "  azure-pip-name: $LB_PIP_NAME"
  [ -n "$LB_FQDN" ] && echo "  LB_FQDN (CNAME target): $LB_FQDN"
else
  echo "ERROR: Failed to patch $SERVICE_FILE" >&2
  exit 1
fi
