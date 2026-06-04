check_azure_cli() {

    echo "Checking Azure CLI..."

    if command -v az >/dev/null 2>&1
    then
        echo "Azure CLI found."
    else
        echo "Azure CLI not installed."
        exit 1
    fi
}

check_azure_login() {

    echo "Checking Azure Login..."

    if az account show >/dev/null 2>&1
    then
        echo "Azure Login Verified."
    else
        echo "Please run az login"
        exit 1
    fi
}