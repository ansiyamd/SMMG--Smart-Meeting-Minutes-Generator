@echo off
setlocal
cd /d "%~dp0"
echo Starting required backend services for release APK test...
powershell -ExecutionPolicy Bypass -NoExit -File "%~dp0run_both_servers.ps1"
endlocal
