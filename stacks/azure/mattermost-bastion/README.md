# Mattermost Bastion Host Stack

This Terraform stack deploys an Azure Bastion host and jumpbox VM for secure access to private Azure resources, particularly AKS clusters.

## Overview

The bastion stack provides:
- **Azure Bastion Host**: Secure, RDP/SSH connectivity without exposing public IPs
- **Jumpbox VM**: Pre-configured Linux VM with kubectl, Azure CLI, and Helm
- **Managed Identity**: Seamless authentication to Azure resources
- **Private Access**: All resources use private IPs, accessed only through Azure Bastion

## Architecture

```
Internet
   │
   ▼
Azure Portal / Azure Bastion (Public)
   │
   ▼
Azure Bastion Host (Private IP in AzureBastionSubnet)
   │
   ▼
Jumpbox VM (Private IP in jumpbox-subnet)
   │
   ▼
Private AKS Cluster / Other Azure Resources
```

## Prerequisites

1. **VNet must exist** with available address space for:
   - Bastion subnet: `/26` minimum (e.g., `10.0.3.0/26`)
   - Jumpbox subnet: `/24` recommended (e.g., `10.0.4.0/24`)

2. **Required Azure permissions**:
   - Contributor role on the resource group
   - Ability to create subnets in the VNet
   - Ability to create Azure Bastion resources

3. **Optional**: AKS cluster name (if you want automatic AKS access configuration)

## Configuration

### Required Variables

```hcl
email_contact        = "your-email@example.com"
environment          = "dev"
location             = "eastus"
resource_group_name  = "your-resource-group"
unique_name_prefix   = "mattermost-dev"
```

### Optional Variables

```hcl
# VNet Configuration
vnet_name = "mattermost-dev-vnet"  # If not provided, uses {prefix}-vnet

# AKS Cluster (optional - for automatic AKS access)
aks_cluster_name         = "mattermost-dev-aks-cluster"
aks_cluster_resource_id  = ""  # Optional, will be derived if not provided

# Bastion Subnet
bastion_subnet_addresses = ["10.0.3.0/26"]

# Jumpbox Configuration
jumpbox_subnet_addresses = ["10.0.4.0/24"]
jumpbox_vm_size         = "Standard_B2s"
jumpbox_admin_username  = "azureuser"
jumpbox_ssh_public_key  = ""  # Optional, will generate if not provided
```

## Deployment

### 1. Initialize Terraform

```bash
TF_VARS="dev-chris"
terraform init --migrate-state -backend-config=tfvars/dev-chris/backend.hcl
```

### 2. Plan the Deployment

```bash
terraform plan -var-file="tfvars/dev-chris/base.tfvars" -out="plan.tfplan"
```

### 3. Apply the Changes

```bash
terraform apply plan.tfplan
```

### 4. Get Connection Information

```bash
# Get SSH private key (if Terraform generated it)
terraform output -raw jumpbox_ssh_private_key > jumpbox_key.pem
chmod 600 jumpbox_key.pem

# Get connection instructions
terraform output bastion_connection_instructions
```

## Connecting to the Jumpbox

### Via Azure Portal

1. Navigate to **Azure Portal** → **Virtual Machines**
2. Find your jumpbox VM: `{prefix}-jumpbox`
3. Click **Connect** → Select **Bastion**
4. Enter:
   - **Username**: `azureuser` (or your custom username)
   - **SSH Private Key**: Paste the private key from Terraform output
      - ```bash
         az keyvault secret show \
            --vault-name <kv-name> \
            --name jumpbox-ssh-private-key \
            --query value \
            -o tsv > jumpbox.pem

            chmod 600 jumpbox.pem
         ```
5. Click **Connect**

### Via Azure CLI

```bash
# Get the VM resource ID
VM_ID=$(terraform output -raw jumpbox_vm_id)

# Connect via Azure CLI (requires Azure CLI extension)
az vm connect --ids $VM_ID --bastion
```

