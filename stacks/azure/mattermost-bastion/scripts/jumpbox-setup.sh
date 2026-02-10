#!/bin/bash
set -e

# Variables from Terraform
AKS_NAME="${AKS_NAME}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME}"
MANAGED_IDENTITY_ID="${MANAGED_IDENTITY_ID}"
ADMIN_USERNAME="${ADMIN_USERNAME}"

# Update system
apt-get update
apt-get install -y curl apt-transport-https ca-certificates gnupg lsb-release

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install other useful tools
apt-get install -y git jq vim

# Create a helper script for AKS access (only if AKS cluster name is provided)
if [ -n "$AKS_NAME" ]; then
cat > /home/${ADMIN_USERNAME}/setup-aks-access.sh << EOF
#!/bin/bash
set -e

# Get variables
AKS_NAME="${AKS_NAME}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME}"
MANAGED_IDENTITY_ID="${MANAGED_IDENTITY_ID}"
ADMIN_USERNAME="${ADMIN_USERNAME}"

echo "Setting up AKS access using managed identity..."

# Login with managed identity
az login --identity --username \$MANAGED_IDENTITY_ID

# Get AKS credentials
echo "Retrieving AKS credentials..."
az aks get-credentials --resource-group \$RESOURCE_GROUP --name \$AKS_NAME --overwrite-existing

# Verify access
echo "Verifying kubectl access..."
kubectl cluster-info
kubectl get nodes

echo "AKS access configured successfully!"
echo "You can now use kubectl to interact with the cluster."
EOF

chmod +x /home/${ADMIN_USERNAME}/setup-aks-access.sh
chown ${ADMIN_USERNAME}:${ADMIN_USERNAME} /home/${ADMIN_USERNAME}/setup-aks-access.sh
fi

# Create a README with instructions
if [ -n "$AKS_NAME" ]; then
cat > /home/${ADMIN_USERNAME}/README.md << READMEEOF
# Jumpbox Setup Complete

## Installed Tools
- Azure CLI
- kubectl
- Helm
- git, jq, vim

## Connecting to AKS

After connecting via Azure Bastion, run:

\`\`\`bash
./setup-aks-access.sh
\`\`\`

This will:
1. Authenticate using the VM's managed identity
2. Configure kubectl to access the AKS cluster
3. Verify connectivity

## Manual Steps

If you prefer to do it manually:

\`\`\`bash
# Login with managed identity
az login --identity --username <managed-identity-client-id>

# Get AKS credentials
az aks get-credentials --resource-group <resource-group> --name <aks-name>

# Verify access
kubectl get nodes
\`\`\`

## Cluster Information
- AKS Name: ${AKS_NAME}
- Resource Group: ${RESOURCE_GROUP_NAME}
- Managed Identity Client ID: ${MANAGED_IDENTITY_ID}
READMEEOF
else
cat > /home/${ADMIN_USERNAME}/README.md << READMEEOF
# Jumpbox Setup Complete

## Installed Tools
- Azure CLI
- kubectl
- Helm
- git, jq, vim

## General Usage

You can use this jumpbox to access any Azure resources. The VM has Azure CLI, kubectl, and Helm pre-installed.

To authenticate with Azure:
\`\`\`bash
az login --identity --username ${MANAGED_IDENTITY_ID}
\`\`\`

## Cluster Information
- Resource Group: ${RESOURCE_GROUP_NAME}
- Managed Identity Client ID: ${MANAGED_IDENTITY_ID}
READMEEOF
fi

chown ${ADMIN_USERNAME}:${ADMIN_USERNAME} /home/${ADMIN_USERNAME}/README.md

# Log completion
echo "Jumpbox setup completed successfully at $(date)" >> /var/log/jumpbox-setup.log
