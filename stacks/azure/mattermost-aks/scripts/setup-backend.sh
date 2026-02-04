#!/bin/bash

RESOURCE_GROUP_NAME=chrisfickess-tfstate-azk
STORAGE_ACCOUNT_NAME=tfstatechrisfickess
CONTAINER_NAME=azure-azk-tfstate
LOCATION=eastus

SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SERVICE_PRINCIPAL_NAME="terraform-sp-chris"

# Create resource group
echo -e "${MAGENTA}Creating Resource Group: ${RESOURCE_GROUP_NAME}${NC}"
az group create \
    --name $RESOURCE_GROUP_NAME \
    --location $LOCATION
echo -e "${GREEN}Resource Group created successfully.${NC}"
echo

# Create storage account
echo -e "${MAGENTA}Creating Storage Account: ${STORAGE_ACCOUNT_NAME}${NC}"
az storage account create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS \
    --kind StorageV2 \
    --encryption-services blob \
    --https-only true
echo -e "${GREEN}Storage Account created successfully.${NC}"
echo

# Create blob container
echo -e "${MAGENTA}Creating Blob Container: ${CONTAINER_NAME}${NC}"
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME
echo -e "${GREEN}Blob Container created successfully.${NC}"
echo

# Create service principal
echo -e "${MAGENTA}Creating Service Principal: ${SERVICE_PRINCIPAL_NAME}${NC}"
az ad sp create-for-rbac --name ${SERVICE_PRINCIPAL_NAME} \
        --role="Contributor" \
        --scopes="/subscriptions/${SUBSCRIPTION_ID}/"
echo -e "${GREEN}Service Principal created successfully.${NC}"
echo

# Get the App ID of the Service Principal
APP_ID=$(az ad sp list --display-name "${SERVICE_PRINCIPAL_NAME}" --query "[0].appId" -o tsv)
echo -e "${MAGENTA}Assigning Storage Blob Data Contributor Role to Service Principal...${NC}"
# Assign Storage Blob Data Contributor Role to the Service Principal
az role assignment create \
        --assignee "$APP_ID" \
        --role "Storage Blob Data Contributor" \
        --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"

# Assign Contributor Role to the Service Principal at the Resource Group Level
echo -e "${MAGENTA}Assigning Contributor Role to Service Principal at Resource Group Level...${NC}"
az role assignment create \
    --assignee "$APP_ID" \
    --role "Contributor" \
    --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"
echo -e "${GREEN}Role assignment completed.${NC}"
echo

# Assign User Access Administrator on the resource group
echo -e "${MAGENTA}Assigning User Access Administrator Role to Service Principal at Resource Group Level...${NC}"
az role assignment create \
    --assignee "$APP_ID" \
    --role "User Access Administrator" \
    --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"
echo -e "${GREEN}Role assignment completed.${NC}"
echo

# List Role Assignments for the Service Principal
echo -e "${MAGENTA}Role Assignments for Service Principal: ${NC}"
az role assignment list --assignee "$APP_ID" --output table
echo -e "${GREEN}Role assignment listing completed.${NC}"
echo 