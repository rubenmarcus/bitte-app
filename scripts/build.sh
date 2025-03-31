#!/bin/bash

# Build the application
pnpm tauri build

# Create download directory if it doesn't exist
mkdir -p src/download

# Copy all bundle files to download directory
cp -r src-tauri/target/release/bundle/* src/download/

# Clean up target directory
rm -rf src-tauri/target/release/bundle

echo "Build complete! Files are in src/download/"