@echo off
setlocal EnableDelayedExpansion
title WINBARS - 1-Click BitLocker Master Recovery Key Generator
color 0A

:: ============================================================================
::  WINBARS 1-CLICK BITLOCKER MASTER RECOVERY KEY GENERATOR
::  Creates a self-signed RSA-2048 BitLocker Data Recovery Agent (DRA) pair:
::    1. Private Key (.pfx)  <-- STORED IN YOUR SAFE / USB (NEVER DEPLOYED)
::    2. Public Cert (.cer)  <-- BUNDLED INTO WINBARS FOR TARGET COMPUTERS
::    3. Base64 Certificate  <-- FOR ZERO-FILE EMBEDDING IN CONFIG / BRAND JSON
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
echo   WINBARS - 1-CLICK BITLOCKER MASTER RECOVERY KEY GENERATOR
echo ==============================================================================
echo   Creates a native BitLocker Data Recovery Agent (DRA) certificate pair.
echo.
echo   HOW IT WORKS:
echo   - The PUBLIC certificate (.cer) binds to client PCs during WINBARS runs.
echo   - The PRIVATE key (.pfx) is kept by you or the company owner.
echo   - If BitLocker ever locks at the blue screen, the machine can be unlocked
echo     instantly without the 48-digit recovery key!
echo.
echo   * 100%% native Windows cryptography (RSA-2048).
echo   * Co-Custody: Supports both Shop Master Key and Company Fleet Key.
echo ==============================================================================
echo.

if defined PRESET_TYPE (
    set "KEY_CHOICE=%PRESET_TYPE%"
    goto PROCESS_CHOICE
)

echo Select Master Key Role:
echo   [1] Shop / Technician Key  (Protects all client PCs serviced by your shop)
echo   [2] Business / Client Key  (Dedicated recovery key for a specific business/fleet)
echo.
set /p KEY_CHOICE="Select option [1-2, Default: 1]: "
if not defined KEY_CHOICE set "KEY_CHOICE=1"

:PROCESS_CHOICE
if "%KEY_CHOICE%"=="2" goto BUSINESS_KEY

:SHOP_KEY
echo.
echo --- SHOP / TECHNICIAN MASTER KEY ---
set /p KEY_NAME="Enter Shop / Business Name (Display Label) [Default: WINBARS Generated]: "
if not defined KEY_NAME set "KEY_NAME=WINBARS Generated"

echo.
set "DEST_PFX=%USERPROFILE%\Desktop\Shop_Master_Private.pfx"
set /p PFX_CHOICE="Save Private Key (.pfx) to Desktop? (Y/N) [Default: Y]: "
if /i "!PFX_CHOICE!"=="N" (
    set /p DEST_PFX="Enter full path to save Shop_Master_Private.pfx: "
)

echo.
echo Generating Shop Master Key... Please enter a strong password when prompted.
echo.

set "KEY_NAME_ENV=!KEY_NAME!"
set "DEST_PFX_ENV=!DEST_PFX!"

