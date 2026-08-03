# cocos2d-x 3.0-oh Win32 编译构建完整指南

> 版本: 2.0  
> 日期: 2026-07-30  
> 项目: cocos2d-x-3.0-oh  
> 目标平台: Win32 (MSVC 2013 x86)  
> 状态: **编译通过，可正常运行**

---

## 目录

1. [环境要求](#1-环境要求)
2. [编译前依赖准备](#2-编译前依赖准备)
3. [快速开始（一键编译）](#3-快速开始一键编译)
4. [构建产物清单](#4-构建产物清单)
5. [CMake 构建配置](#5-cmake-构建配置)
6. [其他平台构建状态](#6-其他平台构建状态)
7. [踩坑记录（必读）](#7-踩坑记录必读)
8. [后续计划](#8-后续计划)

---

## 1. 环境要求

### 1.1 硬件要求

| 项目 | 最低要求 | 推荐配置 |
|------|---------|---------|
| CPU | 双核 x86 | 4 核以上 |
| 内存 | 4 GB | 8 GB+ |
| 磁盘 | 5 GB 可用 | 10 GB+ |

### 1.2 必备软件

| 工具 | 版本 | 说明 |
|------|------|------|
| **CMake** | 3.6+ | 构建系统生成器 |
| **Visual Studio** | 2013 (v120 toolset) | C++ 编译器与链接器 |
| **MSYS2/Mingw32** | 任意版本 | 提供运行时 DLL（`libgcc_s_dw2-1.dll`、`libwinpthread-1.dll`） |
| Git | 任意版本 | 版本控制 |

### 1.3 当前开发环境（已验证）

| 工具 | 版本 | 路径 |
|------|------|------|
| 操作系统 | Windows 10 Pro 22H2 (19045) | — |
| CPU | Intel Core i5-11600KF (6C12T) | — |
| 内存 | 32 GB | — |
| CMake | 3.10.0-rc1 | `D:\Program Files\CMake\bin` |
| MSVC | VS2013 (18.00.30723) | `D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin` |
| MSYS2 | — | `C:\msys64\mingw32\bin` |

---

## 2. 编译前依赖准备

编译 Win32 平台前，需确保以下三类依赖文件就位。

### 2.1 第一类：预编译链接库 (.lib)

> 链接阶段必须，共 13 个。

| 库文件 | 路径 | 用途 |
|--------|------|------|
| `libjpeg.lib` | `external/jpeg/prebuilt/win32/` | JPEG 图片解码（已改为静态库，从源码编译） |
| `libpng.lib` | `external/png/prebuilt/win32/` | PNG 图片解码 |
| `libtiff.lib` | `external/tiff/prebuilt/win32/` | TIFF 图片解码 |
| `libwebp.lib` | `external/webp/prebuilt/win32/` | WebP 图片解码 |
| `freetype.lib` / `freetype250.lib` | `external/freetype2/prebuilt/win32/` | FreeType 字体渲染 |
| `libcurl.lib` | `external/curl/prebuilt/win32/` | HTTP 网络请求 |
| `glfw3.lib` | `external/glfw3/prebuilt/win32/` | 窗口创建与 OpenGL 上下文 |
| `websockets.lib` | `external/websockets/prebuilt/win32/` | WebSocket 通信 |
| `glew32.lib` | `external/win32-specific/gles/prebuilt/` | OpenGL 扩展加载 |
| `zlib.lib` / `libzlib.lib` | `external/win32-specific/zlib/prebuilt/` | 数据压缩 |
| `libiconv.lib` | `external/win32-specific/icon/prebuilt/` | 字符编码转换 |
| `libssl.lib` | `external/openssl/prebuilt/win32/` | SSL/TLS 加密 |
| `libcrypto.lib` | `external/openssl/prebuilt/win32/` | 加密算法 |

### 2.2 第二类：运行时 DLL

> 运行 MH-Game.exe 必须，共 14 个核心 DLL。

| DLL 文件 | 来源路径 |
|----------|----------|
| `libpng16-16.dll` | `external/png/prebuilt/win32/` |
| `libtiff-6.dll` | `external/tiff/prebuilt/win32/` |
| `libwebp-7.dll` | `external/webp/prebuilt/win32/` |
| `libfreetype-6.dll` | `external/freetype2/prebuilt/win32/` |
| `libcurl-4.dll` | `external/curl/prebuilt/win32/` |
| `glfw3.dll` | `external/glfw3/prebuilt/win32/` |
| `libwebsockets.dll` | `external/websockets/prebuilt/win32/` |
| `glew32.dll` | `external/win32-specific/gles/prebuilt/` |
| `zlib1.dll` | `external/win32-specific/zlib/prebuilt/` |
| `libiconv-2.dll` | `external/win32-specific/icon/prebuilt/` |
| `libssl-1_1.dll` | `external/openssl/prebuilt/win32/` |
| `libcrypto-1_1.dll` | `external/openssl/prebuilt/win32/` |
| `libgcc_s_dw2-1.dll` | `C:/msys64/mingw32/bin/` |
| `libwinpthread-1.dll` | `C:/msys64/mingw32/bin/` |

> **注意**: `libjpeg-8.dll` 已不再需要。JPEG 库已从源码编译为静态库直接链接，消除了 DLL 版本不匹配问题。

### 2.3 第三类：源码级依赖

> 从源码编译为静态库，共 6 个。

| 目录 | 输出库 | 用途 |
|------|--------|------|
| `external/chipmunk/` | `chipmunk.lib` | 2D 物理引擎 |
| `external/tinyxml2/` | `tinyxml2.lib` | XML 解析 |
| `cocos/math/kazmath/` | `kazmath.lib` | 数学库（向量/矩阵/四元数） |
| `external/xxhash/` | `xxhash.lib` | 快速哈希算法 |
| `external/edtaa3func/` | 内置 | 距离场计算 |
| `external/unzip/` | `unzip.lib` | ZIP 文件解压 |

### 2.4 预编译库目录结构完整清单

```
external/
├── jpeg/prebuilt/win32/
│   └── libjpeg.lib          ← 静态库（从源码编译）
├── png/prebuilt/win32/
│   ├── libpng.lib
│   └── libpng16-16.dll
├── tiff/prebuilt/win32/
│   ├── libtiff.lib
│   └── libtiff-6.dll
├── webp/prebuilt/win32/
│   ├── libwebp.lib
│   └── libwebp-7.dll
├── freetype2/prebuilt/win32/
│   ├── freetype.lib / freetype250.lib
│   └── libfreetype-6.dll
├── curl/prebuilt/win32/
│   ├── libcurl.lib
│   └── libcurl-4.dll
├── glfw3/prebuilt/win32/
│   ├── glfw3.lib            ← MSYS2 mingw32 生成
│   └── glfw3.dll
├── websockets/prebuilt/win32/
│   ├── websockets.lib
│   └── libwebsockets.dll
├── openssl/prebuilt/win32/
│   ├── libssl.lib / libcrypto.lib
│   ├── libssl-1_1.dll / libcrypto-1_1.dll
├── win32-specific/
│   ├── gles/prebuilt/
│   │   ├── glew32.lib
│   │   └── glew32.dll
│   ├── zlib/prebuilt/
│   │   ├── zlib.lib / libzlib.lib
│   │   └── zlib1.dll
│   └── icon/prebuilt/
│       ├── libiconv.lib
│       ├── libiconv-2.dll
│       └── iconv.dll
├── chipmunk/                 ← 源码编译
├── tinyxml2/                 ← 源码编译
├── xxhash/                   ← 源码编译
├── unzip/                    ← 源码编译
└── edtaa3func/               ← 源码编译
```

**MSYS2 额外 DLL**:
```
C:/msys64/mingw32/bin/
├── libgcc_s_dw2-1.dll       ← GCC 运行时
└── libwinpthread-1.dll      ← POSIX 线程运行时
```

---

## 3. 快速开始（一键编译）

### 3.1 首次编译

```powershell
# 1. 进入项目根目录
cd g:\cocos2d-x-3.0-oh

# 2. 创建构建目录并生成 VS2013 解决方案
mkdir build\win32-msvc-vs2013-x86
cd build\win32-msvc-vs2013-x86
cmake ..\.. -G "Visual Studio 12 2013"

# 3. 编译 MH-Game（含所有依赖库）
cmake --build . --config Debug --target MH-Game -- /m /v:minimal

# 4. 运行
.\bin\MH-Game\Debug\MH-Game.exe
```

### 3.2 增量编译（仅编译修改过的文件）

```powershell
cd g:\cocos2d-x-3.0-oh\build\win32-msvc-vs2013-x86
cmake --build . --config Debug --target MH-Game -- /m /v:minimal
```

### 3.3 CMake 选项说明

| 选项 | 默认值 | 说明 |
|------|--------|------|
| `USE_CHIPMUNK` | ON | 使用 Chipmunk 物理引擎 |
| `USE_BOX2D` | OFF | 使用 Box2D 物理引擎 |
| `BUILD_LIBS_LUA` | OFF | 编译 Lua 脚本绑定 |
| `BUILD_GUI` | ON | 编译 GUI 模块 |
| `BUILD_NETWORK` | ON | 编译网络模块 |
| `BUILD_EXTENSIONS` | ON | 编译扩展模块 |
| `BUILD_EDITOR_SPINE` | ON | 编译 Spine 骨骼动画 |
| `BUILD_EDITOR_COCOSTUDIO` | ON | 编译 CocosStudio 支持 |
| `BUILD_EDITOR_COCOSBUILDER` | ON | 编译 CocosBuilder 支持 |
| `BUILD_CppTests` | ON | 编译 MH-Game 测试项目 |
| `BUILD_LuaTests` | OFF | 编译 Lua 测试项目 |

---

## 4. 构建产物清单

### 4.1 静态库（15 个）

```
build/win32-msvc-vs2013-x86/lib/Debug/
```

| 序号 | 库名 | 来源 | 说明 |
|------|------|------|------|
| 1 | `box2d.lib` | `external/Box2D` | Box2D 物理引擎（源码编译） |
| 2 | `chipmunk.lib` | `external/chipmunk/src` | Chipmunk 物理引擎（源码编译） |
| 3 | `cocos2d.lib` | `cocos/2d` | 核心 2D 引擎 |
| 4 | `cocosbase.lib` | `cocos/base` | 基础库 |
| 5 | `cocosbuilder.lib` | `cocos/editor-support/cocosbuilder` | CocosBuilder 编辑器支持 |
| 6 | `cocostudio.lib` | `cocos/editor-support/cocostudio` | CocosStudio 编辑器支持 |
| 7 | `extensions.lib` | `extensions` | 扩展模块 |
| 8 | `kazmath.lib` | `cocos/math/kazmath` | 数学库 |
| 9 | `network.lib` | `cocos/network` | 网络模块 |
| 10 | `spine.lib` | `cocos/editor-support/spine` | Spine 骨骼动画 |
| 11 | `tinyxml2.lib` | `external/tinyxml2` | XML 解析（源码编译） |
| 12 | `ui.lib` | `cocos/ui` | GUI 控件模块 |
| 13 | `unzip.lib` | `external/unzip` | ZIP 解压（源码编译） |
| 14 | `websockets.lib` | `external/libwebsockets-src` | WebSocket 通信（源码编译） |
| 15 | `xxhash.lib` | `external/xxhash` | 快速哈希（源码编译） |

### 4.2 可执行文件

```
build/win32-msvc-vs2013-x86/bin/MH-Game/Debug/
├── MH-Game.exe (8.3 MB)
├── MH-Game.pdb (调试符号)
├── *.dll (30+ 运行时依赖)
└── Resources/ (自动复制自 tests/cpp-tests/Resources/)
```

### 4.3 运行时 DLL 完整清单（30+ 个）

| 类别 | DLL 文件 | 用途 |
|------|---------|------|
| 窗口系统 | `glfw3.dll` | GLFW 窗口管理 |
| OpenGL | `glew32.dll` | OpenGL 扩展管理 |
| 图像 | `libpng16-16.dll`, `libtiff-6.dll`, `libwebp-7.dll` | 图像编解码（JPEG 已改为静态链接） |
| 字体 | `libfreetype-6.dll`, `libharfbuzz-0.dll`, `libgraphite2.dll`, `libglib-2.0-0.dll`, `libpcre2-8-0.dll` | FreeType 字体渲染 |
| 压缩 | `zlib1.dll`, `libbz2-1.dll`, `liblzma-5.dll`, `libzstd.dll` | 数据压缩 |
| 网络 | `libcurl-4.dll`, `libssh2-1.dll`, `libnghttp2-14.dll` | HTTP/HTTPS 网络通信 |
| 加密 | `libcrypto-3.dll`, `libssl-3.dll` | OpenSSL 加密 |
| 编码 | `libiconv-2.dll`, `libcharset-1.dll`, `libintl-8.dll` | 字符编码转换 |
| 运行时 | `libgcc_s_dw2-1.dll`, `libwinpthread-1.dll`, `libstdc++-6.dll` | MinGW/GCC 运行时 |

---

## 5. CMake 构建配置

### 5.1 构建目标平台

| 目标平台 | CMake 变量 | 状态 |
|---------|-----------|------|
| **Win32 (MSVC)** | `WIN32` + `MSVC` | **已完成** |
| Win32 (MinGW) | `WIN32` + `MINGW` | 阻塞 — 缺预编译库 |
| Android | `ANDROID` | 部分就绪 |
| OHOS | `OHOS` | 阻塞 — 缺 NDK |

### 5.2 环境变量

```powershell
# Win32 构建
$env:VS120COMNTOOLS = "D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\"

# Android 构建（待验证）
$env:ANDROID_HOME = "D:\Android\android-sdk-64"
$env:ANDROID_NDK_HOME = "D:\Android\android-sdk-64\ndk\16.1.4479499"
$env:JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_144"

# OHOS 构建（待安装）
$env:OHOS_SDK_HOME = "<DevEco Studio SDK 路径>"
$env:OHOS_NDK_HOME = "<OHOS Native NDK 路径>"
```

---

## 6. 其他平台构建状态

### 6.1 OHOS
- **状态**: 阻塞
- **原因**: 缺少 OHOS NDK 工具链
- **解决方案**: 安装 DevEco Studio，通过 SDK Manager 下载 OHOS SDK 和 Native NDK

### 6.2 Android
- **状态**: 部分就绪
- **工具链**: NDK r16b + SDK r24.1.2，已安装
- **待验证**: 预编译库兼容性

### 6.3 MinGW
- **状态**: 阻塞
- **原因**: GCC 15.2.0 版本过高，与预编译库 ABI 不兼容
- **解决方案**: 降级 GCC 或重新编译所有预编译库

---

## 7. 踩坑记录（必读）

> **重要**: 以下记录了编译构建过程中遇到的所有关键问题。每个问题包含：现象、根因、解决方案、预防措施。后续重构或维护前请务必参考此清单，避免重复踩坑。

---

### 踩坑 #1: 预编译库缺失 — Win32 平台完全无法编译

| 项目 | 内容 |
|------|------|
| **严重程度** | **阻塞级** |
| **现象** | CMake 配置时找不到 `glfw3.lib`、`glew32.lib`、`iconv.dll` 等预编译库，链接阶段报 LNK1181 错误 |
| **根因** | 原始预编译库文件被标记为 `.REMOVED.git-id`，导致库文件实际上不存在 |
| **解决方案** | 使用 MSYS2 mingw32 安装所有缺失的预编译库，并用 `gendef` + `lib.exe` 从 DLL 生成 `.lib` 导入库 |
| **预防措施** | 保留完整的预编译库清单；在 CMakeLists.txt 中添加库文件检查 |

**恢复步骤**:
```powershell
# 在 MSYS2 mingw32 终端中安装
pacman -S mingw-w64-i686-glfw mingw-w64-i686-glew mingw-w64-i686-libiconv
pacman -S mingw-w64-i686-libjpeg-turbo mingw-w64-i686-libpng
pacman -S mingw-w64-i686-libtiff mingw-w64-i686-libwebp
pacman -S mingw-w64-i686-freetype mingw-w64-i686-curl

# 从 DLL 生成 .lib 导入库
gendef glew32.dll
lib /machine:x86 /def:glew32.def /out:glew32.lib
```

---

### 踩坑 #2: libwebsockets 编译错误 — LWS_LIBRARY_VERSION 宏定义

| 项目 | 内容 |
|------|------|
| **严重程度** | **编译阻断级** |
| **现象** | MSVC 编译报错 `error C2001: newline in constant` |
| **根因** | `CMakeLists.txt` 中 `LWS_LIBRARY_VERSION="1.2"` 的引号被 MSVC 解释为字符串字面量的一部分 |
| **解决方案** | 移除引号：`LWS_LIBRARY_VERSION=1.2` |
| **修复位置** | `external/libwebsockets-src/CMakeLists.txt` 第 40 行 |

---

### 踩坑 #3: MH-Game.exe 启动断言失败 — config-example.plist 找不到

| 项目 | 内容 |
|------|------|
| **严重程度** | **运行阻断级** |
| **现象** | `Assertion failed: !dict.empty()` at CCConfiguration.cpp:273 |
| **根因** | `loadConfigFile` 时 FileUtils 搜索路径中不包含 `Resources/` 目录 |
| **解决方案** | 在 loadConfigFile 前添加 `fileUtils->addSearchPath("Resources")` |
| **修复位置** | `tests/cpp-tests/Classes/AppDelegate.cpp` 第 48-50 行 |

---

### 踩坑 #4: 启动黑屏 — setSearchPaths 覆盖 Resources 搜索路径

| 项目 | 内容 |
|------|------|
| **严重程度** | **运行阻断级** |
| **现象** | 启动后窗口黑屏，console 输出 `No file found at Images/close.png` |
| **根因** | `setSearchPaths` 会先 `clear()` 清空所有路径，导致之前添加的 `Resources` 路径丢失 |
| **解决方案** | 在 `setSearchPaths` 前将 `"Resources"` 追加到 `searchPaths` 向量末尾 |
| **修复位置** | `tests/cpp-tests/Classes/AppDelegate.cpp` 第 104-107 行 |

---

### 踩坑 #5: VS Code IntelliSense 报大量错误

| 项目 | 内容 |
|------|------|
| **严重程度** | **开发体验级** |
| **现象** | VS Code 中报 24 个 IntelliSense 错误，但代码实际编译 0 error |
| **根因** | VS Code C++ 扩展无法自动解析 CMakeLists.txt 中的 include 路径 |
| **解决方案** | 创建 `.vscode/c_cpp_properties.json`，手动配置 34 个 include 路径和 7 个宏定义 |
| **配置文件** | `.vscode/c_cpp_properties.json` |

---

### 踩坑 #6: PDB 文件写入失败 — LNK1201 错误

| 项目 | 内容 |
|------|------|
| **严重程度** | **编译阻断级** |
| **现象** | `LNK1201: error writing to program database` |
| **根因** | `mspdbsrv.exe` 进程残留持有 PDB 文件锁 |
| **解决方案** | 终止 `mspdbsrv.exe` 并删除残留 `.pdb` 文件 |
| **快速修复** | `taskkill /f /im mspdbsrv.exe` |

---

### 踩坑 #7: Git Submodule 错误

| 项目 | 内容 |
|------|------|
| **严重程度** | **版本控制级** |
| **现象** | `no submodule mapping found in .gitmodules` |
| **根因** | `external/libwebsockets-src/` 内残留 `.git` 目录 |
| **解决方案** | 删除 `external/libwebsockets-src/.git` 目录 |

---

### 踩坑 #8: GetCurrentDirectoryW 导致非 exe 目录运行失败

| 项目 | 内容 |
|------|------|
| **严重程度** | **运行阻断级** |
| **现象** | 从项目根目录运行 exe 时断言失败 |
| **根因** | `CCFileUtilsWin32.cpp` 使用 `GetCurrentDirectoryW` 获取资源根路径，而非 exe 路径 |
| **解决方案** | 替换为 `GetModuleFileNameW(NULL, ...)` 获取 exe 自身路径 |
| **修复位置** | `cocos/2d/platform/win32/CCFileUtilsWin32.cpp` 第 58-71 行 |

---

### 踩坑 #9: CreateFileW dwShareMode=0 导致并发字体加载失败

| 项目 | 内容 |
|------|------|
| **严重程度** | **运行错误级** |
| **现象** | 日志大量报 `error code is 32` (ERROR_SHARING_VIOLATION) |
| **根因** | `CreateFileW` 使用 `dwShareMode=0`（独占模式），并发加载 `arial.ttf` 时冲突 |
| **解决方案** | 将 `dwShareMode` 从 `0` 改为 `FILE_SHARE_READ` |
| **修复位置** | `cocos/2d/platform/win32/CCFileUtilsWin32.cpp` 第 157 行和第 232 行 |

---

### 踩坑 #10: clangd 找不到头文件

| 项目 | 内容 |
|------|------|
| **严重程度** | **开发体验级** |
| **现象** | VS Code 中 clangd 报 `'cocos2d.h' file not found` |
| **根因** | clangd 不读取 `.vscode/c_cpp_properties.json`，需要独立的 `.clangd` 配置文件 |
| **解决方案** | 创建 `.clangd` 配置文件，包含所有 include 路径和宏定义 |
| **配置文件** | `.clangd` |

---

### 踩坑 #11: JPEG 库版本不匹配

| 项目 | 内容 |
|------|------|
| **严重程度** | **运行错误级** |
| **现象** | `jpeg error: JPEG parameter struct mismatch: library thinks size is 448, caller expects 456` |
| **根因** | 预编译 `libjpeg-8.dll` 与项目头文件结构体大小不一致 |
| **解决方案** | 下载 libjpeg 8d 源码，编译为静态库 `libjpeg.lib`，直接链接消除 DLL 不匹配 |
| **修复位置** | `external/jpeg/prebuilt/win32/libjpeg.lib` |

---

## 8. 后续计划

### 阶段二：CMake 与工具链升级 (P1)

- 升级 CMake 到 3.28+ 正式版
- 添加 VS2022 构建支持
- 配置 x64 构建目标

### 阶段三：OHOS 编译环境搭建 (P0)

- 安装 DevEco Studio 和 OHOS SDK/NDK
- 编写 CMake 工具链文件
- 实现 OHOS 平台交叉编译

### 阶段四：Android 编译验证 (P1)

- 验证 NDK r16b 兼容性
- 执行 Android 编译 (armeabi-v7a)
- APK 打包验证

### 阶段五：完整构建验证与 CI 配置 (P2)

- 全平台全量编译验证
- 编写一键构建脚本
- 配置 GitHub Actions CI

---

## 附录

### 相关文档

- [外部依赖与扩展](./外部依赖与扩展.md) — 外部依赖库详细说明
- [编译构建实施计划](./编译构建实施计划.md) — 分阶段实施计划
- [编译构建环境评估报告](./编译构建环境评估报告.md) — 环境评估与踩坑详情
- [架构概览](./架构概览.md) — 项目整体架构说明

### 快速构建命令速查

```powershell
# 首次构建
cd g:\cocos2d-x-3.0-oh\build\win32-msvc-vs2013-x86
cmake ..\.. -G "Visual Studio 12 2013"
cmake --build . --config Debug --target MH-Game -- /m /v:minimal

# 增量构建
cmake --build . --config Debug --target MH-Game -- /m /v:minimal

# 运行
.\bin\MH-Game\Debug\MH-Game.exe

# 查看日志
cat .\bin\MH-Game\Debug\MH-Game.log
```