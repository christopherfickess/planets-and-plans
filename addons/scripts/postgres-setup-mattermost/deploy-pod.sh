#!/usr/bin/env bash

set -e

echo "Azure PostgreSQL client deployment"
echo ""

read -p "Namespace (default: chrisfickess): " NAMESPACE
export APP_NAME="${NAMESPACE:-chrisfickess}"

read -p "Azure Key Vault name for database credentials (default: mattermost-dev-chris-kv): " VAULT_NAME
VAULT_NAME=${VAULT_NAME:-"mattermost-dev-chris-kv"}

if [ $(az keyvault secret show --vault-name "$VAULT_NAME" --name postgresadmin --query value -o tsv) ]; then
    echo "Retrieved database admin username from Key Vault."
    PGUSER=$(az keyvault secret show --vault-name "$VAULT_NAME" --name  postgresadmin --query value -o tsv)
else
    read -p "Admin username (example: adminuser@myserver): " PGUSER
fi

if [ $(az keyvault secret show --vault-name "$VAULT_NAME" --name postgres-admin-password --query value -o tsv) ]; then
    echo "Retrieved database admin password from Key Vault."
    PGPASSWORD=$(az keyvault secret show --vault-name "$VAULT_NAME" --name postgres-admin-password --query value -o tsv)
else
    read -s -p "Admin password: " PGPASSWORD
fi

read -p "Azure Postgres server name (Default: mattermost-dev-chris-postgres-flex): " PGSERVER
PGSERVER=${PGSERVER:-mattermost-dev-chris-postgres-flex}

echo ""

PGHOST=$(az postgres flexible-server show \
    --name "$PGSERVER" \
    --query fullyQualifiedDomainName \
    -o tsv 2>/dev/null)

if [ -n "$PGHOST" ]; then
    echo "Successfully resolved PostgreSQL server hostname."
    echo "Host: $PGHOST"
else
    echo "Error: Unable to resolve PostgreSQL server hostname."
    echo "Check server name and resource group."
fi

echo "Resolved host: $PGHOST"
echo ""

read -p "Database name inside server (default: mattermost): " PGDATABASE
PGDATABASE=${PGDATABASE:-mattermost}
read -p "Port (default 5432): " PGPORT
PGPORT=${PGPORT:-5432}

export PGHOST
export PGUSER
export PGPASSWORD
export PGDATABASE
export PGPORT

echo ""

if [ $(az keyvault secret show --vault-name "$VAULT_NAME" --name postgres-internal-password --query value -o tsv) ]; then
    echo "Retrieved application database password from Key Vault."
    NEW_DB_PASSWORD=$(az keyvault secret show --vault-name "$VAULT_NAME" --name postgres-internal-password --query value -o tsv)
else
    read -s -p "New application database password: " NEW_DB_PASSWORD
fi

if [ $(az keyvault secret show --vault-name "$VAULT_NAME" --name postgresinternaluser --query value -o tsv) ]; then
    echo "Retrieved application database username from Key Vault."
    NEW_DB_USER=$(az keyvault secret show --vault-name "$VAULT_NAME" --name postgresinternaluser --query value -o tsv)
else
    read -p "New application database username: " NEW_DB_USER
fi


export NEW_DB_USER
export NEW_DB_PASSWORD

echo ""
echo "Creating namespace if needed..."
kubectl get ns "$APP_NAME" >/dev/null 2>&1 || kubectl create ns "$APP_NAME"


envsubst < create-user.sql > db-init-final.sql

echo "Deploying postgres client pod..."
envsubst < deploy-pod-to-configure-database.yaml | kubectl apply -f -

echo "Waiting for pod ready..."
kubectl wait --for=condition=Ready pod/postgres-client -n "$APP_NAME" --timeout=120s


echo ""
echo "Pod ready."
echo ""
echo "Connect with:"
echo kubectl exec -it postgres-client -n "$APP_NAME" -- bash
echo ""
echo "Inside pod you can run:"
echo psql "sslmode=require host=$PGHOST user=$PGUSER dbname=$PGDATABASE password=$PGPASSWORD port=$PGPORT"

echo "Do you need to update the database schema? (y/n)"
read -p "Update database schema? (y/n): " UPDATE_SCHEMA
if [ "$UPDATE_SCHEMA" = "y" ]; then
    echo "Updating database schema..."
    kubectl cp db-init-final.sql $APP_NAME/postgres-client:/tmp/db-init.sql
    kubectl exec -it postgres-client -n $APP_NAME -- bash -c \
    "psql \"host=$PGHOST user=$PGUSER dbname=$PGDATABASE password=$PGPASSWORD sslmode=require port=$PGPORT\" -f /tmp/db-init.sql"

        
    kubectl create secret generic postgres-db-credentials \
        -n "$APP_NAME" \
        --from-literal=DB_USER="$NEW_DB_USER" \
        --from-literal=DB_PASSWORD="$NEW_DB_PASSWORD" \
        --from-literal=DB_HOST="$PGHOST" \
        --from-literal=DB_NAME="$PGDATABASE" \
        --from-literal=DB_PORT="$PGPORT" \
        --dry-run=client -o yaml | kubectl apply -f -
else 
    echo "No database schema update needed."
    echo "Connecting to database..."
    kubectl exec -it postgres-client -n $APP_NAME -- bash -c \
    "psql \"host=$PGHOST user=$PGUSER dbname=$PGDATABASE password=$PGPASSWORD sslmode=require port=$PGPORT\""
    echo "Done."
    echo "Connect with:"
    echo kubectl exec -it postgres-client -n "$APP_NAME" -- bash
    echo ""
    echo "Inside pod you can run:"
    echo psql "sslmode=require host=$PGHOST user=$PGUSER dbname=$PGDATABASE password=$PGPASSWORD port=$PGPORT"
    echo "Done."
fi

