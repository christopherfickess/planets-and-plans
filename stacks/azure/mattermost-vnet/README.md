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
    terraform init --upgrade -backend-config=tfvars/${TF_VARS}/backend.hcl
    terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"
    terraform apply plan.tfplan
    
    terraform plan --destroy -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan-destroy.tfplan"
    terraform apply plan-destroy.tfplan
popd
```

---

## 3️⃣ Load Balancer Outputs (NLB/ALB)

The VNet stack deploys the load balancer (ALB by default) outside the AKS cluster for decoupled lifecycle. Use these outputs for Kubernetes annotations or AGIC brownfield integration.

### Get values via Terraform output

```bash
cd stacks/azure/mattermost-vnet/
terraform output nlb_pip_name
terraform output load_balancer_resource_group
terraform output load_balancer_fqdn
```

### Get `azure-pip-name` via Azure CLI (NLB)

When using NLB (`lb_type = "nlb"`), get the Public IP name for the `service.beta.kubernetes.io/azure-pip-name` annotation:

```bash
# List Public IPs in the resource group (filter by load balancer)
az network public-ip list \
  --resource-group <RESOURCE_GROUP_NAME> \
  --query "[?contains(name, 'nlb') || contains(name, 'alb')].{name:name, ip:ipAddress, fqdn:fqdn}" \
  -o table

# Get the specific PIP name for NLB (use the name from above, e.g. mattermost-dev-chris-nlb-pip)
az network public-ip list \
  --resource-group <RESOURCE_GROUP_NAME> \
  --query "[?contains(name, 'nlb')].name" \
  -o tsv
```

**Example** (replace `chrisfickess-tfstate-azk` with your resource group):

```bash
RG="chrisfickess-tfstate-azk"
az network public-ip list --resource-group $RG --query "[?contains(name, 'nlb')].name" -o tsv
# Output: mattermost-dev-chris-nlb-pip
```

### Kubernetes LoadBalancer service annotation (NLB)

Use the PIP name with your LoadBalancer or Ingress service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mattermost-ingress
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-resource-group: "chrisfickess-tfstate-azk"
    service.beta.kubernetes.io/azure-pip-name: "mattermost-dev-chris-nlb-pip"
spec:
  type: LoadBalancer
  # ...
```

Replace `chrisfickess-tfstate-azk` and `mattermost-dev-chris-nlb-pip` with values from `terraform output load_balancer_resource_group` and `terraform output nlb_pip_name` (or the az CLI commands above).

### Mattermost LoadBalancer - CNAME (like AWS ELB)

A dedicated PIP is created for the Mattermost Kubernetes LoadBalancer service with a stable FQDN for CNAME (no IP in DNS):

```bash
terraform output mattermost_lb_pip_name   # e.g. mattermost-dev-chris-mattermost-pip
terraform output mattermost_lb_fqdn      # e.g. mattermost-dev-chris-mattermost.eastus2.cloudapp.azure.com
```

Use `mattermost_lb_pip_name` in the service annotation. Point your domain (e.g. dev-chris.dev.cloud.mattermost.com) to `mattermost_lb_fqdn` via CNAME.

### Cloudflare CNAME (optional - like AWS Route53)

To have Terraform create the CNAME record in Cloudflare:

1. Get your zone ID from Cloudflare (Dashboard → dev.cloud.mattermost.com → Overview → Zone ID)
2. Create a Cloudflare API token with Zone:DNS:Edit
3. Add to your tfvars or pass at apply:

```hcl
cloudflare_zone_id     = "<your-zone-id>"
cloudflare_api_token   = "<token>"   # or set env CLOUDFLARE_API_TOKEN / TF_VAR_cloudflare_api_token
cloudflare_record_name = "dev-chris" # record name in zone (dev-chris.dev.cloud.mattermost.com)
```

Terraform will create: `dev-chris` (CNAME) → `mattermost-dev-chris-mattermost.eastus2.cloudapp.azure.com`
