# Deploy AZK with Azure Backend (AKS + Terraform)

This guide walks you through deploying Mattermost on AKS using Terraform with an Azure backend.

It covers:

* Preparing Azure
* Configuring the Terraform backend
* Deploying required Terraform stacks
* Setting up RBAC and Service Principals

---

## 1️⃣ Prerequisites

Ensure the following tools are installed:

* [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
* [Terraform](https://www.terraform.io/downloads.html)
* `kubelogin` for AKS Azure AD authentication

```bash
# Install kubelogin (Linux example)

curl -LO [https://github.com/Azure/kubelogin/releases/download/v0.2.14/kubelogin-linux-amd64.zip](https://github.com/Azure/kubelogin/releases/download/v0.2.14/kubelogin-linux-amd64.zip)
unzip kubelogin-linux-amd64.zip -d /usr/local/bin/
chmod +x /usr/local/bin/kubelogin
```

---

## 2️⃣ Login to Azure

```bash
az login
```

> This will open a browser window for authentication.

---

## 3️⃣ Setup Terraform Backend

Update your variables and provider configuration as needed.
Then run:

```bash
source ./scripts/setup-backend.sh
```

---

## 4️⃣ Deploy Terraform Stacks

The deployment requires two Terraform stacks: VNet first, then AZK.

### 4.1 Deploy the VNet Stack

```bash
pushd stacks/azure/mattermost-vnet/
TF_VARS="dev-chris"
terraform init --migrate-state -backend-config=tfvars/${TF_VARS}/backend.hcl
terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"
terraform apply plan.tfplan
popd
```

### 4.2 Deploy the AZK Stack

```bash
pushd stacks/azure/mattermost-azk/
TF_VARS="dev-chris"
terraform init --migrate-state -backend-config=tfvars/${TF_VARS}/backend.hcl
terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"
terraform apply plan.tfplan
popd
```

---

## 5️⃣ Manual Setup Steps

Some steps are not fully automated yet.

### 5.1 Install Azure CLI & kubelogin

```bash
az login

curl -LO [https://github.com/Azure/kubelogin/releases/download/v0.2.14/kubelogin-linux-amd64.zip](https://github.com/Azure/kubelogin/releases/download/v0.2.14/kubelogin-linux-amd64.zip)
unzip kubelogin-linux-amd64.zip -d /usr/local/bin/
chmod +x /usr/local/bin/kubelogin
```

### 5.2 Create Resource Group

```bash
rg_name="chrisfickess-tfstate-azk"

az group create 
--name ${rg_name} 
--location eastus
```

### 5.3 Create Storage Account

```bash
storage_account_name="chrisfickesstfstateazk"

az storage account create 
--name ${storage_account_name} 
--resource-group ${rg_name} 
--location eastus 
--sku Standard_LRS 
--kind StorageV2
```

### 5.4 Create Storage Container

```bash
container_name="azure-azk-tfstate"

az storage container create 
--name ${container_name} 
--account-name ${storage_account_name}
```

### 5.5 Create Service Principal

```bash
subscription_id=$(az account show --query id --output tsv)
service_principal_name="terraform-sp-chris"

az ad sp create-for-rbac 
--name ${service_principal_name} 
--role="Contributor" 
--scopes="/subscriptions/${subscription_id}/"
```

### 5.6 Assign Storage Blob Data Contributor Role

```bash
appId=$(az ad sp list --display-name "${service_principal_name}" --query "[0].appId" -o tsv)

az role assignment create 
--assignee "$appId" 
--role "Storage Blob Data Contributor" 
--scope "/subscriptions/$subscription_id/resourceGroups/$rg_name/providers/Microsoft.Storage/storageAccounts/$storage_account_name"
```

### 5.7 Assign Contributor Role to Azure AD Groups

```bash
az role assignment create 
--assignee "$appId" 
--role "Contributor" 
--scope "/subscriptions/$subscription_id/resourceGroups/$rg_name"
```

### 5.8 Assign User Access Administrator Role

```bash
az role assignment create 
--assignee "$appId" 
--role "User Access Administrator" 
--scope "/subscriptions/$subscription_id/resourceGroups/$rg_name"
```

### 5.9 Verify Role Assignments

```bash
az role assignment list --assignee "$appId" --output table
```

---

## 6️⃣ Work in Progress

* Add RBAC bindings for AKS cluster-admins and users based on Azure AD groups

```bash
╷
│ Error: Post "[http://localhost/apis/rbac.authorization.k8s.io/v1/clusterrolebindings](http://localhost/apis/rbac.authorization.k8s.io/v1/clusterrolebindings)": dial tcp 127.0.0.1:80: connect: connection refused
│
│   with module.mattermost_aks.kubernetes_cluster_role_binding_v1.aks_admin_binding,
│   on ../../../modules/azure/common/aks/rbac.tf line 3, in resource "kubernetes_cluster_role_binding_v1" "aks_admin_binding":
│    3: resource "kubernetes_cluster_role_binding_v1" "aks_admin_binding" {
╵
```

* Migrate Networking to new stack
* EKS Stack Only

---

## 7️⃣ TFVARS Example

```bash
# Azure Group Variables

email_contact       = "[email.address@example.com](mailto:email.address@example.com)"
environment         = "dev-chris"
location            = "East US"
resource_group_name = "resource-group-name-from-above"
unique_name_prefix  = "chris-fickess"

# Azure Group Variables

azure_pde_admin_group_display_name = "AKS Role Admins"
aks_admin_rbac_name                = "aks-cluster-admin"
admin_group_display_name           = "chrisfickess-azk-dev-admins"
user_group_display_name            = "chrisfickess-azk-dev-users"

# VNet Variables

vnet_name            = "chrisfickess-azk-vnet-dev"
address_space        = ["172.16.10.0/23"]
aks_subnet_addresses = ["172.16.10.0/25"]
pod_subnet_addresses = ["172.16.10.128/26"]

net_profile_service_cidr   = "10.2.0.0/16"
net_profile_dns_service_ip = "10.2.0.10"
```