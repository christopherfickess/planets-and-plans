#!/bin/bash
# =============================================================================
# get-aks-credentials.sh - Get AKS cluster credentials for kubectl
# =============================================================================
# Merges AKS credentials into ~/.kube/config so you can run kubectl
#
# Prerequisites: RESOURCE_GROUP_NAME, AKS_CLUSTER_NAME
# Run: source addons/docs/env.local.sh && ./addons/scripts/get-aks-credentials.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$(dirname "$SCRIPT_DIR")/docs"

if [ -f "$DOCS_DIR/env.local.sh" ]; then
  source "$DOCS_DIR/env.local.sh"
fi

if [ -z "$RESOURCE_GROUP_NAME" ] || [ -z "$AKS_CLUSTER_NAME" ]; then
  echo "ERROR: RESOURCE_GROUP_NAME and AKS_CLUSTER_NAME required."
  echo "Source env.local.sh or export them."
  exit 1
fi

echo "=== Getting AKS credentials ==="
echo "Cluster: $AKS_CLUSTER_NAME"
echo "Resource group: $RESOURCE_GROUP_NAME"
echo ""

az aks get-credentials \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$AKS_CLUSTER_NAME" \
  --overwrite-existing

echo ""
echo "Verifying connection..."
kubectl get nodes -o wide 2>/dev/null || echo "kubectl not in PATH or cluster unreachable"
