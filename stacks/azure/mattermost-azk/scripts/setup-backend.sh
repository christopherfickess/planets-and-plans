#!/bin/bash

RESOURCE_GROUP_NAME=chrisfickess-tfstate-azk
STORAGE_ACCOUNT_NAME=tfstateChrisFickess
CONTAINER_NAME=azure-azk-tfstate
LOCATION=eastus

# Create resource group
az group create \
    --name $RESOURCE_GROUP_NAME \
    --location $LOCATION

# Create storage account
az storage account create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS \
    --kind StorageV2 \
    --encryption-services blob \
    --https-only true

# Create blob container
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME