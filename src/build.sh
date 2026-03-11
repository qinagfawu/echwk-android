#!/bin/bash

set -e

# Clone ech-wk repository
git clone https://github.com/byJoey/ech-wk core

# Navigate to the core directory
cd core

# Initialize Go module in the correct directory
go mod init github.com/byJoey/ech-wk

# Download dependencies
go mod tidy

# Build the Go binary for Android (arm64)
GOOS=android GOARCH=arm64 go build -o ech-workers

# Go back to the main project directory
cd ..

# Create necessary directories for the final build
mkdir -p build/module
cp -r src/* build/module
cp -r webui build/module
cp -r api build/module

# Copy the Go binary to the final directory
mkdir -p build/module/system/bin
cp core/ech-workers build/module/system/bin/

# Set permissions for the binary
chmod 755 build/module/system/bin/ech-workers

# Copy the default config file
cp default/config.json build/module/

# Zip everything into the final module zip
cd build/module
zip -r ../echwk-module.zip *

# Clean up the temporary files
cd ../..
rm -rf core

echo "Build Complete!"
