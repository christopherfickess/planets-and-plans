
# Deploy AZK with Azure Backend

# Connect to Azure

`az login`

# Setup Backend

Update the variables and the tf provider to the variables you want. Then run:
`source ./setup-backend.sh`

# Deploy Terraform

```bash
TF_VARS="dev-chris"
terraform init -backend-config=tfvars/${TF_VARS}/backend.hcl

terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"

terraform apply plan.tfplan
```