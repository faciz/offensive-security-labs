#!/bin/bash

echo "Creating decoded setup script..."

# Create a temporary file for safe decoding
TEMP_FILE=$(mktemp)

# Decode to temporary file first and check if it was successful
if base64 -d lab01_setup_encoded.txt > "$TEMP_FILE"; then
    echo "Successfully decoded setup script"
    # Move the temp file to the final destination
    mv "$TEMP_FILE" lab01_setup_source.sh
    rm lab01_setup_encoded.txt
    echo "Decoded setup script created as lab01_setup_source.sh"
else
    echo "Error: Failed to decode lab01_setup_encoded.txt"
    # Clean up the temp file on failure
    rm -f "$TEMP_FILE"
    exit 1
fi