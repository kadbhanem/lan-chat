#!/bin/bash

# ============================================
# Create GitHub Release Package
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
OUTPUT_DIR="$SCRIPT_DIR/../releases"
VERSION="1.0.0"

echo "Creating release packages v$VERSION..."
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Create service tarball for Linux
echo "Creating Linux package..."
LINUX_DIR=$(mktemp -d)
mkdir -p "$LINUX_DIR/lan-chat-service"

# Copy service files
cp -r "$PROJECT_DIR/service/"* "$LINUX_DIR/lan-chat-service/"

# Remove unnecessary files
rm -rf "$LINUX_DIR/lan-chat-service/venv"
rm -rf "$LINUX_DIR/lan-chat-service/__pycache__"
rm -rf "$LINUX_DIR/lan-chat-service/*/__pycache__"
rm -rf "$LINUX_DIR/lan-chat-service/*/*/__pycache__"
rm -f "$LINUX_DIR/lan-chat-service"/*.pyc

# Create tarball
cd "$LINUX_DIR"
tar -czf "$OUTPUT_DIR/lan-chat-service.tar.gz" lan-chat-service
rm -rf "$LINUX_DIR"
echo "  ✓ lan-chat-service.tar.gz"

# Create Windows ZIP
echo "Creating Windows package..."
WIN_DIR=$(mktemp -d)
mkdir -p "$WIN_DIR/lan-chat-windows"
mkdir -p "$WIN_DIR/lan-chat-windows/service"

# Copy service files
cp -r "$PROJECT_DIR/service/"* "$WIN_DIR/lan-chat-windows/service/"

# Copy Windows installer
cp "$OUTPUT_DIR/install-windows.bat" "$WIN_DIR/lan-chat-windows/" 2>/dev/null || true

# Remove unnecessary files
rm -rf "$WIN_DIR/lan-chat-windows/service/venv"
rm -rf "$WIN_DIR/lan-chat-windows/service/__pycache__"
find "$WIN_DIR" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find "$WIN_DIR" -name "*.pyc" -delete 2>/dev/null || true

# Create ZIP
cd "$WIN_DIR"
zip -r "$OUTPUT_DIR/lan-chat-windows.zip" lan-chat-windows -q
rm -rf "$WIN_DIR"
echo "  ✓ lan-chat-windows.zip"

# Copy installer scripts
echo "Copying installer scripts..."
cp "$SCRIPT_DIR/../releases/install-linux.sh" "$OUTPUT_DIR/" 2>/dev/null || true
cp "$SCRIPT_DIR/../releases/install-windows.bat" "$OUTPUT_DIR/" 2>/dev/null || true

echo ""
echo "Release packages created in: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"
echo ""
echo "Next: Upload these files to GitHub Releases"