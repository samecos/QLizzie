# QLizzie

QLizzie is a Qt 6 desktop analysis interface with a fixed 2D board, Lizzie-style side panels, SGF support, game-tree navigation, and GTP engine analysis.

## Build

```powershell
cmake -S . -B build\qlizzie -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="C:\Qt\6.10.3\msvc2022_64"
cmake --build build\qlizzie --config Release
```
