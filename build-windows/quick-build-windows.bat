@echo off
chcp 65001 >nul
title AI赢标助手 - 快速打包脚本

echo 🚀 AI赢标助手 Windows 快速打包脚本
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 需要管理员权限
    echo 请右键以管理员身份运行
    pause
    exit /b 1
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

:: 检查 Tauri CLI
tauri --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 未找到 Tauri CLI
    echo 正在安装...
    npm install -g @tauri-apps/cli
)

echo ✅ 环境检查通过
echo.

:: 检查当前目录
if not exist "package.json" (
    echo ❌ 当前目录不是 Tauri 项目
    echo 请确保在项目根目录运行此脚本
    pause
    exit /b 1
)

:: 安装依赖
echo 📦 安装依赖...
npm install

:: 清理构建
echo 🧹 清理构建...
npm run tauri clean --yes 2>nul

:: 开始打包
echo 🔨 开始打包...
echo.

npm run tauri build

if %errorlevel% equ 0 (
    echo.
    echo 🎉 打包成功！
    echo.
    echo 📦 产物位置:
    if exist "src-tauri\target\release\bundle\msi" (
        echo    MSI: src-tauri\target\release\bundle\msi\
        dir /b "src-tauri\target\release\bundle\msi\*.msi"
    )
    if exist "src-tauri\target\release\bundle\nsis" (
        echo    EXE: src-tauri\target\release\bundle\nsis\
        dir /b "src-tauri\target\release\bundle\nsis\*.exe"
    )
    echo.
    
    set /p "open=打开输出目录？(y/n): "
    if /i "%open%"=="y" (
        if exist "src-tauri\target\release\bundle\msi" (
            explorer "src-tauri\target\release\bundle\msi"
        ) else if exist "src-tauri\target\release\bundle\nsis" (
            explorer "src-tauri\target\release\bundle\nsis"
        )
    )
) else (
    echo ❌ 打包失败
)

pause