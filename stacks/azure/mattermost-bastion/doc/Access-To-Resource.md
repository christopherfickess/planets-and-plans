
<!-- # Create Service Principal for Terraform

```bash
service_principal_name="tfstate-chrisfickess"   

az ad sp create-for-rbac \
    --name "${service_principal_name}" \
    --role "Contributor" \
    --scopes "/subscriptions/${subscription_id}/resourceGroups/${rg_name}"
``` -->

# Create Resources Group

### Create Resource Group

```bash
rg_name="chrisfickess-tfstate-azk"
location="eastus"

az group create \
    --name ${rg_name} \
    --location ${location}
```

## Create Storage Blocks For Terraform State

```bash
storage_account_name="chrisfickesstfstateazk"

az storage account create \
    --name ${storage_account_name} \
    --resource-group ${rg_name} \
    --location ${location} \
    --sku Standard_LRS \
    --kind StorageV2
```

#### 1. Create Storage Container for VNet Terraform State

```bash
storage_account_name="tfstatechrisfickess"
container_name="azure-vnet-tfstate"

az storage container create \
    --name ${container_name} \
    --account-name ${storage_account_name}
```

#### 2. Create Storage Container for Postgres Terraform State

```bash
storage_account_name="tfstatechrisfickess"
container_name="azure-postgres-tfstate"

az storage container create \
    --name ${container_name} \
    --account-name ${storage_account_name}
```

#### 3. Create Storage Container for AKS Terraform State

```bash
storage_account_name="tfstatechrisfickess"
container_name="azure-aks-tfstate"

az storage container create \
    --name ${container_name} \
    --account-name ${storage_account_name}
```

#### 4. Create Storage Container for Bastion Terraform State

```bash
storage_account_name="tfstatechrisfickess"
container_name="azure-bastion-tfstate"

az storage container create \
    --name ${container_name} \
    --account-name ${storage_account_name}
```


### 5.5 Create Service Principal

```bash
subscription_id=$(az account show --query id --output tsv)
service_principal_name="terraform-sp-chris"

az ad sp create-for-rbac \
    --name ${service_principal_name} \
    --role="Contributor" \
    --scopes="/subscriptions/${subscription_id}/"
```

### 5.6 Assign Storage Blob Data Contributor Role

```bash
appId=$(az ad sp list --display-name "${service_principal_name}" --query "[0].appId" -o tsv)

az role assignment create \
    --assignee "$appId" \
    --role "Storage Blob Data Contributor" \
    --scope "/subscriptions/$subscription_id/resourceGroups/$rg_name/providers/Microsoft.Storage/storageAccounts/$storage_account_name"
```

### 5.7 Assign Contributor Role to Azure AD Groups

```bash
az role assignment create \
    --assignee "$appId" \
    --role "Contributor" \
    --scope "/subscriptions/$subscription_id/resourceGroups/$rg_name"
```

### 5.7 Assign Contributor Role to Azure AD Groups

```bash
appId=$(az ad sp list --display-name "${service_principal_name}" --query "[0].appId" -o tsv)

az role assignment create \
    --assignee "$appId" \
    --role "Contributor" \
    --scope "/subscriptions/$subscription_id/resourceGroups/$rg_name/providers/Microsoft.KeyVault/vaults/mattermost-dev-chris-kv"
```
### 5.8 Assign User Access Administrator Role

```bash
az role assignment create \
    --assignee "$appId" \
    --role "User Access Administrator" \
    --scope "/subscriptions/$subscription_id/resourceGroups/$rg_name"
```

### 5.9 Verify Role Assignments

```bash
az role assignment list --assignee "$appId" --output table
```




---------------------------------------
# Notes

# Assign Azure PDE group to Key Vault Access Policy

```bash
group_object_id="$(az ad group show --group "Azure PDE" --query "id" -o tsv)"    # You can get this with az ad group show
kv_name="mattermost-dev-chris-kv"
rg_name="chrisfickess-tfstate-azk"
subscription_id=$(az account show --query id --output tsv)

# Assign role
az role assignment create \
    --assignee $group_object_id \
    --role "Key Vault Secrets User" \
    --scope "/subscriptions/$subscription_id/resourceGroups/$rg_name/providers/Microsoft.KeyVault/vaults/$kv_name"