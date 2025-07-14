#!/bin/bash

echo "Creating encoded setup script..."

SCRIPT_DIR="$(dirname "$0")"

TEMP_FILE=$(mktemp)

if base64 "$SCRIPT_DIR/lab01_setup_source.sh" > "$TEMP_FILE"; then
    mv "$TEMP_FILE" "$SCRIPT_DIR/lab01_setup_encoded.txt"
    rm "$SCRIPT_DIR/lab01_setup_source.sh"
    echo "Created lab01_setup_encoded.txt - users can run this without seeing the source!"
else
    echo "Error: Failed to encode lab01_setup_source.sh"
    rm -f "$TEMP_FILE"
    exit 1
fi