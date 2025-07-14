#!/bin/bash

echo "Setting up Offensive Security Lab 01..."

# Check if encoded file exists
if [ ! -f "lab01_setup_encoded.txt" ]; then
    echo "Error: Encoded setup file not found!"
    exit 1
fi

# Decode to temporary file and execute with proper stdin
TEMP_SCRIPT=$(mktemp)
base64 -d lab01_setup_encoded.txt > "$TEMP_SCRIPT"
chmod +x "$TEMP_SCRIPT"

# Execute the script normally (preserving stdin for user input)
"$TEMP_SCRIPT"

# Clean up
rm -f "$TEMP_SCRIPT"

