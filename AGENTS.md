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
├── th06                            # Compiled game binary
├── th06_config                     # Configuration utility
└── AGENTS.md                       # This file

~/Downloads/[th06] 东方红魔乡 (汉化版)/  # Game runtime directory (Chinese version)
├── th06_portable                   # Copied from th06-portable repo
├── th06_config                     # Copied from th06-portable repo
├── msgothic.ttc                    # Copied from NotoSans-Regular.ttf (font)
├── *.DAT                           # Game resource files (required for running)
├── 東方紅魔郷.cfg                   # Game configuration
└── th06.exe                        # Original Chinese-patched EXE (not used)
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

## Run Instructions

```bash
cd "/Users/remi/Downloads/[th06] 东方红魔乡 (汉化版)"
./th06_portable
```

The config tool (`./th06_config`) allows switching between fullscreen/windowed mode, refresh rate, and color depth.

## What Was Deleted

- `~/Downloads/th06-master/` (~3.4G) — Decompilation project (master branch), including VS2002 devenv
- `~/.wineth06` (~335M) — Wine prefix created for the master branch build system

Both were artifacts from an initial attempt to run the Chinese-patched EXE via Wine (failed) and set up the decompilation build environment (not needed for portable).

## Git Remote Setup

```
origin  → https://github.com/GensokyoClub/th06.git  (upstream)
myrepo  → https://github.com/u-u-z/th06-portable.git (user's fork)
```

Current branch: `portable`.
