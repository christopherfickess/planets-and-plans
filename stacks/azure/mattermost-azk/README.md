
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