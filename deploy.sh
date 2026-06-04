#!/bin/bash

source config.env

source modules/prerequisites.sh
source modules/ssh.sh
source modules/resourcegroup.sh
source modules/vm.sh
source modules/network.sh
source modules/verification.sh
source modules/summary.sh
source modules/cleanup.sh

main() {

    check_azure_cli
    check_azure_login
    create_ssh_keys
    create_resource_group

    if ! create_vm; then
        echo "VM creation failed. Stopping pipeline."
        exit 1
    fi

    open_http_port
    get_public_ip
    wait_for_cloud_init
    verify_website
    show_summary
    cleanup
}

main
