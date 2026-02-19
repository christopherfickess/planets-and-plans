# Mattermost (dev-chris)

## Quick Reference

```bash
# Key Vault secrets
az keyvault secret list --vault-name mattermost-dev-chris-pgs --query "[].id" -o tsv
az keyvault secret show --vault-name mattermost-dev-chris-pgs --name postgres-internal-password --query "value" -o tsv
az keyvault secret show --vault-name mattermost-dev-chris-pgs --name postgresinternaluser --query "value" -o tsv
```

**License:** Set to empty to start. Use ExternalSecret when license is in Key Vault.

**Replicas:** Set to 1 until HA license is available (avoids "not licensed to run in High Availability mode").

**File storage:** `MM_FILESETTINGS_DRIVERNAME=local` forces local/NFS storage instead of S3 (fixes "unable to check if the S3 bucket exists" and profile image uploads).

**Other log noise (addressed in patches):**
- HA: `MM_CLUSTERSETTINGS_ENABLE=false` — disables cluster mode (no HA license).
- SMTP: `MM_EMAILSETTINGS_SMTPSERVER=""` — disables SMTP connection test.
- Plugins: `MM_PLUGINSETTINGS_PLUGINSTATES` — disables mattermost-ai (needs search/ffmpeg) and com.mattermost.calls (needs public IP). Remove or adjust if you need these plugins.

**External Secret (license):** Use `externalsecret-license-delete.yaml` to remove the license ExternalSecret when `mattermost-license-store` is not yet in Key Vault. Add it back when the license is ready.

---

## NFS

**NFS path:** If the PVC stays `Pending`, verify the Azure Files share name from Terraform:
```bash
cd stacks/azure/mattermost-nfs && terraform output -json nfs | jq -r '.nfs_share_name'
```
Update `pvc.yaml` path to `/<storage-account>/<share-name>` (e.g. `/mattermostdevchrisnfs/<actual-share-name>`).

---

## LoadBalancer & DNS

The LoadBalancer uses a dedicated Azure Public IP with a stable FQDN (from Terraform `mattermost-vnet`). You can use the Azure FQDN directly or a custom domain with a CNAME.

### Files to configure

| File | What to set |
|------|-------------|
| `service.yaml` | `azure-pip-name: "mattermost-dev-chris-mattermost-pip"` (from `terraform output mattermost_lb_pip_name`) |
| `patches.yaml` | `ingress.host` and `MM_SITEURL` — must match the URL users access (see options below) |

### Option A: Azure FQDN (no DNS setup)

Use the Azure PIP FQDN directly. Works immediately, no DNS provider needed.

**patches.yaml:**
```yaml
ingress:
  host: mattermost-dev-chris-mattermost.eastus2.cloudapp.azure.com
mattermostEnv:
  - name: MM_SITEURL
    value: "https://mattermost-dev-chris-mattermost.eastus2.cloudapp.azure.com"
```

**Access:** `https://mattermost-dev-chris-mattermost.eastus2.cloudapp.azure.com`

**DNS:** Azure creates an A record automatically. Nothing to configure.

---

### Option B: Custom domain with Cloudflare

Use `dev-chris.dev.cloud.mattermost.com` with a CNAME pointing to the Azure FQDN.

**1. Create CNAME in Cloudflare**

| Field | Value |
|-------|-------|
| **Zone** | `dev.cloud.mattermost.com` |
| **Type** | CNAME |
| **Name** | `dev-chris` |
| **Target** | `mattermost-dev-chris-mattermost.eastus2.cloudapp.azure.com` |
| **Proxy** | DNS only (grey cloud) |

**2. Update patches.yaml**
```yaml
ingress:
  host: dev-chris.dev.cloud.mattermost.com
mattermostEnv:
  - name: MM_SITEURL
    value: "https://dev-chris.dev.cloud.mattermost.com"
```

**Access:** `https://dev-chris.dev.cloud.mattermost.com`

---

### Option C: Custom domain with Azure DNS

Use `dev-chris.dev.cloud.mattermost.com` with Azure DNS hosting the zone.

**1. Create CNAME in Azure DNS**

If the zone `dev.cloud.mattermost.com` is in Azure DNS:

```bash
# Zone must exist. Create CNAME record set.
az network dns record-set cname set-record \
  --zone-name dev.cloud.mattermost.com \
  --record-set-name dev-chris \
  --cname mattermost-dev-chris-mattermost.eastus2.cloudapp.azure.com
```

Or via Portal: DNS zones → `dev.cloud.mattermost.com` → Add record set → Type: CNAME, Name: `dev-chris`, Value: `mattermost-dev-chris-mattermost.eastus2.cloudapp.azure.com`

**2. Update patches.yaml** (same as Option B)
```yaml
ingress:
  host: dev-chris.dev.cloud.mattermost.com
mattermostEnv:
  - name: MM_SITEURL
    value: "https://dev-chris.dev.cloud.mattermost.com"
```

**Access:** `https://dev-chris.dev.cloud.mattermost.com`

---

### Summary

| Option | Host / MM_SITEURL | DNS record | Where |
|-------|-------------------|------------|-------|
| A | `mattermost-dev-chris-mattermost.eastus2.cloudapp.azure.com` | A (auto) | Azure |
| B | `dev-chris.dev.cloud.mattermost.com` | CNAME → Azure FQDN | Cloudflare |
| C | `dev-chris.dev.cloud.mattermost.com` | CNAME → Azure FQDN | Azure DNS |

**Important:** `host` and `MM_SITEURL` must always match the URL users type in the browser. The Kubernetes Service always shows an external IP; DNS (A or CNAME) resolves the hostname to that IP.

---

### Get FQDN from Terraform

```bash
cd stacks/azure/mattermost-vnet
terraform output mattermost_lb_fqdn      # e.g. mattermost-dev-chris-mattermost.eastus2.cloudapp.azure.com
terraform output mattermost_lb_pip_name # e.g. mattermost-dev-chris-mattermost-pip
```

### Verify LoadBalancer

```bash
kubectl get svc mattermost-lb -n mattermost -w
# External IP may take 2–5 minutes after apply
```

### Show hostname instead of IP in kubectl

Azure only populates the IP in service status. Two options:

1. **Annotation** (already set): The FQDN is in `lb-fqdn` annotation:
   ```bash
   kubectl get svc mattermost-lb -n mattermost -o jsonpath='{.metadata.annotations.lb-fqdn}'
   ```

2. **Status patch CronJob** (optional): Makes `kubectl get svc` show the hostname. Azure will overwrite periodically; the CronJob re-applies every minute:
   ```bash
   kubectl apply -f addons/clusters/azure/dev-chris/apps/mattermost/lb-status-patch-cronjob.yaml
   ```
