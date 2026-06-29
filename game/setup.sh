#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Touhou 06 Portable Setup ==="
echo

# Check for compiled binary
if [ ! -f "$SCRIPT_DIR/th06" ]; then
    echo "[!] th06 binary not found at game/th06."
    echo "    Build it first: premake5 gmake && cd build && make -j16"
    exit 1
fi

chmod +x "$SCRIPT_DIR/th06"

# DAT files
DAT_FILES=(
    "紅魔郷CM.DAT"
    "紅魔郷ED.DAT"
    "紅魔郷IN.DAT"
    "紅魔郷MD.DAT"
    "紅魔郷ST.DAT"
    "紅魔郷TL.DAT"
)

if [ "${1:-}" = "" ]; then
    echo "Usage: $0 <path-to-original-game-directory>"
    echo
    echo "Provide the directory containing the original game files"
    echo "(紅魔郷*.DAT, 東方紅魔郷.cfg, etc.) from your legally acquired copy."
    echo
    echo "DAT files are NOT included in this repository due to copyright."
    exit 1
fi

SRC_DIR="$1"

if [ ! -d "$SRC_DIR" ]; then
    echo "[!] Source directory not found: $SRC_DIR"
    exit 1
fi

missing=0
for dat in "${DAT_FILES[@]}"; do
    if [ ! -f "$SRC_DIR/$dat" ]; then
        echo "[!] Missing: $dat"
        missing=1
    fi
done

if [ $missing -eq 1 ]; then
    echo
    echo "One or more required DAT files are missing from the source directory."
    echo "You need the original game data from 東方紅魔郷 ~ the Embodiment of Scarlet Devil."
    exit 1
fi

echo "[*] Copying DAT files..."
for dat in "${DAT_FILES[@]}"; do
    cp -v "$SRC_DIR/$dat" "$SCRIPT_DIR/"
done

# Config file
if [ -f "$SRC_DIR/東方紅魔郷.cfg" ]; then
    echo "[*] Copying config file..."
    cp -v "$SRC_DIR/東方紅魔郷.cfg" "$SCRIPT_DIR/"
else
    echo "[*] No config file found, game will create one on first launch."
fi

# Font
FONT_SRC=""
if [ -f "$SRC_DIR/msgothic.ttc" ]; then
    FONT_SRC="$SRC_DIR/msgothic.ttc"
elif [ -f "$REPO_DIR/NotoSans-Regular.ttf" ]; then
    FONT_SRC="$REPO_DIR/NotoSans-Regular.ttf"
fi

if [ -n "$FONT_SRC" ]; then
    echo "[*] Copying font..."
    cp -v "$FONT_SRC" "$SCRIPT_DIR/msgothic.ttc"
else
    echo "[*] No font found. Place a TrueType font named 'msgothic.ttc' in the game directory."
fi

# Config tool
if [ -f "$REPO_DIR/th06_config" ]; then
    cp -v "$REPO_DIR/th06_config" "$SCRIPT_DIR/"
fi

echo
echo "=== Setup complete ==="
echo
echo "Run: cd game && ./th06"
echo "Configure: ./th06_config"
