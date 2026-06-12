# =========================================================
# CREATE VIRTUAL NETWORK
# =========================================================
create_vnet() {

    echo "Creating Virtual Network..."

    if ! az network vnet create \
        --resource-group "$RG" \
        --name "$VNET_NAME" \
        --location "$LOCATION" \
        --address-prefix 10.0.0.0/16 \
        --output none
    then
        echo "ERROR: Failed to create VNet"
        return 1
    fi

    echo "Virtual Network Created"
}

# =========================================================
# CREATE SUBNET
# =========================================================
create_subnet() {

    echo "Creating Subnet..."

    if ! az network vnet subnet create \
        --resource-group "$RG" \
        --vnet-name "$VNET_NAME" \
        --name "$SUBNET_NAME" \
        --address-prefixes 10.0.1.0/24 \
        --output none
    then
        echo "ERROR: Failed to create subnet"
        return 1
    fi

    echo "Subnet Created"
}

# =========================================================
# CREATE NETWORK SECURITY GROUP
# =========================================================
create_nsg() {

    echo "Creating Network Security Group..."

    if ! az network nsg create \
        --resource-group "$RG" \
        --name "$NSG_NAME" \
        --location "$LOCATION" \
        --output none
    then
        echo "ERROR: Failed to create NSG"
        return 1
    fi

    echo "NSG Created"
}

# =========================================================
# NSG RULES
# =========================================================
create_nsg_rules() {

    echo "Adding NSG Rules..."

    az network nsg rule create \
        --resource-group "$RG" \
        --nsg-name "$NSG_NAME" \
        --name allow-ssh \
        --priority 100 \
        --direction Inbound \
        --access Allow \
        --protocol Tcp \
        --destination-port-ranges 22 \
        --source-address-prefixes "*" \
        --output none

    az network nsg rule create \
        --resource-group "$RG" \
        --nsg-name "$NSG_NAME" \
        --name allow-http \
        --priority 200 \
        --direction Inbound \
        --access Allow \
        --protocol Tcp \
        --destination-port-ranges 80 \
        --source-address-prefixes "*" \
        --output none

    az network nsg rule create \
        --resource-group "$RG" \
        --nsg-name "$NSG_NAME" \
        --name allow-https \
        --priority 300 \
        --direction Inbound \
        --access Allow \
        --protocol Tcp \
        --destination-port-ranges 443 \
        --source-address-prefixes "*" \
        --output none

    echo "NSG Rules Created"
}

# =========================================================
# CREATING PUBLIC IP
# =========================================================
create_public_ip() {

    echo "Creating Public IP..."

    if ! az network public-ip create \
        --resource-group "$RG" \
        --name "$PUBLIC_IP_NAME" \
        --location "$LOCATION" \
        --sku Standard \
        --allocation-method Static \
        --output none
    then
        echo "ERROR: Failed to create Public IP"
        return 1
    fi

    echo "Public IP Created"
}
# =========================================================
# GET PUBLIC IP
# =========================================================
get_public_ip() {

    PUBLIC_IP=$(az vm show \
        --resource-group "$RG" \
        --name "$VM_NAME" \
        --location "$LOCATION" \
        -d \
        --query publicIps \
        -o tsv)

    echo
    echo "Public IP: $PUBLIC_IP"
    echo
}

# =========================================================
# CREATING NIC
# =========================================================
create_nic() {

    echo "Creating NIC..."

    if ! az network nic create \
        --resource-group "$RG" \
        --name "$NIC_NAME" \
        --location "$LOCATION" \
        --vnet-name "$VNET_NAME" \
        --subnet "$SUBNET_NAME" \
        --network-security-group "$NSG_NAME" \
        --public-ip-address "$PUBLIC_IP_NAME" \
        --output none
    then
        echo "ERROR: Failed to create NIC"
        return 1
    fi

    echo "NIC Created"
}

# =========================================================
# ATTACHING NSG TO NIC
# =========================================================
attach_nsg_to_nic() {

    echo "Attaching NSG to NIC..."

    if ! az network nic update \
        -g "$RG" \
        -n "$NIC_NAME" \
        --network-security-group "$NSG_NAME" \
        --output none
    then
        echo "ERROR: Failed to attach NSG to NIC"
        return 1
    fi

    echo -e "\e[32mNSG attached to NIC ✔\e[0m"
}

attach_nsg_to_subnet() {
    echo "Attaching NSG to Subnet..."
    az network vnet subnet update \
        --resource-group "$RG" \
        --vnet-name "$VNET_NAME" \
        --name "$SUBNET_NAME" \
        --network-security-group "$NSG_NAME" \
        --output none
    echo -e "\e[32mNSG attached to Subnet ✔\e[0m"
}