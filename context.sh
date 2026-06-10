#!/bin/bash

# =========================================================
# LOAD BASE CONFIG (ONLY STATIC VALUES)
# =========================================================
source config-prod.env

# =========================================================
# GENERATE RUN CONTEXT (THIS WAS MISSING)
# =========================================================
RUN_ID=$(date +%Y%m%d%H%M%S)

RG="rg-prod-$RUN_ID"
VM_NAME="jioke-prod-vm-$RUN_ID"
KV_NAME="jkv-$RUN_ID"

# =========================================================
# STATIC PATHS
# =========================================================
KEY_DIR="/c/Users/HomePC/Downloads/saved-keys"

SSH_PATH="$KEY_DIR/id_rsa_prod"
SSH_PUBLIC_KEY="${SSH_PATH}.pub"

CLOUD_INIT_FILE="./cloud-init.yaml"

# =========================================================
# FAIL FAST VALIDATION
# =========================================================
if [ -z "$RUN_ID" ] || [ -z "$RG" ] || [ -z "$VM_NAME" ] || [ -z "$KV_NAME" ]; then
    echo "ERROR: Context generation failed"
    exit 1
fi

# =========================================================
# EXPORT EVERYTHING
# =========================================================
export RUN_ID RG VM_NAME KV_NAME
export LOCATION IMAGE VM_SIZE ADMIN_USER
export KEY_DIR SSH_PATH SSH_PUBLIC_KEY CLOUD_INIT_FILE
export SUBSCRIPTION_ID ENABLE_MANAGED_IDENTITY RBAC_ROLE

# =========================================================
# DEBUG
# =========================================================
echo "================ CONTEXT LOADED ================"
echo "RUN_ID=$RUN_ID"
echo "RG=$RG"
echo "VM_NAME=$VM_NAME"
echo "KV_NAME=$KV_NAME"
echo "SSH_PATH=$SSH_PATH"
echo "SSH_PUBLIC_KEY=$SSH_PUBLIC_KEY"
echo "==============================================="