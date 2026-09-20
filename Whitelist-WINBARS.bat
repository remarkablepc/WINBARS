@echo off
setlocal EnableDelayedExpansion
title WINBARS - Windows Defender Exclusion Whitelister
:: ============================================================================
::  WINBARS WINDOWS DEFENDER EXCLUSION WHITELISTER
::  Configures folder and process exclusions for WINBARS in Windows Defender
::  to prevent false-positive heuristic alerts on native backup operations
::  (such as registry hive archiving, VSS snapshots, and BitLocker discovery).
:: ============================================================================

:: Check for /quiet or /unattended flags
set "QUIET_MODE=0"
if /i "%~1"=="/quiet" set "QUIET_MODE=1"
if /i "%~1"=="/unattended" set "QUIET_MODE=1"
if /i "%~1"=="-quiet" set "QUIET_MODE=1"

:: Elevation Check
net session >nul 2>&1
if not !errorLevel! EQU 0 (
    echo Elevating to Administrator...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c `\"%~f0`\" %*' -Verb RunAs"
    exit /b
)

echo.
echo ========================================================================
echo   WINBARS - Windows Defender Whitelist Utility
echo ========================================================================
echo   Target Folder 1 : C:\Tools\WINBARS
echo   Target Folder 2 : C:\ProgramData\WINBARS
echo   Target Process  : WINBARS.exe
echo.

:: Ensure destination folders exist so Defender can register paths cleanly
if not exist "C:\Tools\WINBARS" mkdir "C:\Tools\WINBARS" >nul 2>&1
if not exist "C:\ProgramData\WINBARS" mkdir "C:\ProgramData\WINBARS" >nul 2>&1

:: Execute PowerShell Whitelisting with Tamper Protection detection
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "$paths = @('C:\Tools\WINBARS', 'C:\ProgramData\WINBARS');" ^
    "$proc = 'WINBARS.exe';" ^
    "$hasDefender = (Get-Command Add-MpPreference -ErrorAction SilentlyContinue) -ne $null;" ^
    "if (-not $hasDefender) {" ^
    "    Write-Host '  [INFO] Windows Defender cmdlets not present on this system (third-party AV or Server core).' -ForegroundColor Cyan;" ^
    "    exit 0;" ^
    "}" ^
    "$tamperActive = $false;" ^
    "try {" ^
    "    $status = Get-MpComputerStatus -ErrorAction SilentlyContinue;" ^
    "    if ($status.IsTamperProtected -eq $true) { $tamperActive = $true }" ^
    "} catch { };" ^
    "try {" ^
    "    Add-MpPreference -ExclusionPath $paths -ExclusionProcess $proc -ErrorAction Stop;" ^
    "    Write-Host '  [SUCCESS] Successfully added WINBARS folder and process exclusions to Windows Defender.' -ForegroundColor Green;" ^
    "    exit 0;" ^
    "} catch {" ^
    "    if ($tamperActive) {" ^
    "        Write-Host '  [NOTICE] Windows Defender Tamper Protection is ENABLED.' -ForegroundColor Yellow;" ^
    "        Write-Host '           Tamper Protection restricts scripts from adding automated exclusions.' -ForegroundColor Gray;" ^
    "        Write-Host '           If Defender alerts on backup tasks or RegBack, you can either:' -ForegroundColor Gray;" ^
    "        Write-Host '           1. Click ''Allow on device'' in Windows Security -> Protection History.' -ForegroundColor White;" ^
    "        Write-Host '           2. Or temporarily toggle Tamper Protection OFF, re-run this script, then toggle it ON.' -ForegroundColor White;" ^
    "    } else {" ^
    "        Write-Host ('  [WARN] Could not update Defender exclusions: ' + $_.Exception.Message) -ForegroundColor Yellow;" ^
    "    }" ^
    "    exit 0;" ^
    "}"

set "WL_EXIT=!errorLevel!"

echo.
echo ========================================================================
if !QUIET_MODE! EQU 0 (
    echo   Press any key to close this window...
    pause >nul
)
exit /b !WL_EXIT!
