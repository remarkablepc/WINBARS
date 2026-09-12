@echo off
setlocal EnableDelayedExpansion
title WINBARS One-Click Installer - Mode 1 (SystemUndo - Service Warranty Baseline)
:: ============================================================================
::  WINBARS ONE-CLICK INSTALLER - MODE 1 : SYSTEM UNDO (SERVICE WARRANTY BASELINE)
::  The Universal Service Warranty Baseline: Native Windows rollback hardening
::  with ZERO resident EXEs, ZERO shortcuts, and ZERO background daemons.
::  Hardens native Windows recovery (daily unthrottled System Restore points,
::  VSS auto-healing, RegBack) with an optional baseline system image
::  (C:\SystemImages\_baseline.wim) if disk space >= 25 GB.
::  Requires WINBARS.exe (or WINBARS.ps1) in this same folder.
:: ============================================================================

echo.
echo ================================================================
echo   WINBARS ONE-CLICK INSTALLER - MODE 1 : SYSTEM UNDO
echo   (Service Warranty Baseline - 0 Resident EXEs)
echo ================================================================
echo   What Mode 1 does:
echo     - Daily unthrottled system restore points (Native Windows)
echo     - VSS writer auto-heal + shadow storage guard (10%% quota)
echo     - Driver/MSI install checkpoints
echo     - Optional baseline system image (C:\SystemImages\_baseline.wim)
echo     - Zero resident EXEs, zero shortcuts, zero tray, zero daemons
echo.
echo   Mode 1 deployment - exactly 1 optional question will be asked.
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
    echo           installer in: %~dp0
    echo.
    pause
    exit /b 1
)

:: ---- 4. Resolve the active config file (same order the engine uses) ----
set "ACTIVE_CONFIG_PATH="
if exist "%~dp0config\config.json" (
    set "ACTIVE_CONFIG_PATH=%~dp0config\config.json"
) else if exist "%~dp0config.json" (
    set "ACTIVE_CONFIG_PATH=%~dp0config.json"
) else if exist "C:\ProgramData\WINBARS\config.json" (
    set "ACTIVE_CONFIG_PATH=C:\ProgramData\WINBARS\config.json"
)
if not defined ACTIVE_CONFIG_PATH (
    if not exist "%~dp0config" mkdir "%~dp0config" >nul 2>&1
    set "ACTIVE_CONFIG_PATH=%~dp0config\config.json"
)

:: ---- 5. Apply Mode 1 SystemUndo profile (0 Resident EXEs) ----
echo.
echo   Applying Mode 1 SystemUndo stealth hardening...
echo   ----------------------------------------------------------------
!RUN_CMD! -SetProfile Minimal -Vanilla -Unattended -ConfigPath "!ACTIVE_CONFIG_PATH!"
set "PROFILE_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !PROFILE_EXIT! EQU 0 (
    echo   [OK] Mode 1 SystemUndo hardening applied successfully.
) else (
    echo   [ERROR] Profile apply failed with exit code !PROFILE_EXIT!.
)

:: ---- 6. Question 1 of 1: Optional immortal baseline system image ----
set "FREE_GB=0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$vol = Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='C:'\" -ErrorAction SilentlyContinue; if ($vol) { $gb = [math]::Round($vol.FreeSpace / 1GB, 1); [System.IO.File]::WriteAllText($env:TEMP + '\winbars_c_free.txt', \"$gb\") }" >nul 2>&1
if exist "%TEMP%\winbars_c_free.txt" (
    set /p FREE_GB=<"%TEMP%\winbars_c_free.txt"
    del /f /q "%TEMP%\winbars_c_free.txt" >nul 2>&1
)

echo.
echo   QUESTION 1 OF 1 - OPTIONAL BASELINE SYSTEM IMAGE
echo   Drive C: has !FREE_GB! GB free space.
set /p BASE_IN="   Capture an immortal baseline system image now (_baseline.wim)? (Y/N) [Default: N]: "
set "IMAGE_EXIT=0"
set "DID_CAPTURE=0"
if /i "!BASE_IN!"=="Y" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "if ([double]'!FREE_GB!' -ge 25.0) { exit 0 } else { exit 1 }" >nul 2>&1
    if !errorLevel! EQU 0 (
        echo.
        echo   Capturing local baseline system image (C:\SystemImages\_baseline.wim)...
        echo   ----------------------------------------------------------------
        !RUN_CMD! -Action SystemImage -Baseline -Unattended
        set "IMAGE_EXIT=!errorLevel!"
        echo   ----------------------------------------------------------------
        if !IMAGE_EXIT! EQU 0 (
            echo   [OK] Local baseline system image captured successfully.
            set "DID_CAPTURE=1"
        ) else (
            echo   [WARN] System image capture returned code !IMAGE_EXIT!.
            echo          Windows restore point hardening remains fully active.
        )
    ) else (
        echo.
        echo   [WARN] Drive C: has !FREE_GB! GB free space (less than 25 GB minimum required).
        echo          Skipping baseline image to avoid exhausting customer disk space.
    )
) else (
    echo   [i] Baseline image skipped. Restore points and VSS hardening active.
)

:: ---- 7. Final verdict ----
set "OVERALL_EXIT=0"
if not !PROFILE_EXIT! EQU 0 set "OVERALL_EXIT=1"
echo.
echo ================================================================
if !OVERALL_EXIT! EQU 0 (
    echo   [SUCCESS] Mode 1 SystemUndo stealth hardening completed!
    echo   ----------------------------------------------------------------
    echo   * Native System Restore points: Active (Daily + Startup)
    echo   * VSS Shadow Storage Quota:     10%% Headroom Hardened
    echo   * 24-Hour Creation Throttle:    Disabled (Unlimited Checkpoints)
    echo   * Resident Third-Party Files:   0 (Zero EXEs, Zero Shortcuts)
    if "!DID_CAPTURE!"=="1" (
    echo   * Local Disaster Image:         C:\SystemImages\_baseline.wim
    )
    echo   ----------------------------------------------------------------
    echo   Technician may safely unplug USB drive now.
) else (
    echo   [FAILED] Mode 1 setup encountered an error. Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log
)
echo ================================================================
echo.
pause
exit /b !OVERALL_EXIT!
