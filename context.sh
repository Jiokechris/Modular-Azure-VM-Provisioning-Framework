#!/bin/bash

# =========================================================
# LOAD BASE CONFIG (ONLY STATIC VALUES)
# =========================================================
set -e

if [ ! -f config-prod.env ]; then
    echo "ERROR: config-prod.env not found"
    exit 1
fi

source config-prod.env

# =========================================================
# GENERATE RUN CONTEXT (THIS WAS MISSING)
# =========================================================
RUN_ID=$(date +%Y%m%d%H%M%S)

if [ -z "$RUN_ID" ]; then
    echo "ERROR: RUN_ID generation failed"
    exit 1
fi

RG="rg-prod-$RUN_ID"
VM_NAME="jioke-prod-vm-$RUN_ID"
KV_NAME="jkv-$RUN_ID"

# =========================================================
# NETWORKING
# =========================================================

VNET_NAME="vnet-prod-$RUN_ID"

SUBNET_NAME="subnet-prod-$RUN_ID"

NSG_NAME="nsg-prod-$RUN_ID"

NIC_NAME="nic-prod-$RUN_ID"

PUBLIC_IP_NAME="pip-prod-$RUN_ID"
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
export VNET_NAME
export SUBNET_NAME
export NSG_NAME
export NIC_NAME
export PUBLIC_IP_NAME
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

if [ -z "$RG" ]; then
    echo "FATAL: Context failed to initialize"
    exit 1
fi