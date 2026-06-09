# QLizzie

QLizzie 是一个 Qt 6 桌面分析界面，使用固定二维棋盘，并保留 Lizzie 风格的左右面板、SGF 读写、棋谱树导航和 GTP 引擎分析。

## 编译

```powershell
cmake -S . -B build\qlizzie -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="C:\Qt\6.10.3\msvc2022_64"
cmake --build build\qlizzie --config Release
```
