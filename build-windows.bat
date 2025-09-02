@echo off
chcp 65001 >nul
title AI赢标助手 Windows 打包脚本

echo 🚀 开始打包 AI赢标助手-WPS环境切换工具 Windows 版本...
echo.

REM 检查 Node.js 是否安装
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到 Node.js
    echo 💡 请访问 https://nodejs.org/ 下载并安装 Node.js
    pause
    exit /b 1
)

REM 检查 npm 是否安装
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到 npm
    pause
    exit /b 1
)

REM 检查 Cargo 是否安装
cargo --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到 Rust/Cargo
    echo 💡 请访问 https://rustup.rs/ 下载并安装 Rust
    pause
    exit /b 1
)

echo ✅ 环境检查通过
echo.

REM 安装依赖
echo 📦 安装前端依赖...
npm install
if %errorlevel% neq 0 (
    echo ❌ 前端依赖安装失败
    pause
    exit /b 1
)

REM 清理之前的构建
echo 🧹 清理之前的构建文件...
npm run tauri clean --yes 2>nul || echo 清理完成

REM 开始打包
echo 🔨 开始打包 Windows 版本...
echo.

npm run tauri build

if %errorlevel% equ 0 (
    echo.
    echo ✅ Windows 版本打包成功！
    echo.
    echo 📦 打包产物位置:
    echo    MSI 安装包: src-tauri\target\release\bundle\msi\
    echo    便携版本: src-tauri\target\release\bundle\nsis\
    echo.
    echo 🎉 打包流程完成！
    
    REM 询问是否打开输出目录
    set /p "openFolder=是否打开输出目录？(y/n): "
    if /i "%openFolder%"=="y" (
        if exist "src-tauri\target\release\bundle\msi" (
            explorer "src-tauri\target\release\bundle\msi"
        ) else if exist "src-tauri\target\release\bundle\nsis" (
            explorer "src-tauri\target\release\bundle\nsis"
        )
    )
) else (
    echo.
    echo ❌ 打包失败，请检查错误信息
    pause
    exit /b 1
)

pause