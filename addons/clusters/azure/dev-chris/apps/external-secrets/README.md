# External Secrets + Azure Workload Identity Setup

## What is UAMI?

**UAMI** = **User-Assigned Managed Identity**. It's an Azure identity resource that lets the External Secrets operator authenticate to Key Vault without storing credentials. The AKS stack creates it via Terraform (mattermost-aks module) and links it to the external-secrets service account via a federated credential.

### UAMI Name

The name follows the pattern: **`<base_identifier>-external-secrets-identity`**

- For dev-chris: **`mattermost-dev-chris-external-secrets-identity`**
- General: `mattermost-<environment>-external-secrets-identity` (from Terraform `base_identifier`)

### How to Find Your UAMI

**Option 1 – Use the discovery script (recommended):**
```bash
./addons/scripts/get-resource-names.sh
# Writes EXTERNAL_SECRETS_IDENTITY_CLIENT_ID to addons/docs/env.local.sh
# Then run:
./addons/scripts/patch-external-secrets-identity.sh
```

**Option 2 – List identities in your resource group:**
```bash
az identity list --resource-group <RESOURCE_GROUP> --query "[?contains(name, 'external-secrets')].{name:name, clientId:clientId}" -o table
```

**Option 3 – If you know the exact name:**
```bash
# Example for dev-chris (resource group from env.local.sh):
az identity show --name mattermost-dev-chris-external-secrets-identity --resource-group chrisfickess-tfstate-azk

# Get just the clientId (used in patches.yaml):
az identity show --name mattermost-dev-chris-external-secrets-identity --resource-group chrisfickess-tfstate-azk --query clientId -o tsv
```

---

## Why a separate ServiceAccount?

The base (mattermost-byoc-infra) Helm chart uses a different client ID (`99a1a097...`), which causes `AADSTS700016: Application not found`. The base overwrites the default `external-secrets` service account during Flux reconciliation. We use **serviceAccount.create: false** and a separate **external-secrets-azure** ServiceAccount that we control—the base cannot overwrite it.

## Problem
External Secrets could not authenticate to Azure Key Vault. Errors showed `AADSTS700016: Application not found`.

## Steps to Fix

1. **Verify UAMI and Federated Identity**
```bash
az identity show --name mattermost-dev-chris-external-secrets-identity --resource-group <RESOURCE_GROUP>
az identity federated-credential list --identity-name mattermost-dev-chris-external-secrets-identity --resource-group <RESOURCE_GROUP>
```

2. Update ServiceAccount

- Ensure `azure.workload.identity/client-id` annotation points to the UAMI clientId.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-secrets
  namespace: external-secrets
  annotations:
    azure.workload.identity/client-id: "<UAMI_CLIENT_ID>"
    eks.amazonaws.com/role-arn: null
```

3. Update ClusterSecretStore

- Confirm the tenantId and `serviceAccountRef` match the ServiceAccount.

```yaml
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: azure-secretsmanager
  namespace: external-secrets
spec:
  provider:
    azurekv:
      vaultUrl: "https://<KEYVAULT_NAME>.vault.azure.net/"
      authType: WorkloadIdentity
      serviceAccountRef:
        name: external-secrets
        namespace: external-secrets
      tenantId: "<TENANT_ID>"
```

4. Redeploy External Secrets

```bash
kubectl annotate clustersecretstore azure-secretsmanager fluxcd.io/force-reconcile="$(date +%s)" --overwrite
```


# Notes

- Always verify `clientId` and `tenantId`.
- Any change to the `SA` or `ClusterSecretStore` may require a forced reconcile or pod restart.