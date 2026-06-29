#!/usr/bin/env bash
set -euo pipefail

REPO="u-u-z/th06-portable"
TAG="v1.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Touhou 06 (EoSD) macOS Portable Setup ==="
echo

# Download release assets
echo "[*] Downloading game data..."
gh release download "$TAG" \
    --repo "$REPO" \
    --pattern "th06-chs-macos.tar.gz" \
    --dir "$SCRIPT_DIR" \
    --clobber

echo "[*] Downloading portable binary..."
gh release download "$TAG" \
    --repo "$REPO" \
    --pattern "th06-portable-macos.tar.gz" \
    --dir "$SCRIPT_DIR" \
    --clobber

# Extract game data
echo "[*] Extracting game data..."
rm -rf "$SCRIPT_DIR/game"
mkdir -p "$SCRIPT_DIR/game"
tar -xzf "$SCRIPT_DIR/th06-chs-macos.tar.gz" -C "$SCRIPT_DIR/game" --strip-components=1 2>/dev/null || \
    tar -xzf "$SCRIPT_DIR/th06-chs-macos.tar.gz" -C "$SCRIPT_DIR/game"

# Extract and merge portable binary
echo "[*] Merging portable binary..."
tar -xzf "$SCRIPT_DIR/th06-portable-macos.tar.gz" --strip-components=1 -C "$SCRIPT_DIR/game" 2>/dev/null || \
    tar -xzf "$SCRIPT_DIR/th06-portable-macos.tar.gz" -C "$SCRIPT_DIR/game"

chmod +x "$SCRIPT_DIR/game/th06"

# Cleanup archives
rm -f "$SCRIPT_DIR/th06-chs-macos.tar.gz" "$SCRIPT_DIR/th06-portable-macos.tar.gz"

echo
echo "=== Setup complete ==="
echo
echo "Run:  cd game && ./th06"
echo "Config:  cd game && ./th06_config"
echo
echo "See COPYRIGHT.md for license information."
