@echo off
setlocal EnableDelayedExpansion
title WINBARS - 1-Click BitLocker Unlock with Master Key
color 1F

:: ============================================================================
::  WINBARS 1-CLICK BITLOCKER DISASTER UNLOCK WITH MASTER KEY
::  Works in WinPE, WinRE, or live Windows command prompts.
::  Unlocks locked drives using native DRA certificate or decrypted escrow
::  (Supports Shop Master Keys, Company/Enterprise Keys, and Custom DRA Keys).
:: ============================================================================

cd /d "%~dp0"
cls
echo ==============================================================================
echo   WINBARS - 1-CLICK BITLOCKER DISASTER UNLOCK WITH MASTER KEY
echo ==============================================================================
echo   This tool unlocks a BitLocker-encrypted drive using your Shop or Company
echo   Master Private Key (.pfx).
echo.

set "DRV=C:"
set /p DRV_INPUT="Enter drive letter to unlock [Default: C:]: "
if defined DRV_INPUT (
    set "DRV=!DRV_INPUT!"
    if "!DRV:~1,1!"=="" set "DRV=!DRV!:"
)

echo.
echo Searching for Master Private Key (.pfx) on attached USB drives and Desktop...
set "PFX_PATH="

:: Check USB drives first (standard recovery environment)
for %%D in (D E F G H I U V W X Y Z) do (
    if not defined PFX_PATH (
        if exist "%%D:\Shop_Master_Private.pfx" set "PFX_PATH=%%D:\Shop_Master_Private.pfx"
        if exist "%%D:\Company_Master_Private.pfx" set "PFX_PATH=%%D:\Company_Master_Private.pfx"
        if exist "%%D:\ShopMasterKey_Private.pfx" set "PFX_PATH=%%D:\ShopMasterKey_Private.pfx"
        if exist "%%D:\CompanyMasterKey_Private.pfx" set "PFX_PATH=%%D:\CompanyMasterKey_Private.pfx"
        if exist "%%D:\ShopVault\Shop_Master_Private.pfx" set "PFX_PATH=%%D:\ShopVault\Shop_Master_Private.pfx"
    )
)

:: Check Desktop if live Windows
if not defined PFX_PATH (
    if exist "%USERPROFILE%\Desktop\Shop_Master_Private.pfx" set "PFX_PATH=%USERPROFILE%\Desktop\Shop_Master_Private.pfx"
    if not defined PFX_PATH if exist "%USERPROFILE%\Desktop\Company_Master_Private.pfx" set "PFX_PATH=%USERPROFILE%\Desktop\Company_Master_Private.pfx"
    if not defined PFX_PATH if exist "%USERPROFILE%\Desktop\ShopMasterKey_Private.pfx" set "PFX_PATH=%USERPROFILE%\Desktop\ShopMasterKey_Private.pfx"
    if not defined PFX_PATH if exist "%USERPROFILE%\Desktop\CompanyMasterKey_Private.pfx" set "PFX_PATH=%USERPROFILE%\Desktop\CompanyMasterKey_Private.pfx"
)

if defined PFX_PATH (
    echo [OK] Detected Master Key at: !PFX_PATH!
    set /p USE_DETECTED="Unlock using this key? (Y/N) [Default: Y]: "
    if /i "!USE_DETECTED!"=="N" set "PFX_PATH="
)

if not defined PFX_PATH (
    set /p PFX_PATH="Enter full path to your Private Key (.pfx): "
)

:: Remove quotes if user dragged and dropped
if defined PFX_PATH set "PFX_PATH=%PFX_PATH:"=%"

if not exist "!PFX_PATH!" (
    echo [ERROR] Could not find private key file at: !PFX_PATH!
    pause
    exit /b 1
)

echo.
echo Unlocking drive !DRV!... Enter your master password when prompted.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "& { if (Test-Path '%~dp0..\src\security\ShopBitLocker.ps1') { . '%~dp0..\src\security\ShopBitLocker.ps1' } else if (Test-Path '%~dp0ShopBitLocker.ps1') { . '%~dp0ShopBitLocker.ps1' }; if (Get-Command 'Unlock-BitLockerWithMasterKey' -ErrorAction SilentlyContinue) { Unlock-BitLockerWithMasterKey -DriveLetter '!DRV!' -PfxPath '!PFX_PATH!' } else { Unlock-BitLockerWithShopKey -DriveLetter '!DRV!' -PfxPath '!PFX_PATH!' } }"

echo.
echo ==============================================================================
echo   Unlock routine completed. Check the status above.
echo ==============================================================================
echo.
pause
exit /b 0
