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

How to deploy the Terraform stacks for the VNet components.

```bash
pushd stacks/azure/mattermost-vnet/
    TF_VARS="dev-chris"
    terraform init --migrate-state -backend-config=tfvars/${TF_VARS}/backend.hcl
    terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"
    terraform apply plan.tfplan
popd
```
