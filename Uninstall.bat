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

:: ---- 0. Parse Command Line Arguments ----
set "QUIET_MODE=0"
set "ARG_SCOPE="
set "ARG_FORCE=0"

:PARSE_LOOP
if "%~1"=="" goto ARGS_DONE
set "A=%~1"

if /i "!A!"=="/?" goto SHOW_HELP
if /i "!A!"=="-?" goto SHOW_HELP
if /i "!A!"=="/help" goto SHOW_HELP
if /i "!A!"=="--help" goto SHOW_HELP
if /i "!A!"=="help" goto SHOW_HELP

if /i "!A!"=="/quiet" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/unattended" ( set "QUIET_MODE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/force" ( set "ARG_FORCE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/yes" ( set "ARG_FORCE=1" & shift & goto PARSE_LOOP )
if /i "!A!"=="/y" ( set "ARG_FORCE=1" & shift & goto PARSE_LOOP )

if /i "!A:~0,7!"=="/scope:" ( set "ARG_SCOPE=!A:~7!" & shift & goto PARSE_LOOP )

shift
goto PARSE_LOOP

:SHOW_HELP
echo.
echo ========================================================================
echo   WINBARS - UNINSTALLER
echo ========================================================================
echo   Removes scheduled tasks, tray sentry, shortcuts, and integrations.
echo   Backup files and restore points are NEVER deleted.
echo.
echo SYNTAX:
echo   Uninstall.bat [/?] [/Quiet] [/Scope:1^|2] [/Force]
echo.
echo SWITCHES:
echo   [/?] or [/Help]   Display this help screen and exit immediately.
echo   /Quiet            Unattended mode: suppresses completion pause prompts.
echo   /Scope:1          Standard uninstall (tasks, tray, shortcuts).
echo   /Scope:2          Full cleanup (+ deletes C:\Tools\WINBARS and ProgramData).
echo   /Force or /Yes    Suppresses confirmation prompt.
echo.
echo EXAMPLES:
echo   Uninstall.bat
echo   Uninstall.bat /Scope:1 /Force /Quiet
echo   Uninstall.bat /Scope:2 /Force /Quiet
echo ========================================================================
echo.
exit /b 0

:ARGS_DONE
if defined ARG_SCOPE set "ARG_SCOPE=!ARG_SCOPE:"=!"

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
) else if exist "C:\Tools\WINBARS\WINBARS.exe" (
    set "RUN_CMD=^"C:\Tools\WINBARS\WINBARS.exe^""
)
if not defined RUN_CMD (
    echo.
    echo   [ERROR] WINBARS.exe could not be located next to this script
    echo           or in C:\Tools\WINBARS.
    echo.
    if not "!QUIET_MODE!"=="1" pause
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
    if not "!QUIET_MODE!"=="1" pause
    exit /b 0
)

:: ---- 5. Choose uninstall scope ----
set "SCOPE="
if defined ARG_SCOPE (
    if "!ARG_SCOPE!"=="1" set "SCOPE=1"
    if "!ARG_SCOPE!"=="2" set "SCOPE=2"
)
if defined SCOPE (
    echo   Uninstall scope pre-set via switch: [!SCOPE!]
    goto CONFIRM
)

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
    if not "!QUIET_MODE!"=="1" pause
    exit /b 0
)
if "!SCOPE!"=="1" goto CONFIRM
if "!SCOPE!"=="2" goto CONFIRM
echo   [ERROR] Invalid selection. Enter 1, 2, or X.
goto ASK_SCOPE

:: ---- 6. Confirm ----
:CONFIRM
if "!ARG_FORCE!"=="1" goto DO_UNINSTALL
echo.
set /p CONFIRM_IN="   Proceed with uninstall? (Y/N) [Default: Y]: "
if /i "!CONFIRM_IN!"=="N" (
    echo.
    echo   Exiting without changes.
    echo.
    if not "!QUIET_MODE!"=="1" pause
    exit /b 0
)

:DO_UNINSTALL
echo.
echo   NOTE: Your backup files, .wim system images, and Windows
echo   restore points are NEVER deleted by this tool.
echo.

:: ---- 7. Run the uninstall via the engine ----
echo   ----------------------------------------------------------------
if "!SCOPE!"=="1" (
    echo   Running standard uninstall...
    !RUN_CMD! -Uninstall -Unattended
) else (
    echo   Running full cleanup uninstall...
    !RUN_CMD! -Uninstall -PurgeAllLogs -Unattended
)
set "UNINSTALL_EXIT=!errorLevel!"
echo   ----------------------------------------------------------------

:: ---- 8. Scope 2 extra cleanup ----
if "!SCOPE!"=="2" (
    echo.
    echo   Performing Scope 2 filesystem cleanup...

    :: Stop any running tray process
    taskkill /f /im WINBARS.exe >nul 2>&1
    taskkill /f /im WinRestoreBackupTray.exe >nul 2>&1

    :: Remove desktop and Start Menu shortcuts
    del /f /q "%PUBLIC%\Desktop\WINBARS*.lnk" >nul 2>&1
    del /f /q "%USERPROFILE%\Desktop\WINBARS*.lnk" >nul 2>&1
    del /f /q "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\WINBARS*.lnk" >nul 2>&1

    :: Remove installed program folder
    if exist "C:\Tools\WINBARS" (
        echo   Removing C:\Tools\WINBARS...
        rmdir /s /q "C:\Tools\WINBARS" >nul 2>&1
        if exist "C:\Tools\WINBARS" (
            echo   [WARN] Could not remove C:\Tools\WINBARS completely. Some files may be in use.
        ) else (
            echo   [OK] Removed C:\Tools\WINBARS.
        )
    )

    :: Remove ProgramData folder
    if exist "C:\ProgramData\WINBARS" (
        echo   Removing C:\ProgramData\WINBARS...
        rmdir /s /q "C:\ProgramData\WINBARS" >nul 2>&1
        if exist "C:\ProgramData\WINBARS" (
            echo   [WARN] Could not remove C:\ProgramData\WINBARS completely.
        ) else (
            echo   [OK] Removed C:\ProgramData\WINBARS.
        )
    )

    echo   [OK] Scope 2 filesystem cleanup complete.
)

:: ---- 9. Final verdict ----
echo.
echo ================================================================
if !UNINSTALL_EXIT! EQU 0 (
    echo   [SUCCESS] WINBARS has been removed from this PC.
    echo   Your personal backup files, system images, and restore points
    echo   remain intact on your drives.
) else (
    echo   [FAILED] Uninstall returned exit code !UNINSTALL_EXIT!.
    echo   Review the messages above.
)
echo ================================================================
echo.
if not "!QUIET_MODE!"=="1" pause
exit /b !UNINSTALL_EXIT!