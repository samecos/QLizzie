# QLizzie

QLizzie 是一个基于 Qt 6 的围棋和五子棋 AI 分析界面，功能和样式方面参考了 LizzieYZY。

![QLizzie 截图](docs/images/screenshot-main.png)

## 简介

QLizzie 是一个桌面分析棋盘程序，重点是干净的 2D 棋盘、引擎选点显示、类似 Lizzie 的左侧分析栏，以及用于复盘变化的游戏树工作流。

本项目在功能方向和视觉行为上参考了 LizzieYZY，但它是一个独立的 Qt 6 实现。本项目基于 Codex vibe coding 的迭代方式构建。

## 功能

- 支持围棋和五子棋分析模式
- 2D 棋盘，支持坐标、棋子、手数、选点标记缩放显示
- GTP 引擎集成，支持 KataGo 风格的 `kata-analyze`
- 选点列表、胜率、计算量、目差/和棋率、排名标号、变化图预览
- 棋谱树节点级分析缓存，回到分析过的局面时可以先显示缓存选点
- 游戏树导航、删除节点、分支处理、SGF 读取和保存
- 引擎通信日志
- 中英双语界面

## 构建

依赖：

- Qt 6
- CMake
- 支持 C++17 的编译器，例如 Windows 上的 MSVC

示例构建命令：

```powershell
cmake -S . -B build/qlizzie
cmake --build build/qlizzie --config Release
```

可执行文件会生成在你选择的构建目录中，例如：

```text
build/qlizzie/app/Release/qlizzie.exe
```

## 引擎

QLizzie 通过 GTP 协议和 AI 引擎通信。默认启动命令可以在引擎设置面板中修改。

如果使用 KataGo 风格分析，请使用能启动 GTP 模式，并指向你的配置文件和模型文件的引擎命令。

## 与 LizzieYZY 的关系

QLizzie 不是 LizzieYZY，也不隶属于 LizzieYZY 项目。LizzieYZY 是本项目在分析工作流、选点显示行为和整体界面感觉上的参考项目。

## 开源协议

QLizzie 使用 GNU General Public License v3.0 开源。详见 [LICENSE](LICENSE)。
