# When in the pod, run the following command to test access to the key vault

az login --identity --client-id 2d358d95-2457-49dd-a7c8-9479cac7b2b0
az keyvault secret show --vault-name mattermost-dev-chris-kv --name postgres-connection-string
az keyvault secret show --vault-name mattermost-dev-chris-kv --name postgres-internal-password
az keyvault secret show --vault-name mattermost-dev-chris-kv --name postgresinternaluser
az keyvault secret show --vault-name mattermost-dev-chris-kv --name mattermost-license-store
