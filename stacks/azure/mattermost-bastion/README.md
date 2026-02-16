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

## Connecting to the Jumpbox

The following is how to connect to the jumpbox VM via Azure Bastion and configure AKS access.

### Using Terraform Outputs

How to get terraform outputs and connect to the jumpbox via Azure Bastion.

```bash
# Get SSH private key (if Terraform generated it)
terraform output -raw jumpbox_ssh_private_key > jumpbox_key.pem
chmod 600 jumpbox_key.pem

# Get connection instructions from terraform
terraform output bastion_connection_instructions
```

### Manual Connection Steps

This method is useful if you want to connect manually or troubleshoot connection issues.

```bash
__environment__="dev-chris"
__resource_group__="chrisfickess-tfstate-azk"
__bastion_name__="mattermost-${__environment__}-bastion"
__key_vault_name__="mattermost-$__environment__-kv"
__secret_name__="mattermost-$__environment__-jumpbox-ssh-private-key"
__jumpbox_vm_name__="mattermost-$__environment__-jumpbox"

mkdir -p ssh/jumpbox_$__environment__;

az keyvault secret show \
   --vault-name $__key_vault_name__ \
   --name $__secret_name__ \
   --query value -o tsv > ssh/jumpbox_$__environment__/jumpbox_$__environment__.key

chmod 600 ssh/jumpbox_$__environment__/jumpbox_$__environment__.key

target_id=$(az vm show \
  --name $__jumpbox_vm_name__ \
  --resource-group $__resource_group__ \
  --query id -o tsv)

az network bastion ssh \
  --name $__bastion_name__ \
  --resource-group $__resource_group__ \
  --target-resource-id "${target_id}" \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ssh/jumpbox_$__environment__/jumpbox_$__environment__.key
```

## Additional Resources

- [Azure Bastion Documentation](https://docs.microsoft.com/azure/bastion/)
- [AKS Private Cluster](https://docs.microsoft.com/azure/aks/private-clusters)
- [Azure Managed Identity](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/)

# Force delete Key Vault

```bash
az keyvault purge --name mattermost-dev-chris-pgs --location eastus 
```