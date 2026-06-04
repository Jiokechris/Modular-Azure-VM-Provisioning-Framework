get_public_ip() {

    PUBLIC_IP=$(az vm show \
        --resource-group "$RG" \
        --name "$VM_NAME" \
        -d \
        --query publicIps \
        -o tsv)

    echo ""
    echo "Public IP: $PUBLIC_IP"
}

wait_for_cloud_init() {

    echo ""
    echo "Waiting for cloud-init to complete..."
    echo "This may take 2-3 minutes."

    sleep 180
}

verify_website() {

    echo ""
    echo "Testing Nginx Website..."

    HTTP_CODE=$(curl \
        -s \
        -o /dev/null \
        -w "%{http_code}" \
        --max-time 10 \
        "http://$PUBLIC_IP")

    if [ "$HTTP_CODE" -eq 200 ]
    then
        echo "Website Verified Successfully!"
    else
        echo "Website Verification Failed."
    fi
}