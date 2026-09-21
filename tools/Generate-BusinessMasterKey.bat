@echo off
setlocal EnableDelayedExpansion
title WINBARS - 1-Click Business / Enterprise Master Key Generator
color 0B

:: ============================================================================
::  WINBARS 1-CLICK BUSINESS / ENTERPRISE MASTER KEY GENERATOR
::  Creates a dedicated Enterprise BitLocker DRA certificate pair for a client company:
::    1. [Company]_Master_Private.pfx  <-- HANDED TO BUSINESS OWNER FOR THEIR SAFE
::    2. [Company]_Public_DRA.cer      <-- DEPLOYED ACROSS FLEET PCS / JSON CONFIG
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
echo   WINBARS - BUSINESS / ENTERPRISE BITLOCKER MASTER KEY GENERATOR
echo ==============================================================================
echo   This wizard creates an Enterprise Master Recovery Certificate for a client
echo   business (medical clinic, law firm, accounting practice, enterprise fleet).
echo.
echo   HOW IT WORKS:
echo   - The PRIVATE key (.pfx) is password-protected and given to the business owner
echo     on a secure USB to store in their physical lockbox or safe.
echo   - The PUBLIC certificate (.cer) is deployed on the company's fleet of PCs
echo     via WINBARS (or embedded as Base64 in config.json / brand JSON).
echo   - If ANY company PC triggers BitLocker recovery (after a motherboard repair,
echo     TPM reset, or BIOS update), the company owner or IT admin can unlock the
echo     machine instantly without hunting for lost 48-digit recovery keys!
echo.
echo   * Co-Custody: Can be deployed alongside or independently of the Tech Shop Key.
echo   * Zero Vendor Lock-in: The business retains 100%% independent ownership.
echo ==============================================================================
echo.

set /p COMP_NAME="Enter Company / Organization Name (e.g. Acme Medical Clinic): "
if not defined COMP_NAME set "COMP_NAME=Enterprise Client"

echo.
echo Generating Enterprise BitLocker DRA Certificate for '!COMP_NAME!'...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module '%~dp0..\src\security\ShopBitLocker.ps1'; `$res = New-BusinessMasterKey -CompanyName '!COMP_NAME!'; if (`$res.Success) { Write-Host '`n==================================================================' -ForegroundColor Green; Write-Host ' BASE64 CERTIFICATE STRING (FOR EMBEDDING DIRECTLY INTO JSON):' -ForegroundColor Yellow; Write-Host `$res.Base64Cert -ForegroundColor White; Write-Host '==================================================================' -ForegroundColor Green; } }"

echo.
echo Done! Press any key to exit.
pause >nul
