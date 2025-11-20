

```bash
terraform init -backend-config=tfvars/dev-chris/backend.hcl

terraform plan -var-file="tfvars/dev-chris/base.tfvars" -out="plan.tfplan"
