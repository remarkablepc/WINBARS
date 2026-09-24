@echo off
setlocal EnableDelayedExpansion
title WINBARS One-Click Installer - Mode 0 (ZeroFootprint)
:: ============================================================================
::  WINBARS ONE-CLICK INSTALLER - MODE 0 : ZERO FOOTPRINT
::  Applies all Mode 0 defaults automatically. Asks only 2 questions:
::    1. Data backup drive      2. Windows system image drive
::  Requires WINBARS.exe (or WINBARS.ps1) in this same folder.
:: ============================================================================

:: ---- 0. Parse Command Line Arguments ----
set "QUIET_MODE=0"
set "FORCE_VANILLA=0"
set "USE_BRANDED=0"
set "ARG_BRAND="
set "ARG_DATA="
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

:: Flags
if /i "!A!"=="/quiet" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/unattended" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/vanilla" ( set "FORCE_VANILLA=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/reset" ( set "ARG_RESET=1" & shift & goto PARSE_LOOP )

:: Switches with values
if /i "!A:~0,7!"=="/brand:" ( set "ARG_BRAND=!A:~7!" & shift & goto PARSE_LOOP )
if /i "!A:~0,6!"=="/data:" ( set "ARG_DATA=!A:~6!" & shift & goto PARSE_LOOP )
if /i "!A:~0,7!"=="/image:" ( set "ARG_IMAGE=!A:~7!" & shift & goto PARSE_LOOP )

shift
goto PARSE_LOOP

:SHOW_HELP
echo.
echo ========================================================================
echo   WINBARS ONE-CLICK INSTALLER - MODE 0 : ZERO FOOTPRINT
echo ========================================================================
echo   Zero resident files on PC (100%% native Windows backup automation).
echo.
echo SYNTAX:
echo   Install-Mode0-ZeroFootprint.bat [/?] [/Quiet] [/Vanilla] [/Brand:Name]
echo                                   [/Data:DriveOrPath] [/Image:DriveOrPath]
echo.
echo SWITCHES:
echo   [/?] or [/Help]   Display this help screen and exit immediately.
echo   /Quiet            Unattended mode: suppresses completion pause prompts.
echo   /Vanilla          Enforces 100%% unbranded deployment.
echo   /Brand:Name       Applies branding token profile from brands\ folder.
echo                     Accepts filename, filename.json, or company name.
echo   /Data:Path        Pre-answers Question 1: Data backup drive (e.g. E:).
echo   /Image:Path       Pre-answers Question 2: System image drive (e.g. E:).
echo.
echo EXAMPLES:
echo   Install-Mode0-ZeroFootprint.bat
echo   Install-Mode0-ZeroFootprint.bat /Data:D /Image:D /Quiet
echo   Install-Mode0-ZeroFootprint.bat /Brand:RemarkablePC /Quiet
echo ========================================================================
echo.
exit /b 0

:ARGS_DONE
if defined ARG_BRAND set "ARG_BRAND=!ARG_BRAND:"=!"
if defined ARG_DATA set "ARG_DATA=!ARG_DATA:"=!"
if defined ARG_IMAGE set "ARG_IMAGE=!ARG_IMAGE:"=!"

echo.
echo ================================================================
echo   WINBARS ONE-CLICK INSTALLER - MODE 0 : ZERO FOOTPRINT
echo ================================================================
echo   What Mode 0 does:
echo     - Zero resident files on this PC (100 percent native engines)
echo     - Daily restore points + user file mirror to the backup drive
echo     - Bare-metal images (wbadmin) + BitLocker key archival
echo     - No tray, no watchdog, no desktop shortcuts
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

:: ---- 6. Auto-detect and pre-check drives ----
set "DATA_LETTER="
set "IMAGE_LETTER="
set "IMG_PATH="

if defined ARG_DATA (
    set "DATA_LETTER=!ARG_DATA:~0,1!"
    echo.
    echo   Data backup drive specified via switch: !DATA_LETTER!:
)
if defined ARG_IMAGE (
    set "TEST_CHAR=!ARG_IMAGE:~2,1!"
    if "!TEST_CHAR!"=="" (
        set "IMAGE_LETTER=!ARG_IMAGE:~0,1!"
        set "IMG_PATH=!IMAGE_LETTER!:\WindowsImageBackup"
    ) else (
        set "IMG_PATH=!ARG_IMAGE!"
    )
    echo   System image location specified via switch: !IMG_PATH!
)

if defined DATA_LETTER if defined IMG_PATH goto WRITE_CONFIG

echo   Available backup drives (non-C):
echo   ----------------------------------------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -in 2,3 -and $_.DeviceID -ne 'C:' } | Sort-Object DeviceID | ForEach-Object { '{0}  {1}  (Free: {2:N1} GB)' -f $_.DeviceID, $_.VolumeName, ($_.FreeSpace/1GB) }"
echo   ----------------------------------------------------------------

