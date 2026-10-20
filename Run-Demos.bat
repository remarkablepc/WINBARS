@echo off
setlocal
title WINBARS Interactive Demo Suite
cls
echo ========================================================
echo       WINBARS Interactive Safe Demonstration Suite
echo ========================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0demo\Run-Demo.ps1" %*
endlocal