powershell -NoProfile -ExecutionPolicy Bypass -Command "& { if (Test-Path '%~dp0..\src\security\ShopBitLocker.ps1') { . '%~dp0..\src\security\ShopBitLocker.ps1' }; if (-not (Get-Command 'New-BitLockerMasterKey' -ErrorAction SilentlyContinue)) { function New-BitLockerMasterKey { param([string]$Name='WINBARS Generated',[string]$Role='Shop',[string]$ExportPfxPath,[string]$ExportCerPath); try { do { Write-Host ' Enter a master passphrase to protect your Private Key (.pfx):' -ForegroundColor Cyan; $p1 = Read-Host -AsSecureString; Write-Host ' Confirm master passphrase:' -ForegroundColor Cyan; $p2 = Read-Host -AsSecureString; $plain1 = [System.Net.NetworkCredential]::new('', $p1).Password; $plain2 = [System.Net.NetworkCredential]::new('', $p2).Password; if (-not $plain1) { Write-Host ' [ERROR] Passphrase cannot be empty. Please try again.`n' -ForegroundColor Red; $m=$false } elseif ($plain1 -ne $plain2) { Write-Host ' [ERROR] Passwords do not match. Please try again.`n' -ForegroundColor Red; $m=$false } else { $m=$true; $secPass=$p1 } } until ($m); Write-Host ' Generating BitLocker DRA certificate...' -ForegroundColor Cyan; $cert = New-SelfSignedCertificate -Subject ('CN=' + $Name + ' BitLocker DRA') -CertStoreLocation 'Cert:\CurrentUser\My' -KeyExportPolicy Exportable -KeyUsage KeyEncipherment,DataEncipherment -Type DocumentEncryptionCert -ErrorAction Stop; $pDir = Split-Path -Parent $ExportPfxPath; if ($pDir -and -not (Test-Path $pDir)) { New-Item -Path $pDir -ItemType Directory -Force | Out-Null }; $cDir = Split-Path -Parent $ExportCerPath; if ($cDir -and -not (Test-Path $cDir)) { New-Item -Path $cDir -ItemType Directory -Force | Out-Null }; [System.IO.File]::WriteAllBytes($ExportPfxPath, $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $secPass)); $cerBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert); [System.IO.File]::WriteAllBytes($ExportCerPath, $cerBytes); try { Remove-Item ('Cert:\CurrentUser\My\' + $cert.Thumbprint) -Force -ErrorAction SilentlyContinue } catch {}; Write-Host ('  [OK] Private Key (.pfx) saved: ' + $ExportPfxPath) -ForegroundColor Green; Write-Host ('  [OK] Public Cert (.cer) saved:  ' + $ExportCerPath) -ForegroundColor Green; return [PSCustomObject]@{ Success=$true; Base64Cert=[Convert]::ToBase64String($cerBytes) } } catch { Write-Host ('  [ERROR] ' + $_) -ForegroundColor Red; return [PSCustomObject]@{ Success=$false } } } }; $res = New-BitLockerMasterKey -Name $env:KEY_NAME_ENV -Role 'Shop' -ExportPfxPath $env:DEST_PFX_ENV -ExportCerPath '%~dp0..\certs\Shop_Public_DRA.cer'; if ($res.Success) { $certDir = '%~dp0..\certs'; if (-not (Test-Path $certDir)) { New-Item -Path $certDir -ItemType Directory -Force | Out-Null }; Copy-Item '%~dp0..\certs\Shop_Public_DRA.cer' (Join-Path $certDir 'ShopMasterKey.cer') -Force -ErrorAction SilentlyContinue; if ($res.Base64Cert) { Write-Host '`n==================================================================' -ForegroundColor Green; Write-Host ' BASE64 CERTIFICATE STRING (FOR EMBEDDING DIRECTLY INTO JSON):' -ForegroundColor Yellow; Write-Host $res.Base64Cert -ForegroundColor White; Write-Host '==================================================================' -ForegroundColor Green; } } }"
goto FINISH

:BUSINESS_KEY
echo.
echo --- BUSINESS / ENTERPRISE CLIENT MASTER KEY ---
set /p COMP_NAME="Enter Company / Organization Name (e.g. Acme Medical Clinic): "
if not defined COMP_NAME set "COMP_NAME=Enterprise Client"

echo.
echo Generating Enterprise BitLocker DRA Certificate for '!COMP_NAME!'...
echo.

set "COMP_NAME_ENV=!COMP_NAME!"

