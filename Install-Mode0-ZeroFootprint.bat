@echo off
setlocal EnableDelayedExpansion
title WINBARS One-Click Installer - Mode 0 (ZeroFootprint)
:: ============================================================================
::  WINBARS ONE-CLICK INSTALLER - MODE 0 : ZERO FOOTPRINT
::  Applies all Mode 0 defaults automatically. Asks only 2 questions:
::    1. Data backup drive      2. Windows system image drive
::  Requires WINBARS.exe (or WINBARS.ps1) in this same folder.
:: ============================================================================

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

:: ---- 5. List available drives ----
echo   Available backup drives (non-C):
echo   ----------------------------------------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -in 2,3 -and $_.DeviceID -ne 'C:' } | Sort-Object DeviceID | ForEach-Object { '{0}  {1}  (Free: {2:N1} GB)' -f $_.DeviceID, $_.VolumeName, ($_.FreeSpace/1GB) }"
echo   ----------------------------------------------------------------

:: ---- 6. Auto-detect a sensible default drive ----
set "AUTO_DRIVE="
powershell -NoProfile -ExecutionPolicy Bypass -Command "$d=Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -and $_.DeviceID -ne 'C:' } | Select-Object -First 1; if($null -eq $d){ $d=Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -in 2,3 -and $_.DeviceID -ne 'C:' } | Select-Object -First 1 }; if($d){ ($d.DeviceID).TrimEnd(':') | Set-Content -Path ($env:TEMP + '\winbars_auto_drive.txt') -Encoding ASCII }" >nul 2>&1
if exist "%TEMP%\winbars_auto_drive.txt" (
    set /p AUTO_DRIVE=<"%TEMP%\winbars_auto_drive.txt"
    del /f /q "%TEMP%\winbars_auto_drive.txt" >nul 2>&1
)

:: ---- 7. Question 1 of 2: Data backup drive ----
:ASK_DATA
set "DATA_LETTER="
echo.
echo   QUESTION 1 OF 2 - DATA BACKUP DRIVE
echo   Personal files, File History and daily syncs are mirrored here.
set /p DATA_IN="   Enter drive letter (e.g. E) or press ENTER for default [!AUTO_DRIVE!]: "
set "DATA_IN=!DATA_IN: =!"
if not defined DATA_IN set "DATA_IN=!AUTO_DRIVE!"
if not defined DATA_IN (
    echo   [i] No external drive detected - WINBARS will auto-resolve
    echo       the target drive at runtime.
) else (
    echo !DATA_IN! | findstr /r "^[A-Za-z]$" >nul
    if !errorLevel! NEQ 0 (
        echo   [ERROR] Invalid entry - enter a single drive letter A-Z.
        goto ASK_DATA
    )
    if not exist "!DATA_IN!:\" (
        echo   [ERROR] Drive !DATA_IN!: does not exist or is not ready.
        goto ASK_DATA
    )
    set "DATA_LETTER=!DATA_IN!"
)

:: ---- 8. Question 2 of 2: System image drive ----
:ASK_IMAGE
set "IMAGE_LETTER="
set "IMG_DEFAULT=!DATA_LETTER!"
if not defined IMG_DEFAULT set "IMG_DEFAULT=!AUTO_DRIVE!"
echo.
echo   QUESTION 2 OF 2 - WINDOWS SYSTEM IMAGE DRIVE
echo   Bare-metal DISM images (.wim) are written here.
set /p IMG_IN="   Enter drive letter or press ENTER for default [!IMG_DEFAULT!]: "
set "IMG_IN=!IMG_IN: =!"
if not defined IMG_IN set "IMG_IN=!IMG_DEFAULT!"
if not defined IMG_IN (
    echo   [i] No image drive specified - WINBARS will auto-resolve at runtime.
) else (
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
)

:: ---- 9. Write chosen drives into the active config ----
set "CFG_EXIT=0"
if not defined DATA_LETTER if not defined IMAGE_LETTER goto SKIP_CFG
set "IMG_PATH="
if defined IMAGE_LETTER set "IMG_PATH=!IMAGE_LETTER!:\WindowsImageBackup"
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
!RUN_CMD! -SetProfile ZeroFootprint -Vanilla -Unattended -ConfigPath "!ACTIVE_CONFIG_PATH!"
set "PROFILE_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !PROFILE_EXIT! EQU 0 (
    echo   [OK] Mode 0 ZeroFootprint profile applied successfully.
) else (
    echo   [ERROR] Profile apply failed with exit code !PROFILE_EXIT!.
)

:: ---- 11. Optional: capture a permanent baseline image now ----
set /p BASE_IN="   Capture a permanent baseline system image now (_baseline.wim)? (Y/N) [Default: N]: "
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

:: ---- 12. Final verdict ----
set "OVERALL_EXIT=0"
if not !CFG_EXIT! EQU 0 set "OVERALL_EXIT=1"
if not !PROFILE_EXIT! EQU 0 set "OVERALL_EXIT=1"
echo.
echo ================================================================
if !OVERALL_EXIT! EQU 0 (
    echo   [SUCCESS] Mode 0 ZeroFootprint installation completed.
    echo   Tip: Run Capture-Baseline.bat to pin a permanent baseline image.
) else (
    echo   [FAILED] One or more steps failed. Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log
)
echo ================================================================
echo.
pause
exit /b !OVERALL_EXIT!
