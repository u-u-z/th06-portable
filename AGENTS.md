# Project: Touhou 06 (EoSD) Portable

This is the `portable` branch of [GensokyoClub/th06](https://github.com/GensokyoClub/th06), a decompilation and cross-platform port of 東方紅魔郷 ~ the Embodiment of Scarlet Devil (1.02h) by Team Shanghai Alice.

## Overview

- **Portable branch**: Replaces DirectX 8 with SDL2 + OpenGL for native cross-platform support (macOS, Linux, Windows).
- **Game data**: Uses original `.DAT` resource files alongside the compiled binary.
- The `master` branch (decompilation project) is NOT needed and was deleted from this machine.

## Current Machine Environment

- **Platform**: macOS (Apple Silicon, M4 Pro)
- **Compiler**: Apple Clang (Xcode Command Line Tools)
- **Dependencies installed via Homebrew**: `sdl2`, `sdl2_image`, `sdl2_ttf`, `premake`
- **Wine**: Installed but not needed for portable branch (was used for master branch devenv setup)

## Directory Layout

```
~/Downloads/th06-portable/          # This repo (source + build)
├── src/                            # C++ source code
├── src/graphics/                   # Rendering backends
│   ├── FixedFunctionGL.cpp/hpp     # OpenGL 1.3 fixed-function backend
│   ├── WebGL.cpp/hpp               # OpenGL ES 2.0 / GL 2.1 shader backend (default)
│   └── Software.cpp/hpp            # Software renderer fallback
├── build/                          # Build output directory
├── premake5.lua                    # Build system configuration
├── th06                            # Compiled game binary (in-tree)
├── th06_config                     # Configuration utility (in-tree)
├── setup.sh                        # One-click: download release → extract → merge → run
├── game/                           # Runtime directory (after setup.sh)
│   ├── th06, th06_config           # Binary copied from build or downloaded
│   ├── 紅魔郷*.DAT                  # Game data (gitignored)
│   ├── 東方紅魔郷.cfg               # Config (gitignored)
│   └── msgothic.ttc                # Font (gitignored)
├── README.md
├── COPYRIGHT.md
└── AGENTS.md                       # This file
```

## Key Modification: Fullscreen Viewport Scaling Fix

**Problem**: On macOS Retina displays, fullscreen mode created a 640×480 window using `SDL_WINDOW_FULLSCREEN`, rendering the game content in the bottom-left corner of the screen.

**Fix** (committed to this repo):
- Changed `SDL_WINDOW_FULLSCREEN` → `SDL_WINDOW_FULLSCREEN_DESKTOP` in both `WebGL.cpp` and `FixedFunctionGL.cpp`
- After window creation, query actual drawable size via `SDL_GL_GetDrawableSize()`
- Compute a centered 4:3 viewport scale factor
- `SetViewport()` and `GetViewport()` apply scale + offset to map game coordinates (640×480) to the scaled centered area
- Added `viewportScale`, `viewportOffsetX`, `viewportOffsetY` member variables to both backend classes

**Files changed**:
- `src/graphics/WebGL.cpp` — lines in `Create()` and `SetViewport()`/`GetViewport()`
- `src/graphics/WebGL.hpp` — added 3 member variables
- `src/graphics/FixedFunctionGL.cpp` — same changes (backup backend)
- `src/graphics/FixedFunctionGL.hpp` — same 3 member variables

**Note**: `ReadPixels()` was intentionally left unscaled to avoid buffer size mismatches. If texture capture issues arise, revisit.

## Build Instructions

```bash
cd ~/Downloads/th06-portable
premake5 gmake          # Generate Makefile
cd build && make -j16   # Compile
```

The binary is produced at `~/Downloads/th06-portable/th06`.

After building, copy the binary into `game/` for distribution:

```bash
cp th06 th06_config game/
```

## Setup / Release Flow

The repo provides two paths to get the game running:

### Path A: Pre-built binary (end user)

```bash
./setup.sh       # Downloads release archives from GitHub, extracts, merges
cd game && ./th06
```

`setup.sh` does NOT compile anything — it downloads two pre-built `.tar.gz` archives from [GitHub Releases](https://github.com/u-u-z/th06-portable/releases):

| Archive | Contents |
|---------|----------|
| `th06-chs-macos.tar.gz` (308 MB) | Game data: DAT files, config, font |
| `th06-portable-macos.tar.gz` (8.6 MB) | Pre-compiled `th06` + `th06_config` binaries |

It extracts both into `game/`, giving a ready-to-run directory.

### Path B: Build from source (developer)

```bash
premake5 gmake && cd build && make -j16
cp th06 th06_config game/
./game/setup.sh "/path/to/original/game"   # Copies DAT from user's copy
cd game && ./th06
```

`game/setup.sh` copies DAT files from a user-provided game directory (does not download anything).

### Creating a new release

After making code changes:

```bash
premake5 gmake && cd build && make -j16
cp th06 th06_config game/
cd game && tar -czf ../th06-portable-macos.tar.gz th06 th06_config
cd .. && gh release create v1.1 th06-portable-macos.tar.gz --repo u-u-z/th06-portable
```

Update `TAG` in `setup.sh` to point to the new release.

## Run Instructions

```bash
cd game && ./th06
```

The config tool (`./th06_config`) allows switching between fullscreen/windowed mode, refresh rate, and color depth.

## Game Directory (`game/`)

```
game/
├── th06              # Pre-built game binary (macOS arm64) — committed to git
├── th06_config       # Configuration utility — committed to git
├── setup.sh          # Copies DAT files from user's original game directory
├── .gitignore        # Excludes copyrighted DAT files from git
├── 紅魔郷*.DAT        # After running setup.sh (gitignored, copyright ZUN)
├── 東方紅魔郷.cfg     # After running setup.sh (gitignored)
└── msgothic.ttc      # After running setup.sh (gitignored)
```

DAT files are NOT in git. They are either:
- Downloaded via root `setup.sh` from GitHub Releases (end user)
- Copied via `game/setup.sh <dir>` from a local game copy (developer)

## What Was Deleted

- `~/Downloads/th06-master/` (~3.4G) — Decompilation project (master branch), including VS2002 devenv
- `~/.wineth06` (~335M) — Wine prefix created for the master branch build system

Both were artifacts from an initial attempt to run the Chinese-patched EXE via Wine (failed) and set up the decompilation build environment (not needed for portable).

## Git Remote Setup

```
origin  → https://github.com/GensokyoClub/th06.git  (upstream)
myrepo  → https://github.com/u-u-z/th06-portable.git (user's fork)
```

Current branch: `main`.

### Upstream

This fork is based on the `portable` branch of [GensokyoClub/th06](https://github.com/GensokyoClub/th06). The upstream repo has two branches:

| Branch | Purpose |
|--------|---------|
| `master` | Decompilation project — reverse-engineer the original EXE (not used here) |
| `portable` | Cross-platform port using SDL2/OpenGL (this fork's base) |

The `portable` branch shares C++ game logic with `master`, but replaces the rendering/audio/input layer.

### Checking for upstream updates

```bash
git fetch origin
git log main..origin/portable --oneline   # see what's new upstream
git merge origin/portable                   # merge upstream changes
```

The main modification on this fork (fullscreen Retina fix in `src/graphics/`) may conflict if upstream changes the same files. Resolve conflicts manually if needed.

## PBG3 Format (DAT files)

All `.DAT` files are compressed with PBG3, ZUN's custom bit-level compression format. Implementation in `src/pbg3/`.

### DAT file inventory

| DAT file | Size | Contents |
|----------|------|----------|
| `紅魔郷CM.DAT` | 935 KB | ANM sprite/animation definitions — textures, sprite UV coords, animation scripts |
| `紅魔郷ED.DAT` | 2.1 MB | Ending sequence data |
| `紅魔郷IN.DAT` | 980 KB | ECL enemy scripts — bullet patterns, stage configuration |
| `紅魔郷MD.DAT` | 1.2 MB | Audio — MIDI sequences + WAV samples |
| `紅魔郷ST.DAT` | 3.3 MB | Stage data — backgrounds, enemy placement, layout |
| `紅魔郷TL.DAT` | 1.3 MB | Title screen data |

### File structure

```
┌─ Magic "PBG3" (4 bytes, 0x33474250)
├─ Compressed bitstream
│   ├─ Entries prefixed by name string (ReadString)
│   ├─ Variable-length integers (ReadVarInt)
│   └─ Raw binary blocks (ReadByteAlignedData)
└─ CRC checksum
```

### Core algorithm

**VarInt (variable-length integer)**

Reads 2 header bits to determine the integer's bit width, then reads the value:
```
00 → 8-bit   (0 to 255)
01 → 16-bit  (0 to 65535)
10 → 24-bit  (0 to 16.7M)
11 → 32-bit
```

This is the main space-saving mechanism — most game data (coordinates, IDs, frame counts) are small values that fit in 8 or 16 bits, but the format can store 32-bit values when needed. No dictionary, no Huffman trees, no back-references.

**Bit-level reading**

The parser consumes the stream one bit at a time via `bitIdxInCurByte` (0x80 → 1 → 0x80 cyclic). Each byte from disk is read only when the previous one is fully consumed:

```
byte:   [b7 b6 b5 b4 b3 b2 b1 b0]
         ↑                   ↓
         bitIdx=0x80    bitIdx=1
```

Adjacent fields don't need byte alignment — a 3-bit flag followed by a 15-bit value uses only 18 bits total, not 4 bytes.

**ReadInt(n)**

Reads `n` bits MSB-first, where `n` is passed as a power-of-two exponent (e.g., ReadInt(8) reads 8 bits, ReadInt(3) reads 8 bits via 2^3=8). Used for reading magic numbers, filenames, and known-width fields.

**SeekToNextByte()**

Skips remaining bits in the current byte (discards partial byte) to align to byte boundary. Used before ReadByteAlignedData which reads raw uncompressed binary (texture pixels, WAV audio, etc.).

### Why no standard compression

ZUN wrote this himself to avoid external library dependencies. The game was built with Visual Studio 2002 and no package manager existed. PBG3 is ~200 lines of C++ (src/pbg3/IPbg3Parser.cpp + Pbg3Parser.cpp). It achieves good compression on game data because:
- Most values are small integers (coordinates, IDs, counts)
- Texture names are short repeated strings
- Pixel data and audio remain uncompressed within the stream
