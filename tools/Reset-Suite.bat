@echo off
setlocal EnableDelayedExpansion
title WINBARS - Factory Reset & Re-provisioning
:: ============================================================================
::  WINBARS - FACTORY RESET & RE-PROVISIONING UTILITY
::  Removes all WINBARS scheduled tasks, startup sentries, and resets config.json
::  back to factory pristine unconfigured state.
::  Keeps WINBARS application files (C:\Tools\WINBARS) and branding intact.
::  Your backup data is NEVER deleted: mirrored files, .wim system images,
::  and Windows restore points always remain untouched on your drives.
:: ============================================================================

:: ---- 0. Parse Command Line Arguments ----
set "QUIET_MODE=0"
set "ARG_FORCE=0"

:PARSE_LOOP
if "%~1"=="" goto ARGS_DONE
set "A=%~1"

if /i "!A!"=="/?" goto SHOW_HELP
if /i "!A!"=="-?" goto SHOW_HELP
if /i "!A!"=="/help" goto SHOW_HELP
if /i "!A!"=="--help" goto SHOW_HELP
if /i "!A!"=="help" goto SHOW_HELP

if /i "!A!"=="/quiet" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/unattended" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/force" ( set "ARG_FORCE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/yes" ( set "ARG_FORCE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/y" ( set "ARG_FORCE=1" & shift & goto PARSE_LOOP )

shift
goto PARSE_LOOP

:SHOW_HELP
echo.
echo ========================================================================
echo   WINBARS - FACTORY RESET & RE-PROVISIONING
echo ========================================================================
echo   Removes scheduled tasks, tray sentries, and resets configuration back
echo   to factory unconfigured state without deleting application files.
echo   Backup files, restore points, and branding are NEVER deleted.
echo.
echo SYNTAX:
echo   Reset-Suite.bat [/?] [/Quiet] [/Force]
echo.
echo SWITCHES:
echo   [/?] or [/Help]   Display this help screen and exit immediately.
echo   /Quiet            Unattended mode: suppresses completion pause prompts.
echo   /Force or /Yes    Suppresses confirmation prompt.
echo.
echo EXAMPLES:
echo   Reset-Suite.bat
echo   Reset-Suite.bat /Force /Quiet
echo ========================================================================
echo.
exit /b 0

:ARGS_DONE

echo.
echo ================================================================
echo   WINBARS - FACTORY RESET & RE-PROVISIONING ENGINE
echo ================================================================
echo   This tool clears all WINBARS scheduled tasks, sentries, and
echo   drive identity markers, resetting the suite to a pristine state.
echo   Application files (C:\Tools\WINBARS), branding, and backups
echo   remain 100%% INTACT.
echo.

:: ---- 1. Request Administrator privileges if needed ----
NET SESSION >nul 2>&1
if !errorLevel! NEQ 0 (
    echo   Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command " = if (.Count -gt 0) { ' ' + ( -join ' ') } else { '' }; Start-Process -FilePath cmd.exe -ArgumentList ('/c \"\"%~f0\"\"' + ) -Verb RunAs" %*
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

:: ---- 3. Detect execution engine ----
set "RUN_CMD="
if exist "%ROOT_DIR%WINBARS.exe" (
    set "RUN_CMD=^"%~dp0WINBARS.exe^""
) else if exist "%ROOT_DIR%WINBARS.ps1" (
    set "RUN_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File ^"%~dp0WINBARS.ps1^""
) else if exist "C:\Tools\WINBARS\WINBARS.exe" (
    set "RUN_CMD=^"C:\Tools\WINBARS\WINBARS.exe^""
) else if exist "%ROOT_DIR%dist\WINBARS.exe" (
    set "RUN_CMD=^"%~dp0dist\WINBARS.exe^""
)
if not defined RUN_CMD (
    echo.
    echo   [ERROR] WINBARS.exe could not be located next to this script
    echo           or in C:\Tools\WINBARS.
    echo.
    if not "!QUIET_MODE!"=="1" pause
    exit /b 1
)

:: ---- 4. Confirmation Prompt ----
if "!ARG_FORCE!"=="0" (
    echo   WHAT WILL HAPPEN:
    echo     1. Running background sentries and tray icons will be stopped.
    echo     2. All WINBARS scheduled tasks will be unregistered from Windows.
    echo     3. Startup run keys and shortcuts will be cleanly removed.
    echo     4. Configuration (config.json) will be reset to factory unconfigured.
    echo     5. WINBARS application files will remain intact at C:\Tools\WINBARS.
    echo     6. White-label branding (branding.json) will be preserved.
    echo     7. All backups, restore points, and .wim images remain untouched.
    echo.
    set /p CONFIRM_RESET="   Proceed with Factory Reset & Re-provisioning? (Y/N) [Default: N]: "
    if /i not "!CONFIRM_RESET!"=="Y" (
        echo.
        echo   [CANCELLED] Reset operation aborted by user.
        echo.
        if not "!QUIET_MODE!"=="1" pause
        exit /b 0
    )
)

:: ---- 5. Execute Reset ----
echo.
echo   Executing WINBARS factory reset...
echo   ----------------------------------------------------------------
!RUN_CMD! -ResetSuite -Unattended
set "RESET_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------

if !RESET_EXIT! EQU 0 (
    echo.
    echo ================================================================
    echo   [SUCCESS] WINBARS Factory Reset Completed!
    echo   ----------------------------------------------------------------
    echo   * Scheduled Tasks:    All unregistered (Clean slate)
    echo   * Sentry Daemons:     Stopped
    echo   * Startup Run Keys:   Removed
    echo   * Configuration:      Reset to pristine baseline
    echo   * Application Files:  Intact at C:\Tools\WINBARS
    echo   * Customer Data:      100%% Safe (Restore points & images untouched)
    echo   ----------------------------------------------------------------
    echo   This machine is now clean and ready for technician re-provisioning
    echo   or out-of-box client handoff.
    echo ================================================================
) else (
    echo.
    echo   [ERROR] Reset operation encountered an issue (Exit code: !RESET_EXIT!).
    echo   Check logs at C:\ProgramData\WINBARS\Logs\backup.log
)
echo.
if not "!QUIET_MODE!"=="1" pause
exit /b !RESET_EXIT!
