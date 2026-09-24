@echo off
setlocal EnableDelayedExpansion
title WINBARS One-Click Installer - Mode 1 (SystemUndo - Service Warranty Baseline)
:: ============================================================================
::  WINBARS ONE-CLICK INSTALLER - MODE 1 : SYSTEM UNDO (SERVICE WARRANTY BASELINE)
::  The Universal Service Warranty Baseline: Native Windows rollback hardening
::  with ZERO resident EXEs, ZERO shortcuts, and ZERO background daemons.
::  Hardens native Windows recovery (daily unthrottled System Restore points,
::  VSS auto-healing, RegBack) with an optional baseline system image
::  (C:\SystemRecovery\_baseline.wim) if disk space >= 25 GB.
::  Requires WINBARS.exe (or WINBARS.ps1) in this same folder.
:: ============================================================================

:: ---- 0. Parse Command Line Arguments ----
set "QUIET_MODE=0"
set "FORCE_VANILLA=0"
set "USE_BRANDED=0"
set "ARG_BRAND="
set "ARG_BASELINE="
set "ARG_IMAGE="

:PARSE_LOOP
if "%~1"=="" goto ARGS_DONE
set "A=%~1"

:: Help triggers
if /i "!A!"=="/?" goto SHOW_HELP
if /i "!A!"=="-?" goto SHOW_HELP
if /i "!A!"=="/help" goto SHOW_HELP
if /i "!A!"=="--help" goto SHOW_HELP
if /i "!A!"=="help" goto SHOW_HELP

