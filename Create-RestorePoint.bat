@echo off
setlocal EnableDelayedExpansion
title WINBARS - Create System Restore Point
:: ============================================================================
::  WINBARS - CREATE SYSTEM RESTORE POINT
::  Creates a hardened, atomic Windows System Restore Point (VSS checkpoint).
::  Optionally pins it as a permanent Baseline Restore Point that is
::  permanently excluded from FIFO pruning and VSS quota eviction.
::  No WINBARS installation is required - runs portably from USB too.
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
echo   WINBARS - CREATE SYSTEM RESTORE POINT
echo ========================================================================
echo   Creates an atomic Windows System Restore Point checkpoint.
echo   Optionally pins it as a permanent Baseline Checkpoint.
echo.
echo SYNTAX:
echo   Create-RestorePoint.bat [/?] [/Quiet] [/Pin:Y^|N] [/Label:"Checkpoint Label"]
echo.
echo SWITCHES:
echo   [/?] or [/Help]   Display this help screen and exit immediately.
echo   /Quiet            Unattended mode: suppresses completion pause prompts.
echo   /Pin:Y^|N         Pre-answers whether to pin as permanent baseline.
echo   /Label:"Name"     Sets custom label for the restore point.
echo.
echo EXAMPLES:
echo   Create-RestorePoint.bat
echo   Create-RestorePoint.bat /Quiet
echo   Create-RestorePoint.bat /Pin:Y /Label:"Pre-Driver Installation" /Quiet
echo ========================================================================
echo.
exit /b 0

:ARGS_DONE
if defined ARG_PIN set "ARG_PIN=!ARG_PIN:"=!"
if defined ARG_LABEL set "ARG_LABEL=!ARG_LABEL:"=!"

echo.
echo ================================================================
echo   WINBARS - CREATE SYSTEM RESTORE POINT
echo ================================================================
echo   A restore point snapshots Windows system files, drivers and
echo   the registry. Personal files are never modified or removed.
echo   Baseline checkpoints are pinned and never pruned.
echo.

:: ---- 1. Request Administrator privileges if needed ----
NET SESSION >nul 2>&1
if !errorLevel! NEQ 0 (
    echo   Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$a = if ($args.Count -gt 0) { ' ' + ($args -join ' ') } else { '' }; Start-Process -FilePath cmd.exe -ArgumentList ('/c \"\"%~f0\"\"' + $a) -Verb RunAs" %*
    exit /b 0
)
cd /d "%~dp0"

:: ---- 2. Auto-unblock files to prevent SmartScreen blocking ----
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%~dp0*' -Recurse | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1

:: ---- 3. Detect execution engine ----
set "RUN_CMD="
if exist "%~dp0WINBARS.exe" (
    set "RUN_CMD=^"%~dp0WINBARS.exe^""
) else if exist "%~dp0WINBARS.ps1" (
    set "RUN_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File ^"%~dp0WINBARS.ps1^""
)
if not defined RUN_CMD (
    echo.
    echo   [ERROR] WINBARS.exe or WINBARS.ps1 was not found next to this
    echo           script in: %~dp0
    echo.
    if not "!QUIET_MODE!"=="1" pause
    exit /b 1
)

:: ---- 4. Ask whether to pin as a permanent baseline ----
set "BASE_CHOICE="
if defined ARG_PIN (
    if /i "!ARG_PIN!"=="Y" set "BASE_CHOICE=Y"
    echo   Pin checkpoint pre-set via switch: !ARG_PIN!
) else (
    set /p BASE_IN="   Pin this as a permanent Baseline Restore Point? (Y/N) [Default: N]: "
    if /i "!BASE_IN!"=="Y" set "BASE_CHOICE=Y"
)

set "LABEL="
if defined BASE_CHOICE (
    if defined ARG_LABEL (
        set "LABEL=!ARG_LABEL!"
        echo   Baseline label pre-set via switch: !LABEL!
    ) else (
        set /p LABEL="   Baseline label - letters, numbers, spaces, dashes only [Default: Baseline Checkpoint]: "
        if not defined LABEL set "LABEL=Baseline Checkpoint"
    )
)

:: ---- 5. Create the restore point ----
echo.
if defined BASE_CHOICE (
    echo   Creating permanent BASELINE restore point: !LABEL!
    echo   ----------------------------------------------------------------
    !RUN_CMD! -Action RestorePoint -Baseline -Description "!LABEL!" -Unattended
) else (
    echo   Creating hardened Windows System Restore Point...
    echo   ----------------------------------------------------------------
    !RUN_CMD! -Action RestorePoint -Unattended
)
set "RP_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !RP_EXIT! EQU 0 (
    if defined BASE_CHOICE (
        echo   [OK] Permanent Baseline Restore Point pinned: !LABEL!
        echo        It is excluded from FIFO pruning and VSS quota eviction.
    ) else (
        echo   [OK] System Restore Point created successfully.
    )
) else (
    echo   [ERROR] Restore point creation failed with exit code !RP_EXIT!.
)

:: ---- 6. Final verdict ----
echo.
echo ================================================================
if !RP_EXIT! EQU 0 (
    echo   [SUCCESS] Restore point creation completed.
) else (
    echo   [FAILED] Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log
)
echo ================================================================
echo.
if not "!QUIET_MODE!"=="1" pause
exit /b !RP_EXIT!