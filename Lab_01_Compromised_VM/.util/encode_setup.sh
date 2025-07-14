#!/bin/bash

echo "Creating encoded setup script..."

# Create a temporary file for safe encoding
TEMP_FILE=$(mktemp)

# Encode to temporary file first and check if it was successful
if base64 lab01_setup_source.sh > "$TEMP_FILE"; then
    echo "Successfully encoded setup script"
    # Move the temp file to the final destination
    mv "$TEMP_FILE" lab01_setup_encoded.txt
    rm lab01_setup_source.sh
    echo "Created lab01_setup_encoded.txt - users can run this without seeing the source!"
else
    echo "Error: Failed to encode lab01_setup_source.sh"
    # Clean up the temp file on failure
    rm -f "$TEMP_FILE"
    exit 1
fi