create_vm() {

    echo "Creating VM..."

    echo "Location: $LOCATION"

    echo "Size: $VM_SIZE"

    if az vm create \
        --resource-group "$RG" \
        --name "$VM_NAME" \
        --location "$LOCATION" \
        --image "$IMAGE" \
        --size "$VM_SIZE" \
        --admin-username "$ADMIN_USER" \
        --ssh-key-values "${SSH_PATH}.pub" \
        --custom-data "$CLOUD_INIT_FILE" \
        --output none
    then

        echo "VM Created Successfully!"

    else

        echo "VM Not Created!"

        exit 1

    fi
}