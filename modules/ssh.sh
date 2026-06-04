create_ssh_keys() {

    mkdir -p "$KEY_DIR"

    if [ ! -f "$SSH_PATH" ]
    then

        ssh-keygen \
            -t rsa \
            -b 4096 \
            -f "$SSH_PATH" \
            -N ""

        echo "SSH Keys Created."

    else

        echo "SSH Key Already Exists."

    fi

    echo "Private Key Location: $SSH_PATH"
}