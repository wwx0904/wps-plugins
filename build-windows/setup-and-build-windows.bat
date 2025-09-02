@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title AI赢标助手 - Windows 环境自动配置和打包脚本

:: 设置颜色
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "RESET=[0m"

echo %BLUE%
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                AI赢标助手 - Windows 自动化脚本              ║
echo ║              自动配置环境 + 一键打包应用                    ║
echo ╚══════════════════════════════════════════════════════════════╝
echo %RESET%

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%❌ 错误: 需要管理员权限运行此脚本%RESET%
    echo %YELLOW%请右键点击此脚本，选择"以管理员身份运行"%RESET%
    pause
    exit /b 1
)

echo %GREEN%✅ 管理员权限检查通过%RESET%
echo.

:: 创建日志文件
set "LOG_FILE=%TEMP%\ai-assistant-install.log"
echo 安装日志 > "%LOG_FILE%"
echo 日期: %date% %time% >> "%LOG_FILE%"

:: 函数：检查命令是否存在
:check_command
where %1 >nul 2>&1
exit /b %errorlevel%

:: 函数：安装软件
:install_software
echo %YELLOW%📦 正在安装 %~1...%RESET%
echo [%time%] 安装 %~1 >> "%LOG_FILE%"
%2
if %errorlevel% equ 0 (
    echo %GREEN%✅ %~1 安装成功%RESET%
    echo [%time%] %~1 安装成功 >> "%LOG_FILE%"
) else (
    echo %RED%❌ %~1 安装失败%RESET%
    echo [%time%] %~1 安装失败 >> "%LOG_FILE%"
    echo %YELLOW%请手动安装 %~1 后重试%RESET%
)
echo.

:: 1. 检查并安装 winget
call :check_command winget
if %errorlevel% neq 0 (
    echo %YELLOW%🔧 Winget 未安装，正在安装...%RESET%
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'))"
    echo %GREEN%✅ Winget 安装完成%RESET%
    echo.
) else (
    echo %GREEN%✅ Winget 已安装%RESET%
    echo.
)

:: 2. 检查并安装 Visual Studio Build Tools
echo %BLUE%🔍 检查 Visual Studio Build Tools...%RESET%
call :check_command cl
if %errorlevel% neq 0 (
    echo %YELLOW%⚠️  Visual Studio Build Tools 未安装，正在安装...%RESET%
    echo [%time%] 安装 Visual Studio Build Tools >> "%LOG_FILE%"
    
    :: 下载并安装 Visual Studio Build Tools
    powershell -Command "& {Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_buildtools.exe' -OutFile '$env:TEMP\vs_buildtools.exe'}"
    
    if exist "%TEMP%\vs_buildtools.exe" (
        echo %YELLOW%🔧 正在安装 Visual Studio Build Tools（这可能需要几分钟）...%RESET%
        "%TEMP%\vs_buildtools.exe" --quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended
        
        if %errorlevel% equ 0 (
            echo %GREEN%✅ Visual Studio Build Tools 安装成功%RESET%
            echo [%time%] Visual Studio Build Tools 安装成功 >> "%LOG_FILE%"
        ) else (
            echo %RED%❌ Visual Studio Build Tools 安装失败%RESET%
            echo [%time%] Visual Studio Build Tools 安装失败 >> "%LOG_FILE%"
            echo %YELLOW%请手动下载安装: https://visualstudio.microsoft.com/visual-cpp-build-tools/%RESET%
            pause
            exit /b 1
        )
        
        del "%TEMP%\vs_buildtools.exe" >nul 2>&1
    ) else (
        echo %RED%❌ 下载 Visual Studio Build Tools 失败%RESET%
        pause
        exit /b 1
    )
    echo.
) else (
    echo %GREEN%✅ Visual Studio Build Tools 已安装%RESET%
    echo.
)

:: 3. 检查并安装 Rust
echo %BLUE%🔍 检查 Rust...%RESET%
call :check_command cargo
if %errorlevel% neq 0 (
    call :install_software "Rust" "winget install --id Rustlang.Rustup -e"
    
    :: 刷新环境变量
    echo %YELLOW%🔄 刷新环境变量...%RESET%
    call refreshenv >nul 2>&1 || (
        echo %YELLOW%请重新运行脚本以使用 Rust%RESET%
        pause
        exit /b 0
    )
    
    :: 重新检查 Rust
    call :check_command cargo
    if %errorlevel% neq 0 (
        echo %RED%❌ Rust 安装后未找到，请重启计算机后重试%RESET%
        pause
        exit /b 1
    )
) else (
    echo %GREEN%✅ Rust 已安装%RESET%
    echo.
)

