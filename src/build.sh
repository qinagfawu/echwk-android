#!/bin/bash

set -e

# Clone ech-wk repository
git clone https://github.com/byJoey/ech-wk core

# Navigate to the core directory
cd core

# Initialize Go module with the correct module path
go mod init github.com/byJoey/ech-wk

# Download dependencies
go mod tidy

# Build the Go binary
GOOS=android GOARCH=arm64 go build -o ech-workers

# Go back to the main project directory
cd ..

# Copy necessary files into build module
mkdir -p build/module
cp -r src/* build/module
cp -r webui build/module
cp -r api build/module

# Ensure that the binary is placed in the correct folder
mkdir -p build/module/system/bin
cp core/ech-workers build/module/system/bin/

# Make sure the binary has proper permissions
chmod 755 build/module/system/bin/ech-workers

# Copy the default config file
cp default/config.json build/module/

# Zip everything into the final module
cd build/module
zip -r ../echwk-module.zip *

# Clean up
cd ../..
rm -rf core

echo "Build Complete!"
