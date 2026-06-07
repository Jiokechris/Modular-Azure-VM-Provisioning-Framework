#!/bin/bash

create_key_vault() {

  echo "Checking Key Vault: $KV_NAME"

  # =========================
  # CHECK IF KEY VAULT EXISTS
  # =========================
  if az keyvault show --name "$KV_NAME" --resource-group "$RG" &>/dev/null; then

    echo "Key Vault already exists. Skipping creation."

  else

    echo "Creating Key Vault..."

    # =========================
    # CREATE KEY VAULT
    # =========================
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

    # =========================
    # VERIFY KEY VAULT EXISTS
    # =========================
    echo "Verifying Key Vault existence..."

    for i in {1..15}; do

      if az keyvault show \
        --name "$KV_NAME" \
        --resource-group "$RG" \
        &>/dev/null
      then

        echo "Key Vault is now available."
        break

      fi

      echo "Waiting for Key Vault provisioning... ($i/15)"
      sleep 5

    done

    # Final verification
    if ! az keyvault show \
      --name "$KV_NAME" \
      --resource-group "$RG" \
      &>/dev/null
    then

      echo "ERROR: Key Vault not found after creation."
      echo "KV_NAME=$KV_NAME"
      echo "RG=$RG"
      return 1

    fi

    # =========================
    # GET USER OBJECT ID
    # =========================
    USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)

    if [ -z "$USER_OBJECT_ID" ]; then

      echo "ERROR: Could not determine signed-in user."
      return 1

    fi

    # =========================
    # GET KV SCOPE
    # =========================
    KV_SCOPE=$(az keyvault show \
      --name "$KV_NAME" \
      --resource-group "$RG" \
      --query id \
      -o tsv)

    if [ -z "$KV_SCOPE" ]; then

      echo "ERROR: Could not resolve Key Vault scope."
      return 1

    fi

    # =========================
    # RBAC ASSIGNMENT
    # =========================
    echo "Assigning Key Vault Secrets Officer role..."

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
    sleep 60

    echo "Key Vault RBAC assignment completed."

  fi
}

# =========================================================
# STORE SSH PRIVATE KEY IN KEY VAULT
# =========================================================
store_ssh_private_key() {

  echo "Storing SSH private key in Key Vault..."
  echo "DEBUG SSH_PATH = $SSH_PATH"

  if [ ! -f "$SSH_PATH" ]; then

    echo "ERROR: SSH private key not found at $SSH_PATH"
    return 1

  fi

  # Convert Git Bash path to Windows path
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

# =========================================================
# STORE RANDOM PASSWORD
# =========================================================
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

  echo "Secret stored in Key Vault"

}

# =========================================================
# RETRIEVE SECRET
# =========================================================
get_secret() {

  az keyvault secret show \
    --vault-name "$KV_NAME" \
    --name "$SECRET_NAME" \
    --query value \
    -o tsv
}