@echo off
setlocal EnableDelayedExpansion
title WINBARS - 1-Click Shop BitLocker Master Key Generator
color 0A

:: ============================================================================
::  WINBARS 1-CLICK SHOP BITLOCKER MASTER KEY GENERATOR
::  Creates a self-signed BitLocker Data Recovery Agent (DRA) certificate pair:
::    1. Shop_Master_Private.pfx  <-- SAVED TO YOUR SAFE / USB (NEVER DEPLOYED)
::    2. Shop_Public_DRA.cer      <-- BUNDLED INTO WINBARS FOR CLIENT PCS
:: ============================================================================

:: Check Admin
net session >nul 2>&1
if !errorLevel! NEQ 0 (
    echo.
    echo   [ELEVATION REQUIRED] Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

cd /d "%~dp0"
cls
echo ==============================================================================
echo   WINBARS - 1-CLICK SHOP BITLOCKER MASTER KEY GENERATOR
echo ==============================================================================
echo   This wizard creates an optional Master Recovery Certificate for your shop.
echo.
echo   HOW IT WORKS:
echo   - The PUBLIC certificate (.cer) is bundled into your WINBARS setup.
echo   - When BitLocker is active on client PCs, WINBARS binds this certificate.
echo   - The PRIVATE key (.pfx) stays with YOU.
echo   - If a customer PC locks at the BitLocker blue screen and they don't have
echo     their 48-digit key, you can unlock it using your Shop Key!
echo.
echo   * Pure native Windows cryptography (0 third-party software).
echo   * 100%% Optional - run once on your shop workstation to generate your shop key.
echo   * SECURITY NOTE: Your Shop Name is used ONLY as a display label on the certificate.
echo     The encryption key is generated mathematically random (RSA-2048). Entering the
echo     same name on another machine will NEVER produce the same key.
echo ==============================================================================
echo.

set /p SHOP_NAME="Enter your Shop / Business Name (Display Label) [Default: WINBARS Tech Partner]: "
if not defined SHOP_NAME set "SHOP_NAME=WINBARS Tech Partner"

echo.
set "DEST_PFX=%USERPROFILE%\Desktop\Shop_Master_Private.pfx"
set /p PFX_CHOICE="Save Private Key (.pfx) to Desktop? (Y/N) [Default: Y]: "
if /i "!PFX_CHOICE!"=="N" (
    set /p DEST_PFX="Enter full path to save Shop_Master_Private.pfx: "
)

echo.
echo Generating keys... Please enter a strong password when prompted.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "& { . '%~dp0..\src\security\ShopBitLocker.ps1'; $res = New-ShopMasterKey -ShopName '!SHOP_NAME!' -ExportPfxPath '!DEST_PFX!' -ExportCerPath '%~dp0..\config\Shop_Public_DRA.cer'; if ($res.Success) { $brandDir = '%~dp0..\branding'; if (-not (Test-Path $brandDir)) { New-Item -Path $brandDir -ItemType Directory -Force | Out-Null }; Copy-Item '%~dp0..\config\Shop_Public_DRA.cer' (Join-Path $brandDir 'ShopMasterKey.cer') -Force -ErrorAction SilentlyContinue } }"

echo.
echo ==============================================================================
echo   GENERATION COMPLETE!
echo.
echo   CRITICAL SECURITY STEPS:
echo   1. Move '!DEST_PFX!' to a secure USB drive or shop safe.
echo   2. Delete any extra copies from public computers.
echo   3. Re-bundle WINBARS so the public certificate is included in builds.
echo ==============================================================================
echo.
pause
exit /b 0