## Accessing AKS from Jumpbox

If you provided `aks_cluster_name`, the jumpbox is pre-configured for AKS access.

### Quick Setup

```bash
# Run the automated setup script
./setup-aks-access.sh
```

### Manual Setup

```bash
# Get the managed identity client ID
MANAGED_IDENTITY_ID=$(terraform output -raw jumpbox_managed_identity_id)

# Login with managed identity
az login --identity --username $MANAGED_IDENTITY_ID

# Get AKS credentials
az aks get-credentials \
  --resource-group <your-resource-group> \
  --name <your-aks-cluster-name> \
  --overwrite-existing

# Verify access
kubectl cluster-info
kubectl get nodes
```

## Deploying Applications

After AKS access is configured:

```bash
# Create a namespace
kubectl create namespace my-app

# Deploy an application
kubectl create deployment nginx \
  --image=nginx \
  --namespace=my-app

# Expose as LoadBalancer
kubectl expose deployment nginx \
  --port=80 \
  --type=LoadBalancer \
  --namespace=my-app
```

## Security Features

✅ **No Public IPs**: Jumpbox VM has no public IP address  
✅ **NSG Protection**: Only Azure Bastion subnet can access jumpbox  
✅ **Managed Identity**: No passwords or keys stored on VM  
✅ **SSH Key Only**: Password authentication disabled  
✅ **Private Access**: All resources use private networking  

## Cost Optimization

### Estimated Monthly Costs

- **Azure Bastion**: ~$140/month (when running)
- **Jumpbox VM (Standard_B2s)**: ~$30/month
- **Total**: ~$170/month

### Stop When Not in Use

To save costs, stop the jumpbox VM when not in use:

```bash
# Stop the VM
az vm stop \
  --resource-group <resource-group> \
  --name <jumpbox-name>

# Start when needed
az vm start \
  --resource-group <resource-group> \
  --name <jumpbox-name>
```

**Note**: Azure Bastion charges apply even when not actively used. Consider deleting and recreating if not needed for extended periods.

## Troubleshooting

### Cannot connect via Bastion

1. **Check Bastion status**:
   ```bash
   az network bastion show \
     --resource-group <resource-group> \
     --name <bastion-name> \
     --query "provisioningState"
   ```

2. **Verify NSG rules**: Ensure jumpbox NSG allows traffic from bastion subnet

3. **Check VM status**:
   ```bash
   az vm show \
     --resource-group <resource-group> \
     --name <jumpbox-name> \
     --query "powerState"
   ```

### Cannot access AKS

1. **Verify managed identity permissions**:
   ```bash
   az role assignment list \
     --assignee <managed-identity-client-id> \
     --scope <aks-resource-id>
   ```

2. **Check AKS cluster status**:
   ```bash
   az aks show \
     --resource-group <resource-group> \
     --name <aks-name> \
     --query "powerState.code"
   ```

### Tools not installed

If tools aren't installed, check logs:

```bash
# Check cloud-init logs
sudo cat /var/log/cloud-init-output.log
sudo cat /var/log/jumpbox-setup.log
```

## Integration with Other Stacks

This bastion stack can be used independently or integrated with other stacks:

### Standalone Deployment

Deploy bastion first, then reference it from other stacks:

```bash
# Deploy bastion
cd stacks/azure/mattermost-bastion
terraform apply

# Get outputs for use in other stacks
terraform output -json > ../bastion-outputs.json
```

### With AKS Stack

If deploying with the AKS stack, provide the AKS cluster name:

```hcl
aks_cluster_name = "mattermost-dev-aks-cluster"
```

The bastion will automatically configure role assignments for AKS access.

## Additional Resources

- [Azure Bastion Documentation](https://docs.microsoft.com/azure/bastion/)
- [AKS Private Cluster](https://docs.microsoft.com/azure/aks/private-clusters)
- [Azure Managed Identity](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/)
