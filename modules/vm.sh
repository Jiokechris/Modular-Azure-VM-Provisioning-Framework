create_vm() {

    echo "Creating VM..."
    echo "Location: $LOCATION"
    echo "Size: $VM_SIZE"

    SSH_PUBLIC_KEY="${SSH_PATH}.pub"

    echo "DEBUG SSH_PATH=$SSH_PATH"
    echo "DEBUG SSH_PUBLIC_KEY=$SSH_PUBLIC_KEY"

    # =========================
    # FIX: normalize path (CRITICAL FOR GIT BASH / WINDOWS)
    # =========================
    if command -v realpath >/dev/null 2>&1; then
        SSH_PUBLIC_KEY=$(realpath "$SSH_PUBLIC_KEY")
    fi

    echo "DEBUG RESOLVED SSH_PUBLIC_KEY=$SSH_PUBLIC_KEY"

    # =========================
    # VALIDATE KEY EXISTS
    # =========================
    if [ ! -f "$SSH_PUBLIC_KEY" ]; then
        echo "ERROR: Public key not found: $SSH_PUBLIC_KEY"
        return 1
    fi

    # =========================
    # CREATE VM
    # =========================
    if az vm create \
        --resource-group "$RG" \
        --name "$VM_NAME" \
        --location "$LOCATION" \
        --image "$IMAGE" \
        --size "$VM_SIZE" \
        --admin-username "$ADMIN_USER" \
        --ssh-key-values "$(cat "$SSH_PUBLIC_KEY")" \
        --custom-data "$CLOUD_INIT_FILE" \
        --assign-identity \
        --output none; then

        echo "VM Created Successfully!"
    else
        echo "VM creation failed"
        return 1
    fi

    # =========================
    # WAIT FOR IDENTITY (IMPORTANT FIX)
    # =========================
    echo "Fetching VM identity..."

    VM_PRINCIPAL_ID=""

    for i in {1..20}; do
        VM_PRINCIPAL_ID=$(az vm show \
            -g "$RG" \
            -n "$VM_NAME" \
            --query identity.principalId -o tsv 2>/dev/null)

        if [ -n "$VM_PRINCIPAL_ID" ]; then
            break
        fi

        echo "Waiting for VM identity... ($i/20)"
        sleep 5
    done

    if [ -z "$VM_PRINCIPAL_ID" ]; then
        echo "WARNING: VM identity not found yet (may still be provisioning)"
        return 0
    fi

    echo "VM Identity: $VM_PRINCIPAL_ID"

    # =========================
    # RBAC ASSIGNMENT (SAFE)
    # =========================
    echo "Assigning Contributor role to VM identity..."

    az role assignment create \
        --assignee "$VM_PRINCIPAL_ID" \
        --role "Contributor" \
        --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG" \
        --output none

    echo "VM RBAC assignment completed."
}