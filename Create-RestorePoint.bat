@echo off
setlocal EnableDelayedExpansion
title WINBARS - Create System Restore Point
:: ============================================================================
::  WINBARS - CREATE SYSTEM RESTORE POINT
::  Creates a hardened, atomic Windows System Restore Point (VSS checkpoint).
::  Optionally pins it as an immortal Baseline Restore Point that is
::  permanently excluded from FIFO pruning and VSS quota eviction.
::  No WINBARS installation is required - runs portably from USB too.
:: ============================================================================

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
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
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
    pause
    exit /b 1
)

:: ---- 4. Ask whether to pin as an immortal baseline ----
set "BASE_CHOICE="
set /p BASE_IN="   Pin this as an immortal Baseline Restore Point? (Y/N) [Default: N]: "
if /i "!BASE_IN!"=="Y" set "BASE_CHOICE=Y"

set "LABEL="
if defined BASE_CHOICE (
    set /p LABEL="   Baseline label - letters, numbers, spaces, dashes only [Default: Baseline Checkpoint]: "
    if not defined LABEL set "LABEL=Baseline Checkpoint"
)

:: ---- 5. Create the restore point ----
echo.
if defined BASE_CHOICE (
    echo   Creating immortal BASELINE restore point: !LABEL!
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
        echo   [OK] Immortal Baseline Restore Point pinned: !LABEL!
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
pause
exit /b !RP_EXIT!
