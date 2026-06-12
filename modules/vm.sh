create_vm() {

    echo "================ VM CREATION START ================"

    echo "Location: $LOCATION"
    echo "Size: $VM_SIZE"

    # ==================================================
    # BUILD PUBLIC KEY PATH
    # ==================================================
    SSH_PUBLIC_KEY="${SSH_PATH}.pub"

    echo "DEBUG SSH_PATH=$SSH_PATH"
    echo "DEBUG SSH_PUBLIC_KEY=$SSH_PUBLIC_KEY"

    # ==================================================
    # VALIDATE PUBLIC KEY FILE EXISTS
    # ==================================================
    if [ ! -f "$SSH_PUBLIC_KEY" ]; then
        echo "ERROR: SSH public key not found: $SSH_PUBLIC_KEY"
        return 1
    fi

    # ==================================================
    # LOAD PUBLIC KEY CONTENT
    # ==================================================
    PUBLIC_KEY_CONTENT=$(cat "$SSH_PUBLIC_KEY")

    if [ -z "$PUBLIC_KEY_CONTENT" ]; then
        echo "ERROR: Public key file is empty"
        return 1
    fi

    echo "Public key loaded successfully."

    # ==================================================
    # VM NETWORK DEBUG
    # ==================================================
    echo "========== VM NETWORK DEBUG =========="
    echo "RG=$RG"
    echo "VM_NAME=$VM_NAME"
echo "NIC_NAME=$NIC_NAME"

    az network nic show \
    --resource-group "$RG" \
    --name "$NIC_NAME" \
    --query id \
    -o tsv

    echo "======================================"
    # ==================================================
    # CREATE VM WITH MANAGED IDENTITY
    # ==================================================
    if ! az vm create \
        --resource-group "$RG" \
        --name "$VM_NAME" \
        --nics "$NIC_NAME" \
        --location "$LOCATION" \
        --image "$IMAGE" \
        --size "$VM_SIZE" \
        --admin-username "$ADMIN_USER" \
        --ssh-key-values "$PUBLIC_KEY_CONTENT" \
        --custom-data "$CLOUD_INIT_FILE" \
        --assign-identity \
        --output none
        then

        echo "ERROR: VM creation failed"
        return 1

    fi

    echo "VM Created Successfully"

    # ==================================================
    # WAIT FOR MANAGED IDENTITY TO APPEAR
    # ==================================================
    echo "Waiting for VM identity..."

    for i in {1..20}; do

        VM_PRINCIPAL_ID=$(az vm show \
            --resource-group "$RG" \
            --name "$VM_NAME" \
            --query identity.principalId \
            -o tsv 2>/dev/null)

        if [ -n "$VM_PRINCIPAL_ID" ] && [ "$VM_PRINCIPAL_ID" != "null" ]; then
            break
        fi

        echo "Waiting for identity... ($i/20)"
        sleep 5

    done

    if [ -z "$VM_PRINCIPAL_ID" ] || [ "$VM_PRINCIPAL_ID" = "null" ]; then
        echo "WARNING: VM identity not ready yet"
        return 0
    fi

    echo "VM Identity: $VM_PRINCIPAL_ID"

    # ==================================================
    # EXPORT FOR RBAC MODULE
    # ==================================================
    export VM_PRINCIPAL_ID

    echo "================ VM CREATION END ================"
}