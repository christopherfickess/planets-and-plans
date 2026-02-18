Perfect. We can verify all the moving parts using the **Azure CLI** and **kubectl**. I’ll break this into sections: ingress, storage, secrets, and Mattermost itself.

---

## **1. Verify the Application Gateway / Ingress**

Check that the gateway exists:

```bash
# Check Application Gateway exists
az network application-gateway show \
  --name <application-gateway-name> \
  --resource-group <resource-group-name>
```

Check its frontend IP and DNS:

```bash
az network application-gateway frontend-ip list \
  --gateway-name <application-gateway-name> \
  --resource-group <resource-group-name> \
  -o table
```

Check subnet used:

```bash
az network vnet subnet show \
  --name <subnet-name> \
  --vnet-name <vnet-name> \
  --resource-group <resource-group-name> \
  -o table
```

---

## **2. Verify AKS cluster can see App Gateway (Ingress addon)**

```bash
az aks show \
  --name <aks-cluster-name> \
  --resource-group <resource-group-name> \
  --query "addonProfiles.ingressApplicationGateway"
```

It should show the App Gateway ID and subnet.

---

## **3. Verify Azure Files / NFS storage**

Check storage account:

```bash
az storage account show \
  --name <storage-account-name> \
  --resource-group <resource-group-name> \
  -o table
```

Check file share:

```bash
az storage share show \
  --name <storage-share-name> \
  --account-name <storage-account-name> \
  -o table
```

Test mountability (optional, from an AKS node):

```bash
# List contents
kubectl run -i --tty az-cli --image=mcr.microsoft.com/azure-cli --restart=Never -- bash
# Inside the pod:
mount -t cifs //<storage-account-name>.file.core.windows.net/<storage-share-name> /mnt -o vers=3.0,username=<storage-account-name>,password=<storage-account-key>,dir_mode=0777,file_mode=0777
ls /mnt
```

---

## **4. Verify secrets in Key Vault**

List secrets:

```bash
az keyvault secret list --vault-name <keyvault-name> -o table
```

Check a specific secret:

```bash
az keyvault secret show \
  --vault-name <keyvault-name> \
  --name <secret-name> \
  --query "value" -o tsv
```

Check the federated identity:

```bash
az identity federated-credential list \
  --identity-name <managed-identity-name> \
  --resource-group <resource-group-name> -o table
```

Make sure `subject` matches `system:serviceaccount:<namespace>:<service-account>`.

---
