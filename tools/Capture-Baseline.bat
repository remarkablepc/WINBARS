@echo off
setlocal EnableDelayedExpansion
title WINBARS - Permanent Baseline Image Capture
:: ============================================================================
::  WINBARS - CAPTURE PERMANENT BASELINE SYSTEM IMAGE
::  Creates SystemImage_..._baseline.wim - permanently excluded from
::  retention rotation on both local and external storage.
::  If WINBARS is not set up yet, offers to run a one-click installer.
:: ============================================================================

:: ---- 0. Parse Command Line Arguments ----
set "QUIET_MODE=0"
set "ARG_PIN="
set "ARG_LABEL="

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

:: Switches with values
if /i "!A:~0,5!"=="/pin:" ( set "ARG_PIN=!A:~5!" & shift & goto PARSE_LOOP )
if /i "!A:~0,7!"=="/label:" ( set "ARG_LABEL=!A:~7!" & shift & goto PARSE_LOOP )

shift
goto PARSE_LOOP

:SHOW_HELP
echo.
echo ========================================================================
echo   WINBARS - CAPTURE PERMANENT BASELINE SYSTEM IMAGE
echo ========================================================================
echo   Creates a permanent baseline system image (_baseline.wim) excluded
echo   from FIFO retention rotation.
echo.
echo SYNTAX:
echo   Capture-Baseline.bat [/?] [/Quiet] [/Pin:Y^|N] [/Label:"Checkpoint Label"]
echo.
echo SWITCHES:
echo   [/?] or [/Help]   Display this help screen and exit immediately.
echo   /Quiet            Unattended mode: suppresses completion pause prompts.
echo   /Pin:Y^|N         Pre-answers whether to also pin a Baseline Restore Point.
echo   /Label:"Name"     Sets custom label for the Baseline Restore Point.
echo.
echo EXAMPLES:
echo   Capture-Baseline.bat
echo   Capture-Baseline.bat /Quiet
echo   Capture-Baseline.bat /Pin:Y /Label:"Pre-Upgrade Master" /Quiet
echo ========================================================================
echo.
exit /b 0

:ARGS_DONE
if defined ARG_PIN set "ARG_PIN=!ARG_PIN:"=!"
if defined ARG_LABEL set "ARG_LABEL=!ARG_LABEL:"=!"

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
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$a = if ($args.Count -gt 0) { ' ' + ($args -join ' ') } else { '' }; Start-Process -FilePath cmd.exe -ArgumentList ('/c \"\"%~f0\"\"' + $a) -Verb RunAs" %*
    exit /b 0
)
cd /d "%~dp0"
set "ROOT_DIR=%~dp0"
if not exist "%ROOT_DIR%WINBARS.exe" if not exist "%ROOT_DIR%WINBARS.ps1" (
    if exist "%~dp0..\WINBARS.exe" set "ROOT_DIR=%~dp0..\"
    if exist "%~dp0..\WINBARS.ps1" set "ROOT_DIR=%~dp0..\"
)

:: ---- 2. Auto-unblock files to prevent SmartScreen blocking ----
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%ROOT_DIR%*' -Recurse | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1

:: ---- 3. Detect whether WINBARS is set up on this PC ----
set "SETUP_FOUND="
if exist "C:\Tools\WINBARS\WINBARS.exe" set "SETUP_FOUND=1"
if not defined SETUP_FOUND if exist "C:\ProgramData\WINBARS\config.json" set "SETUP_FOUND=1"
if not defined SETUP_FOUND if exist "%ROOT_DIR%config\config.json" set "SETUP_FOUND=1"
if not defined SETUP_FOUND if exist "%ROOT_DIR%config.json" set "SETUP_FOUND=1"
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
    if not "!QUIET_MODE!"=="1" pause
    exit /b 0
)
for %%m in (0 N 1 2 3 4) do if /i "!CHOICE!"=="%%m" goto RUN_INSTALLER
echo   [ERROR] Invalid selection. Enter 0, N, 1, 2, 3, 4, or X.
goto ASK_MODE

:RUN_INSTALLER
echo.
set "INST_DIR=%ROOT_DIR%installers\"
if not exist "%INST_DIR%" set "INST_DIR=%ROOT_DIR%"
if /i "!CHOICE!"=="0" call "%INST_DIR%Install-Mode0-ZeroFootprint.bat"
if /i "!CHOICE!"=="N" call "%INST_DIR%Install-ModeN-NearZeroFootprint.bat"
if /i "!CHOICE!"=="1" call "%INST_DIR%Install-Mode1-SystemUndo.bat"
if /i "!CHOICE!"=="2" call "%INST_DIR%Install-Mode2-LocalDisasterGuard.bat"
if /i "!CHOICE!"=="3" call "%INST_DIR%Install-Mode3-HeadlessFull.bat"
if /i "!CHOICE!"=="4" call "%INST_DIR%Install-Mode4-TotalProtection.bat"
echo.
echo   Setup complete. Run Capture-Baseline.bat again to capture
echo   your permanent baseline image.
echo.
if not "!QUIET_MODE!"=="1" pause
exit /b 0

:: ---- 4. WINBARS is set up: detect execution engine ----
:SETUP_OK
set "RUN_CMD="
if exist "%ROOT_DIR%WINBARS.exe" (
    set "RUN_CMD=^"%~dp0WINBARS.exe^""
) else if exist "%ROOT_DIR%WINBARS.ps1" (
    set "RUN_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File ^"%~dp0WINBARS.ps1^""
) else if exist "C:\Tools\WINBARS\WINBARS.exe" (
    set "RUN_CMD=^"C:\Tools\WINBARS\WINBARS.exe^""
)
if not defined RUN_CMD (
    echo.
    echo   [ERROR] WINBARS.exe could not be located next to this script
    echo           or in C:\Tools\WINBARS.
    echo.
    if not "!QUIET_MODE!"=="1" pause
    exit /b 1
)

:: ---- 5. Optional pinned restore point ----
set "RP_CHOICE="
if defined ARG_PIN (
    if /i "!ARG_PIN!"=="Y" set "RP_CHOICE=Y"
    echo   Pin restore point pre-set via switch: !ARG_PIN!
) else (
    set /p RP_IN="   Also pin a permanent Baseline Restore Point? (Y/N) [Default: N]: "
    if /i "!RP_IN!"=="Y" set "RP_CHOICE=Y"
)

set "RP_LABEL="
if defined RP_CHOICE (
    if defined ARG_LABEL (
        set "RP_LABEL=!ARG_LABEL!"
        echo   Baseline label pre-set via switch: !RP_LABEL!
    ) else (
        set /p RP_LABEL="   Baseline label - letters, numbers, spaces, dashes only [Default: Baseline Checkpoint]: "
        if not defined RP_LABEL set "RP_LABEL=Baseline Checkpoint"
    )
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
if not "!QUIET_MODE!"=="1" pause
exit /b !OVERALL_EXIT!