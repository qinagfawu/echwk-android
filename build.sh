#!/bin/bash
set -e

echo "Downloading ECH Workers Android binary from releases..."

LATEST="v1.4"
ASSET="ECHWorkers-linux-arm64.tar.gz"
URL="https://github.com/byJoey/ech-wk/releases/download/${LATEST}/${ASSET}"

# Log the download URL
echo "Download URL: $URL"

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

echo "Copying..."
mkdir -p build/module
cp -r src/* build/module
cp -r webui build/module
cp -r api build/module

mkdir -p build/module/system/bin
cp "$BINFILE" build/module/system/bin/ech-workers
chmod 755 build/module/system/bin/ech-workers

cp default/config.json build/module/

# Check if zip file will be created
echo "Creating zip file..."

# Go to the module directory and create the zip in the root directory
cd build/module
zip -r ../echwk-module.zip *

# Ensure the zip file exists at the root directory
cd ../..
if [ ! -f "echwk-module.zip" ]; then
    echo "ERROR: Module zip file not found at the root!"
    exit 1
fi

echo "Checking file existence..."
ls -lh echwk-module.zip  # Print the details of the zip file to ensure it's created

echo "Uploading artifact..."

# Now upload the zip file to GitHub Actions (path should be root)
if [ -f "echwk-module.zip" ]; then
    echo "Uploading artifact..."
    # Ensure correct file upload path
    upload_path="./echwk-module.zip"
    echo "Uploading $upload_path..."
    curl --upload-file "$upload_path" "https://uploads.github.com/"
else
    echo "ERROR: Failed to find module zip file!"
    exit 1
fi

echo "Done!"
