# Module: azure/common/blob_storage

Creates the Azure storage resources needed for CrossGuard blob transport: one storage account and one blob container. Unlike the queue module, no queues are created — blob transport uses the connection name as the routing key, writing to `messages/<connection-name>/` within a single shared container.

## Resources created

| Resource | Type | Notes |
|---|---|---|
| `azurerm_storage_account.crossguard` | Storage Account | Name derived from `unique_name_prefix` + `bs` suffix |
| `azurerm_storage_container.crossguard_files` | Blob Container | Shared staging area — both instances read and write here |
| `azurerm_role_assignment.vm_blob_contributor` | RBAC | Storage Blob Data Contributor — one per entry in `principal_ids` |

## Storage account naming

Azure storage account names must be 3–24 lowercase alphanumeric characters with no hyphens and must be globally unique across all Azure customers. This module derives the name from `unique_name_prefix` by stripping hyphens, truncating to 22 characters, and appending `bs`. For example, `mm-cg-prod` becomes `mmcgprodbs`.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `unique_name_prefix` | `string` | — | Short unique prefix for resource names. Keep to 20 characters or fewer. |
| `environment` | `string` | — | Environment label applied as a tag (`dev`, `staging`, `prod`). |
| `location` | `string` | `"eastus2"` | Azure region for all resources. |
| `resource_group_name` | `string` | — | Existing resource group to deploy into. |
| `tags` | `map(string)` | `{}` | Additional tags merged onto all resources. |
| `email_contact` | `string` | — | Owner email applied as a tag. |
| `storage_account_replication_type` | `string` | `"LRS"` | `LRS`, `GRS`, or `RAGRS`. |
| `blob_container_name` | `string` | `"crossguard-files"` | Blob container used for CrossGuard message and file staging. |
| `principal_ids` | `map(string)` | `{}` | Map of Azure principal IDs to grant blob contributor access. Keys must be static strings. Leave empty when using account key auth. |
| `public_network_access_enabled` | `bool` | `true` | Allow public internet access. Set to `false` and add a private endpoint for production VNet deployments. |
| `allowed_subnet_ids` | `list(string)` | `[]` | Subnet IDs allowed through network rules. Only applies when `public_network_access_enabled = false`. |

## Outputs

| Name | Sensitive | Description |
|---|---|---|
| `storage_account_name` | No | Name of the CrossGuard storage account. |
| `storage_account_id` | No | Resource ID of the storage account. |
| `blob_endpoint` | No | Primary Blob Storage endpoint URL. |
| `blob_container_name` | No | Name of the blob container. |
| `primary_access_key` | Yes | Primary account key. Used by the CrossGuard plugin for account key auth. |
| `crossguard_plugin_config` | Yes | All CrossGuard plugin config values formatted for copy-paste. |

## Usage

```hcl
module "blob_storage" {
  source = "../../../modules/azure/common/blob_storage"

  unique_name_prefix  = var.unique_name_prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  email_contact       = var.email_contact

  blob_container_name = var.blob_container_name

  storage_account_replication_type = var.storage_account_replication_type
  public_network_access_enabled    = var.public_network_access_enabled

  # Leave empty if using account key auth (default).
  principal_ids = var.principal_ids
}
```

## Blob routing between instances

Blob transport uses the **connection name** as the routing key. The plugin writes outbound messages to `messages/<connection-name>/` and polls that prefix for inbound. Because of this, connection names must be crossed between instances — not the credentials:

| | Instance A | Instance B |
|---|---|---|
| `outbound` connection `name:` | `to-instance-b` | `to-instance-a` |
| `inbound` connection `name:` | `to-instance-a` | `to-instance-b` |

Instance A writes to `messages/to-instance-b/`. Instance B's inbound connection reads from `messages/to-instance-b/`. Both instances use the same storage account and container — only the connection names flip.

## Auth note

The CrossGuard plugin authenticates with `NewSharedKeyCredential` (account key). `shared_access_key_enabled = true` is set on the storage account for this reason and cannot be removed without breaking the plugin. RBAC via `principal_ids` is only needed when Mattermost authenticates through a managed identity instead of the account key, which the plugin does not support by default.
