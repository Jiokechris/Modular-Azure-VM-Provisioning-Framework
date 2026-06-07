create_resource_group() {

    echo "DEBUG RG VALUE = $RG"

    echo "Checking Resource Group..."

    EXISTS=$(az group exists --name "$RG" --output tsv)

    if [ "$EXISTS" = "true" ]; then

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