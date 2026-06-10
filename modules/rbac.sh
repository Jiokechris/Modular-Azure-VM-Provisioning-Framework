assign_rbac() {

    echo "================ RBAC START ================"

    # =========================
    # FORCE SUBSCRIPTION CONTEXT
    # =========================
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)

    if [ -z "$SUBSCRIPTION_ID" ]; then
        echo "ERROR: No active subscription"
        return 1
    fi

    az account set --subscription "$SUBSCRIPTION_ID"

    echo "Using subscription: $SUBSCRIPTION_ID"

    # =========================
    # WAIT FOR VM IDENTITY (CRITICAL)
    # =========================
    echo "Waiting for VM identity..."

    for i in {1..20}; do
        VM_PRINCIPAL_ID=$(az vm show \
            -g "$RG" \
            -n "$VM_NAME" \
            --query identity.principalId \
            -o tsv 2>/dev/null)

        if [ -n "$VM_PRINCIPAL_ID" ] && [ "$VM_PRINCIPAL_ID" != "null" ]; then
            echo "VM Identity ready: $VM_PRINCIPAL_ID"
            break
        fi

        echo "Waiting for VM identity... ($i/20)"
        sleep 5
    done

    if [ -z "$VM_PRINCIPAL_ID" ]; then
        echo "ERROR: VM identity not available"
        return 1
    fi

    # =========================
    # WAIT FOR KEY VAULT SCOPE
    # =========================
    echo "Resolving Key Vault scope..."

    for i in {1..20}; do
        KV_SCOPE=$(az keyvault show \
            -g "$RG" \
            -n "$KV_NAME" \
            --query id \
            -o tsv 2>/dev/null)

        if [ -n "$KV_SCOPE" ]; then
            echo "Key Vault scope ready"
            break
        fi

        echo "Waiting for Key Vault... ($i/20)"
        sleep 5
    done

    if [ -z "$KV_SCOPE" ]; then
        echo "ERROR: Key Vault scope not found"
        return 1
    fi

    # =========================
    # ROLE ASSIGNMENT
    # =========================
    echo "Assigning RBAC role..."

    az role assignment create \
        --assignee "$VM_PRINCIPAL_ID" \
        --role "Key Vault Secrets User" \
        --scope "$KV_SCOPE" \
        --output none

    # =========================
    # RBAC VERIFICATION LOOP (THE KEY FIX)
    # =========================
    echo "Verifying RBAC propagation..."

    for i in {1..12}; do

        CHECK=$(az role assignment list \
            --assignee "$VM_PRINCIPAL_ID" \
            --scope "$KV_SCOPE" \
            --query "[].roleDefinitionName" -o tsv)

        if echo "$CHECK" | grep -q "Key Vault Secrets User"; then
            echo "RBAC ACTIVE CONFIRMED"
            echo "================ RBAC COMPLETE ================"
            return 0
        fi

        echo "RBAC not active yet... ($i/12)"
        sleep 5
    done

    echo "WARNING: RBAC assignment created but not yet active"
    return 0
}