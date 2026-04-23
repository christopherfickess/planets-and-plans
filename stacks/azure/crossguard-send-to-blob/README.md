# CrossGuard — Azure Blob Storage Transport

Deploys the Azure storage infrastructure required for the CrossGuard plugin to relay messages between two Mattermost instances using Azure Blob Storage. Creates one storage account and one blob container. No VMs or networking resources are created.

## What gets deployed

| Resource | Purpose |
|---|---|
| Storage Account | Hosts the CrossGuard blob container |
| Blob Container: `crossguard-files` | Shared staging area — both instances read and write here |

## How blob routing works

Unlike queue transport, blob transport uses the **connection name** as the routing key. The plugin writes outbound messages to `messages/<connection-name>/` and polls that same prefix for inbound. Because of this, the connection names must be crossed between instances:

| | Instance A | Instance B |
|---|---|---|
| `outbound` connection `name:` | `to-instance-b` | `to-instance-a` |
| `inbound` connection `name:` | `to-instance-a` | `to-instance-b` |

Instance A writes to `messages/to-instance-b/`. Instance B's inbound connection reads from `messages/to-instance-b/`. The names flip on Instance B.

## Prerequisites

- Terraform >= 1.14.0
- Azure CLI installed and authenticated (`az login`)
- An existing Azure resource group to deploy into
- An existing Azure storage account to store Terraform state (separate from the CrossGuard account)
- The CrossGuard plugin uploaded and enabled on both Mattermost instances

## Configure Terraform state backend

Fill in `tfvars/env/backend.hcl` with the storage account details where Terraform state will be stored:

```hcl
resource_group_name  = "<your-tfstate-resource-group>"
storage_account_name = "<your-tfstate-storage-account>"
container_name       = "tfstate"
key                  = "crossguard-send-to-blob/terraform.tfstate"
use_azuread_auth     = true
```

Your identity needs **Storage Blob Data Contributor** on the state storage account to read and write state.

## Fill in your tfvars

Fill in `tfvars/env/terraform.tfvars`:

```hcl
# ── Required ────────────────────────────────────────────────────────────────

# The existing resource group to deploy into.
resource_group_name = "<your-resource-group>"

# Short prefix used to name resources. Keep to 20 characters or fewer.
# The storage account name is derived from this — Azure requires it to be
# globally unique across all Azure customers.
unique_name_prefix = "<your-prefix>"

# Owner or team email — applied as a tag on all resources.
email_contact = "<your-email>"

# ── Optional — change only if needed ────────────────────────────────────────

# Azure region. Must match the region of your resource group.
# location = "eastus2"

# environment = "dev"

# Blob container name — only change if you need multiple CrossGuard deployments
# in the same storage account.
# blob_container_name = "crossguard-files"

# Storage replication: LRS (default), GRS, or RAGRS.
# storage_account_replication_type = "LRS"

# Set to false and configure a private endpoint if Mattermost runs inside a VNet.
# public_network_access_enabled = true

# Only needed if your Mattermost instances authenticate via managed identity.
# Leave empty when using account key auth (the CrossGuard plugin default).
# principal_ids = {
#   instance_a = "<azure-object-id>"
#   instance_b = "<azure-object-id>"
# }
```

## Deploy

```bash
terraform init -backend-config=tfvars/env/backend.hcl
terraform plan -var-file=tfvars/env/terraform.tfvars
terraform apply -var-file=tfvars/env/terraform.tfvars
```

## Get your CrossGuard config values

After apply, run this to get all values needed for the CrossGuard config files:

```bash
# All values formatted for copy-paste
terraform output crossguard_plugin_config

# Account key on its own
terraform output -raw storage_account_key

# Individual values
terraform output storage_account_name
terraform output blob_service_url
terraform output blob_container_name
```

## Fill in the CrossGuard config files

Use the output values to fill in `config-instance-a.yaml` and `config-instance-b.yaml`. The connection names must be crossed:

```yaml
# config-instance-a.yaml
inbound_connections:
  - name: to-instance-a        # matches Instance B's outbound name
    provider: azure-blob
    azure_blob:
      service_url: "<blob_service_url>"
      account_name: "<storage_account_name>"
      account_key: "<storage_account_key>"
      blob_container_name: "crossguard-files"

outbound_connections:
  - name: to-instance-b        # matches Instance B's inbound name
    provider: azure-blob
    azure_blob:
      service_url: "<blob_service_url>"
      account_name: "<storage_account_name>"
      account_key: "<storage_account_key>"
      blob_container_name: "crossguard-files"
```

Instance B's config uses the same values but with the connection names flipped (`to-instance-b` becomes inbound, `to-instance-a` becomes outbound).

Then run the setup script against each instance:

```bash
# From the crossguard setup directory
mmctl auth use <instance-a-name>
./setup-crossguard.sh --config=config-instance-a.yaml

mmctl auth use <instance-b-name>
./setup-crossguard.sh --config=config-instance-b.yaml
```
