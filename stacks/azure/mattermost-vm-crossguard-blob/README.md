



```bash
# Terraform Commands

TF_VARS="dev-chris"
az storage container create \
    --account-name tfstatechrisfickess \
    --name azure-crossguard-tfstate \
    --auth-mode login

terraform init --upgrade -backend-config=tfvars/${TF_VARS}/backend.hcl

terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"

terraform apply plan.tfplan


terraform plan --destroy -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan-destroy.tfplan"
terraform apply plan-destroy.tfplan
terraform force-unlock <LOCK_ID>
```
