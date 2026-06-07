assign_rbac() {

echo "Assigning Key Vault Secrets Officer role to current user..."

# =========================
# VALIDATE INPUTS
# =========================
if [ -z "$KV_NAME" ] || [ -z "$RG" ]; then
    echo "ERROR: KV_NAME or RG is empty"
    exit 1
fi

echo "DEBUG KV_NAME=$KV_NAME"
echo "DEBUG RG=$RG"

# =========================
# RESOLVE KEY VAULT
# =========================
KV_SCOPE=$(az keyvault show \
    --name "$KV_NAME" \
    --resource-group "$RG" \
    --query id \
    -o tsv 2>/dev/null)

if [ -z "$KV_SCOPE" ]; then
    echo "ERROR: Key Vault not found. RBAC cannot proceed."
    echo "KV_NAME=$KV_NAME"
    echo "RG=$RG"
    exit 1
fi

echo "Key Vault Scope resolved: $KV_SCOPE"

# =========================
# GET USER OBJECT ID
# =========================
USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)

if [ -z "$USER_OBJECT_ID" ]; then
    echo "ERROR: Could not resolve user object ID"
    exit 1
fi

# =========================
# ROLE ASSIGNMENT
# =========================
if ! az role assignment create \
  --assignee "$USER_OBJECT_ID" \
  --role "Key Vault Secrets Officer" \
  --scope "$KV_SCOPE" \
  --output none; then

    echo "ERROR: RBAC assignment failed"
    exit 1
fi

echo "Waiting for RBAC propagation..."
sleep 60

echo "RBAC assignment completed successfully."

}