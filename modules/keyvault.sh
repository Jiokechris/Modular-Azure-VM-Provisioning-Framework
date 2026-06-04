#!/bin/bash

create_key_vault() {
  az keyvault create \
    --name "$KV_NAME" \
    --resource-group "$RG_NAME" \
    --location "$LOCATION" \
    --enable-rbac-authorization true
}

store_secret() {
  PASSWORD=$(openssl rand -base64 24)

  az keyvault secret set \
    --vault-name "$KV_NAME" \
    --name "$SECRET_NAME" \
    --value "$PASSWORD"
}

get_secret() {
  az keyvault secret show \
    --vault-name "$KV_NAME" \
    --name "$SECRET_NAME" \
    --query value -o tsv
}