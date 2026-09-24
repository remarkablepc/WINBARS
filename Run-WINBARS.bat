@echo off
setlocal EnableDelayedExpansion
title WINBARS - Windows Backup, Assistance, Recovery ^& Security
:: ============================================================
:: TECHNICIAN SHOP RUNNER & UNIFIED LAUNCHER
:: ============================================================

:: 1. Check for Administrative Privileges
NET SESSION >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Requesting Administrator Privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath cmd.exe -ArgumentList '/c \"\"%~f0\"\" %*' -Verb RunAs"
    exit /b
)
cd /d "%~dp0"

:: 2. Auto-Unblock files to prevent SmartScreen / Zone.Identifier execution blocking
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%~dp0*' -Recurse | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1

:: 3. Auto-adjust console buffer and window size for optimal layout
mode con: cols=110 lines=48 >nul 2>&1

:: 4. Detect Execution Engine (WINBARS.exe or WINBARS.ps1 fallback)
set "RUN_CMD="
if exist "%~dp0WINBARS.exe" (
    set RUN_CMD="%~dp0WINBARS.exe"
) else if exist "%~dp0WINBARS.ps1" (
    set RUN_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0WINBARS.ps1"
)

if not defined RUN_CMD (
    echo [ERROR] Neither WINBARS.exe nor WINBARS.ps1 was found in %~dp0
    pause
    exit /b 1
)

:: 5. If command-line arguments were provided, pass them directly to engine
if not "%~1"=="" (
    !RUN_CMD! %*
    exit /b !errorLevel!
)

:: 6. Auto-Discover Available Branding Profiles
set "BRAND_ARG=-Vanilla"
if exist "%~dp0brands\default.json" (
    set "BRAND_ARG=-Branded"
) else if exist "%~dp0branding.json" (
    set "BRAND_ARG=-Branded"
)

:: 7. Launch Unified WINBARS Console Engine
!RUN_CMD! !BRAND_ARG!
exit /b !errorLevel!