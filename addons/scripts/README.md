# Addons Scripts

Scripts to retrieve Azure resource values and apply patches for addons deployment.

## Structure

| Folder | Purpose |
|--------|---------|
| **patches/** | Scripts that patch YAML files with values from env.local.sh |
| **resources/** | Scripts that fetch/gather Azure resource values |
| *(root)* | **get-resource-names.sh** – Discovers resources and writes env.local.sh |

## WSL / Windows

If you get `No such file or directory` when running scripts, it may be CRLF line endings. Fix with:

```bash
# Re-normalize line endings (run from repo root)
git add --renormalize addons/scripts addons/docs
git checkout -- addons/scripts addons/docs
```

Or run with bash explicitly: `bash addons/scripts/resources/get-all-addon-values.sh`

## Prerequisites

- Azure CLI installed and logged in (`az login`)
- (Optional) `env.local.sh` – created by get-resource-names.sh or copy from `addons/docs/env.sh`

## Scripts

### Discovery (root)

| Script | Purpose |
|--------|---------|
| **get-resource-names.sh** | Discover Azure resource names, write to addons/docs/env.local.sh |

### Resources (resources/)

| Script | Purpose |
|--------|---------|
| **get-all-addon-values.sh** | Master script – runs discovery + all getters |
| **get-keyvault-secrets.sh** | List Key Vault secrets used by External Secrets and Mattermost |
| **get-nfs-storage-values.sh** | Get NFS storage account, share name for `pvc.yaml` |
| **get-aks-credentials.sh** | Merge AKS kubeconfig for kubectl |
| **get-terraform-outputs.sh** | Get values from Terraform stack outputs |

### Patches (patches/)

| Script | Purpose |
|--------|---------|
| **check-patches-needed.sh** | Check if patches need to be applied (compare env vs repo) |
| **patch-mattermost-lb.sh** | Update mattermost service.yaml with LB annotations |
| **patch-envoy-gateway-lb.sh** | Update envoy-gateway patches.yaml with LB annotations |
| **patch-external-secrets-identity.sh** | Update external-secrets patches with workload identity client ID |

## Quick Start

```bash
# 1. Discover what resources exist
./addons/scripts/get-resource-names.sh

# 2. Source env and get all values
source addons/docs/env.local.sh
./addons/scripts/resources/get-all-addon-values.sh

# 3. Check if patches need applying
./addons/scripts/patches/check-patches-needed.sh

# 4. Apply patches if needed
./addons/scripts/patches/patch-mattermost-lb.sh
./addons/scripts/patches/patch-external-secrets-identity.sh
```

## Check if patches need applying

Before applying patches, run the check script to see what's out of sync:

```bash
./addons/scripts/patches/check-patches-needed.sh
# Or for a specific cluster:
./addons/scripts/patches/check-patches-needed.sh addons/clusters/azure/dev-chris
```

Output: `[OK]` = already applied, `[NEEDED]` = run the corresponding patch script. Exit code 1 if any patches are needed.

## Terraform outputs

```bash
# From repo root, after terraform apply
./addons/scripts/resources/get-terraform-outputs.sh mattermost-nfs
./addons/scripts/resources/get-terraform-outputs.sh mattermost-postgres
./addons/scripts/resources/get-terraform-outputs.sh mattermost-vnet
```
