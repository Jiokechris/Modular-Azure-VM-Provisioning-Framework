
# =========================================================
# KEY VAULT MODULE (HARDENED VERSION)
# =========================================================

# ---------------------------------------------------------
# 1. CREATE KEY VAULT
# ---------------------------------------------------------
create_key_vault() {

  echo "Checking Key Vault: $KV_NAME"

  if az keyvault show --name "$KV_NAME" --resource-group "$RG" &>/dev/null; then
    echo "Key Vault already exists. Skipping creation."
    return 0
  fi

  echo "Creating Key Vault..."

  if ! az keyvault create \
    --name "$KV_NAME" \
    --resource-group "$RG" \
    --location "$LOCATION" \
    --enable-rbac-authorization true \
    --output none
  then
    echo "ERROR: Key Vault creation failed."
    return 1
  fi

  echo "Key Vault creation command succeeded."
}

# ---------------------------------------------------------
# 2. WAIT FOR KEY VAULT TO BE READY (NO BLIND SLEEP)
# ---------------------------------------------------------
wait_for_keyvault() {

  echo "Waiting for Key Vault provisioning..."

  for i in {1..20}; do

    STATE=$(az keyvault show \
      --name "$KV_NAME" \
      --query properties.provisioningState -o tsv 2>/dev/null)

    if [ "$STATE" == "Succeeded" ]; then
      echo "Key Vault is fully ready."
      return 0
    fi

    echo "Waiting for Key Vault... ($i/20)"
    sleep 5
  done

  echo "ERROR: Key Vault did not reach 'Succeeded' state."
  return 1
}

# ---------------------------------------------------------
# 3. ASSIGN RBAC TO KEY VAULT
# ---------------------------------------------------------
assign_keyvault_rbac() {

  echo "Assigning Key Vault Secrets Officer role..."

  # Try user identity first
  USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null)

  # fallback for SP/CI environments
  if [ -z "$USER_OBJECT_ID" ]; then
    USER_OBJECT_ID=$(az account show --query user.name -o tsv)
  fi

  if [ -z "$USER_OBJECT_ID" ]; then
    echo "ERROR: Could not resolve user identity."
    return 1
  fi

  KV_SCOPE=$(az keyvault show \
    --name "$KV_NAME" \
    --resource-group "$RG" \
    --query id -o tsv)

  if [ -z "$KV_SCOPE" ]; then
    echo "ERROR: Could not resolve Key Vault scope."
    return 1
  fi

  if ! az role assignment create \
    --assignee "$USER_OBJECT_ID" \
    --role "Key Vault Secrets Officer" \
    --scope "$KV_SCOPE" \
    --output none
  then
    echo "ERROR: Failed to assign Key Vault role."
    return 1
  fi

  echo "Waiting for RBAC propagation..."

  # Proper RBAC verification loop (no blind sleep)
  for i in {1..12}; do

    CHECK=$(az role assignment list \
      --assignee "$USER_OBJECT_ID" \
      --scope "$KV_SCOPE" \
      --query "[].roleDefinitionName" -o tsv)

    if echo "$CHECK" | grep -q "Key Vault Secrets Officer"; then
      echo "RBAC assignment confirmed."
      return 0
    fi

    echo "RBAC not active yet... ($i/12)"
    sleep 5
  done

  echo "WARNING: RBAC assignment may still be propagating."
  return 0
}

# ---------------------------------------------------------
# 4. STORE SSH PRIVATE KEY
# ---------------------------------------------------------
store_ssh_private_key() {

  echo "Storing SSH private key in Key Vault..."
  echo "DEBUG SSH_PATH = $SSH_PATH"

  if [ ! -f "$SSH_PATH" ]; then
    echo "ERROR: SSH private key not found at $SSH_PATH"
    return 1
  fi

   WIN_SSH_PATH=$(cygpath -w "$SSH_PATH")

   echo "DEBUG WINDOWS PATH = $WIN_SSH_PATH"

  if ! az keyvault secret set \
    --vault-name "$KV_NAME" \
    --name "ssh-private-key" \
    --file "$WIN_SSH_PATH" \
    --output none
  then
    echo "ERROR: Failed to store SSH private key."
    return 1
  fi

  echo "SSH private key stored successfully."
}

# ---------------------------------------------------------
# 5. STORE RANDOM SECRET (OPTIONAL)
# ---------------------------------------------------------
store_secret() {

  echo "Generating secret..."

  PASSWORD=$(openssl rand -base64 24)

  if ! az keyvault secret set \
    --vault-name "$KV_NAME" \
    --name "$SECRET_NAME" \
    --value "$PASSWORD" \
    --output none
  then
    echo "ERROR: Failed to store secret."
    return 1
  fi

  echo "Secret stored successfully."
}

# ---------------------------------------------------------
# 6. RETRIEVE SECRET
# ---------------------------------------------------------
get_secret() {

  az keyvault secret show \
    --vault-name "$KV_NAME" \
    --name "$SECRET_NAME" \
    --query value -o tsv
}