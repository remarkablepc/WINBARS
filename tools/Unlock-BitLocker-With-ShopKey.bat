@echo off
setlocal EnableDelayedExpansion
title WINBARS - 1-Click BitLocker Unlock with Shop Master Key
color 1F

:: ============================================================================
::  WINBARS 1-CLICK BITLOCKER DISASTER UNLOCK WITH SHOP KEY
::  Works in WinPE, WinRE, or live Windows command prompts.
::  Unlocks locked drives using native DRA certificate or decrypted escrow.
:: ============================================================================

cd /d "%~dp0"
cls
echo ==============================================================================
echo   WINBARS - 1-CLICK BITLOCKER DISASTER UNLOCK WITH SHOP KEY
echo ==============================================================================
echo   This tool unlocks a BitLocker-encrypted drive using your Shop Master Key.
echo.

set "DRV=C:"
set /p DRV_INPUT="Enter drive letter to unlock [Default: C:]: "
if defined DRV_INPUT (
    set "DRV=!DRV_INPUT!"
    if "!DRV:~1,1!"=="" set "DRV=!DRV!:"
)

echo.
echo Searching for Shop_Master_Private.pfx on attached USB drives...
set "PFX_PATH="
for %%D in (D E F G H I U V W X Y Z) do (
    if not defined PFX_PATH (
        if exist "%%D:\Shop_Master_Private.pfx" set "PFX_PATH=%%D:\Shop_Master_Private.pfx"
        if exist "%%D:\ShopVault\Shop_Master_Private.pfx" set "PFX_PATH=%%D:\ShopVault\Shop_Master_Private.pfx"
    )
)

if defined PFX_PATH (
    echo [OK] Found Shop Master Key at: !PFX_PATH!
) else (
    set /p PFX_PATH="Enter full path to your Shop_Master_Private.pfx: "
)

if not exist "!PFX_PATH!" (
    echo [ERROR] Could not find private key file at: !PFX_PATH!
    pause
    exit /b 1
)

echo.
echo Unlocking drive !DRV!... Enter your master password when prompted.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "& { if (Test-Path '%~dp0..\src\security\ShopBitLocker.ps1') { . '%~dp0..\src\security\ShopBitLocker.ps1' } else if (Test-Path '%~dp0ShopBitLocker.ps1') { . '%~dp0ShopBitLocker.ps1' }; Unlock-BitLockerWithShopKey -DriveLetter '!DRV!' -PfxPath '!PFX_PATH!' }"

echo.
echo ==============================================================================
echo   Unlock routine completed. Check the status above.
echo ==============================================================================
echo.
pause
exit /b 0
