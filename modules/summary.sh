show_summary() {

    echo ""
    echo "======================================="
    echo "Deployment Complete"
    echo "======================================="

    echo ""
    echo "VM Name: $VM_NAME"

    echo "Resource Group: $RG"

    echo "Public IP: $PUBLIC_IP"

    echo ""

    echo "Website:"

    echo "http://$PUBLIC_IP"

    echo ""

    echo "SSH Command:"

    echo "ssh -i $SSH_PATH $ADMIN_USER@$PUBLIC_IP"
}