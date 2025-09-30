#!/usr/bin/env bash
set -euo pipefail

# Build and package the .NET Lambda function into lambda.zip at repo root.
# Overwrites lambda.zip if it already exists.
# Uses source under /src (publishes HelloWorld project).

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/src/HelloWorld"
PUBLISH_DIR="$PROJECT_DIR/bin/Release/net6.0/publish"
ZIP_FILE="$ROOT_DIR/lambda.zip"

echo "Root: $ROOT_DIR"
echo "Project: $PROJECT_DIR"
echo "Publish dir: $PUBLISH_DIR"
echo "Zip file: $ZIP_FILE"

# Validate tooling
if ! command -v dotnet >/dev/null 2>&1; then
  echo "Error: dotnet not found in PATH."
  exit 2
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "Error: zip utility not found in PATH."
  exit 3
fi

# Clean previous publish
echo "Cleaning previous publish directory..."
rm -rf "$PUBLISH_DIR"
mkdir -p "$PUBLISH_DIR"

echo "Restoring project..."
dotnet restore "$PROJECT_DIR"

echo "Publishing project for linux-x64 (Lambda runtime uses linux)..."
dotnet publish "$PROJECT_DIR" -c Release -r linux-x64 --self-contained false -o "$PUBLISH_DIR"

# Create (or overwrite) zip at repo root
if [ -f "$ZIP_FILE" ]; then
  echo "Overwriting existing zip: $ZIP_FILE"
  rm -f "$ZIP_FILE"
fi

echo "Creating zip archive..."
cd "$PUBLISH_DIR"
# Zip published files so assemblies are at the root of the zip
zip -r -X "$ZIP_FILE" ./* >/dev/null

if [ -f "$ZIP_FILE" ]; then
  SIZE=$(stat -c%s "$ZIP_FILE" 2>/dev/null || stat -f%z "$ZIP_FILE")
  echo "Created $ZIP_FILE (size: ${SIZE} bytes)"
else
  echo "Error: zip file was not created."
  exit 4
fi

echo "Build and packaging completed."