# th06-portable

Native macOS (Apple Silicon) port of Touhou 6: The Embodiment of Scarlet Devil.

A fork of [GensokyoClub/th06](https://github.com/GensokyoClub/th06) `portable` branch, with fixes for macOS Retina fullscreen rendering and a one-click setup script.

## Quick Start

```bash
git clone https://github.com/u-u-z/th06-portable.git
cd th06-portable
./setup.sh
cd game && ./th06
```

Requires: macOS (Apple Silicon), `gh` CLI ([install](https://cli.github.com)).

## What This Is

The original 東方紅魔郷 (2002) runs on Windows via DirectX 8. This project replaces the rendering, audio, and input layers with SDL2 + OpenGL so it runs natively on macOS, Linux, and Windows — no Wine, no emulation.

## Upstream

| Repo | Branch | Purpose |
|------|--------|---------|
| [GensokyoClub/th06](https://github.com/GensokyoClub/th06) | `master` | Decompilation: reverse-engineer the original EXE byte-for-byte |
| [GensokyoClub/th06](https://github.com/GensokyoClub/th06) | `portable` | Cross-platform port using SDL2/OpenGL (this fork's base) |

The C++ game logic (bullet patterns, enemy AI, stage data parsing) is identical between both branches — they share the same decompiled code. The `portable` branch only swaps out the platform-specific layers.

## Fork Improvements

- **macOS Retina fullscreen fix**: Upstream renders at 640×480 in the bottom-left corner on HiDPI displays. This fork uses `SDL_WINDOW_FULLSCREEN_DESKTOP` with viewport scaling to center and fill the screen at proper 4:3 aspect ratio.
- **One-click setup**: `./setup.sh` downloads a pre-built binary and game data from GitHub Releases — no compilation required.
- **Documentation**: AGENTS.md covers the full project state, build steps, PBG3 format internals, and release workflow.

See [AGENTS.md](AGENTS.md) for technical details.

## Setup (End User)

```bash
./setup.sh       # Downloads from GitHub Releases (~317 MB), extracts, merges
cd game && ./th06
```

`setup.sh` fetches two archives:

| File | Size | Contents |
|------|------|----------|
| `th06-chs-macos.tar.gz` | 308 MB | Game data: DAT resource files, config, font |
| `th06-portable-macos.tar.gz` | 8.6 MB | Pre-compiled `th06` + `th06_config` for macOS arm64 |

They are extracted into the `game/` directory and merged — the result is a self-contained, ready-to-run game folder.

To switch between fullscreen and windowed mode, run `./th06_config`.

## Build from Source

### macOS

```bash
# Install dependencies
brew install premake sdl2 sdl2_image sdl2_ttf

# Compile
premake5 gmake
cd build && make -j16

# Prepare runtime
cp th06 th06_config game/
./game/setup.sh "/path/to/original/game"
cd game && ./th06
```

### Debian / Ubuntu

```bash
sudo apt install build-essential premake5 libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libasound2-dev
premake5 gmake
cd build && make -j$(nproc)
```

### Windows

Install MSYS2, then install SDL2 via pacman and build with premake + make.

## Project Structure

```
th06-portable/
├── src/                    # C++ source (decompiled game logic)
│   ├── graphics/           # SDL2/OpenGL rendering backends
│   ├── pbg3/               # PBG3 archive parser (DAT files)
│   └── Config/             # th06_config utility
├── game/                   # Runtime directory
│   ├── th6                 # Game binary
│   ├── th06_config         # Configuration tool
│   └── setup.sh            # Copies DAT from user's original game
├── build/                  # Build output (gitignored)
├── premake5.lua            # Build system config
├── setup.sh                # One-click download + setup
├── COPYRIGHT.md            # License & copyright info
├── AGENTS.md               # Full project documentation
└── README.md               # This file
```

## Game Data (DAT Files)

The game reads six PBG3-compressed resource files:

| File | Size | Contents |
|------|------|----------|
| `紅魔郷CM.DAT` | 935 KB | Sprites, textures, animation scripts |
| `紅魔郷ED.DAT` | 2.1 MB | Ending sequences |
| `紅魔郷IN.DAT` | 980 KB | Enemy scripts (ECL) |
| `紅魔郷MD.DAT` | 1.2 MB | Music and sound effects |
| `紅魔郷ST.DAT` | 3.3 MB | Stage backgrounds, layouts |
| `紅魔郷TL.DAT` | 1.3 MB | Title screen assets |

PBG3 is ZUN's custom bit-level compression format. See AGENTS.md for a full breakdown.

## Configuration

`th06_config` provides a GUI for:

- **Screen Mode**: Fullscreen or Windowed
- **Refresh Rate**: 1/1, 1/2, or 1/3
- **Colors**: 32-bit or 16-bit

Settings are saved to `東方紅魔郷.cfg`.

## License

Source code is derived from [GensokyoClub/th06](https://github.com/GensokyoClub/th06) and licensed under [CC0-1.0](https://creativecommons.org/publicdomain/zero/1.0/).

Game data (DAT files, artwork, music) is copyright (c) Team Shanghai Alice / ZUN. This repository does not include them. See [COPYRIGHT.md](COPYRIGHT.md).

## Credits

This project exists thanks to the [GensokyoClub](https://github.com/GensokyoClub) decompilation team. See the [upstream repository](https://github.com/GensokyoClub/th06) for full contributor credits.
