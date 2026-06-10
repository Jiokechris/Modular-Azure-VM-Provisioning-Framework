#!/bin/bash

export MSYS_NO_PATHCONV=1

source context.sh

source modules/prerequisites.sh
source modules/ssh.sh
source modules/resourcegroup.sh
source modules/network.sh
source modules/keyvault.sh
source modules/vm.sh
source modules/rbac.sh
source modules/verification.sh
source modules/summary.sh
source modules/cleanup.sh

main() {

    # =========================
    # PRECHECKS
    # =========================
    check_azure_cli
    check_azure_login

    # =========================
    # AZURE CONTEXT FIX (CRITICAL)
    # =========================
    echo "DEBUG ACCOUNTS:"
    az account list -o table

    echo "CURRENT ACCOUNT BEFORE FIX:"
    az account show -o json || echo "No active subscription detected"

    echo "Setting Azure subscription explicitly..."

    SUBSCRIPTION_ID=$(az account list --query "[0].id" -o tsv)

    if [ -z "$SUBSCRIPTION_ID" ]; then
        echo "ERROR: No Azure subscriptions found for this account"
        exit 1
    fi

    az account set --subscription "$SUBSCRIPTION_ID"

    echo "Using Subscription: $SUBSCRIPTION_ID"

    echo "VERIFY SUBSCRIPTION:"
    az account show --query id -o tsv

    # =========================
    # INFRASTRUCTURE BUILD FLOW
    # =========================

    create_ssh_keys
    create_resource_group

    echo "DEBUG RG = $RG"
    echo "DEBUG KV = $KV_NAME"

    if ! create_key_vault; then
        echo "Key Vault creation failed. Stopping pipeline."
        exit 1
    fi

    if ! wait_for_keyvault; then
        echo "key vault not ready. stoppind pipeline."
        exit 1
    fi    

     if ! assign_keyvault_rbac; then
        echo "Key Vault RBAC assignment failed. Stopping pipeline."
        exit 1
    fi

    if ! store_ssh_private_key; then
        echo "SSH private key storage failed. Stopping pipeline."
        exit 1
    fi

    if ! create_vm; then
        echo "VM creation failed. Stopping pipeline."
        exit 1
    fi

    if ! assign_rbac; then
        echo "RBAC assignment failed. Stopping pipeline."
        exit 1
    fi

    # =========================
    # POST DEPLOYMENT
    # =========================
    open_http_port
    get_public_ip

    wait_for_cloud_init
    verify_website
    show_summary

    cleanup
}

main