set "AUTO_DRIVE="
powershell -NoProfile -ExecutionPolicy Bypass -Command "$d=Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -and $_.DeviceID -ne 'C:' } | Select-Object -First 1; if($null -eq $d){ $d=Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -in 2,3 -and $_.DeviceID -ne 'C:' } | Select-Object -First 1 }; if($d){ ($d.DeviceID).TrimEnd(':') | Set-Content -Path ($env:TEMP + '\winbars_auto_drive.txt') -Encoding ASCII }" >nul 2>&1
if exist "%TEMP%\winbars_auto_drive.txt" (
    set /p AUTO_DRIVE=<"%TEMP%\winbars_auto_drive.txt"
    del /f /q "%TEMP%\winbars_auto_drive.txt" >nul 2>&1
)

:: ---- 7. Data backup drive ----
if not defined DATA_LETTER (
    set "DATA_LETTER=!AUTO_DRIVE!"
)
if defined DATA_LETTER (
    echo   Data backup drive target: !DATA_LETTER!:
) else (
    echo   [i] No external drive detected - WINBARS will auto-resolve the target drive at runtime.
)

:: ---- 8. System image drive ----
if not defined IMG_PATH (
    set "IMG_DEFAULT=!DATA_LETTER!"
    if not defined IMG_DEFAULT set "IMG_DEFAULT=!AUTO_DRIVE!"
    if defined IMG_DEFAULT (
        set "IMAGE_LETTER=!IMG_DEFAULT!"
        set "IMG_PATH=!IMAGE_LETTER!:\WindowsImageBackup"
        echo   Windows System Image target: !IMG_PATH!
    ) else (
        echo   [i] No image drive specified - WINBARS will auto-resolve at runtime.
    )
)

:WRITE_CONFIG
:: ---- 9. Write chosen drives into the active config ----
set "CFG_EXIT=0"
if not defined DATA_LETTER if not defined IMG_PATH goto SKIP_CFG
echo.
echo   Writing backup destinations to config:
echo     !ACTIVE_CONFIG_PATH!
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='!ACTIVE_CONFIG_PATH!'; $dir=Split-Path -Parent $p; if($dir -and -not (Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Path $dir -Force | Out-Null }; if(Test-Path -LiteralPath $p){ $c=Get-Content -LiteralPath $p -Raw | ConvertFrom-Json } else { $c='{}' | ConvertFrom-Json }; if($null -eq $c.StorageAndHardware){ $c | Add-Member -NotePropertyName StorageAndHardware -NotePropertyValue @{} -Force }; if('!DATA_LETTER!' -ne ''){ $c.StorageAndHardware | Add-Member -NotePropertyName PreferredExternalDriveLetter -NotePropertyValue '!DATA_LETTER!' -Force }; if('!IMG_PATH!' -ne ''){ $c.StorageAndHardware | Add-Member -NotePropertyName ImageBackupPath -NotePropertyValue '!IMG_PATH!' -Force }; $c | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $p -Encoding UTF8"
set "CFG_EXIT=!errorLevel!"
if !CFG_EXIT! EQU 0 (
    echo   [OK] Config updated.  Data drive: !DATA_LETTER!  Image path: !IMG_PATH!
) else (
    echo   [ERROR] Config update failed with exit code !CFG_EXIT!.
)
:SKIP_CFG

:: ---- 10. Apply the profile (all other settings use mode defaults) ----
echo.
echo   Applying Mode 0 ZeroFootprint defaults and scheduling tasks...
echo   ----------------------------------------------------------------
!RUN_CMD! -SetProfile ZeroFootprint !BRAND_FLAG! -Unattended -ConfigPath "!ACTIVE_CONFIG_PATH!"
set "PROFILE_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !PROFILE_EXIT! EQU 0 (
    echo   [OK] Mode 0 ZeroFootprint profile applied successfully.
) else (
    echo   [ERROR] Profile apply failed with exit code !PROFILE_EXIT!.
)

:: ---- 11. Final verdict ----
set "OVERALL_EXIT=0"
if not !CFG_EXIT! EQU 0 set "OVERALL_EXIT=1"
if not !PROFILE_EXIT! EQU 0 set "OVERALL_EXIT=1"
echo.
echo ================================================================
if !OVERALL_EXIT! EQU 0 (
    echo   [SUCCESS] Mode 0 ZeroFootprint setup completed.
    echo   No files were installed to this PC.
    echo   Tasks are registered with Windows Task Scheduler.
    echo   Tip: To make this backup drive directly bootable, run Create-RescueUSB.bat!
) else (
    echo   [FAILED] One or more steps failed. Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log
)
echo ================================================================
echo.
if not "!QUIET_MODE!"=="1" pause
exit /b !OVERALL_EXIT!