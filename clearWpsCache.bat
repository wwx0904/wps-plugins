@echo off
@REM 干掉wps相关进程避免缓存文件被占用
taskkill /f /im wpscloudsvr.exe
taskkill /f /im wps.exe
taskkill /f /im wpp.exe
taskkill /f /im et.exe
taskkill /f /im wpspdf.exe
taskkill /f /im wpsupdate.exe
taskkill /f /im updateself.exe
taskkill /f /im ktpcntr.exe
taskkill /f /im wpsoffice.exe
taskkill /f /im promecefpluginhost.exe
echo deleteing WPS Cache Directory
rmdir /S /q %AppData%\Kingsoft\wps\addons\data\win-i386
pause