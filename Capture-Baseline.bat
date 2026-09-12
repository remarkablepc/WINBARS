@echo off
setlocal EnableDelayedExpansion
title WINBARS - Permanent Baseline Image Capture
:: ============================================================================
::  WINBARS - CAPTURE PERMANENT BASELINE SYSTEM IMAGE
::  Creates SystemImage_..._baseline.wim - permanently excluded from
::  retention rotation on both local and external storage.
::  If WINBARS is not set up yet, offers to run a one-click installer.
:: ============================================================================

echo.
echo ================================================================
echo   WINBARS - CAPTURE PERMANENT BASELINE SYSTEM IMAGE
echo ================================================================
echo   The baseline image is the permanent Day-1 rollback target.
echo   It is never rotated, pruned, or deleted by retention rules.
echo.

:: ---- 1. Request Administrator privileges if needed ----
NET SESSION >nul 2>&1
if !errorLevel! NEQ 0 (
    echo   Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b 0
)
cd /d "%~dp0"

:: ---- 2. Auto-unblock files to prevent SmartScreen blocking ----
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%~dp0*' -Recurse | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1

:: ---- 3. Detect whether WINBARS is set up on this PC ----
set "SETUP_FOUND="
if exist "C:\Tools\WINBARS\WINBARS.exe" set "SETUP_FOUND=1"
if not defined SETUP_FOUND if exist "C:\ProgramData\WINBARS\config.json" set "SETUP_FOUND=1"
if not defined SETUP_FOUND if exist "%~dp0config\config.json" set "SETUP_FOUND=1"
if not defined SETUP_FOUND if exist "%~dp0config.json" set "SETUP_FOUND=1"
if not defined SETUP_FOUND (
    schtasks /query /tn "\WinRestoreBackup\SystemRestorePoint" >nul 2>&1
    if not errorlevel 1 set "SETUP_FOUND=1"
)
if not defined SETUP_FOUND (
    schtasks /query /tn "\WindowsBackup\SystemRestorePoint" >nul 2>&1
    if not errorlevel 1 set "SETUP_FOUND=1"
)

if not defined SETUP_FOUND goto NOT_SETUP
goto SETUP_OK

:: ---- 3a. WINBARS not set up: offer the one-click installers ----
:NOT_SETUP
echo   [i] WINBARS does not appear to be set up on this PC yet.
echo.
echo   Run a one-click installer first:
echo     [0] Install-Mode0-ZeroFootprint.bat
echo     [N] Install-ModeN-NearZeroFootprint.bat
echo     [1] Install-Mode1-SystemUndo.bat
echo     [2] Install-Mode2-LocalDisasterGuard.bat
echo     [3] Install-Mode3-HeadlessFull.bat
echo     [4] Install-Mode4-TotalProtection.bat
echo     [X] Exit without installing
echo.
:ASK_MODE
set /p CHOICE="   Select a mode to install (0/N/1/2/3/4) or X to exit: "
set "CHOICE=!CHOICE: =!"
if /i "!CHOICE!"=="X" (
    echo.
    echo   Exiting without changes.
    echo.
    pause
    exit /b 0
)
for %%m in (0 N 1 2 3 4) do if /i "!CHOICE!"=="%%m" goto RUN_INSTALLER
echo   [ERROR] Invalid selection. Enter 0, N, 1, 2, 3, 4, or X.
goto ASK_MODE

:RUN_INSTALLER
echo.
if /i "!CHOICE!"=="0" call "%~dp0Install-Mode0-ZeroFootprint.bat"
if /i "!CHOICE!"=="N" call "%~dp0Install-ModeN-NearZeroFootprint.bat"
if /i "!CHOICE!"=="1" call "%~dp0Install-Mode1-SystemUndo.bat"
if /i "!CHOICE!"=="2" call "%~dp0Install-Mode2-LocalDisasterGuard.bat"
if /i "!CHOICE!"=="3" call "%~dp0Install-Mode3-HeadlessFull.bat"
if /i "!CHOICE!"=="4" call "%~dp0Install-Mode4-TotalProtection.bat"
echo.
echo   Setup complete. Run Capture-Baseline.bat again to capture
echo   your permanent baseline image.
echo.
pause
exit /b 0

:: ---- 4. WINBARS is set up: detect execution engine ----
:SETUP_OK
set "RUN_CMD="
if exist "%~dp0WINBARS.exe" (
    set "RUN_CMD=^"%~dp0WINBARS.exe^""
) else if exist "%~dp0WINBARS.ps1" (
    set "RUN_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File ^"%~dp0WINBARS.ps1^""
) else if exist "C:\Tools\WINBARS\WINBARS.exe" (
    set "RUN_CMD=^"C:\Tools\WINBARS\WINBARS.exe^""
)
if not defined RUN_CMD (
    echo.
    echo   [ERROR] WINBARS.exe could not be located next to this script
    echo           or in C:\Tools\WINBARS.
    echo.
    pause
    exit /b 1
)

:: ---- 5. Optional pinned restore point ----
set "RP_CHOICE="
set /p RP_IN="   Also pin a permanent Baseline Restore Point? (Y/N) [Default: N]: "
if /i "!RP_IN!"=="Y" set "RP_CHOICE=Y"
set "RP_LABEL="
if defined RP_CHOICE (
    set /p RP_LABEL="   Baseline label - letters, numbers, spaces, dashes only [Default: Baseline Checkpoint]: "
    if not defined RP_LABEL set "RP_LABEL=Baseline Checkpoint"
)

:: ---- 6. Capture the permanent baseline system image ----
echo.
echo   Capturing permanent baseline system image (_baseline.wim)...
echo   This can take 30-90+ minutes depending on system size.
echo   ----------------------------------------------------------------
!RUN_CMD! -Action SystemImage -Baseline -Unattended
set "IMG_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !IMG_EXIT! EQU 0 (
    echo   [OK] Permanent baseline image captured successfully.
    echo        File: SystemImage_..._baseline.wim
    echo        It is permanently excluded from retention rotation.
) else (
    echo   [ERROR] Baseline image capture failed with exit code !IMG_EXIT!.
)

:: ---- 7. Optional pinned restore point capture ----
set "RP_EXIT=0"
if defined RP_CHOICE (
    echo.
    echo   Pinning permanent Baseline Restore Point...
    !RUN_CMD! -Action RestorePoint -Baseline -Description "!RP_LABEL!" -Unattended
    set "RP_EXIT=!errorLevel!"
    if !RP_EXIT! EQU 0 (
        echo   [OK] Permanent Baseline Restore Point pinned: !RP_LABEL!
    ) else (
        echo   [WARN] Baseline Restore Point failed with exit code !RP_EXIT!.
    )
)

:: ---- 8. Final verdict ----
set "OVERALL_EXIT=0"
if not !IMG_EXIT! EQU 0 set "OVERALL_EXIT=1"
if not !RP_EXIT! EQU 0 set "OVERALL_EXIT=1"
echo.
echo ================================================================
if !OVERALL_EXIT! EQU 0 (
    echo   [SUCCESS] Baseline capture completed.
) else (
    echo   [FAILED] One or more steps failed. Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log
)
echo ================================================================
echo.
pause
exit /b !OVERALL_EXIT!
