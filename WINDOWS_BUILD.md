# Windows 打包指南

## 🪟 Windows 打包方案

### 方案一：在 Windows 环境中直接打包（推荐）

#### 1. 环境准备

**安装 Rust**：
```powershell
# 方法1：使用 winget
winget install Rustlang.Rustup

# 方法2：访问官网下载
# https://rustup.rs/
```

**安装 Node.js**：
```powershell
# 方法1：使用 winget
winget install OpenJS.NodeJS

# 方法2：访问官网下载
# https://nodejs.org/
```

**安装 Visual Studio Build Tools**（必需）：
```powershell
# 方法1：使用 winget
winget install Microsoft.VisualStudio.2022.BuildTools

# 方法2：下载 Build Tools
# https://visualstudio.microsoft.com/visual-cpp-build-tools/
# 安装时选择 "C++ build tools" 工作负载
```

**安装 Tauri CLI**：
```powershell
npm install -g @tauri-apps/cli
```

#### 2. 项目准备

将项目复制到 Windows 机器：

```powershell
# 方法1：使用 git
git clone <你的项目仓库地址>
cd install-tauri

# 方法2：直接复制文件
# 将整个 install-tauri 文件夹复制到 Windows 机器
```

#### 3. 安装依赖并打包

```powershell
# 安装前端依赖
npm install

# 打包 Windows 版本
npm run tauri build
```

#### 4. 打包结果

打包成功后，Windows 安装包位于：
```
src-tauri\target\release\bundle\msi\
├── AI赢标助手-WPS环境切换工具_0.1.0_x64_en-US.msi
└── AI赢标助手-WPS环境切换工具_0.1.0_x64_zh-CN.msi
```

以及便携版本：
```
src-tauri\target\release\bundle\nsis\
└── AI赢标助手-WPS环境切换工具-x64_0.1.0.exe
```

### 方案二：使用 GitHub Actions 自动打包

#### 1. 创建 GitHub Actions 工作流

在项目根目录创建 `.github/workflows/build.yml`：

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:

jobs:
  build:
    strategy:
      fail-fast: false
      matrix:
        platform: [windows-latest, macos-latest, ubuntu-latest]
    
    runs-on: ${{ matrix.platform }}
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        
    - name: Install Rust (Windows)
      if: matrix.platform == 'windows-latest'
      uses: dtolnay/rust-toolchain@stable
      with:
        targets: x86_64-pc-windows-msvc
        
    - name: Install Rust (macOS)
      if: matrix.platform == 'macos-latest'
      uses: dtolnay/rust-toolchain@stable
      
    - name: Install Rust (Linux)
      if: matrix.platform == 'ubuntu-latest'
      uses: dtolnay/rust-toolchain@stable
      
    - name: Install dependencies (Windows)
      if: matrix.platform == 'windows-latest'
      run: |
        npm install
        choco install nsis
        
    - name: Install dependencies (macOS/Linux)
      if: matrix.platform != 'windows-latest'
      run: npm install
      
    - name: Build Tauri app
      uses: tauri-apps/tauri-action@v0
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tagName: v__VERSION__ # the action automatically replaces \_\_VERSION\_\_ with the git tag
        releaseName: 'AI赢标助手 v__VERSION__'
        releaseBody: 'See the assets to download this version and install.'
        releaseDraft: true
        prerelease: false
        
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: ${{ matrix.platform }}-bundle
        path: |
          src-tauri/target/release/bundle/*
```

#### 2. 使用方法

```bash
# 提交并推送到 GitHub
git add .
git commit -m "添加 GitHub Actions 自动打包"
git push

# 创建版本标签并推送
git tag v1.0.0
git push origin v1.0.0
```

### 方案三：使用 WSL（Windows Subsystem for Linux）

#### 1. 安装 WSL
```powershell
wsl --install
```

#### 2. 在 WSL 中设置环境
```bash
# 更新包管理器
sudo apt update && sudo apt upgrade

# 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# 安装 Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装 Windows 交叉编译工具
sudo apt-get install -y mingw-w64
rustup target add x86_64-pc-windows-gnu
```

#### 3. 打包
```bash
npm install
npm run tauri build --target x86_64-pc-windows-gnu
```

## 🎯 推荐方案

**最佳选择**：方案一（在 Windows 环境中直接打包）
- ✅ 最稳定，兼容性最好
- ✅ 官方支持，问题最少
- ✅ 可以直接测试 Windows 版本

**自动化选择**：方案二（GitHub Actions）
- ✅ 自动打包所有平台
- ✅ 版本管理自动化
- ✅ 适合持续集成/持续部署

## 📋 Windows 打包后的产物

- **MSI 安装包**：标准 Windows 安装程序
- **NSIS 便携版**：单个 exe 文件，无需安装
- **版本支持**：Windows 7+ (x64)
- **文件大小**：约 8-12 MB（取决于依赖）

## 🔧 常见问题解决

1. **链接错误**：确保安装了 Visual Studio Build Tools
2. **权限问题**：以管理员身份运行命令提示符
3. **依赖问题**：运行 `npm install` 清理并重新安装依赖
4. **Tauri 版本**：确保 `@tauri-apps/cli` 版本与项目一致