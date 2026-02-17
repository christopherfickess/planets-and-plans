# External Secrets + Azure Workload Identity Setup

## Problem
External Secrets could not authenticate to Azure Key Vault. Errors showed `AADSTS700016: Application not found`.

## Steps to Fix

1. **Verify UAMI and Federated Identity**
```bash
az identity show --name <UAMI_NAME> --resource-group <RESOURCE_GROUP>
az identity federated-credential list --identity-name <UAMI_NAME> --resource-group <RESOURCE_GROUP>
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