:: 4. 检查并安装 Node.js
echo %BLUE%🔍 检查 Node.js...%RESET%
call :check_command node
if %errorlevel% neq 0 (
    call :install_software "Node.js" "winget install --id OpenJS.NodeJS -e"
    
    :: 刷新环境变量
    echo %YELLOW%🔄 刷新环境变量...%RESET%
    call refreshenv >nul 2>&1
    
    :: 重新检查 Node.js
    call :check_command node
    if %errorlevel% neq 0 (
        echo %RED%❌ Node.js 安装后未找到，请重启计算机后重试%RESET%
        pause
        exit /b 1
    )
) else (
    echo %GREEN%✅ Node.js 已安装%RESET%
    echo.
)

:: 5. 检查并安装 Git
echo %BLUE%🔍 检查 Git...%RESET%
call :check_command git
if %errorlevel% neq 0 (
    call :install_software "Git" "winget install --id Git.Git -e"
    
    :: 刷新环境变量
    echo %YELLOW%🔄 刷新环境变量...%RESET%
    call refreshenv >nul 2>&1
    
    :: 重新检查 Git
    call :check_command git
    if %errorlevel% neq 0 (
        echo %RED%❌ Git 安装后未找到，请重启计算机后重试%RESET%
        pause
        exit /b 1
    )
) else (
    echo %GREEN%✅ Git 已安装%RESET%
    echo.
)

:: 6. 安装 Tauri CLI
echo %BLUE%🔍 检查 Tauri CLI...%RESET%
call :check_command tauri
if %errorlevel% neq 0 (
    echo %YELLOW%📦 正在安装 Tauri CLI...%RESET%
    echo [%time%] 安装 Tauri CLI >> "%LOG_FILE%"
    npm install -g @tauri-apps/cli
    
    if %errorlevel% equ 0 (
        echo %GREEN%✅ Tauri CLI 安装成功%RESET%
        echo [%time%] Tauri CLI 安装成功 >> "%LOG_FILE%"
    ) else (
        echo %RED%❌ Tauri CLI 安装失败%RESET%
        echo [%time%] Tauri CLI 安装失败 >> "%LOG_FILE%"
        pause
        exit /b 1
    )
    echo.
) else (
    echo %GREEN%✅ Tauri CLI 已安装%RESET%
    echo.
)

:: 7. 安装 NSIS（用于 Windows 打包）
echo %BLUE%🔍 检查 NSIS...%RESET%
call :check_command makensis
if %errorlevel% neq 0 (
    call :install_software "NSIS" "winget install --id NSIS.NSIS -e"
) else (
    echo %GREEN%✅ NSIS 已安装%RESET%
    echo.
)

:: 8. 环境检查完成
echo %GREEN%╔══════════════════════════════════════════════════════════════╗%RESET%
echo %GREEN%║                    🎉 环境配置完成！                          ║%RESET%
echo %GREEN%╚══════════════════════════════════════════════════════════════╝%RESET%
echo.

:: 显示已安装的软件版本
echo %BLUE%📋 已安装的软件版本:%RESET%
echo %YELLOW%├─ Rust/Cargo:%RESET%
cargo --version
echo %YELLOW%├─ Node.js:%RESET%
node --version
echo %YELLOW%├─ npm:%RESET%
npm --version
echo %YELLOW%├─ Git:%RESET%
git --version
echo %YELLOW%├─ Tauri CLI:%RESET%
tauri --version
echo.

:: 9. 询问用户下一步操作
echo %BLUE%🎯 环境配置完成，请选择下一步操作:%RESET%
echo %YELLOW%1. 克隆/下载项目代码%RESET%
echo %YELLOW%2. 打包现有项目%RESET%
echo %YELLOW%3. 退出%RESET%
echo.

set /p "choice=请输入选择 (1/2/3): "

if "%choice%"=="1" (
    call :clone_project
) else if "%choice%"=="2" (
    call :build_project
) else if "%choice%"=="3" (
    echo %GREEN%👋 再见！%RESET%
    pause
    exit /b 0
) else (
    echo %RED%❌ 无效选择%RESET%
    pause
    exit /b 1
)

pause
exit /b 0

:: 克隆项目函数
:clone_project
echo %BLUE%📥 准备克隆项目...%RESET%
echo.

