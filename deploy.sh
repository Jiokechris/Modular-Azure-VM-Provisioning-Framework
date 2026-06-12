#!/bin/bash

export MSYS_NO_PATHCONV=1

source "$(dirname "$0")/context.sh"

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

     # ALWAYS take active subscription (not first in list)
     SUBSCRIPTION_ID=$(az account show --query id -o tsv)

    if [ -z "$SUBSCRIPTION_ID" ]; then
       echo "ERROR: No active Azure subscription found"
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

    if ! create_vnet; then
        echo "VNet creation failed. Stopping pipeline."
        exit 1
    fi

    if ! create_subnet; then
        echo "Subnet creation failed. Stopping pipeline."
        exit 1
    fi

    if ! create_nsg; then
         echo "NSG creation failed"
         exit 1
    fi

    if ! create_nsg_rules; then
        echo "NSG rules failed"
        exit 1
    fi

    if ! create_public_ip; then
        echo "Public IP creation failed"
        exit 1
    fi

    if ! create_nic; then
        echo "NIC creation failed"
        exit 1
    fi

    if ! attach_nsg_to_nic; then
        echo "Attaching NSG to NIC failed"
        exit 1
    fi  

    if ! attach_nsg_to_subnet; then
        echo "Attaching NSG to Subnet failed"
        exit 1
    fi

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
    get_public_ip || { echo "FATAL: Could not retrieve Public IP. Exiting."; exit 1; }

    wait_for_cloud_init || { echo "FATAL: Nginx not ready. Exiting."; exit 1; }
    verify_website || { echo "FATAL: Website verification failed. Exiting."; exit 1; }
    show_summary

    cleanup
}       

main