:: Unattended & Vanilla flags
if /i "!A!"=="/quiet" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/unattended" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/vanilla" ( set "FORCE_VANILLA=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/reset" ( set "ARG_RESET=1" & shift & goto PARSE_LOOP )

if /i "!A:~0,7!"=="/brand:" ( set "ARG_BRAND=!A:~7!" & shift & goto PARSE_LOOP )
if /i "!A:~0,10!"=="/baseline:" ( set "ARG_BASELINE=!A:~10!" & shift & goto PARSE_LOOP )
if /i "!A:~0,7!"=="/image:" ( set "ARG_IMAGE=!A:~7!" & shift & goto PARSE_LOOP )
if /i "!A:~0,10!"=="/customer:" ( set "ARG_CUSTOMER=!A:~10!" & shift & goto PARSE_LOOP )
if /i "!A:~0,11!"=="/shoplabel:" ( set "ARG_SHOPLABEL=!A:~11!" & shift & goto PARSE_LOOP )
if /i "!A:~0,8!"=="/ticket:" ( set "ARG_SHOPLABEL=!A:~8!" & shift & goto PARSE_LOOP )
if /i "!A:~0,7!"=="/label:" ( set "ARG_SHOPLABEL=!A:~7!" & shift & goto PARSE_LOOP )

shift
goto PARSE_LOOP

:SHOW_HELP
echo.
echo ========================================================================
echo   WINBARS ONE-CLICK INSTALLER - MODE 1 : SYSTEM UNDO
echo   (Service Warranty Baseline - 0 Resident Files)
echo ========================================================================
echo   Hardens native Windows rollback with daily unthrottled restore points,
echo   VSS shadow storage auto-healing, and optional baseline image.
echo.
echo SYNTAX:
echo   Install-Mode1-SystemUndo.bat [/?] [/Quiet] [/Vanilla] [/Brand:Name]
echo                                [/Baseline:Y^|N] [/Image:Y^|N]
echo.
echo SWITCHES:
echo   [/?] or [/Help]   Display this help screen and exit immediately.
echo   /Quiet            Unattended mode: suppresses completion pause prompts.
echo   /Vanilla          Enforces 100%% unbranded deployment.
echo   /Brand:Name       Applies branding token profile from brands\ folder.
echo                     Accepts filename, filename.json, or company name.
echo   /Baseline:Y^|N     Pre-answers Question 1: capture baseline system image?
echo   /Image:Y^|N        Alias for /Baseline:Y^|N in Mode 1.
echo.
echo EXAMPLES:
echo   Install-Mode1-SystemUndo.bat
echo   Install-Mode1-SystemUndo.bat /Baseline:Y /Quiet
echo   Install-Mode1-SystemUndo.bat /Brand:RemarkablePC /Quiet
echo ========================================================================
echo.
exit /b 0

:ARGS_DONE
if defined ARG_BRAND set "ARG_BRAND=!ARG_BRAND:"=!"
if defined ARG_BASELINE set "ARG_BASELINE=!ARG_BASELINE:"=!"
if defined ARG_IMAGE (
    set "ARG_IMAGE=!ARG_IMAGE:"=!"
    if not defined ARG_BASELINE (
        if /i "!ARG_IMAGE!"=="Y" set "ARG_BASELINE=Y"
        if /i "!ARG_IMAGE!"=="N" set "ARG_BASELINE=N"
    )
)

echo.
echo ================================================================
echo   WINBARS ONE-CLICK INSTALLER - MODE 1 : SYSTEM UNDO
echo   (Service Warranty Baseline - 0 Resident EXEs)
echo ================================================================
echo   What Mode 1 does:
echo     - Daily unthrottled system restore points (Native Windows)
echo     - VSS writer auto-heal + shadow storage guard (10%% quota)
echo     - Driver/MSI install checkpoints
echo     - Optional baseline system image (C:\SystemRecovery\_baseline.wim)
echo     - Zero resident EXEs, zero shortcuts, zero tray, zero daemons
echo.
echo   Mode 1 deployment - exactly 1 optional question will be asked.
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

:: ---- 3. Detect execution engine ----
set "RUN_CMD="
if exist "%ROOT_DIR%WINBARS.exe" (
    set "RUN_CMD=^"%ROOT_DIR%WINBARS.exe^""
) else if exist "%ROOT_DIR%WINBARS.ps1" (
    set "RUN_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File ^"%ROOT_DIR%WINBARS.ps1^""
)
if not defined RUN_CMD (
    echo.
    echo   [ERROR] WINBARS.exe or WINBARS.ps1 was not found next to this
    echo           installer in: %ROOT_DIR%
    echo.
    if not "!QUIET_MODE!"=="1" pause
    exit /b 1
)

:: ---- 4. Resolve Brand Profile if specified ----
if defined ARG_BRAND (
    echo.
    echo   Resolving brand profile: "!ARG_BRAND!"...
    set "RESOLVED_BRAND="
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$brand = '!ARG_BRAND!'; $root = '%ROOT_DIR%'; $candidates = @( $brand, ($root + $brand), ($root + 'brands\' + $brand), ($root + 'brands\' + $brand + '.json') ); foreach($c in $candidates) { if (Test-Path -LiteralPath $c) { [System.IO.File]::WriteAllText($env:TEMP + '\winbars_brand_res.txt', (Resolve-Path -LiteralPath $c).Path); exit 0 } }; $files = Get-ChildItem -Path ($root + 'brands\*.json') -ErrorAction SilentlyContinue; foreach($f in $files) { try { $j = Get-Content -LiteralPath $f.FullName -Raw | ConvertFrom-Json; $comp = if ($j.SupportBranding.CompanyName) { $j.SupportBranding.CompanyName } elseif ($j.CompanyName) { $j.CompanyName } else { '' }; if ($comp -and ($comp -like ('*' + $brand + '*') -or $brand -like ('*' + $comp + '*'))) { [System.IO.File]::WriteAllText($env:TEMP + '\winbars_brand_res.txt', $f.FullName); exit 0 } } catch {} }; exit 1" >nul 2>&1
    if exist "%TEMP%\winbars_brand_res.txt" (
        set /p RESOLVED_BRAND=<"%TEMP%\winbars_brand_res.txt"
        del /f /q "%TEMP%\winbars_brand_res.txt" >nul 2>&1
    )
    if defined RESOLVED_BRAND (
        echo   [OK] Applied brand profile: !RESOLVED_BRAND!
        copy /y "!RESOLVED_BRAND!" "%ROOT_DIR%config\branding.json" >nul 2>&1
        copy /y "!RESOLVED_BRAND!" "%ROOT_DIR%branding.json" >nul 2>&1
        if not exist "C:\ProgramData\WINBARS" mkdir "C:\ProgramData\WINBARS" >nul 2>&1
        copy /y "!RESOLVED_BRAND!" "C:\ProgramData\WINBARS\branding.json" >nul 2>&1
        if exist "C:\Tools\WINBARS" copy /y "!RESOLVED_BRAND!" "C:\Tools\WINBARS\branding.json" >nul 2>&1
        set "USE_BRANDED=1"
    ) else (
        echo   [WARN] Brand profile not found for '!ARG_BRAND!'. Using standard branding.
    )
)

set "BRAND_FLAG=-Vanilla"
if "!USE_BRANDED!"=="1" set "BRAND_FLAG=-Branded"
if "!FORCE_VANILLA!"=="1" set "BRAND_FLAG=-Vanilla"

:: ---- 5. Resolve the active config file (same order the engine uses) ----
set "ACTIVE_CONFIG_PATH="
if exist "%ROOT_DIR%config\config.json" (
    set "ACTIVE_CONFIG_PATH=%ROOT_DIR%config\config.json"
) else if exist "%ROOT_DIR%config.json" (
    set "ACTIVE_CONFIG_PATH=%ROOT_DIR%config.json"
) else if exist "C:\ProgramData\WINBARS\config.json" (
    set "ACTIVE_CONFIG_PATH=C:\ProgramData\WINBARS\config.json"
)
if not defined ACTIVE_CONFIG_PATH (
    if not exist "%ROOT_DIR%config" mkdir "%ROOT_DIR%config" >nul 2>&1
    set "ACTIVE_CONFIG_PATH=%ROOT_DIR%config\config.json"
)

if "!ARG_RESET!"=="1" (
    echo.
    echo   Executing pre-install factory reset (/Reset specified)...
    echo   ----------------------------------------------------------------
    !RUN_CMD! -ResetSuite -Unattended
    echo   ----------------------------------------------------------------
)

:: ---- 6. Apply Mode 1 SystemUndo profile (0 Resident EXEs) ----
echo.
echo   Applying Mode 1 SystemUndo stealth hardening...
echo   ----------------------------------------------------------------
set "EXTRA_FLAGS="
if defined ARG_CUSTOMER set "EXTRA_FLAGS=!EXTRA_FLAGS! -Customer "!ARG_CUSTOMER!""
if defined ARG_SHOPLABEL set "EXTRA_FLAGS=!EXTRA_FLAGS! -ShopLabel "!ARG_SHOPLABEL!""

!RUN_CMD! -SetProfile SystemUndo !BRAND_FLAG! -Unattended -ConfigPath "!ACTIVE_CONFIG_PATH!" !EXTRA_FLAGS!
set "PROFILE_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !PROFILE_EXIT! EQU 0 (
    echo   [OK] Mode 1 SystemUndo hardening applied successfully.
) else (
    echo   [ERROR] Profile apply failed with exit code !PROFILE_EXIT!.
)

:: ---- 7. Question 1 of 1: Optional permanent baseline system image ----
set "FREE_GB=0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$vol = Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='C:'\" -ErrorAction SilentlyContinue; if ($vol) { $gb = [math]::Round($vol.FreeSpace / 1GB, 1); [System.IO.File]::WriteAllText($env:TEMP + '\winbars_c_free.txt', \"$gb\") }" >nul 2>&1
if exist "%TEMP%\winbars_c_free.txt" (
    set /p FREE_GB=<"%TEMP%\winbars_c_free.txt"
    del /f /q "%TEMP%\winbars_c_free.txt" >nul 2>&1
)

echo.
echo   BASELINE SYSTEM IMAGE STATUS
echo   Drive C: has !FREE_GB! GB free space.
set "BASE_IN="
if defined ARG_BASELINE (
    set "BASE_IN=!ARG_BASELINE!"
    echo   Baseline capture pre-set via switch: !BASE_IN!
) else (
    set "BASE_IN=N"
    echo   Baseline image capture: Skipped by default (Restore points & VSS auto-healing active).
)
set "IMAGE_EXIT=0"
set "DID_CAPTURE=0"
if /i "!BASE_IN!"=="Y" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "if ([double]'!FREE_GB!' -ge 25.0) { exit 0 } else { exit 1 }" >nul 2>&1
    if !errorLevel! EQU 0 (
        echo.
        echo   Capturing local baseline system image (C:\SystemRecovery\_baseline.wim)...
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

:: ---- 7b. Automatically whitelist C:\SystemRecovery in Windows Defender ----
echo.
echo   Configuring Windows Defender exclusion for C:\SystemRecovery...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "if (Get-Command Add-MpPreference -ErrorAction SilentlyContinue) {" ^
    "    try {" ^
    "        Add-MpPreference -ExclusionPath 'C:\SystemRecovery' -ErrorAction SilentlyContinue;" ^
    "        Write-Host '  [OK] C:\SystemRecovery excluded from Windows Defender heuristics.' -ForegroundColor Green;" ^
    "    } catch { }" ^
    "}" >nul 2>&1

:: ---- 8. Final verdict ----
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
    echo   * Defender Script Exclusion:    C:\SystemRecovery (Protected)
    echo   * Resident Third-Party Files:   0 (Zero EXEs, Zero Shortcuts)
    if "!DID_CAPTURE!"=="1" (
    echo   * Local Disaster Image:         C:\SystemRecovery\_baseline.wim
    )
    echo   ----------------------------------------------------------------
    echo   Technician may safely unplug USB drive now.
) else (
    echo   [FAILED] Mode 1 setup encountered an error. Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log
)
echo ================================================================
echo.
if not "!QUIET_MODE!"=="1" pause
exit /b !OVERALL_EXIT!