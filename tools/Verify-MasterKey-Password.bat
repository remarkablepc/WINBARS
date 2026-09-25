@echo off
setlocal EnableDelayedExpansion
title WINBARS - Master Key (.pfx) Password Verifier
color 0B

:: ============================================================================
::  WINBARS MASTER KEY (.PFX) PASSWORD VERIFIER
::  Safely verifies your unlock passphrase against your private .pfx certificate.
::  Does NOT alter, unlock, or lock any drives or system settings.
:: ============================================================================

cd /d "%~dp0"
cls
echo ==============================================================================
echo   WINBARS - MASTER KEY (.PFX) PASSWORD VERIFIER
echo ==============================================================================
echo   This tool safely validates whether your unlock password matches your
echo   Shop or Enterprise Private Key (.pfx) file.
echo.
echo   * Safe to run anytime - 0 disk or BitLocker changes.
echo   * Confirms password correctness and prints certificate validity details.
echo ==============================================================================
echo.

set "PFX_PATH="

:: Auto-detect from Desktop
if exist "%USERPROFILE%\Desktop\Shop_Master_Private.pfx" set "PFX_PATH=%USERPROFILE%\Desktop\Shop_Master_Private.pfx"
if not defined PFX_PATH if exist "%USERPROFILE%\Desktop\ShopMasterKey_Private.pfx" set "PFX_PATH=%USERPROFILE%\Desktop\ShopMasterKey_Private.pfx"
if not defined PFX_PATH if exist "%USERPROFILE%\Desktop\Company_Master_Private.pfx" set "PFX_PATH=%USERPROFILE%\Desktop\Company_Master_Private.pfx"
if not defined PFX_PATH if exist "%USERPROFILE%\Desktop\CompanyMasterKey_Private.pfx" set "PFX_PATH=%USERPROFILE%\Desktop\CompanyMasterKey_Private.pfx"

:: Auto-detect from USB drives
if not defined PFX_PATH (
    for %%D in (D E F G H I U V W X Y Z) do (
        if not defined PFX_PATH (
            if exist "%%D:\Shop_Master_Private.pfx" set "PFX_PATH=%%D:\Shop_Master_Private.pfx"
            if exist "%%D:\BitLocker\Shop_Master_Private.pfx" set "PFX_PATH=%%D:\BitLocker\Shop_Master_Private.pfx"
            if exist "%%D:\ShopMasterKey_Private.pfx" set "PFX_PATH=%%D:\ShopMasterKey_Private.pfx"
            if exist "%%D:\BitLocker\ShopMasterKey_Private.pfx" set "PFX_PATH=%%D:\BitLocker\ShopMasterKey_Private.pfx"
            if exist "%%D:\ShopVault\Shop_Master_Private.pfx" set "PFX_PATH=%%D:\ShopVault\Shop_Master_Private.pfx"
            if exist "%%D:\Company_Master_Private.pfx" set "PFX_PATH=%%D:\Company_Master_Private.pfx"
            if exist "%%D:\CompanyMasterKey_Private.pfx" set "PFX_PATH=%%D:\CompanyMasterKey_Private.pfx"
        )
    )
)

if defined PFX_PATH (
    echo [DETECTED] Found Private Key at: !PFX_PATH!
    set /p USE_DETECTED="Test this key file? (Y/N) [Default: Y]: "
    if /i "!USE_DETECTED!"=="N" set "PFX_PATH="
)

if not defined PFX_PATH (
    set /p PFX_PATH="Enter full path to your Private Key (.pfx): "
)

:: Remove quotes if user dragged and dropped
if defined PFX_PATH set "PFX_PATH=%PFX_PATH:"=%"

if not exist "!PFX_PATH!" (
    echo.
    echo [ERROR] Could not find file at: !PFX_PATH!
    echo.
    pause
    exit /b 1
)

set "TARGET_PFX=!PFX_PATH!"

echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $pfx = $env:TARGET_PFX; if (Test-Path '%~dp0..\src\security\ShopBitLocker.ps1') { . '%~dp0..\src\security\ShopBitLocker.ps1' }; if (Get-Command 'Test-MasterKeyPassword' -ErrorAction SilentlyContinue) { Test-MasterKeyPassword -PfxPath $pfx } else { Write-Host ' Enter password to test against PFX:' -ForegroundColor Cyan; $sec = Read-Host -AsSecureString; $plain = [System.Net.NetworkCredential]::new('', $sec).Password; try { $c = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pfx, $plain, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet); Write-Host '`n =========================================================' -ForegroundColor Green; Write-Host ' [SUCCESS] Password verified. Key is valid and intact.' -ForegroundColor Green; Write-Host ' =========================================================' -ForegroundColor Green; Write-Host (' Certificate Subject : ' + $c.Subject) -ForegroundColor Cyan; Write-Host (' Thumbprint          : ' + $c.Thumbprint) -ForegroundColor Cyan; Write-Host (' Valid Until         : ' + $c.NotAfter.ToShortDateString()) -ForegroundColor Cyan } catch { Write-Host '`n =========================================================' -ForegroundColor Red; Write-Host ' [FAILED] Incorrect password or corrupt PFX file.' -ForegroundColor Red; Write-Host (' Detail: ' + $_.Exception.Message.Trim()) -ForegroundColor Yellow; Write-Host ' =========================================================' -ForegroundColor Red } } }"

echo.
pause
exit /b 0
