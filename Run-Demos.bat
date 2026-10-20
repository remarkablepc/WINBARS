@echo off
setlocal
title WINBARS Interactive Demo Suite
echo ========================================================
echo       WINBARS Interactive Safe Demonstration Suite
echo ========================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0demo\Run-Demo.ps1" %*
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Demonstration exited with status %ERRORLEVEL%.
    pause
)
endlocal
