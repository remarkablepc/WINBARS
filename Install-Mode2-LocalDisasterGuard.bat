@echo off
setlocal EnableDelayedExpansion
title WINBARS One-Click Installer - Mode 2 (LocalDisasterGuard)
:: ============================================================================
::  WINBARS ONE-CLICK INSTALLER - MODE 2 : LOCAL DISASTER GUARD
::  Applies all Mode 2 defaults automatically. Asks only 1 question:
::    Windows system image drive (default C: = C:\SystemRecovery)
::  Mode 2 is a single-drive design: no external data drive is used.
::  Requires WINBARS.exe (or WINBARS.ps1) in this same folder.
:: ============================================================================

:: ---- 0. Parse Command Line Arguments ----
set "QUIET_MODE=0"
set "FORCE_VANILLA=0"
set "USE_BRANDED=0"
set "ARG_BRAND="
set "ARG_IMAGE="
set "ARG_BASELINE="

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
if /i "!A!"=="/nowhitelist" ( set "ARG_WHITELIST=N" & shift & goto PARSE_LOOP )
if /i "!A!"=="/whitelist" ( set "ARG_WHITELIST=Y" & shift & goto PARSE_LOOP )

:: Switches with values
if /i "!A:~0,7!"=="/brand:" ( set "ARG_BRAND=!A:~7!" & shift & goto PARSE_LOOP )
if /i "!A:~0,7!"=="/image:" ( set "ARG_IMAGE=!A:~7!" & shift & goto PARSE_LOOP )
if /i "!A:~0,10!"=="/baseline:" ( set "ARG_BASELINE=!A:~10!" & shift & goto PARSE_LOOP )

shift
goto PARSE_LOOP

:SHOW_HELP
echo.
echo ========================================================================
echo   WINBARS ONE-CLICK INSTALLER - MODE 2 : LOCAL DISASTER GUARD
echo ========================================================================
echo   Local Partition Bare-Metal DISM Image + Desktop Suite (Single-Drive).
echo.
echo SYNTAX:
echo   Install-Mode2-LocalDisasterGuard.bat [/?] [/Quiet] [/Vanilla] [/Brand:Name]
echo                                        [/Image:DriveOrPath] [/Baseline:Y^|N]
echo.
echo SWITCHES:
echo   [/?] or [/Help]   Display this help screen and exit immediately.
echo   /Quiet            Unattended mode: suppresses completion pause prompts.
echo   /Vanilla          Enforces 100%% unbranded deployment.
echo   /Brand:Name       Applies branding token profile from brands\ folder.
echo                     Accepts filename, filename.json, or company name.
echo   /Image:Path       Pre-answers Question 1: System image drive (e.g. C or D:\Images).
echo   /Baseline:Y^|N     Pre-answers Question 2: capture permanent baseline image now?
echo.
echo EXAMPLES:
echo   Install-Mode2-LocalDisasterGuard.bat
echo   Install-Mode2-LocalDisasterGuard.bat /Image:C /Baseline:Y /Quiet
echo   Install-Mode2-LocalDisasterGuard.bat /Brand:RemarkablePC /Quiet
echo ========================================================================
echo.
exit /b 0

:ARGS_DONE
if defined ARG_BRAND set "ARG_BRAND=!ARG_BRAND:"=!"
if defined ARG_IMAGE set "ARG_IMAGE=!ARG_IMAGE:"=!"
if defined ARG_BASELINE set "ARG_BASELINE=!ARG_BASELINE:"=!"

echo.
echo ================================================================
echo   WINBARS ONE-CLICK INSTALLER - MODE 2 : LOCAL DISASTER GUARD
echo ================================================================
echo   What Mode 2 does:
echo     - Monthly bare-metal DISM system image for offline recovery
echo     - Daily restore points + VSS self-healing
echo     - Single-drive design - no external drive required
echo     - Default image location: C:\SystemRecovery
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
    echo           installer in: %~dp0
    echo.
    if not "!QUIET_MODE!"=="1" pause
    exit /b 1
)

