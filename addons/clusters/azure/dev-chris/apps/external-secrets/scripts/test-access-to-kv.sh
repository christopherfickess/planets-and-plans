# When in the pod, run the following command to test access to the key vault

if [ -z "$1" ]; then
    echo "Usage: $0 <keyvault-name> (e.g. mattermost-dev-kv)"
    return 1
else
    export KEYVAULT_NAME=$1
fi

if [ -z "$SUBSCRIPTION_CLIENT_ID" ]; then
    echo "Usage: $0 <subscription-client-id>"
    return 1
else
    export SUBSCRIPTION_CLIENT_ID=$1
fi


az login --identity --client-id $SUBSCRIPTION_CLIENT_ID
az keyvault secret show --vault-name $KEYVAULT_NAME --name postgres-connection-string
az keyvault secret show --vault-name $KEYVAULT_NAME --name postgres-internal-password
az keyvault secret show --vault-name $KEYVAULT_NAME --name postgresinternaluser
az keyvault secret show --vault-name $KEYVAULT_NAME --name mattermost-license-store
