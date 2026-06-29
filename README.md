# th06-portable

A fork of [GensokyoClub/th06](https://github.com/GensokyoClub/th06) `portable` branch — a cross-platform port of Touhou 6: The Embodiment of Scarlet Devil using SDL2 and OpenGL.

## Upstream

| Branch | Repo | Purpose |
|--------|------|---------|
| `master` | [GensokyoClub/th06](https://github.com/GensokyoClub/th06) | Decompilation — reverse-engineer the original EXE byte-for-byte |
| `portable` | [GensokyoClub/th06](https://github.com/GensokyoClub/th06) (portable branch) | Cross-platform port using SDL2/OpenGL |

## How This Fork Differs from Upstream

This fork includes a fix for **fullscreen rendering on macOS Retina (HiDPI) displays**. The upstream portable branch creates a 640×480 fullscreen window via `SDL_WINDOW_FULLSCREEN`, which renders the game content in the bottom-left corner on high-resolution screens. This fork uses `SDL_WINDOW_FULLSCREEN_DESKTOP` with proper viewport scaling to center and fill the display while maintaining the original 4:3 aspect ratio.

See [AGENTS.md](AGENTS.md) for full technical details and local setup notes.

## Requirements

- SDL2, SDL2_image, SDL2_ttf
- C++20 compiler
- OpenGL 1.3+ or GL ES 2.0+

## Build

```bash
premake5 gmake
cd build && make -j$(nproc)
```

### macOS (Homebrew)

```bash
brew install premake sdl2 sdl2_image sdl2_ttf
premake5 gmake
cd build && make -j16
```

### Debian/Ubuntu

```bash
sudo apt install build-essential libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libasound2-dev
premake5 gmake
cd build && make -j16
```

## Usage

Drop the compiled `th06` binary into your Touhou 6 game directory alongside the original `.DAT` resource files, `東方紅魔郷.cfg`, and a `msgothic.ttc` font file (e.g., NotoSans-Regular.ttf renamed).

Run `th06_config` to adjust fullscreen/windowed mode, refresh rate, and color depth.

## Credits

This project exists thanks to the [GensokyoClub](https://github.com/GensokyoClub) decompilation team. See the [upstream README](https://github.com/GensokyoClub/th06) for full credits.
