@echo off
setlocal EnableDelayedExpansion
title WINBARS - Uninstaller
:: ============================================================================
::  WINBARS - UNINSTALLER
::  Removes WINBARS scheduled tasks, tray sentry, shortcuts and suite
::  integration from this PC. Optionally performs a full cleanup of all
::  local WINBARS folders and backup-drive identity markers.
::  Your backup data is NEVER deleted: mirrored files, .wim system images,
::  and Windows restore points always remain untouched on your drives.
:: ============================================================================

echo.
echo ================================================================
echo   WINBARS - UNINSTALLER
echo ================================================================
echo   Removes scheduled tasks, tray sentry, shortcuts and suite
echo   integration. Backup data is NEVER deleted by this tool.
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
) else if exist "C:\Tools\WINBARS\WINBARS.exe" (
    set "RUN_CMD=^"C:\Tools\WINBARS\WINBARS.exe^""
)
if not defined RUN_CMD (
    echo.
    echo   [ERROR] WINBARS.exe could not be located next to this script
    echo           or in C:\Tools\WINBARS.
    echo.
    pause
    exit /b 1
)

:: ---- 4. Detect whether WINBARS is set up on this PC ----
set "SETUP_FOUND="
if exist "C:\Tools\WINBARS\WINBARS.exe" set "SETUP_FOUND=1"
if not defined SETUP_FOUND if exist "C:\ProgramData\WINBARS\config.json" set "SETUP_FOUND=1"
if not defined SETUP_FOUND if exist "%~dp0config\config.json" set "SETUP_FOUND=1"
if not defined SETUP_FOUND if exist "%~dp0config.json" set "SETUP_FOUND=1"
if not defined SETUP_FOUND (
    schtasks /query /tn "\WinRestoreBackup\SystemRestorePoint" >nul 2>&1
    if not errorlevel 1 set "SETUP_FOUND=1"
)
if not defined SETUP_FOUND (
    schtasks /query /tn "\WindowsBackup\SystemRestorePoint" >nul 2>&1
    if not errorlevel 1 set "SETUP_FOUND=1"
)

if not defined SETUP_FOUND (
    echo.
    echo   [i] WINBARS does not appear to be installed on this PC.
    echo       Nothing to uninstall. Your backup files are untouched.
    echo.
    pause
    exit /b 0
)

:: ---- 5. Choose uninstall scope ----
echo.
echo   Uninstall scope:
echo     [1] Standard uninstall
echo         Removes scheduled tasks, tray sentry, desktop and Start
echo         Menu shortcuts, WinRE and Safe Mode integrations.
echo         Keeps: local suite folder, logs, and configuration.
echo.
echo     [2] Full cleanup
echo         Standard uninstall + deletes C:\Tools\WINBARS,
echo         C:\ProgramData\WINBARS, desktop shortcut files, and
echo         optionally WINBARS identity/canary markers on a backup drive.
echo         Backup files and system images are never deleted.
echo.
echo     [X] Exit without changes
echo.
:ASK_SCOPE
set /p SCOPE="   Select scope (1/2) or X to exit: "
set "SCOPE=!SCOPE: =!"
if /i "!SCOPE!"=="X" (
    echo.
    echo   Exiting without changes.
    echo.
    pause
    exit /b 0
)
if "!SCOPE!"=="1" goto CONFIRM
if "!SCOPE!"=="2" goto CONFIRM
echo   [ERROR] Invalid selection. Enter 1, 2, or X.
goto ASK_SCOPE

:: ---- 6. Confirm ----
:CONFIRM
echo.
set /p CONFIRM_IN="   Proceed with uninstall? (Y/N) [Default: Y]: "
if /i "!CONFIRM_IN!"=="N" (
    echo.
    echo   Exiting without changes.
    echo.
    pause
    exit /b 0
)
echo.
echo   NOTE: Your backup files, .wim system images, and Windows
echo   restore points are NEVER deleted by this tool.
echo.

