

```bash
TF_VARS="dev-chris"
terraform init -backend-config=tfvars/${TF_VARS}/backend.hcl

terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"

terraform apply plan.tfplan
```
