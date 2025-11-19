

```
terraform init -backend-config=tfvars/dev/backend.hcl

terraform plan -var-file="tfvars/dev/base.tfvars" -out="plan.tfplan"
