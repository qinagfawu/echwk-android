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

cd build/module
zip -r ../echwk-module.zip *
cd ../..

# Ensure the file exists before uploading it as artifact
if [ ! -f "echwk-module.zip" ]; then
    echo "ERROR: Module zip file not found!"
    exit 1
fi

echo "Uploading artifact..."
# Upload the artifact to GitHub Actions
curl --upload-file echwk-module.zip "https://uploads.github.com/"

echo "Done!"
