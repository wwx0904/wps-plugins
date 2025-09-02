@echo off
chcp 65001 >nul
title AI赢标助手开发服务器

echo 🚀 启动 AI赢标助手开发环境...
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  注意: 建议以管理员身份运行以获得完整功能
    echo.
)

:: 检查 Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 未找到 Node.js
    echo 请先运行 setup-and-build-windows.bat 安装环境
    pause
    exit /b 1
)

:: 检查 Cargo
cargo --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 未找到 Rust/Cargo
    echo 请先运行 setup-and-build-windows.bat 安装环境
    pause
    exit /b 1
)

:: 检查端口占用
netstat -ano | findstr :1420 >nul
if %errorlevel% equ 0 (
    echo ⚠️  端口 1420 已被占用，正在停止相关进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :1420') do taskkill /f /pid %%a >nul 2>&1
    timeout /t 2 >nul
)

echo ✅ 环境检查通过
echo.
echo 🔧 启动开发服务器...
echo 📍 应用将运行在: http://localhost:1420/
echo 🛑 按 Ctrl+C 停止服务器
echo.

npm run tauri:dev

pause