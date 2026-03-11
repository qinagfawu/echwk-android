#!/bin/bash
set -e

echo "Downloading ECH Workers Android binary from releases..."

LATEST="v1.4"
ASSET="ECHWorkers-linux-arm64.tar.gz"
URL="https://github.com/byJoey/ech-wk/releases/download/${LATEST}/${ASSET}"

# Create tmp directory and download the file
mkdir -p tmp
wget -q --show-progress -O tmp/eche.tar.gz "$URL" || { echo "Failed to download file."; exit 1; }

echo "Extracting..."
tar -xzf tmp/eche.tar.gz -C tmp

# Ensure binary is extracted
BINFILE=$(find tmp -type f -name "ech-workers*" | head -n 1)

if [ ! -f "$BINFILE" ]; then
    echo "ERROR: binary not found in release!"
    exit 1
fi

# Ensure module.prop exists in the src directory
if [ ! -f "src/module.prop" ]; then
    echo "ERROR: module.prop file not found!"
    exit 1
fi

echo "Copying files to build/module..."

# Create necessary directories and copy files
mkdir -p build/module
cp -r src/* build/module
cp -r webui build/module
cp -r api build/module

# Create system directory and copy the binary
mkdir -p build/module/system/bin
cp "$BINFILE" build/module/system/bin/ech-workers
chmod 755 build/module/system/bin/ech-workers

cp src/default/config.json build/module/
cp src/module.prop build/module/

# Create the zip file inside the build/module directory
cd build/module
zip -r echwk-module.zip .  # Create the zip file in build/module

# Ensure the zip file exists
cd ../..
if [ ! -f "build/module/echwk-module.zip" ]; then
    echo "ERROR: Module zip file not found in build/module!"
    exit 1
fi

# Check the zip file creation
ls -lh build/module/echwk-module.zip

echo "Uploading artifact..."

# Upload the zip file as an artifact
if [ -f "build/module/echwk-module.zip" ]; then
    echo "Uploading $PWD/build/module/echwk-module.zip..."
    curl --upload-file "$PWD/build/module/echwk-module.zip" "https://uploads.github.com/"
else
    echo "ERROR: Failed to find module zip file!"
    exit 1
fi

echo "Done!"
