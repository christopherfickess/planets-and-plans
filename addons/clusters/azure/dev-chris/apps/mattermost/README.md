



```bash
 az keyvault secret list --vault-name mattermost-dev-chris-pgs  --query "[].id" -o tsv

 az keyvault secret show --vault-name mattermost-dev-chris-pgs --name postgres-internal-password --query "value" -o tsv
az keyvault secret show --vault-name mattermost-dev-chris-pgs --name postgresinternaluser --query "value" -o tsv
```


License Null to start

make the external secret optional to prevent errors until we have the license in place. We can add it later when we have the license ready.

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: mattermost-license
  namespace: mattermost
spec:
  refreshInterval: 5m
  secretStoreRef:
    kind: ClusterSecretStore
    name: azure-secretsmanager
  target:
    name: mattermost-license
    creationPolicy: Owner
  data:
    - secretKey: license-internal
      remoteRef:
        key: mattermost-license-store
        property: license-internal
        optional: true
```

# NFS 

[docs/dns.md](./docs/dns.md)

**NFS path:** If the PVC stays `Pending`, verify the Azure Files share name from Terraform:
```bash
cd stacks/azure/mattermost-nfs && terraform output -json nfs | jq -r '.nfs_share_name'
```
Update `pvc.yaml` path to `/<storage-account>/<share-name>` (e.g. `/mattermostdevchrisnfs/<actual-share-name>`).

---

# LoadBalancer & Website Hosting

1. **Get the external IP** (may take 2–5 minutes after apply):
   ```bash
   kubectl get svc mattermost-lb -n mattermost -w
   ```

2. **Create DNS A record** for `dev-chris.dev.cloud.mattermost.com` → LoadBalancer external IP.

3. **Optional – static public IP:** Create an Azure public IP, then uncomment and set the annotations in `service.yaml`:
   - `service.beta.kubernetes.io/azure-load-balancer-resource-group`
   - `service.beta.kubernetes.io/azure-pip-name`
