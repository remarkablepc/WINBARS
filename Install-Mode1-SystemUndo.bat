@echo off
setlocal EnableDelayedExpansion
title WINBARS One-Click Installer - Mode 1 (SystemUndo)
:: ============================================================================
::  WINBARS ONE-CLICK INSTALLER - MODE 1 : SYSTEM UNDO
::  Applies all Mode 1 defaults automatically. No drive questions:
::  Mode 1 omits user data sync and system images entirely.
::  Requires WINBARS.exe (or WINBARS.ps1) in this same folder.
:: ============================================================================

echo.
echo ================================================================
echo   WINBARS ONE-CLICK INSTALLER - MODE 1 : SYSTEM UNDO
echo ================================================================
echo   What Mode 1 does:
echo     - Daily unthrottled system restore points
echo     - VSS writer auto-heal + shadow storage guard
echo     - Driver/MSI install checkpoints
echo     - No data sync, no images, no tray - pure OS rollback
echo.
echo   Mode 1 needs no backup drives, so no questions will be asked.
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

:: ---- 5. Install WINBARS suite to C:\Tools\WINBARS ----
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

:: ---- 6. Switch to the installed engine for profile application ----
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

:: ---- 7. Resolve config path for installed location ----
if not defined ACTIVE_CONFIG_PATH (
    set "ACTIVE_CONFIG_PATH=C:\Tools\WINBARS\config\config.json"
)
if exist "C:\Tools\WINBARS\config\config.json" (
    set "ACTIVE_CONFIG_PATH=C:\Tools\WINBARS\config\config.json"
)

:: ---- 8. Apply the profile (all settings use mode defaults) ----
echo.
echo   Applying Mode 1 SystemUndo defaults and scheduling tasks...
echo   ----------------------------------------------------------------
!RUN_CMD! -SetProfile Minimal -Vanilla -Unattended -ConfigPath "!ACTIVE_CONFIG_PATH!"
set "PROFILE_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !PROFILE_EXIT! EQU 0 (
    echo   [OK] Mode 1 SystemUndo profile applied successfully.
) else (
    echo   [ERROR] Profile apply failed with exit code !PROFILE_EXIT!.
)

:: ---- 9. Final verdict ----
set "OVERALL_EXIT=0"
if not !INSTALL_EXIT! EQU 0 set "OVERALL_EXIT=1"
if not !PROFILE_EXIT! EQU 0 set "OVERALL_EXIT=1"
echo.
echo ================================================================
if !OVERALL_EXIT! EQU 0 (
    echo   [SUCCESS] Mode 1 SystemUndo installation completed.
) else (
    echo   [FAILED] One or more steps failed. Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log
)
echo ================================================================
echo.
pause
exit /b !OVERALL_EXIT!
