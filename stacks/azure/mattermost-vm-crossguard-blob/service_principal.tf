# stacks/azure/mattermost-vm-crossguard-blob/service_principal.tf
#
# Service principal RBAC for CrossGuard plugin service-principal auth mode.
#
# The app registration and client secret are created outside Terraform
# (by an AD admin or via az cli) and passed in via tfvars. Terraform only
# manages the RBAC role assignment so the SP can access the storage account.
#
# Set enable_service_principal = true and provide sp_object_id to activate.

# Storage Blob Data Contributor is assigned via the blob_storage module's
# principal_ids map (see blob_storage.tf). No additional resources needed here.
