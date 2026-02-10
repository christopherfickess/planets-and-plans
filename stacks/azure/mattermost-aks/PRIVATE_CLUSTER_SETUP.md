# Private AKS Cluster with Bastion Host Access

This document explains the configuration for deploying a private AKS cluster that is only accessible via the Azure Bastion host and jumpbox VM.

## Architecture Overview

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
Private AKS API Server (Private IP, System-managed DNS)
```

## Key Security Features

✅ **Private AKS Cluster**: API server endpoint is not exposed to the internet  
✅ **System-Managed Private DNS**: Azure automatically creates and manages private DNS zone  
✅ **VNet-Only Access**: Only resources within the VNet can access the AKS API server  
✅ **Bastion-Only Access**: All access goes through Azure Bastion (no public IPs)  
✅ **Managed Identity**: Jumpbox uses managed identity for seamless authentication  

## Configuration

### 1. AKS Stack Configuration

In `stacks/azure/mattermost-aks/tfvars/dev-chris/base.tfvars`:

```hcl
# Enable private cluster
private_cluster_enabled = true

# Network profile (must match existing cluster if updating)
net_profile_service_cidr   = "10.2.0.0/16"
net_profile_dns_service_ip = "10.2.0.10"
```

### 2. Bastion Stack Configuration

In `stacks/azure/mattermost-bastion/tfvars/dev-chris/base.tfvars`:

```hcl
# VNet Configuration
vnet_name = "mattermost-dev-chris-vnet"  # Or your actual VNet name

# AKS Cluster Configuration
aks_cluster_name = "mattermost-dev-chris-aks"

# Bastion Subnet (must be /26 or larger)
bastion_subnet_addresses = ["10.0.3.0/26"]

# Jumpbox Subnet
jumpbox_subnet_addresses = ["10.0.4.0/24"]
```

## Deployment Order

### Step 1: Deploy/Update AKS Stack (Private Cluster)

```bash
cd stacks/azure/mattermost-aks
terraform init -backend-config=tfvars/dev-chris/backend.hcl
terraform plan -var-file="tfvars/dev-chris/base.tfvars"
terraform apply
```

**Important**: Enabling `private_cluster_enabled = true` on an existing cluster will **force replacement** of the cluster. This is expected behavior as network profile changes require cluster recreation.

### Step 2: Deploy Bastion Stack

```bash
cd stacks/azure/mattermost-bastion
terraform init -backend-config=tfvars/dev-chris/backend.hcl
terraform plan -var-file="tfvars/dev-chris/base.tfvars"
terraform apply
```

## Network Requirements

### VNet Address Space

Ensure your VNet has sufficient address space for:
- AKS subnet: `/24` (e.g., `10.0.0.0/24`)
- Bastion subnet: `/26` minimum (e.g., `10.0.3.0/26`)
- Jumpbox subnet: `/24` (e.g., `10.0.4.0/24`)
- Service CIDR: Must not overlap with VNet (e.g., `10.2.0.0/16`)

### Private DNS Zone

When `private_cluster_enabled = true`, Azure automatically creates a private DNS zone:
- Zone name: `privatelink.{region}.azmk8s.io`
- Managed by: Azure (System)
- Access: Resources in the same VNet can resolve AKS API server FQDN

## Accessing the Private Cluster

### Via Azure Portal

1. Navigate to **Virtual Machines** → `{prefix}-jumpbox`
2. Click **Connect** → **Bastion**
3. Enter username and SSH key
4. Once connected, run:

```bash
# Authenticate with managed identity
az login --identity --username <managed-identity-client-id>

# Get AKS credentials (uses private endpoint)
az aks get-credentials \
  --resource-group <resource-group> \
  --name <aks-cluster-name> \
  --overwrite-existing

# Verify access
kubectl cluster-info
kubectl get nodes
```

### Using the Setup Script

If the jumpbox was deployed with `aks_cluster_name` configured:

```bash
./setup-aks-access.sh
```

## Security Considerations

### Network Security

- **No Public IPs**: Jumpbox VM has no public IP address
- **NSG Rules**: Jumpbox subnet only allows inbound from Bastion subnet
- **Private Endpoint**: AKS API server only accessible from within VNet
- **Private DNS**: DNS resolution only works within the VNet

### Access Control

- **Azure AD RBAC**: Cluster uses Azure AD for authentication
- **Managed Identity**: Jumpbox uses managed identity (no stored credentials)
- **Role Assignments**: Jumpbox identity has "Azure Kubernetes Service RBAC Admin" role

### Best Practices

1. **Deploy Bastion First**: Ensure bastion is deployed before making AKS private
2. **Test Connectivity**: Verify jumpbox can access AKS before disabling public access
3. **Monitor Access**: Use Azure Monitor to track cluster access attempts
4. **Backup Access**: Keep alternative access method (e.g., VPN) as backup

## Troubleshooting

### Cannot Resolve AKS API Server

**Issue**: `kubectl` cannot resolve the AKS API server FQDN

**Solution**:
1. Verify private DNS zone exists: `az network private-dns zone list`
2. Check VNet link: `az network private-dns link vnet list`
3. Ensure jumpbox is in the same VNet as AKS

### Cannot Connect via Bastion

**Issue**: Cannot connect to jumpbox via Azure Bastion

**Solution**:
1. Verify Bastion is running: `az network bastion show`
2. Check NSG rules allow Bastion subnet
3. Verify jumpbox VM is running: `az vm show --query powerState`

### AKS Credentials Fail

**Issue**: `az aks get-credentials` fails

**Solution**:
1. Verify managed identity has "Azure Kubernetes Service Cluster User Role"
2. Check you're using managed identity: `az account show`
3. Ensure private DNS zone is linked to VNet

## Migration from Public to Private

If migrating an existing public cluster to private:

1. **Deploy Bastion First**: Ensure you have access method ready
2. **Update Configuration**: Set `private_cluster_enabled = true`
3. **Plan Changes**: Review Terraform plan (will show cluster replacement)
4. **Apply Changes**: Apply during maintenance window
5. **Verify Access**: Test access via bastion immediately after deployment

**Warning**: This will recreate the cluster. Ensure you have:
- Backups of cluster state
- Application deployment manifests
- Configuration backups
- Maintenance window scheduled

## Additional Resources

- [AKS Private Cluster Documentation](https://docs.microsoft.com/azure/aks/private-clusters)
- [Azure Bastion Documentation](https://docs.microsoft.com/azure/bastion/)
- [Private DNS Zones](https://docs.microsoft.com/azure/dns/private-dns-overview)
