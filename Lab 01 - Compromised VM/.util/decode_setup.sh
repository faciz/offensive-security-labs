#!/bin/bash

echo "Creating decoded setup script..."

SCRIPT_DIR="$(dirname "$0")"

TEMP_FILE=$(mktemp)

if base64 -d "$SCRIPT_DIR/lab01_setup_encoded.txt" > "$TEMP_FILE"; then
    mv "$TEMP_FILE" "$SCRIPT_DIR/lab01_setup_source.sh"
    rm "$SCRIPT_DIR/lab01_setup_encoded.txt"
    echo "Decoded setup script created as lab01_setup_source.sh"
else
    echo "Error: Failed to decode lab01_setup_encoded.txt"
    rm -f "$TEMP_FILE"
    exit 1
fi