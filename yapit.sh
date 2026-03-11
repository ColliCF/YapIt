#!/bin/bash

KEYS_DIR="keys"
DATA_DIR="yaps"
PRIV_KEY_FILE="$KEYS_DIR/id_rsa"
PUB_KEY_FILE="$KEYS_DIR/id_rsa.pub"

mkdir -p "$KEYS_DIR" "$DATA_DIR"

# [1. PKI Setup]
if [[ ! -f "$PRIV_KEY_FILE" && ! -f "$PUB_KEY_FILE" ]]; then
    echo -e "Forging RSA-2048 keys...\n"
    openssl genpkey -algorithm RSA -out "$PRIV_KEY_FILE" -pkeyopt rsa_keygen_bits:2048 2>/dev/null
    openssl rsa -pubout -in "$PRIV_KEY_FILE" -out "$PUB_KEY_FILE" 2>/dev/null
    chmod 600 "$PRIV_KEY_FILE"
fi

# [2. Encrypt/Write]
function yap() {
    local ts=$(date +%s)
    local target_dir="$DATA_DIR/$ts"
    mkdir -p "$target_dir"

    echo -e "\nSpill the tea (Ctrl+D to finish your yap session):"

    # Limitado a blocos de 180 bytes
    cat | split -b 180 - "$target_dir/chunk_"

    local i=0
    for file in "$target_dir"/chunk_*; do
        [[ -e "$file" ]] || continue

        openssl pkeyutl -encrypt -in "$file" -pubin -inkey "$PUB_KEY_FILE" \
            -pkeyopt rsa_padding_mode:oaep | base64 > "$target_dir/$i.enc"
        rm "$file"
        ((i++))
    done

    echo -e "\n\nYap secured at: $target_dir"
}

# [3. Decrypt/Read]
function unpack() {
    echo -e "\nAvailable yap sessions:"
    ls -1 "$DATA_DIR"
    read -p "Drop the timestamp you wanna unpack: " ts

    local target_dir="$DATA_DIR/$ts"
    if [[ ! -d "$target_dir" ]]; then
        echo "ERROR: 404 Yap not found." && exit 1
    fi

    echo -e "\n--- UNPACKING YAP ---"

    for file in $(ls -1v "$target_dir"/*.enc 2>/dev/null); do
        base64 -d "$file" | openssl pkeyutl -decrypt -inkey "$PRIV_KEY_FILE" -pkeyopt rsa_padding_mode:oaep
    done

    echo -e "\n--- END OF YAP ---\n"
}

# Entrypoint
echo "1) Yap"
echo "2) Unpack"
read -p "Pick your poison: " opt

case $opt in
    1) yap ;;
    2) unpack ;;
    *) echo "Bruh, invalid option."; exit 1 ;;
esac