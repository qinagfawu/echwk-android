#!/bin/bash
set -e

echo "Downloading ECH Workers Android binary from releases..."

LATEST="v1.4"
ASSET="ECHWorkers-linux-arm64.tar.gz"
URL="https://github.com/byJoey/ech-wk/releases/download/${LATEST}/${ASSET}"

# Log the download URL
echo "Download URL: $URL"

# Create the tmp directory and download the file to tmp
mkdir -p tmp
wget -q --show-progress -O tmp/eche.tar.gz "$URL" || { echo "Failed to download file."; exit 1; }

echo "Extracting..."
tar -xzf tmp/eche.tar.gz -C tmp

# Assume extracted has the binary named ech-workers or similar inside
BINFILE=$(find tmp -type f -name "ech-workers*" | head -n 1)

if [ ! -f "$BINFILE" ]; then
    echo "ERROR: binary not found in release!"
    exit 1
fi

echo "Copying files to build/module..."

# Create the necessary directories and copy files
mkdir -p build/module
cp -r src/* build/module
cp -r webui build/module
cp -r api build/module

# Create necessary directories in build/module
mkdir -p build/module/system/bin
cp "$BINFILE" build/module/system/bin/ech-workers
chmod 755 build/module/system/bin/ech-workers

cp default/config.json build/module/
cp module.prop build/module/

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
