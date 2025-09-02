#!/bin/bash

# AI赢标助手 WPS环境切换工具 - 多平台构建脚本

set -e

echo "🚀 开始构建 AI赢标助手 WPS环境切换工具..."

# 加载Rust环境
echo "📦 加载Rust环境..."
source "$HOME/.cargo/env"

# 检查依赖
if ! command -v cargo &> /dev/null; then
    echo "❌ 错误: 未找到 Rust/Cargo，请先安装 Rust"
    echo "💡 安装命令: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ 错误: 未找到 npm，请先安装 Node.js"
    exit 1
fi

# 安装前端依赖
echo "📦 安装前端依赖..."
npm install

# 创建dist目录
mkdir -p dist/{macos,windows,linux}

# 构建当前平台
echo "🔨 构建当前平台 ($(uname -s))..."
npm run tauri:build

# 复制构建产物
echo "📦 整理构建产物..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    cp -r src-tauri/target/release/bundle/macos/*.app dist/macos/
    if [ -d "src-tauri/target/release/bundle/dmg" ]; then
        cp -r src-tauri/target/release/bundle/dmg/*.dmg dist/macos/
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows
    cp -r src-tauri/target/release/bundle/msi/*.msi dist/windows/
else
    # Linux
    cp -r src-tauri/target/release/bundle/deb/*.deb dist/linux/
    cp -r src-tauri/target/release/bundle/appimage/*.AppImage dist/linux/
fi

echo "✅ 构建完成！"
echo "📁 构建产物位置:"
ls -la dist/

# 显示文件大小
echo ""
echo "📊 文件大小:"
find dist -type f -exec du -h {} \;