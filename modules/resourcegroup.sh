create_resource_group() {

    echo "Checking Resource Group..."

    if az group exists --name "$RG" | grep -q true
    then

        echo "Resource Group already exists."

    else

        echo "Creating Resource Group..."

        az group create \
            --name "$RG" \
            --location "$LOCATION" \
            --output none

        echo "Resource Group Created."

    fi
}