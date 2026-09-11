@echo off
setlocal EnableDelayedExpansion
title WINBARS One-Click Installer - Mode 2 (LocalDisasterGuard)
:: ============================================================================
::  WINBARS ONE-CLICK INSTALLER - MODE 2 : LOCAL DISASTER GUARD
::  Applies all Mode 2 defaults automatically. Asks only 1 question:
::    Windows system image drive (default C: = C:\SystemImages)
::  Mode 2 is a single-drive design: no external data drive is used.
::  Requires WINBARS.exe (or WINBARS.ps1) in this same folder.
:: ============================================================================

echo.
echo ================================================================
echo   WINBARS ONE-CLICK INSTALLER - MODE 2 : LOCAL DISASTER GUARD
echo ================================================================
echo   What Mode 2 does:
echo     - Monthly bare-metal DISM system image for offline recovery
echo     - Daily restore points + VSS self-healing
echo     - Single-drive design - no external drive required
echo     - Default image location: C:\SystemImages
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
echo   Available drives (non-C):
echo   ----------------------------------------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -in 2,3 -and $_.DeviceID -ne 'C:' } | Sort-Object DeviceID | ForEach-Object { '{0}  {1}  (Free: {2:N1} GB)' -f $_.DeviceID, $_.VolumeName, ($_.FreeSpace/1GB) }"
echo   ----------------------------------------------------------------

:: ---- 6. Question 1 of 1: System image drive ----
:ASK_IMAGE
set "IMAGE_LETTER="
echo.
echo   QUESTION 1 OF 1 - WINDOWS SYSTEM IMAGE DRIVE
echo   Mode 2 stores a monthly bare-metal image for offline recovery.
echo   Default: C: (local folder C:\SystemImages).
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

:: ---- 7. Write the chosen image drive into the active config ----
set "CFG_EXIT=0"
set "IMG_PATH=!IMAGE_LETTER!:\SystemImages"
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
!RUN_CMD! -InstallLocal -Vanilla
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
    pause
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
    pause
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
!RUN_CMD! -SetProfile LocalDisasterGuard -Vanilla -Unattended -ConfigPath "!ACTIVE_CONFIG_PATH!"
set "PROFILE_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !PROFILE_EXIT! EQU 0 (
    echo   [OK] Mode 2 LocalDisasterGuard profile applied successfully.
) else (
    echo   [ERROR] Profile apply failed with exit code !PROFILE_EXIT!.
)

:: ---- 9. Optional: capture an immortal baseline image now ----
set /p BASE_IN="   Capture an immortal baseline system image now (_baseline.wim)? (Y/N) [Default: N]: "
if /i "!BASE_IN!"=="Y" (
    echo.
    echo   Capturing immortal baseline image (never rotated or deleted)...
    !RUN_CMD! -Action SystemImage -Baseline -Unattended
    set "BASE_EXIT=!errorLevel!"
    if !BASE_EXIT! EQU 0 (
        echo   [OK] Immortal baseline image captured successfully.
    ) else (
        echo   [WARN] Baseline capture failed with exit code !BASE_EXIT!.
        echo          The install itself is still complete. You can re-run
        echo          Capture-Baseline.bat at any time.
    )
)

:: ---- 12. Final verdict ----
set "OVERALL_EXIT=0"
if not !INSTALL_EXIT! EQU 0 set "OVERALL_EXIT=1"
if not !CFG_EXIT! EQU 0 set "OVERALL_EXIT=1"
if not !PROFILE_EXIT! EQU 0 set "OVERALL_EXIT=1"
echo.
echo ================================================================
if !OVERALL_EXIT! EQU 0 (
    echo   [SUCCESS] Mode 2 LocalDisasterGuard installation completed.
    echo   Tip: Run Capture-Baseline.bat to pin an immortal baseline image.
) else (
    echo   [FAILED] One or more steps failed. Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log
)
echo ================================================================
echo.
pause
exit /b !OVERALL_EXIT!
