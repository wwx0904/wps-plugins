#!/bin/bash

# AI赢标助手开发环境启动脚本
# 自动加载Rust环境并启动开发服务器

echo "🚀 启动 AI赢标助手开发环境..."

# 加载Rust环境
echo "📦 加载Rust环境..."
source "$HOME/.cargo/env"

# 检查依赖
if ! command -v cargo &> /dev/null; then
    echo "❌ 错误: 未找到 Rust/Cargo"
    echo "💡 请先安装 Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ 错误: 未找到 npm"
    echo "💡 请先安装 Node.js"
    exit 1
fi

# 检查端口是否被占用
if lsof -ti:1420 > /dev/null 2>&1; then
    echo "⚠️  端口 1420 已被占用，正在停止相关进程..."
    lsof -ti:1420 | xargs kill -9
    sleep 2
fi

# 启动开发服务器
echo "🔧 启动开发服务器..."
echo "📍 应用将运行在: http://localhost:1420/"
echo "🛑 按 Ctrl+C 停止服务器"
echo ""

npm run tauri:dev