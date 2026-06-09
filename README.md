# QLizzie | [中文版](README.zh-CN.md)

QLizzie is a Qt 6 AI analysis interface for Go and Gomoku, with functionality and visual style inspired by LizzieYZY.

![QLizzie screenshot](docs/images/screenshot-main.png)

## Overview

QLizzie is a desktop analysis board built with Qt 6. It focuses on a clean 2D board, engine candidate visualization, a Lizzie-like left analysis panel, and a game tree workflow for reviewing variations.

The project references LizzieYZY for feature direction and visual behavior, but it is a separate Qt 6 implementation. It was built through an iterative Codex vibe-coding workflow.

## Features

- Go and Gomoku analysis modes
- Fixed 2D board with scalable coordinates, stones, move numbers, and candidate markers
- GTP engine integration, including KataGo-style `kata-analyze`
- Candidate list, winrate, visits, score/draw-rate display, ranking labels, and variation preview
- Per-node analysis cache in the game tree for previously analyzed positions
- Game tree navigation, node deletion, branch handling, and SGF loading/saving
- Engine communication log
- English and Chinese UI

## Build

Requirements:

- Qt 6
- CMake
- A C++17-capable compiler, such as MSVC on Windows

Example build:

```powershell
cmake -S . -B build/qlizzie
cmake --build build/qlizzie --config Release
```

The executable is generated under the selected build directory, for example:

```text
build/qlizzie/app/Release/qlizzie.exe
```

## Engine

QLizzie communicates with a GTP-compatible AI engine. The default command can be edited from the engine settings panel.

For KataGo-style analysis, use an engine command that starts GTP mode and points to your config and model files.

## Relationship To LizzieYZY

QLizzie is not LizzieYZY and is not affiliated with the LizzieYZY project. LizzieYZY is used as a reference for the expected analysis workflow, candidate display behavior, and overall interface feel.

## License

QLizzie is released under the GNU General Public License v3.0. See [LICENSE](LICENSE).
