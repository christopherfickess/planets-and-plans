# Terraform Deployment Guide


This guide walks you through deploying Mattermost on Postgres using Terraform with an Azure backend.

---

## 1️⃣ Login to Azure

1. Login to your Azure account using the Azure CLI:

    ```bash
    az login
    ```

    > This will open a browser window for authentication.

2. Set the desired subscription if you have access to multiple:

    ```bash
    az account set --subscription "Your Subscription Name or ID"
    ```

3. Setup Terraform Environment Variables for Azure Authentication:

  - You can set these as environment variables in your shell, or use a tool like `direnv` to automatically load them when you navigate to the project directory.
    ```bash
    export ARM_CLIENT_ID=##
    export ARM_CLIENT_SECRET=##
    export ARM_TENANT_ID=##
    export ARM_SUBSCRIPTION_ID=##
    ```


 - Additionally you can use Custom Script
    ```bash
    function azure.dev(){
        local SUBSCRIPTION_NAME="Your Subscription Name"
        export ARM_CLIENT_ID=##
        export ARM_CLIENT_SECRET=##
        export ARM_TENANT_ID=##
        export ARM_SUBSCRIPTION_ID=##
        
        az account set --subscription "$SUBSCRIPTION_NAME"
    }
    ```

---

## 2️⃣ Deploy Terraform Stacks

How to deploy the Terraform stacks for the AKS components.

```bash
pushd stacks/azure/mattermost-aks/
    TF_VARS="dev-chris"
    terraform init --migrate-state -backend-config=tfvars/${TF_VARS}/backend.hcl
    terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"
    terraform apply plan.tfplan
  
  # To connect to the cluster after deployment:
    terraform output connect_cluster

    # To destroy the stack:
    terraform destroy -var-file="tfvars/${TF_VARS}/base.tfvars"
    terraform force-unlock <LOCK_ID>
popd
```

---

## 🔒 Private Cluster Configuration

This stack is configured to deploy a **private AKS cluster** that is only accessible via the Azure Bastion host and jumpbox VM.

### Key Features

- **Private API Server**: AKS API server endpoint is not exposed to the internet
- **System-Managed Private DNS**: Azure automatically manages private DNS zone for cluster resolution
- **Bastion-Only Access**: All cluster access goes through Azure Bastion (no public IPs)
- **VNet-Only Access**: Only resources within the VNet can access the cluster

### Configuration

In `tfvars/dev-chris/base.tfvars`:

```hcl
# Enable private cluster
private_cluster_enabled = true

# Network profile (must match existing values to prevent replacement)
net_profile_service_cidr   = "10.2.0.0/16"
net_profile_dns_service_ip = "10.2.0.10"
```

### Accessing the Private Cluster

1. **Deploy Bastion Stack**: See `../mattermost-bastion/README.md`
2. **Connect via Azure Bastion**: Portal → VMs → Connect → Bastion
3. **Authenticate**: Use managed identity on jumpbox
4. **Get Credentials**: `az aks get-credentials --resource-group <rg> --name <cluster>`

For detailed instructions, see [PRIVATE_CLUSTER_SETUP.md](./PRIVATE_CLUSTER_SETUP.md)

---

# Notes 

Need to figure out how to allow RBAC access to the Key Vault for the AKS cluster. This is required for the cluster to retrieve the Postgres password stored in Key Vault.

Need to add this to the AKS admin role assignment:

```
resource "azurerm_role_assignment" "aks_kv" {
  principal_id   = module.aks.identity_principal_id
  role_definition_name = "Key Vault Secrets User"
  scope          = data.azurerm_key_vault.mattermost_key_vault.id
}
```


# Debugging

RBAC access issues to the cluster

```
environment="dev-chris"
cluster_name="mattermost-${environment}-aks"
resource_group="chrisfickess-tfstate-azk"

# Nothing
az aks show --name  $cluster_name --resource-group "${resource_group}" --query "apiServerAccessProfile.authorizedIpRanges"

# get aks resource id
aks_resource_id=$(az aks show --name  $cluster_name --resource-group "${resource_group}" --query "id" -o tsv)

az role assignment list --assignee christopher.fickess@mattermost.com --scope $aks_resource_id

# Check Azure PDE group permissions to cluster

az ad user get-member-groups \
  --id christopher.fickess@mattermost.com \
  --security-enabled-only

az role assignment list \
  --scope 26c3b8b8-a3bd-4401-9067-77a5e2541a18 \
  --query "[].{principal:principalName,role:roleDefinitionName}"
```


az role assignment create \
  --assignee christopher.fickess@mattermost.com \
  --role "Azure Kubernetes Service Cluster Admin Role" \
  --scope /subscriptions/95a937e7-e4a7-4f4b-9cb5-ce5affa2b458/resourceGroups/chrisfickess-tfstate-azk/providers/Microsoft.ContainerService/managedClusters/mattermost-dev-chris-aks

az role assignment create \
  --assignee christopher.fickess@mattermost.com \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope /subscriptions/95a937e7-e4a7-4f4b-9cb5-ce5affa2b458/resourceGroups/chrisfickess-tfstate-azk/providers/Microsoft.ContainerService/managedClusters/mattermost-dev-chris-aks
