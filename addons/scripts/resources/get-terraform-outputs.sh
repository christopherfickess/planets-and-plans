#!/bin/bash
# =============================================================================
# get-terraform-outputs.sh - Get values from Terraform stack outputs
# =============================================================================
# The most reliable source: Terraform outputs from your deployed stacks.
# Run from repo root. Requires Terraform initialized in each stack.
#
# Run: ./addons/scripts/resources/get-terraform-outputs.sh [stack-name]
#   stack-name: mattermost-nfs | mattermost-postgres | mattermost-aks | mattermost-vnet
#   If omitted, runs for mattermost-nfs and mattermost-postgres (most used by addons)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
STACKS_DIR="$REPO_ROOT/stacks/azure"

STACK="${1:-}"

run_output() {
  local stack_path="$1"
  local stack_name=$(basename "$stack_path")
  if [ -d "$stack_path" ]; then
    echo "--- $stack_name ---"
    (cd "$stack_path" && terraform output -json 2>/dev/null) || echo "  (run terraform init/plan first)"
    echo ""
  fi
}

echo "=== Terraform Outputs for Addons ==="
echo ""

if [ -n "$STACK" ]; then
  run_output "$STACKS_DIR/$STACK"
else
  run_output "$STACKS_DIR/mattermost-nfs"
  run_output "$STACKS_DIR/mattermost-postgres"
  echo "To get AKS or VNet outputs: ./addons/scripts/resources/get-terraform-outputs.sh mattermost-aks"
fi
