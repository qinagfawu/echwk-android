#!/bin/bash
set -e

echo "Downloading ECH Workers Android binary from releases..."

LATEST="v1.4"
ASSET="com.ech.workers-20251203new-arm64-v8a-release.zip"
URL="https://github.com/byJoey/ech-wk/releases/download/${LATEST}/${ASSET}"

mkdir -p tmp
wget -q -O tmp/eche.tar "$URL"

echo "Extracting..."
unzip -o tmp/eche.tar -d tmp

# assume extracted has the binary named ech-workers or similar inside
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

echo "Done!"
