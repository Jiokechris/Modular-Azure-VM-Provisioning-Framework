# =========================================================
# COLOR CODES
# =========================================================
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# =========================================================
# GET PUBLIC IP
# =========================================================
get_public_ip() {

    echo ""
    echo -e "${YELLOW}Fetching Public IP...${RESET}"

    for i in $(seq 1 10); do

        PUBLIC_IP=$(az vm show \
            --resource-group "$RG" \
            --name "$VM_NAME" \
            -d \
            --query publicIps \
            -o tsv | tr -d '[:space:]')

        if [ -n "$PUBLIC_IP" ]; then
            echo -e "${GREEN}Public IP: $PUBLIC_IP ✔${RESET}"
            return 0
        fi

        echo "Attempt $i/10 - IP not ready yet, retrying in 10s..."
        sleep 10
    done

    echo -e "${RED}ERROR: Public IP not found after retries.${RESET}"
    return 1
}

# =========================================================
# WAIT + VERIFY NGINX
# =========================================================
wait_for_cloud_init() {

    echo ""
    echo -e "${YELLOW}Waiting for VM provisioning and Nginx startup...${RESET}"

    for i in $(seq 1 30); do

        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
            --connect-timeout 5 \
            --max-time 10 \
            "http://$PUBLIC_IP" | tr -d '[:space:]')

        HTTP_CODE=${HTTP_CODE:-000}

        echo "Attempt $i/30 - HTTP Status: $HTTP_CODE"

        if [[ "$HTTP_CODE" == "200" ]]; then
            echo ""
            echo -e "${GREEN}VM is ready and Nginx is responding. ✔${RESET}"
            return 0
        fi

        sleep 10
    done

    echo ""
    echo -e "${RED}ERROR: Timed out waiting for Nginx.${RESET}"
    return 1
}

# =========================================================
# VERIFY WEBSITE (FINAL CHECK)
# =========================================================
verify_website() {

    echo ""
    echo -e "${YELLOW}Testing Nginx Website...${RESET}"

    for i in $(seq 1 3); do

        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
            --connect-timeout 5 \
            --max-time 10 \
            "http://$PUBLIC_IP" | tr -d '[:space:]')

        HTTP_CODE=${HTTP_CODE:-000}

        echo "Attempt $i/3 - HTTP Status: $HTTP_CODE"

        if [[ "$HTTP_CODE" == "200" ]]; then
            echo ""
            echo -e "${GREEN}Website Verified Successfully! ✔${RESET}"
            return 0
        fi

        sleep 5
    done

    echo ""
    echo -e "${RED}Website Verification Failed. ✗${RESET}"
    return 1
}