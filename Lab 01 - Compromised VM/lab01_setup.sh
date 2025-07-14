#!/bin/bash

echo "Setting up Offensive Security Lab 01..."

SCRIPT_DIR="$(dirname "$0")"

if [ ! -f "$SCRIPT_DIR/.util/lab01_setup_encoded.txt" ]; then
    echo "Error: Encoded setup file not found!"
    exit 1
fi

TEMP_SCRIPT=$(mktemp)
base64 -d "$SCRIPT_DIR/.util/lab01_setup_encoded.txt" > "$TEMP_SCRIPT"
chmod +x "$TEMP_SCRIPT"

"$TEMP_SCRIPT"

rm -f "$TEMP_SCRIPT"

