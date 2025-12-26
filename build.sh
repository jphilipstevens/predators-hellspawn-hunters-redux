#!/bin/bash

# Build script for Predators Hellspawn Hunters Redux
# Creates a PK3 file from the src directory

set -e

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Output filename
OUTPUT_NAME="predators-hellspawn-hunters-redux.pk3"

# Remove old build if it exists
if [ -f "$OUTPUT_NAME" ]; then
    echo "Removing old $OUTPUT_NAME..."
    rm "$OUTPUT_NAME"
fi

# Create the PK3 (which is just a ZIP file)
echo "Building $OUTPUT_NAME..."
cd src
zip -r "../$OUTPUT_NAME" . -x "*.git*" -x "*jdredalerts*" -x "*.DS_Store"
cd ..

echo "Build complete! Created $OUTPUT_NAME"
echo "Size: $(du -h "$OUTPUT_NAME" | cut -f1)"