:: ---- 7. Run engine uninstall ----
echo   Running WINBARS uninstaller...
echo   ----------------------------------------------------------------
!RUN_CMD! -Uninstall -Vanilla
set "UNINSTALL_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------
if !UNINSTALL_EXIT! EQU 0 (
    echo   [OK] Scheduled tasks, tray and shortcuts removed.
) else (
    echo   [ERROR] Engine uninstall reported exit code !UNINSTALL_EXIT!.
)

:: ---- 8. Full cleanup (scope 2 only) ----
set "CLEAN_EXIT=0"
if not "!SCOPE!"=="2" goto SKIP_CLEANUP

if exist "C:\Tools\WINBARS" (
    rmdir /s /q "C:\Tools\WINBARS" >nul 2>&1
    if not exist "C:\Tools\WINBARS" (
        echo   [OK] Removed C:\Tools\WINBARS
    ) else (
        echo   [WARN] Could not fully remove C:\Tools\WINBARS
        set "CLEAN_EXIT=1"
    )
)
if exist "C:\ProgramData\WINBARS" (
    rmdir /s /q "C:\ProgramData\WINBARS" >nul 2>&1
    if not exist "C:\ProgramData\WINBARS" (
        echo   [OK] Removed C:\ProgramData\WINBARS
    ) else (
        echo   [WARN] Could not fully remove C:\ProgramData\WINBARS
        set "CLEAN_EXIT=1"
    )
)
if exist "%USERPROFILE%\Desktop\WINBARS*.lnk" del /f /q "%USERPROFILE%\Desktop\WINBARS*.lnk" >nul 2>&1
if exist "%PUBLIC%\Desktop\WINBARS*.lnk" del /f /q "%PUBLIC%\Desktop\WINBARS*.lnk" >nul 2>&1
echo   [OK] Desktop shortcut files cleaned.

:: ---- 9. Optional: remove identity/canary markers from a backup drive ----
set /p MARK_IN="   Remove WINBARS identity/canary markers from a backup drive? (Y/N) [Default: N]: "
if /i not "!MARK_IN!"=="Y" goto SKIP_CLEANUP
:ASK_MARK_DRIVE
set /p MARK_DRIVE="   Enter backup drive letter (e.g. E): "
set "MARK_DRIVE=!MARK_DRIVE: =!"
echo !MARK_DRIVE! | findstr /r "^[A-Za-z]$" >nul
if !errorLevel! NEQ 0 (
    echo   [ERROR] Invalid entry - enter a single drive letter A-Z.
    goto ASK_MARK_DRIVE
)
if not exist "!MARK_DRIVE!:\" (
    echo   [ERROR] Drive !MARK_DRIVE!: does not exist or is not ready.
    goto ASK_MARK_DRIVE
)
echo   NOTE: Removing the canary marker disables ransomware sentinel
echo   detection on that drive.
for %%m in (.winbars_identity.json .backup_identity.json .backup_target .winbar_canary.dat) do (
    if exist "!MARK_DRIVE!:\%%m" (
        del /a:hs /f /q "!MARK_DRIVE!:\%%m" >nul 2>&1
        echo   [OK] Removed !MARK_DRIVE!:\%%m
    )
)
:SKIP_CLEANUP

:: ---- 10. Final verdict ----
set "OVERALL_EXIT=0"
if not !UNINSTALL_EXIT! EQU 0 set "OVERALL_EXIT=1"
if not !CLEAN_EXIT! EQU 0 set "OVERALL_EXIT=1"
echo.
echo ================================================================
if !OVERALL_EXIT! EQU 0 (
    echo   [SUCCESS] WINBARS uninstall completed.
    echo   All backup files, images and restore points are untouched.
) else (
    echo   [FAILED] Some steps reported problems. Review the messages above.
    echo   Logs: C:\ProgramData\WINBARS\Logs\backup.log (if still present)
)
echo ================================================================
echo.
pause
exit /b !OVERALL_EXIT!
