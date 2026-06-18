# QLizzie — Agent Guide

QLizzie is a Qt 6 desktop analysis GUI for Go, Gomoku, Hex, and related board games. It is inspired by LizzieYZY and is primarily tested against KataGo/KataGomo-style GTP engines that emit `kata-analyze` output.

This document is written for AI coding agents who need to understand, build, modify, or debug the project.

## Project overview

- **Language / framework**: C++17 with Qt 6 (Core + Quick). The UI is implemented in QML and most game logic lives in JavaScript/QML modules.
- **Build system**: CMake 3.24+.
- **License**: GNU General Public License v3.0 (see `LICENSE`).
- **Platforms**: Developed and packaged for Windows, but the CMake build is cross-platform and has been built on macOS (arm64) as well.
- **Repository**: `https://github.com/samecos/QLizzie.git`

The workspace contains two CMake targets:

1. **`qlizzie`** (`app/`) — the main Qt Quick application.
2. **`qlizzie_launcher`** (`launcher/`) — a tiny Windows-only launcher that starts `bin\qlizzie.exe` from a portable package root.

## Directory layout

```text
QLizzie/
├── CMakeLists.txt              # Workspace root: adds app/ and launcher/
├── app/
│   ├── CMakeLists.txt          # Main application target
│   ├── src/                    # C++ backend sources
│   │   ├── main.cpp            # Entry point, registers QML context objects
│   │   ├── enginecontroller.*  # GTP engine process management
│   │   ├── appsettings.*       # Persistent settings (settings.ini)
│   │   ├── fileio.*            # Text file read/write for QML
│   │   └── gomokuforbidden.*   # Gomoku forbidden-move detection
│   ├── qml/                    # QML UI and JS logic modules
│   │   ├── Main.qml            # Root ApplicationWindow and global state
│   │   ├── BoardScene.qml      # Board layout, sizing, and coordinates
│   │   ├── BoardInputLayer.qml # Mouse/touch input handling
│   │   ├── InfoPanel.qml       # Left analysis / candidate panel
│   │   ├── BranchPanel.qml     # Bottom game-tree panel
│   │   ├── AnalysisToolbar.qml
│   │   ├── CommandToolbar.qml
│   │   ├── SettingsDialog.qml
│   │   ├── EngineListDialog.qml
│   │   ├── *.js                # Helper libraries
│   │   └── rules/RuleCatalog.js
│   └── resources/              # Icons, fonts, Windows RC file
├── launcher/
│   ├── CMakeLists.txt
│   └── src/launcher.cpp        # Windows portable launcher
├── cmake/
│   └── PackagePortable.cmake   # Copies runtime files into a portable package
├── docs/images/                # Screenshots for README
├── README.md / README.zh-CN.md
└── LICENSE
```

## Technology stack and architecture

### C++ backend (`app/src/`)

Registered as QML context objects in `main.cpp`:

- **`engineController`** (`EngineController`) — wraps a `QProcess`, starts/stops the GTP engine, sends commands, parses `kata-analyze` info lines, and exposes candidate data as `QVariantList` properties. Also supports `genmove` requests.
- **`appSettings`** (`AppSettings`) — thin wrapper around `QSettings` backed by `settings.ini` located next to the executable (or portable package root).
- **`fileIo`** (`FileIo`) — exposes `readTextFile` / `writeTextFile` to QML for SGF load/save.
- **`gomokuForbidden`** (`GomokuForbidden`) — computes forbidden points for Gomoku rule variants (standard/Renju/Caro/etc.).

### QML/JS frontend (`app/qml/`)

The UI is single-window Qt Quick. `Main.qml` owns most global application state (board size, stones, game tree, candidates, settings). JavaScript modules (`.pragma library`) contain the bulk of the rules and helpers:

- `GameRules.js` — rule constants, move legality, captures, scoring, win detection for all supported games.
- `CandidateAnalysis.js` — formatting winrate, visits, score/draw-rate, candidate labels, and variation previews.
- `BoardRenderer.js` / `BoardVisuals.js` / `BoardInteraction.js` — rendering and input coordinate mapping.
- `SgfSession.js` / `SgfUtils.js` — SGF serialization and parsing.
- `SettingsStore.js` — loading, normalizing, and saving persistent settings.
- `EnginePresets.js` / `EngineSupport.js` — engine preset list and communication helpers.
- `Translations.js` — bilingual (zh/en) UI string table.
- `rules/RuleCatalog.js` — board presentation / Hex rotation option catalogs.

