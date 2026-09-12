@echo off
setlocal EnableDelayedExpansion
title WINBARS - Bootable WinRE/WinPE Rescue USB Creator
:: ============================================================================
::  WINBARS - CREATE BOOTABLE RESCUE USB FLASH DRIVE
::  Creates a dedicated UEFI-bootable USB drive loaded with native Windows
::  Recovery Environment (WinRE), offline drivers, and the WINBARS Emergency Suite.
:: ============================================================================

:: ---- 0. Parse Command Line Arguments ----
set "QUIET_MODE=0"
set "DRY_RUN=0"
set "ARG_DRIVE="

:PARSE_LOOP
if "%~1"=="" goto ARGS_DONE
set "A=%~1"

:: Help triggers
if /i "!A!"=="/?" goto SHOW_HELP
if /i "!A!"=="-?" goto SHOW_HELP
if /i "!A!"=="/help" goto SHOW_HELP
if /i "!A!"=="--help" goto SHOW_HELP
if /i "!A!"=="help" goto SHOW_HELP

:: Flags
if /i "!A!"=="/quiet" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/unattended" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="-quiet" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="-unattended" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/dryrun" ( set "DRY_RUN=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="-dryrun" ( set "DRY_RUN=1" & shift & goto PARSE_LOOP )

:: Switches with values
if /i "!A:~0,7!"=="/drive:" ( set "ARG_DRIVE=!A:~7!" & shift & goto PARSE_LOOP )
if /i "!A:~0,7!"=="-drive:" ( set "ARG_DRIVE=!A:~7!" & shift & goto PARSE_LOOP )
if /i "!A:~0,8!"=="/target:" ( set "ARG_DRIVE=!A:~8!" & shift & goto PARSE_LOOP )
if /i "!A:~0,8!"=="-target:" ( set "ARG_DRIVE=!A:~8!" & shift & goto PARSE_LOOP )

shift
goto PARSE_LOOP

:SHOW_HELP
echo.
echo ========================================================================
echo   WINBARS - BOOTABLE RESCUE USB CREATOR
echo ========================================================================
echo   Formats or prepares a USB flash drive (4 GB+) with native UEFI boot files,
echo   Windows Recovery Environment (WinRE), offline storage drivers, and the
echo   offline WINBARS Bare-Metal Disaster Recovery assistant.
echo.
echo SYNTAX:
echo   Create-RescueUSB.bat [/?] [/Quiet] [/Drive:E:] [/DryRun]
echo.
echo SWITCHES:
echo   [/?] or [/Help]   Display this help screen and exit immediately.
echo   /Quiet            Unattended execution (requires /Drive:X:).
echo   /Drive:E:         Specifies target USB drive letter directly.
echo   /DryRun           Simulates detection and staging without modifying the USB.
echo.
echo EXAMPLES:
echo   Create-RescueUSB.bat
echo   Create-RescueUSB.bat /Drive:E:
echo   Create-RescueUSB.bat /Drive:E: /Quiet
echo   Create-RescueUSB.bat /DryRun
echo ========================================================================
echo.
exit /b 0

:ARGS_DONE
:: ---- 1. Check Administrator Privileges ----
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ========================================================================
    echo   ELEVATION REQUIRED
    echo ========================================================================
    echo   Administrator privileges are required to configure USB boot sectors
    echo   and export Windows Recovery Environment (WinRE) files.
    echo.
    echo   Requesting elevation prompt...
    echo ========================================================================
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath cmd.exe -ArgumentList '/c \"\"%~f0\"\" %*' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

:: ---- 2. Unblock Files ----
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%~dp0*' -Recurse | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1

:: ---- 3. Locate Engine ----
set "ENGINE_CMD="
if exist "%~dp0WINBARS.exe" (
    set ENGINE_CMD="%~dp0WINBARS.exe"
) else if exist "%~dp0WINBARS.ps1" (
    set ENGINE_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0WINBARS.ps1"
) else (
    echo.
    echo [ERROR] Neither WINBARS.exe nor WINBARS.ps1 was found in:
    echo         %~dp0
    echo.
    if "%QUIET_MODE%"=="0" pause
    exit /b 1
)

:: ---- 4. Assemble Parameter List ----
set "CALL_ARGS=-RescueUsb"

if not "%ARG_DRIVE%"=="" (
    set "CALL_ARGS=!CALL_ARGS! -TargetDriveLetter %ARG_DRIVE%"
)

if "%DRY_RUN%"=="1" (
    set "CALL_ARGS=!CALL_ARGS! -DryRun"
)

if "%QUIET_MODE%"=="1" (
    set "CALL_ARGS=!CALL_ARGS! -Unattended"
)

:: ---- 5. Execute Rescue USB Engine ----
echo.
echo Launching WINBARS Bootable Rescue Media Engine...
echo Executing: !ENGINE_CMD! !CALL_ARGS!
echo.

!ENGINE_CMD! !CALL_ARGS!
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%QUIET_MODE%"=="0" (
    echo ========================================================================
    echo   Operation finished with exit code: %EXIT_CODE%
    echo ========================================================================
    pause
)

exit /b %EXIT_CODE%
