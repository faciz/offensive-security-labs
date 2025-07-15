#!/bin/bash

echo "Setting up Offensive Security Lab 01..."

SCRIPT_DIR="$(dirname "$0")"
SOURCE_SCRIPT="$SCRIPT_DIR/.util/lab01_setup_source.sh"
ENCODED_SCRIPT="$SCRIPT_DIR/.util/lab01_setup_encoded.txt"

# Check if the decoded source script exists and is executable
if [ -f "$SOURCE_SCRIPT" ] && [ -x "$SOURCE_SCRIPT" ]; then
    chmod +x "$SOURCE_SCRIPT"
    "$SOURCE_SCRIPT"
elif [ -f "$ENCODED_SCRIPT" ]; then
    TEMP_SCRIPT=$(mktemp)
    base64 -d "$ENCODED_SCRIPT" > "$TEMP_SCRIPT"
    chmod +x "$TEMP_SCRIPT"
    "$TEMP_SCRIPT"
    rm -f "$TEMP_SCRIPT"
else
    echo "Error: No setup file found!"
    exit 1
fi

