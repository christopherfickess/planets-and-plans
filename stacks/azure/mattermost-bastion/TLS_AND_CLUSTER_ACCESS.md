# TLS Provider and Closing Off Cluster Access

## 1. Where does the TLS provider come from?

**In the bastion stack only.**

- **Provider**: HashiCorp TLS provider (`hashicorp/tls`, version `~> 4.0`)
- **Declared in**: `stacks/azure/mattermost-bastion/main.tf` under `required_providers`
- **Used for**: Generating an SSH key pair for the **jumpbox VM** when you don’t provide your own `jumpbox_ssh_public_key`

**What it does in the bastion stack:**

```hcl
# bastion.tf
resource "tls_private_key" "jumpbox" {
  count = var.jumpbox_ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}
```

- If `jumpbox_ssh_public_key` is **empty** → Terraform generates a key with the TLS provider and uses it for the jumpbox.
- If you set `jumpbox_ssh_public_key` → the generated key is not created; your key is used instead.

So TLS is only for **SSH key generation for the jumpbox**, not for the AKS cluster or its API.

---

## 2. Do you add TLS to the cluster (AKS) stack?

**No.** The AKS cluster stack does **not** need the TLS provider.

- The **cluster stack** only deploys the AKS cluster (and related networking, RBAC, etc.). It doesn’t create VMs or SSH keys.
- TLS is only needed in the **bastion stack**, where the jumpbox VM is created and needs an SSH key.

**Cluster stack providers** (in `stacks/azure/mattermost-aks/main.tf`) are enough as-is:

- `azurerm`
- `time`

No TLS block is required there.

---

## 3. What in the cluster stack “closes off” access so only the bastion path works?

Access is closed off by making the cluster **private**. That’s done entirely in the **cluster stack**, with one setting.

### The one setting: private cluster

In the cluster stack:

**Variable** (e.g. in `stacks/azure/mattermost-aks/variable.tf`):

```hcl
variable "private_cluster_enabled" {
  description = "Enable Private Cluster for the AKS cluster."
  type        = bool
  default     = false
}
```

**Passed into the AKS module** (e.g. in `stacks/azure/mattermost-aks/aks.tf`):

```hcl
private_cluster_enabled = var.private_cluster_enabled  # (bastion required if true)
```

**Set in tfvars** (e.g. `stacks/azure/mattermost-aks/tfvars/dev-chris/base.tfvars`):

```hcl
# Enable private cluster - API server only accessible from within VNet
# Requires bastion host for access
private_cluster_enabled = true
```

When `private_cluster_enabled = true`:

- The AKS API server gets a **private endpoint only** (no public IP).
- The API server is only reachable from inside the **same VNet** (and linked private DNS).
- There is **no** separate “allow only bastion” flag on AKS; “private” means “VNet-only.”

So:

- **Cluster stack**: you only need `private_cluster_enabled = true` to close off direct internet access to the cluster.
- **Bastion stack**: provides the only path in (Bastion → jumpbox → private AKS). The cluster doesn’t need to “know” about Bastion; it just has to be private.

### How it fits together

- **Cluster stack**: `private_cluster_enabled = true` → API server is VNet-only → no public access.
- **Bastion stack**: Bastion + jumpbox (with TLS-generated or your SSH key) → you get into the VNet and then to the cluster.

So:

- **TLS**: only in the bastion stack, for jumpbox SSH keys; **do not** add TLS to the cluster stack.
- **Closing off access**: only the cluster stack is needed; set `private_cluster_enabled = true` in the AKS stack (variable + tfvars). Nothing else is required on the cluster side to restrict access to the bastion path.
