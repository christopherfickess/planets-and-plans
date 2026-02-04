
# Deploy AZK with Azure Backend

# Connect to Azure

`az login`

# Setup Backend

Update the variables and the tf provider to the variables you want. Then run:
`source ./scripts/setup-backend.sh`

# Deploy Terraform

```bash

export ARM_CLIENT_ID=##
export ARM_CLIENT_SECRET=##
export ARM_TENANT_ID=##
export ARM_SUBSCRIPTION_ID=##

# or use 

azure.dev

# Terraform Commands

TF_VARS="dev-chris"
terraform init --migrate-state -backend-config=tfvars/${TF_VARS}/backend.hcl

terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"

terraform apply plan.tfplan

terraform destroy -var-file="tfvars/${TF_VARS}/base.tfvars"

terraform force-unlock <LOCK_ID>
```


### Notes

This process had several steps that were not fully automated yet.

1. Install the Azure CLI and login with your account:
    ```bash
    az login

    curl -LO https://github.com/Azure/kubelogin/releases/download/v0.2.14/kubelogin-linux-amd64.zip
    unzip kubelogin-linux-amd64.zip -d /usr/local/bin/
    chmod +x /usr/local/bin/kubelogin
    ```

2. Create the Resource Group:

    ```bash
    rg_name="chrisfickess-tfstate-azk"
    
    # Create Resource Group
    az group create \
        --name ${rg_name} \
        --location eastus   
    ```

3. Create the Storage Account:

    ```bash
    rg_name="chrisfickess-tfstate-azk"
    storage_account_name="chrisfickesstfstateazk"

    # Create Storage Account
    az storage account create \
        --name ${storage_account_name} \
        --resource-group ${rg_name} \
        --location eastus \
        --sku Standard_LRS \
        --kind StorageV2
    ```

4. Create the Storage Container:

    ```bash
    container_name="azure-azk-tfstate"
    storage_account_name="chrisfickesstfstateazk"

    # Create Storage Container
    az storage container create \
        --name ${container_name} \
        --account-name ${storage_account_name}
    ```

5. Create the Service Principal:

    ```bash
    subscription_id=$(az account show --query id --output tsv)
    service_principal_name="terraform-sp-chris"

    # Create Service Principal
    az ad sp create-for-rbac --name ${service_principal_name} \
            --role="Contributor" \
            --scopes="/subscriptions/${subscription_id}/"
    ```

6. Assign Storage Blob Data Contributor Role to the Service Principal

    ```bash
    rg_name="chrisfickess-tfstate-azk"
    storage_account_name="chrisfickesstfstateazk"
    appId='$(az ad sp list --display-name "${service_principal_name}" --query "[0].appId" -o tsv)'
    subscription_id=$(az account show --query id --output tsv)

    # Assign Storage Blob Data Contributor role to the Service Principal
    az role assignment create \
        --assignee "$appId" \
        --role "Storage Blob Data Contributor" \
        --scope "/subscriptions/$subscription_id/resourceGroups/$rg_name/providers/Microsoft.Storage/storageAccounts/$storage_account_name"
    ```

7. Add Contributer Role to the Azure AD Groups

    ```bash
    rg_name="chrisfickess-tfstate-azk"
    appId='$(az ad sp list --display-name "${service_principal_name}" --query "[0].appId" -o tsv)'
    subscription_id=$(az account show --query id --output tsv)

    az role assignment create \
        --assignee "$appId" \
        --role "Contributor" \
        --scope "/subscriptions/$subscription_id/resourceGroups/$rg_name"
    ```

8. Assign User Access Administrator Role to the Service Principal

    ```bash
    rg_name="chrisfickess-tfstate-azk"
    appId='$(az ad sp list --display-name "${service_principal_name}" --query "[0].appId" -o tsv)'
    subscription_id=$(az account show --query id --output tsv)

    # Assign User Access Administrator on the resource group
    az role assignment create \
        --assignee "$appId" \
        --role "User Access Administrator" \
        --scope "/subscriptions/$subscription_id/resourceGroups/$rg_name"
    ```

9. Verify the Role Assignments

    ```bash
    service_principal_name="terraform-sp-chris"
    appId=$(az ad sp list --display-name "${service_principal_name}" --query "[0].appId" -o tsv)

    # List Role Assignments for the Service Principal
    az role assignment list --assignee "$appId" --output table
    ```


# Work in Progress

- Add RBAC bindings for AKS cluster-admins and users based on Azure AD groups.
    ```bash
    ╷
    │ Error: Post "http://localhost/apis/rbac.authorization.k8s.io/v1/clusterrolebindings": dial tcp 127.0.0.1:80: connect: connection refused
    │
    │   with module.mattermost_aks.kubernetes_cluster_role_binding_v1.aks_admin_binding,
    │   on ../../../modules/azure/common/aks/rbac.tf line 3, in resource "kubernetes_cluster_role_binding_v1" "aks_admin_binding":
    │    3: resource "kubernetes_cluster_role_binding_v1" "aks_admin_binding" {
    │
    ╵
    ```
- Migrate Networking to new Stack.
- EKS Stack Only


## TFVARS Example

```json
# Azure Group Variables


email_contact       = "email.address@example.com"
environment         = "dev-chris"
location            = "East US"
resource_group_name = "resource-group-name-from-above"
unique_name_prefix  = "chris-fickess"

# Azure Group Variables
azure_pde_admin_group_display_name = "AKS Role Admins"  # Role with authority to assign RBAC roles in AKS
aks_admin_rbac_name                = "aks-cluster-admin"  # Name of Admin RBAC user
admin_group_display_name           = "chrisfickess-azk-dev-admins" # Mattermost Admins Group
user_group_display_name            = "chrisfickess-azk-dev-users"  # Mattermost Users Group

# Mattermost Admins Group Object ID
azure_group_principal_id = "26c3b8b8-a3bd-4401-9067-77a5e2541a18" # Azure PDE Admins Group

# Vnet Variables
vnet_name            = "chrisfickess-azk-vnet-dev"
address_space        = ["172.16.10.0/23"]   # Full VNet
aks_subnet_addresses = ["172.16.10.0/25"]   # Subnet for AKS nodes
pod_subnet_addresses = ["172.16.10.128/26"] # Subnet for pods (Azure CNI)

net_profile_service_cidr   = "10.2.0.0/16"
net_profile_dns_service_ip = "10.2.0.10"
```