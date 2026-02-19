#!/bin/bash
# =============================================================================
# patch-envoy-gateway-lb.sh - Update envoy-gateway patches.yaml with LB annotations
# =============================================================================
# Run get-resource-names.sh first, then this script to add Azure load balancer
# annotations to envoy-gateway. Uses LB_PIP_NAME and RESOURCE_GROUP_NAME for
# azure-pip-name and azure-load-balancer-resource-group. LB_FQDN is for CNAME.
#
# Run: source addons/docs/env.local.sh && ./addons/scripts/patch-envoy-gateway-lb.sh
# Or:  ./addons/scripts/patch-envoy-gateway-lb.sh addons/clusters/azure/dev-chris
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

if [ -z "$LB_PIP_NAME" ] || [ -z "$RESOURCE_GROUP_NAME" ]; then
  echo "ERROR: LB_PIP_NAME and RESOURCE_GROUP_NAME must be set in env.local.sh" >&2
  echo "       Run get-resource-names.sh to discover them." >&2
  exit 1
fi

# Target: addons/clusters/azure/<cluster>/apps/envoy-gateway/patches.yaml
CLUSTER_PATH="${1:-addons/clusters/azure/dev-chris}"
PATCHES_FILE="$REPO_ROOT/$CLUSTER_PATH/apps/envoy-gateway/patches.yaml"

if [ ! -f "$PATCHES_FILE" ]; then
  echo "ERROR: Patches file not found: $PATCHES_FILE" >&2
  echo "       Usage: $0 [cluster-path]" >&2
  exit 1
fi

# Replace annotations: {} with actual Azure LB annotations
# Use perl for reliable multiline replacement (more portable than sed -i)
perl -i.bak -0pe "s/annotations: \{\}/annotations:\n      service.beta.kubernetes.io\/azure-load-balancer-resource-group: \"$RESOURCE_GROUP_NAME\"\n      service.beta.kubernetes.io\/azure-pip-name: \"$LB_PIP_NAME\"/s" "$PATCHES_FILE" 2>/dev/null
if [ $? -eq 0 ]; then
  rm -f "${PATCHES_FILE}.bak"
  echo "Updated $PATCHES_FILE with LB annotations:"
  echo "  azure-load-balancer-resource-group: $RESOURCE_GROUP_NAME"
  echo "  azure-pip-name: $LB_PIP_NAME"
  [ -n "$LB_FQDN" ] && echo "  LB_FQDN (CNAME target): $LB_FQDN"
else
  echo "ERROR: Failed to patch $PATCHES_FILE" >&2
  exit 1
fi
