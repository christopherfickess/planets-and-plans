# CrossGuard — Azure Queue Storage Transport

Deploys the Azure storage infrastructure required for the CrossGuard plugin to relay messages between two Mattermost instances using Azure Queue Storage. Creates one storage account, two queues, and one blob container. No VMs or networking resources are created.

## What gets deployed

| Resource | Purpose |
|---|---|
| Storage Account | Hosts all CrossGuard queues and the file transfer container |
| Queue: `crossguard-inbound` | Carries messages from Instance B to Instance A |
| Queue: `crossguard-outbound` | Carries messages from Instance A to Instance B |
| Blob Container: `crossguard-files` | Staging area for file attachments (only needed if file transfer is enabled) |

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
key                  = "crossguard-send-to-queue/terraform.tfstate"
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

# Queue names — only change if you need multiple CrossGuard deployments
# in the same storage account.
# inbound_queue_name  = "crossguard-inbound"
# outbound_queue_name = "crossguard-outbound"
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
terraform output queue_service_url
terraform output blob_service_url
terraform output inbound_queue_name
terraform output outbound_queue_name
terraform output blob_container_name
```

## Fill in the CrossGuard config files

Use the output values to fill in `config-instance-a.yaml` and `config-instance-b.yaml`. Both instances point at the same two queues in Azure — the queue names in Azure don't change, only the role each instance assigns them in its CrossGuard config:

| | Instance A | Instance B |
|---|---|---|
| `inbound` → `queue_name` | `crossguard-inbound` | `crossguard-outbound` |
| `outbound` → `queue_name` | `crossguard-outbound` | `crossguard-inbound` |

Instance A reads from `crossguard-inbound` (where B writes). Instance A writes to `crossguard-outbound` (where B reads). The roles flip on Instance B — the queue names in Azure stay the same.

### Multiple CrossGuard links in the same storage account

If you need a second independent link (e.g. Instance A connecting to both Instance B and Instance C), deploy this stack a second time with distinct queue names so the two links don't share the same queues. Use a naming scheme that identifies the link, not just the direction:

```hcl
# First link: A ↔ B
inbound_queue_name  = "cg-a-to-b-inbound"
outbound_queue_name = "cg-a-to-b-outbound"

# Second link: A ↔ C
inbound_queue_name  = "cg-a-to-c-inbound"
outbound_queue_name = "cg-a-to-c-outbound"
```

Each instance's CrossGuard config then references the queue names for its specific link. Instance B uses `cg-a-to-b-inbound` as its outbound and `cg-a-to-b-outbound` as its inbound. Instance C does the same for the `a-to-c` queues.

Then run the setup script against each instance:

```bash
# From the crossguard setup directory
mmctl auth use <instance-a-name>
./setup-crossguard.sh --config=config-instance-a.yaml

mmctl auth use <instance-b-name>
./setup-crossguard.sh --config=config-instance-b.yaml
```
