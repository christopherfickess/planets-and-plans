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

How to deploy the Terraform stacks for the Postgres components.

```bash
# Terraform Commands

TF_VARS="dev-chris"
terraform init --migrate-state -backend-config=tfvars/${TF_VARS}/backend.hcl

terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"

terraform apply plan.tfplan

terraform destroy -var-file="tfvars/${TF_VARS}/base.tfvars"

terraform force-unlock <LOCK_ID>
```

# Configuration Steps

## Database Deployment Steps

Deploy the Post cofiguration scripts in the [Module/common/postgres/scripts](../../../modules/azure/common/postgres/scripts) directory. These scripts will create the necessary database, users, and permissions for the Mattermost application.

- Run the following command to deploy this configuration:
   - Updated the information as needed in the outputs of the scripts.

```bash
pushd ${HOME}/git/terraform/planets-and-plans/modules/azure/common/postgres/scripts
    ./deploy.sh
popd
```

# Notes 

Need to figure out how to allow RBAC access to the Key Vault for the AKS cluster. This is required for the cluster to retrieve the Postgres password stored in Key Vault.

Need to add this to the AKS

```
resource "azurerm_role_assignment" "aks_kv" {
  principal_id   = module.aks.identity_principal_id
  role_definition_name = "Key Vault Secrets User"
  scope          = azurerm_key_vault.example.id
}
```