@echo off
setlocal EnableDelayedExpansion

echo DEBUG: Script is starting...

REM --- Set up error handler ---
set "ERROR_OCCURRED=0"

REM --- UAC Elevation Check ---
echo DEBUG: Checking admin rights...
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
echo DEBUG: Admin check completed, errorlevel: %errorlevel%
if '%errorlevel%' NEQ '0' (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~f0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs" >nul 2>&1
    exit /B
)
echo DEBUG: Script has admin rights, continuing...
echo DEBUG: Admin process started successfully
echo.
echo ==========================================
echo 管理员权限模式已启动
echo ==========================================
echo.

REM --- Script has admin rights from here ---

set "HOST_IP=47.104.218.212"
set "HOST_NAME=bsh.ai.qianlima.com"
set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"
set "ENTRY_TO_ADD=%HOST_IP% %HOST_NAME%"
set "POPUP_VBS_FILE=%temp%\_host_popup.vbs"
set "OPERATION_SUCCESS=0"
set "URL_TO_OPEN=http://%HOST_NAME%/wuye"
echo DEBUG: Variables set successfully
echo DEBUG: HOSTS_FILE=%HOSTS_FILE%
echo DEBUG: ENTRY_TO_ADD=%ENTRY_TO_ADD%

echo DEBUG: Checking if hosts file exists...
if not exist "%HOSTS_FILE%" (
    echo DEBUG: ERROR - Hosts file not found!
    (echo MsgBox "严重错误: Hosts 文件 (%HOSTS_FILE%) 未找到!", vbCritical, "错误") > "%POPUP_VBS_FILE%"
    cscript //nologo "%POPUP_VBS_FILE%" >nul 2>&1
    del "%POPUP_VBS_FILE%" >nul 2>&1
    echo CRITICAL ERROR: Hosts file not found.
    echo.
    echo DEBUG: About to pause for error...
    echo Press any key to exit...
    pause >nul
    echo DEBUG: Pause completed, exiting...
    timeout /t 2 >nul
    exit /B 1
)
echo DEBUG: Hosts file found successfully!

echo DEBUG: About to check if entry already exists...
echo DEBUG: Searching for: %ENTRY_TO_ADD%
findstr /C:"%ENTRY_TO_ADD%" "%HOSTS_FILE%" >nul
echo DEBUG: findstr command executed
if errorlevel 1 goto ADD_ENTRY
echo DEBUG: Entry already exists in hosts file
set "OPERATION_SUCCESS=1"
echo DEBUG: Set OPERATION_SUCCESS=1
goto AFTER_HOSTS_CHECK

:ADD_ENTRY
echo DEBUG: Entry not found, will attempt to add
REM --- Check and handle read-only attribute ---
set "HOSTS_WAS_READONLY=0"
attrib "%HOSTS_FILE%" | find "R" >nul
if %errorlevel% equ 0 (
    set "HOSTS_WAS_READONLY=1"
    attrib -R "%HOSTS_FILE%"
    if %errorlevel% neq 0 (
        set "OPERATION_SUCCESS=0"
        goto skip_hosts_write
    )
) else (
    REM Hosts file is not read-only
)

REM --- Attempt to write to hosts file ---
(echo. >> "%HOSTS_FILE%") && (echo %ENTRY_TO_ADD% >> "%HOSTS_FILE%")
if %errorlevel% equ 0 (
    set "OPERATION_SUCCESS=1"
) else (
    set "OPERATION_SUCCESS=0"
)

REM --- Restore read-only attribute if it was originally set ---
if "%HOSTS_WAS_READONLY%"=="1" (
    attrib +R "%HOSTS_FILE%"
)

:skip_hosts_write

:AFTER_HOSTS_CHECK
echo DEBUG: Hosts operation completed
echo DEBUG: OPERATION_SUCCESS=%OPERATION_SUCCESS%
echo DEBUG: About to check if operation was successful...

if NOT "%OPERATION_SUCCESS%"=="1" goto OPERATION_FAILED

echo DEBUG: Entering successful operation branch
start "" "%URL_TO_OPEN%"
timeout /t 2 /nobreak >nul
(echo MsgBox "Hosts 条目操作成功！浏览器应该已经打开。", vbInformation, "成功") > "%POPUP_VBS_FILE%"
goto SHOW_POPUP

:OPERATION_FAILED
echo DEBUG: Entering failed operation branch
(echo MsgBox "Hosts 条目操作失败。", vbCritical, "错误") > "%POPUP_VBS_FILE%"

:SHOW_POPUP
echo DEBUG: About to execute VBS popup...
if exist "%POPUP_VBS_FILE%" (
    echo DEBUG: VBS file exists, executing...
    cscript //nologo "%POPUP_VBS_FILE%"
    echo DEBUG: VBS execution completed
) else (
    echo DEBUG: ERROR - VBS file does not exist!
    echo VBS file not found: %POPUP_VBS_FILE%
)
del "%POPUP_VBS_FILE%" >nul 2>&1
:END_OF_SCRIPT
echo.
echo DEBUG: Script reached the end normally
echo Script finished.
echo Press any key to close this window...
pause >nul
echo DEBUG: About to exit...
timeout /t 1 >nul
endlocal
exit