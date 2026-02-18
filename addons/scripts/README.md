# Addons Scripts

Scripts to retrieve Azure resource values needed for addons deployment.

## WSL / Windows

If you get `No such file or directory` when running scripts, it may be CRLF line endings. Fix with:

```bash
# Re-normalize line endings (run from repo root)
git add --renormalize addons/scripts/*.sh addons/docs/*.sh
git checkout -- addons/scripts/*.sh addons/docs/*.sh
```

Or run the master script with bash explicitly: `bash addons/scripts/get-all-addon-values.sh`

## Prerequisites

- Azure CLI installed and logged in (`az login`)
- (Optional) `env.local.sh` – copy from `addons/docs/env.sh` and fill in your resource names

## Scripts

| Script | Purpose |
|--------|---------|
| **get-resource-names.sh** | Discover resource names when you only know the resource group or partial names (e.g. "mattermost") |
| **get-keyvault-secrets.sh** | List and verify Key Vault secrets used by External Secrets and Mattermost |
| **get-nfs-storage-values.sh** | Get NFS storage account, share name, and mount path for `pvc.yaml` |
| **get-aks-credentials.sh** | Merge AKS kubeconfig so you can run `kubectl` |
| **get-terraform-outputs.sh** | Get values from Terraform stack outputs (most reliable source) |
| **get-all-addon-values.sh** | Run discovery and all getters; outputs a full summary |

## Quick Start

```bash
# 1. Discover what resources exist
./addons/scripts/get-resource-names.sh

# 2. Create env file from discovered values
cp addons/docs/env.sh addons/docs/env.local.sh
# Edit env.local.sh with the resource names from step 1

# 3. Get all values
source addons/docs/env.local.sh
./addons/scripts/get-all-addon-values.sh
```

## Or use Terraform outputs

```bash
# From repo root, after terraform apply
./addons/scripts/get-terraform-outputs.sh mattermost-nfs
./addons/scripts/get-terraform-outputs.sh mattermost-postgres
```