:: ---- 4. Resolve Brand Profile if specified ----
if defined ARG_BRAND (
    echo.
    echo   Resolving brand profile: "!ARG_BRAND!"...
    set "RESOLVED_BRAND="
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$brand = '!ARG_BRAND!'; $root = '%~dp0'; $candidates = @( $brand, ($root + $brand), ($root + 'brands\' + $brand), ($root + 'brands\' + $brand + '.json') ); foreach($c in $candidates) { if (Test-Path -LiteralPath $c) { [System.IO.File]::WriteAllText($env:TEMP + '\winbars_brand_res.txt', (Resolve-Path -LiteralPath $c).Path); exit 0 } }; $files = Get-ChildItem -Path ($root + 'brands\*.json') -ErrorAction SilentlyContinue; foreach($f in $files) { try { $j = Get-Content -LiteralPath $f.FullName -Raw | ConvertFrom-Json; $comp = if ($j.SupportBranding.CompanyName) { $j.SupportBranding.CompanyName } elseif ($j.CompanyName) { $j.CompanyName } else { '' }; if ($comp -and ($comp -like ('*' + $brand + '*') -or $brand -like ('*' + $comp + '*'))) { [System.IO.File]::WriteAllText($env:TEMP + '\winbars_brand_res.txt', $f.FullName); exit 0 } } catch {} }; exit 1" >nul 2>&1
    if exist "%TEMP%\winbars_brand_res.txt" (
        set /p RESOLVED_BRAND=<"%TEMP%\winbars_brand_res.txt"
        del /f /q "%TEMP%\winbars_brand_res.txt" >nul 2>&1
    )
    if defined RESOLVED_BRAND (
        echo   [OK] Applied brand profile: !RESOLVED_BRAND!
        copy /y "!RESOLVED_BRAND!" "%~dp0config\branding.json" >nul 2>&1
        copy /y "!RESOLVED_BRAND!" "%~dp0branding.json" >nul 2>&1
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

:: ---- 6. Question 1 of 1: System image drive ----
set "IMAGE_LETTER="
set "IMG_PATH="

if defined ARG_IMAGE (
    set "TEST_CHAR=!ARG_IMAGE:~2,1!"
    if "!TEST_CHAR!"=="" (
        set "IMAGE_LETTER=!ARG_IMAGE:~0,1!"
        set "IMG_PATH=!IMAGE_LETTER!:\SystemRecovery"
    ) else (
        set "IMG_PATH=!ARG_IMAGE!"
    )
    echo.
    echo   System image location specified via switch: !IMG_PATH!
    goto WRITE_CONFIG
)

echo   Available drives (non-C):
echo   ----------------------------------------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -in 2,3 -and $_.DeviceID -ne 'C:' } | Sort-Object DeviceID | ForEach-Object { '{0}  {1}  (Free: {2:N1} GB)' -f $_.DeviceID, $_.VolumeName, ($_.FreeSpace/1GB) }"
echo   ----------------------------------------------------------------

:ASK_IMAGE
echo.
echo   QUESTION 1 OF 1 - WINDOWS SYSTEM IMAGE DRIVE
echo   Mode 2 stores a monthly bare-metal image for offline recovery.
echo   Default: C: (local folder C:\SystemRecovery).
set /p IMG_IN="   Enter drive letter or press ENTER for default [C]: "
set "IMG_IN=!IMG_IN: =!"
if not defined IMG_IN set "IMG_IN=C"
echo !IMG_IN! | findstr /r "^[A-Za-z]$" >nul
if !errorLevel! NEQ 0 (
    echo   [ERROR] Invalid entry - enter a single drive letter A-Z.
    goto ASK_IMAGE
)
if not exist "!IMG_IN!:\" (
    echo   [ERROR] Drive !IMG_IN!: does not exist or is not ready.
    goto ASK_IMAGE
)
set "IMAGE_LETTER=!IMG_IN!"
set "IMG_PATH=!IMAGE_LETTER!:\SystemRecovery"

:WRITE_CONFIG
:: ---- 7. Write the chosen image drive into the active config ----
set "CFG_EXIT=0"
echo.
echo   Writing backup destination to config:
echo     !ACTIVE_CONFIG_PATH!
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='!ACTIVE_CONFIG_PATH!'; $dir=Split-Path -Parent $p; if($dir -and -not (Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Path $dir -Force | Out-Null }; if(Test-Path -LiteralPath $p){ $c=Get-Content -LiteralPath $p -Raw | ConvertFrom-Json } else { $c='{}' | ConvertFrom-Json }; if($null -eq $c.StorageAndHardware){ $c | Add-Member -NotePropertyName StorageAndHardware -NotePropertyValue @{} -Force }; $c.StorageAndHardware | Add-Member -NotePropertyName ImageBackupPath -NotePropertyValue '!IMG_PATH!' -Force; $c | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $p -Encoding UTF8"
set "CFG_EXIT=!errorLevel!"
if !CFG_EXIT! EQU 0 (
    echo   [OK] Config updated.  Image path: !IMG_PATH!
) else (
    echo   [ERROR] Config update failed with exit code !CFG_EXIT!.
)

:: ---- 8. Install WINBARS suite to C:\Tools\WINBARS ----
echo.
echo   Installing WINBARS suite to C:\Tools\WINBARS...
echo   ----------------------------------------------------------------
!RUN_CMD! -InstallLocal !BRAND_FLAG!
set "INSTALL_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !INSTALL_EXIT! EQU 0 (
    echo   [OK] Suite installed to C:\Tools\WINBARS.
) else (
    echo   [ERROR] Installation failed with exit code !INSTALL_EXIT!.
    echo          Cannot proceed with profile setup.
    echo.
    echo ================================================================
    echo   [FAILED] Install step failed. Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log
    echo ================================================================
    echo.
    if not "!QUIET_MODE!"=="1" pause
    exit /b !INSTALL_EXIT!
)

:: ---- 9. Switch to the installed engine for profile application ----
set "INSTALLED_EXE=C:\Tools\WINBARS\WINBARS.exe"
set "INSTALLED_PS1=C:\Tools\WINBARS\WINBARS.ps1"
if exist "!INSTALLED_EXE!" (
    set RUN_CMD="!INSTALLED_EXE!"
) else if exist "!INSTALLED_PS1!" (
    set RUN_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!INSTALLED_PS1!"
) else (
    echo   [ERROR] Installed engine not found at C:\Tools\WINBARS after install step.
    echo          The file copy may have failed silently. Check the source folder.
    echo.
    if not "!QUIET_MODE!"=="1" pause
    exit /b 1
)

:: ---- 10. Resolve config path for installed location ----
if exist "C:\Tools\WINBARS\config\config.json" (
    set "ACTIVE_CONFIG_PATH=C:\Tools\WINBARS\config\config.json"
)

:: ---- 11. Apply the profile (all other settings use mode defaults) ----
echo.
echo   Applying Mode 2 LocalDisasterGuard defaults and scheduling tasks...
echo   ----------------------------------------------------------------
!RUN_CMD! -SetProfile LocalDisasterGuard !BRAND_FLAG! -Unattended -ConfigPath "!ACTIVE_CONFIG_PATH!"
set "PROFILE_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !PROFILE_EXIT! EQU 0 (
    echo   [OK] Mode 2 LocalDisasterGuard profile applied successfully.
) else (
    echo   [ERROR] Profile apply failed with exit code !PROFILE_EXIT!.
)

:: ---- 12. Optional: capture a permanent baseline image now ----
set "BASE_IN="
if defined ARG_BASELINE (
    set "BASE_IN=!ARG_BASELINE!"
    echo.
    echo   Baseline capture pre-set via switch: !BASE_IN!
) else (
    echo.
    set /p BASE_IN="   Capture a permanent baseline system image now (_baseline.wim)? (Y/N) [Default: N]: "
)
if /i "!BASE_IN!"=="Y" (
    echo.
    echo   Capturing permanent baseline image (never rotated or deleted)...
    !RUN_CMD! -Action SystemImage -Baseline -Unattended
    set "BASE_EXIT=!errorLevel!"
    if !BASE_EXIT! EQU 0 (
        echo   [OK] Permanent baseline image captured successfully.
    ) else (
        echo   [WARN] Baseline capture failed with exit code !BASE_EXIT!.
        echo          The install itself is still complete. You can re-run
        echo          Capture-Baseline.bat at any time.
    )
)

:: ---- 13. Optional: Windows Defender Whitelisting ----
set "WL_IN="
if defined ARG_WHITELIST (
    set "WL_IN=!ARG_WHITELIST!"
    echo.
    echo   Windows Defender whitelisting pre-set via switch: !WL_IN!
) else if not "!QUIET_MODE!"=="1" (
    echo.
    set /p WL_IN="   Add Windows Defender folder & process exclusions for WINBARS? (Y/N) [Default: Y]: "
) else (
    set "WL_IN=Y"
)
if not defined WL_IN set "WL_IN=Y"
if /i "!WL_IN!"=="Y" (
    if exist "%~dp0Whitelist-WINBARS.bat" (
        call "%~dp0Whitelist-WINBARS.bat" /quiet
    ) else if exist "C:\Tools\WINBARS\Whitelist-WINBARS.bat" (
        call "C:\Tools\WINBARS\Whitelist-WINBARS.bat" /quiet
    )
)

:: ---- 14. Final verdict ----
set "OVERALL_EXIT=0"
if not !INSTALL_EXIT! EQU 0 set "OVERALL_EXIT=1"
if not !CFG_EXIT! EQU 0 set "OVERALL_EXIT=1"
if not !PROFILE_EXIT! EQU 0 set "OVERALL_EXIT=1"
echo.
echo ================================================================
if !OVERALL_EXIT! EQU 0 (
    echo   [SUCCESS] Mode 2 LocalDisasterGuard installation completed.
    echo   Tip: Run Capture-Baseline.bat to pin a permanent baseline image.
    echo   Tip: To make this backup drive directly bootable, run Create-RescueUSB.bat!
) else (
    echo   [FAILED] One or more steps failed. Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log
)
echo ================================================================
echo.
if not "!QUIET_MODE!"=="1" pause
exit /b !OVERALL_EXIT!