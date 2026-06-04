open_http_port() {

    echo "Opening HTTP Port..."

    az vm open-port \
        --resource-group "$RG" \
        --name "$VM_NAME" \
        --port 80 \
        --output none

    echo "Port 80 Opened."
}