set /p "repo_url=请输入项目仓库地址 (留空使用默认): "
if "%repo_url%"=="" (
    set "repo_url=https://github.com/your-username/ai-bidding-wps-installer.git"
    echo %YELLOW%使用默认仓库地址%RESET%
)

set /p "project_dir=请输入项目目录 (留空使用默认 install-tauri): "
if "%project_dir%"=="" (
    set "project_dir=install-tauri"
)

echo %YELLOW%📥 正在克隆项目到 %project_dir%...%RESET%
git clone "%repo_url%" "%project_dir%"

if %errorlevel% equ 0 (
    echo %GREEN%✅ 项目克隆成功%RESET%
    cd /d "%project_dir%"
    call :build_project
) else (
    echo %RED%❌ 项目克隆失败%RESET%
    echo %YELLOW%请检查仓库地址是否正确%RESET%
    pause
)
exit /b 0

:: 构建项目函数
:build_project
echo %BLUE%🔨 开始构建项目...%RESET%
echo.

:: 检查是否在正确的目录
if not exist "package.json" (
    echo %RED%❌ 当前目录不是有效的 Tauri 项目目录%RESET%
    echo %YELLOW%请确保目录中包含 package.json 文件%RESET%
    pause
    exit /b 1
)

:: 安装依赖
echo %YELLOW%📦 安装项目依赖...%RESET%
npm install

if %errorlevel% neq 0 (
    echo %RED%❌ 依赖安装失败%RESET%
    pause
    exit /b 1
)

:: 清理之前的构建
echo %YELLOW%🧹 清理之前的构建文件...%RESET%
npm run tauri clean --yes 2>nul || echo 清理完成

:: 开始打包
echo %YELLOW%🔨 开始打包 Windows 版本...%RESET%
echo %GREEN%这可能需要几分钟时间，请耐心等待...%RESET%
echo.

npm run tauri build

if %errorlevel% equ 0 (
    echo %GREEN%╔══════════════════════════════════════════════════════════════╗%RESET%
    echo %GREEN%║                    🎉 打包成功！                          ║%RESET%
    echo %GREEN%╚══════════════════════════════════════════════════════════════╝%RESET%
    echo.
    echo %BLUE%📦 打包产物位置:%RESET%
    echo %YELLOW%├─ MSI 安装包:%RESET%
    if exist "src-tauri\target\release\bundle\msi" (
        dir /b "src-tauri\target\release\bundle\msi\*.msi"
    )
    echo %YELLOW%├─ 便携版 EXE:%RESET%
    if exist "src-tauri\target\release\bundle\nsis" (
        dir /b "src-tauri\target\release\bundle\nsis\*.exe"
    )
    echo.
    
    :: 询问是否打开输出目录
    set /p "openFolder=是否打开输出目录？(y/n): "
    if /i "%openFolder%"=="y" (
        if exist "src-tauri\target\release\bundle\msi" (
            explorer "src-tauri\target\release\bundle\msi"
        ) else if exist "src-tauri\target\release\bundle\nsis" (
            explorer "src-tauri\target\release\bundle\nsis"
        )
    )
    
    :: 询问是否创建桌面快捷方式
    set /p "createShortcut=是否为打包产物创建桌面快捷方式？(y/n): "
    if /i "%createShortcut%"=="y" (
        call :create_shortcuts
    )
    
) else (
    echo %RED%❌ 打包失败，请检查错误信息%RESET%
    echo %YELLOW%查看详细日志: type "%LOG_FILE%"%RESET%
    pause
    exit /b 1
)

exit /b 0

:: 创建快捷方式函数
:create_shortcuts
echo %YELLOW%🔗 创建桌面快捷方式...%RESET%

set "desktop=%USERPROFILE%\Desktop"

:: 创建 MSI 安装包快捷方式
if exist "src-tauri\target\release\bundle\msi\*.msi" (
    for %%f in ("src-tauri\target\release\bundle\msi\*.msi") do (
        powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%desktop%\%%~nf 安装包.lnk'); $s.TargetPath = '%%f'; $s.Save()"
    )
)

:: 创建便携版快捷方式
if exist "src-tauri\target\release\bundle\nsis\*.exe" (
    for %%f in ("src-tauri\target\release\bundle\nsis\*.exe") do (
        powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%desktop%\%%~nf 便携版.lnk'); $s.TargetPath = '%%f'; $s.Save()"
    )
)

echo %GREEN%✅ 桌面快捷方式创建完成%RESET%
exit /b 0