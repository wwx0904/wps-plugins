#!/bin/bash

# AI赢标助手 WPS环境切换工具 - Tauri版本构建脚本

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

# 开发模式
if [ "$1" = "dev" ]; then
    echo "🔧 启动开发模式..."
    npm run tauri:dev
    exit 0
fi

# 构建当前平台
if [ "$1" = "build" ] || [ -z "$1" ]; then
    echo "🔨 构建当前平台..."
    npm run tauri:build
    echo "✅ 构建完成！检查 src-tauri/target/release/bundle/ 目录"
    exit 0
fi

# 构建所有平台
if [ "$1" = "build-all" ]; then
    echo "🔨 构建所有平台..."
    
    # 检查是否有交叉编译能力
    echo "注意: 交叉编译可能需要额外的工具和配置"
    echo "建议在对应平台上分别构建以获得最佳结果"
    
    npm run tauri:build
    echo "✅ 构建完成！"
    exit 0
fi

# 构建特定平台
if [ "$1" = "build-windows" ]; then
    echo "🔨 构建 Windows 版本..."
    echo "⚠️  注意: 需要 Windows 环境或交叉编译工具链"
    echo "💡 建议在 Windows 机器上使用 build-windows.bat 脚本"
    echo "📖 查看 WINDOWS_BUILD.md 获取详细说明"
    exit 0
fi

# 显示帮助
echo "用法: $0 [dev|build|build-all|build-windows]"
echo "  dev          - 开发模式"
echo "  build        - 构建当前平台"
echo "  build-all    - 构建所有平台"
echo "  build-windows - Windows 构建指南"
echo ""
echo "构建产物将输出到: src-tauri/target/release/bundle/"
echo ""
echo "📖 Windows 打包指南: WINDOWS_BUILD.md"
echo "🚀 Windows 构建脚本: build-windows.bat"