powershell -NoProfile -ExecutionPolicy Bypass -Command "& { if (Test-Path '%~dp0..\src\security\ShopBitLocker.ps1') { . '%~dp0..\src\security\ShopBitLocker.ps1' }; if (-not (Get-Command 'New-BitLockerMasterKey' -ErrorAction SilentlyContinue)) { function New-BitLockerMasterKey { param([string]$Name='Enterprise Client',[string]$Role='Business'); try { $safeName = ($Name -replace '[^\w\-]', '_').Trim('_'); $cPath = Join-Path '%~dp0..\certs' ('{0}_Public_DRA.cer' -f $safeName); $pPath = Join-Path ([Environment]::GetFolderPath('Desktop')) ('{0}_Master_Private.pfx' -f $safeName); do { Write-Host ' Enter a master passphrase to protect your Company Private Key (.pfx):' -ForegroundColor Cyan; $p1 = Read-Host -AsSecureString; Write-Host ' Confirm master passphrase:' -ForegroundColor Cyan; $p2 = Read-Host -AsSecureString; $plain1 = [System.Net.NetworkCredential]::new('', $p1).Password; $plain2 = [System.Net.NetworkCredential]::new('', $p2).Password; if (-not $plain1) { Write-Host ' [ERROR] Passphrase cannot be empty. Please try again.`n' -ForegroundColor Red; $m=$false } elseif ($plain1 -ne $plain2) { Write-Host ' [ERROR] Passwords do not match. Please try again.`n' -ForegroundColor Red; $m=$false } else { $m=$true; $secPass=$p1 } } until ($m); Write-Host (' Generating Enterprise BitLocker DRA certificate for ' + $Name + '...') -ForegroundColor Cyan; $cert = New-SelfSignedCertificate -Subject ('CN=' + $Name + ' BitLocker DRA') -CertStoreLocation 'Cert:\CurrentUser\My' -KeyExportPolicy Exportable -KeyUsage KeyEncipherment,DataEncipherment -Type DocumentEncryptionCert -ErrorAction Stop; $pDir = Split-Path -Parent $pPath; if ($pDir -and -not (Test-Path $pDir)) { New-Item -Path $pDir -ItemType Directory -Force | Out-Null }; $cDir = Split-Path -Parent $cPath; if ($cDir -and -not (Test-Path $cDir)) { New-Item -Path $cDir -ItemType Directory -Force | Out-Null }; [System.IO.File]::WriteAllBytes($pPath, $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $secPass)); $cerBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert); [System.IO.File]::WriteAllBytes($cPath, $cerBytes); try { Remove-Item ('Cert:\CurrentUser\My\' + $cert.Thumbprint) -Force -ErrorAction SilentlyContinue } catch {}; Write-Host ('  [OK] Private Key (.pfx) saved: ' + $pPath) -ForegroundColor Green; Write-Host ('  [OK] Public Cert (.cer) saved:  ' + $cPath) -ForegroundColor Green; return [PSCustomObject]@{ Success=$true; Base64Cert=[Convert]::ToBase64String($cerBytes) } } catch { Write-Host ('  [ERROR] ' + $_) -ForegroundColor Red; return [PSCustomObject]@{ Success=$false } } } }; $res = New-BitLockerMasterKey -Name $env:COMP_NAME_ENV -Role 'Business'; if ($res.Success) { Write-Host '`n==================================================================' -ForegroundColor Green; Write-Host ' BASE64 CERTIFICATE STRING (FOR EMBEDDING DIRECTLY INTO JSON):' -ForegroundColor Yellow; Write-Host $res.Base64Cert -ForegroundColor White; Write-Host '==================================================================' -ForegroundColor Green; } }"
goto FINISH

:FINISH
echo.
echo ==============================================================================
echo   GENERATION COMPLETE!
echo.
echo   CRITICAL NEXT STEPS:
echo   1. Move your Private Key (.pfx) to an offline USB drive or hardware safe.
echo   2. You can verify your password anytime with 'tools\Verify-MasterKey-Password.bat'.
echo   3. Public certificates (.cer) are safe to bundle and deploy.
echo ==============================================================================
echo.
pause
exit /b 0
