# Addons Deployment Guide: Getting Azure Resource Values

This guide helps new developers retrieve all Azure resource names and values needed to deploy the addons in `addons/clusters/azure/<cluster-name>/`.

**See also:** [addons/scripts/README.md](../scripts/README.md) for script usage.

**Prerequisites:**
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in (`az login`)
- Access to the Azure subscription where the Terraform stacks were deployed

---

## Quick Start

1. **Set your environment variables** – Copy `env.sh` and fill in the resource names for your deployment:
   ```bash
   cp addons/docs/env.sh addons/docs/env.local.sh
   # Edit env.local.sh with your resource names
   source addons/docs/env.local.sh
   ```

2. **Run the discovery script** (if you don't know resource names yet):
   ```bash
   ./addons/scripts/get-resource-names.sh
   ```

3. **Get specific values** – Use the scripts in `addons/scripts/` for each resource type.

---

## Resource Overview

The addons depend on these Azure resources (created by Terraform stacks):

| Resource | Used By | Key Values Needed |
|----------|---------|-------------------|
| **Key Vault** | External Secrets, Mattermost DB | Vault name, secret names |
| **PostgreSQL** | Mattermost | Connection string, user, password (from Key Vault) |
| **NFS Storage** | Mattermost file storage | Storage account, share name, NFS server hostname |
| **AKS Cluster** | All addons | Cluster name, resource group, kubeconfig |
| **Private DNS** | NFS connectivity | Zone name, A record for NFS |

---

## Step-by-Step: Finding Resource Names

### If you know the resource group name

Most resources live in a single resource group (e.g. `chrisfickess-tfstate-azk`). List everything:

```bash
# List all resources in the resource group
az resource list --resource-group <RESOURCE_GROUP_NAME> -o table

# Filter by type
az resource list --resource-group <RESOURCE_GROUP_NAME> --resource-type "Microsoft.KeyVault/vaults" -o table
az resource list --resource-group <RESOURCE_GROUP_NAME> --resource-type "Microsoft.ContainerService/managedClusters" -o table
az resource list --resource-group <RESOURCE_GROUP_NAME> --resource-type "Microsoft.Storage/storageAccounts" -o table
az resource list --resource-group <RESOURCE_GROUP_NAME> --resource-type "Microsoft.DBforPostgreSQL/flexibleServers" -o table
```

### If you only know partial names (e.g. "mattermost" or "dev-chris")

```bash
# Search for Key Vaults containing "mattermost"
az keyvault list --query "[?contains(name, 'mattermost')].{name:name, resourceGroup:resourceGroup}" -o table

# Search for AKS clusters
az aks list --query "[?contains(name, 'mattermost')].{name:name, resourceGroup:resourceGroup}" -o table

# Search for storage accounts
az storage account list --query "[?contains(name, 'nfs')].{name:name, resourceGroup:resourceGroup}" -o table

# Search for PostgreSQL servers
az postgres flexible-server list --query "[?contains(name, 'mattermost')].{name:name, resourceGroup:resourceGroup}" -o table
```

---

## Script Reference

| Script | Purpose |
|--------|---------|
| `get-resource-names.sh` | Discover resource names when you only know the resource group or partial names |
| `resources/get-keyvault-secrets.sh` | Retrieve Key Vault secrets (DB credentials, license) for addons |
| `resources/get-nfs-storage-values.sh` | Get NFS storage account, share name, and mount path for PVC config |
| `resources/get-aks-credentials.sh` | Get AKS kubeconfig and cluster info |
| `resources/get-all-addon-values.sh` | Run all scripts and output a summary of values needed for addons |

---

## Manual az CLI Commands Reference

### Key Vault (for External Secrets, ClusterSecretStore)

```bash
# List all secrets in the vault
az keyvault secret list --vault-name <KEYVAULT_NAME> --query "[].name" -o tsv

# Get specific secrets (used by addons)
az keyvault secret show --vault-name <KEYVAULT_NAME> --name postgres-internal-password --query "value" -o tsv
az keyvault secret show --vault-name <KEYVAULT_NAME> --name postgresinternaluser --query "value" -o tsv
az keyvault secret show --vault-name <KEYVAULT_NAME> --name postgres-connection-string --query "value" -o tsv
az keyvault secret show --vault-name <KEYVAULT_NAME> --name mattermost-license-store --query "value" -o tsv
```

### NFS Storage (for Mattermost PVC)

```bash
# List storage accounts
az storage account list --resource-group <RESOURCE_GROUP> -o table

# List file shares in the NFS storage account
az storage share list --account-name <NFS_STORAGE_ACCOUNT> -o table

# Get storage account key (for filestore secret - use carefully)
az storage account keys list --account-name <NFS_STORAGE_ACCOUNT> --query "[0].value" -o tsv
```

**NFS mount path format:** `/<storage-account-name>/<share-name>`  
Example: `/mattermostdevchrisnfs/mattermostdevchrisshare`

**NFS server hostname:** `<storage-account-name>.privatelink.file.core.windows.net`

### AKS Cluster

```bash
# Get AKS credentials (merges into ~/.kube/config)
az aks get-credentials --resource-group <RESOURCE_GROUP> --name <AKS_CLUSTER_NAME>

# Verify connection
kubectl get nodes
```

### Private Endpoint (NFS connectivity)

```bash
# List private endpoints
az network private-endpoint list --resource-group <RESOURCE_GROUP> -o table

# Get private endpoint details (for NFS)
az network private-endpoint show --name <NFS_PRIVATE_ENDPOINT_NAME> --resource-group <RESOURCE_GROUP>
```

---

## Mapping Values to Addon Files

| Addon File | Azure Value | How to Get |
|------------|-------------|------------|
| `external-secrets/clustersecretstore.yaml` | `vaultUrl` | `https://<KEYVAULT_NAME>.vault.azure.net/` |
| `mattermost/externalsecret-database.yaml` | Key Vault secrets | `postgres-connection-string`, `postgres-internal-password`, `postgresinternaluser` |
| `mattermost/externalsecret-license.yaml` | Key Vault secret | `mattermost-license-store` |
| `mattermost/pvc.yaml` | NFS server, path | Storage account + share from `resources/get-nfs-storage-values.sh` |
| `mattermost/secret.yaml` | Storage account, key | For Azure Blob filestore (if used instead of NFS) |

---

## Troubleshooting

**"Resource not found"** – Verify you're in the correct subscription: `az account show`

**"Access denied"** – Ensure your Azure identity has Reader (or higher) on the resource group and Key Vault Secrets User on the Key Vault.

**"Key Vault name doesn't match"** – Different stacks may use different Key Vault names (`-kv` vs `-pgs`). Check Terraform outputs or the ClusterSecretStore in your cluster.
