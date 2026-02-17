



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