### Supported games

- Go
- Gomoku (freestyle, standard, Renju, Caro, direct-four, Caro-no-six)
- Hex
- Connect6
- Reversi
- Hexagonal Go variants (parallelogram, hexagon, triangle)
- Ataxx
- Breakthrough
- Free-grid (no rules)

## Build and run

### Prerequisites

- Qt 6 (Core + Quick modules; project setup requires Qt 6.8+)
- CMake 3.24 or newer
- A C++17 compiler (MSVC on Windows, Clang/GCC on macOS/Linux)

### Standard build

```bash
cmake -S . -B build/qlizzie
cmake --build build/qlizzie --config Release
```

On Windows the executable will be at `build/qlizzie/app/Release/qlizzie.exe`. On macOS an app bundle is produced at `build/qlizzie/app/qlizzie.app`.

### Portable Windows package

The `qlizzie_portable` target assembles a portable folder in `release/`:

```bash
cmake --build build/qlizzie --config Release --target qlizzie_portable
```

This copies `qlizzie.exe` into `release/bin/` and the launcher (`QLizzie.exe`) into `release/`. The launcher sets `QLIZZIE_LAUNCHED_BY_LAUNCHER=1` and `QLIZZIE_PORTABLE_ROOT`, then starts the inner executable. The main app refuses to run directly from `bin\qlizzie.exe` on Windows and shows a bilingual warning.

### QML lint targets

CMake generates `qmllint` targets automatically. You can run them with:

```bash
cmake --build build/qlizzie --target qlizzie_qmllint
```

## Development conventions

- **Code style**: Existing code is pragmatic and consistent within each language. C++ uses modern Qt idioms (`QStringLiteral`, signal/slot lambdas, `Q_INVOKABLE`). QML/JS uses 4-space indentation and mixed camelCase / PascalCase matching Qt conventions.
- **Language of comments**: Source comments and identifiers are in English. UI strings are bilingual (Chinese and English) via `Translations.js`.
- **No external package managers**: The project uses only Qt 6 and the C++ standard library. Do not add `package.json`, `Cargo.toml`, `pyproject.toml`, or similar unless explicitly requested.
- **Settings persistence**: Settings are stored in `settings.ini` next to the executable (or the portable root). `AppSettings` is the single point of persistence; QML code should call `appSettings.value()` / `appSettings.setValue()` / `appSettings.sync()`.
- **Engine communication**: All engine I/O goes through `EngineController`. Do not spawn processes from QML.

## Testing

There is currently **no automated test suite**. Manual testing typically involves:

1. Building the application.
2. Running it and configuring a KataGo/KataGomo engine preset.
3. Loading an SGF or placing stones and verifying that analysis candidates appear in the left panel.
4. Testing game-tree navigation, branch deletion, and SGF save/load.

When adding logic in `GameRules.js`, `SgfUtils.js`, or `CandidateAnalysis.js`, verify manually with the relevant rule mode (Go, Gomoku, Hex, etc.) and both Chinese and English UI languages.

## Deployment and release

- The primary release artifact is a Windows portable package built via the `qlizzie_portable` target.
- `windeployqt` is invoked automatically when available to satisfy Qt runtime dependencies.
- The `.gitignore` excludes `/build/`, `/release/`, `/gtp_logs/`, `/ref_lizzie3d/`, and temporary handoff files.

## Security considerations

- The engine command line is user-configurable and executed through `QProcess`. Do not run untrusted engine presets.
- `settings.ini` is written next to the executable; on shared systems ensure the directory permissions are appropriate.
- GTP logs may be written to `gtp_logs/` depending on user settings; this directory is gitignored.

## Useful references

- `README.md` / `README.zh-CN.md` — user-facing feature overview and screenshots.
- `app/CMakeLists.txt` — authoritative list of source files and QML modules.
- `app/qml/Main.qml` — root application state and menu actions.
- `app/src/enginecontroller.h` — engine API exposed to QML.
- `app/qml/GameRules.js` — rule/mode constants and core game logic.
