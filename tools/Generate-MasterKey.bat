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
set /p YEARS_VALID="Enter Certificate Validity in Years [Default: 30 (recommended)]: "
if not defined YEARS_VALID set "YEARS_VALID=30"

echo.
echo.
set "DEST_PFX=%USERPROFILE%\Desktop\Shop_Master_Private.pfx"
set /p PFX_CHOICE="Save Master Key pair and token to Desktop? (Y/N) [Default: Y]: "
if /i "!PFX_CHOICE!"=="N" (
    set /p DEST_PFX="Enter full path to save Shop_Master_Private.pfx: "
)

echo.
echo Generating Shop Master Key (!YEARS_VALID! Years)... Please enter a strong password when prompted.
echo.

set "KEY_NAME_ENV=!KEY_NAME!"
set "DEST_PFX_ENV=!DEST_PFX!"
set "YEARS_VALID_ENV=!YEARS_VALID!"

powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $y = [int]$env:YEARS_VALID_ENV; if ($y -le 0) { $y = 30 }; if (Test-Path '%~dp0..\src\security\ShopBitLocker.ps1') { . '%~dp0..\src\security\ShopBitLocker.ps1' }; if (-not (Get-Command 'New-BitLockerMasterKey' -ErrorAction SilentlyContinue)) { function New-BitLockerMasterKey { param([string]$Name='WINBARS Generated',[string]$Role='Shop',[int]$YearsValid=30,[string]$ExportPfxPath,[string]$ExportCerPath); try { do { Write-Host ' Enter a master passphrase to protect your Private Key (.pfx):' -ForegroundColor Cyan; $p1 = Read-Host -AsSecureString; Write-Host ' Confirm master passphrase:' -ForegroundColor Cyan; $p2 = Read-Host -AsSecureString; $plain1 = [System.Net.NetworkCredential]::new('', $p1).Password; $plain2 = [System.Net.NetworkCredential]::new('', $p2).Password; if (-not $plain1) { Write-Host ' [ERROR] Passphrase cannot be empty. Please try again.`n' -ForegroundColor Red; $m=$false } elseif ($plain1 -ne $plain2) { Write-Host ' [ERROR] Passwords do not match. Please try again.`n' -ForegroundColor Red; $m=$false } else { $m=$true; $secPass=$p1 } } until ($m); if ($YearsValid -le 0) { $YearsValid = 30 }; $notAfter = (Get-Date).AddYears($YearsValid); Write-Host (' Generating BitLocker DRA certificate (' + $YearsValid + ' Years)...') -ForegroundColor Cyan; $cert = New-SelfSignedCertificate -Subject ('CN=' + $Name + ' BitLocker DRA') -CertStoreLocation 'Cert:\CurrentUser\My' -KeyExportPolicy Exportable -KeyUsage KeyEncipherment,DataEncipherment -Type DocumentEncryptionCert -NotAfter $notAfter -ErrorAction Stop; $pDir = Split-Path -Parent $ExportPfxPath; if ($pDir -and -not (Test-Path $pDir)) { New-Item -Path $pDir -ItemType Directory -Force | Out-Null }; $cDir = Split-Path -Parent $ExportCerPath; if ($cDir -and -not (Test-Path $cDir)) { New-Item -Path $cDir -ItemType Directory -Force | Out-Null }; [System.IO.File]::WriteAllBytes($ExportPfxPath, $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $secPass)); $cerBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert); [System.IO.File]::WriteAllBytes($ExportCerPath, $cerBytes); try { Remove-Item ('Cert:\CurrentUser\My\' + $cert.Thumbprint) -Force -ErrorAction SilentlyContinue } catch {}; Write-Host ('  [OK] Private Key (.pfx) saved: ' + $ExportPfxPath) -ForegroundColor Green; Write-Host ('  [OK] Public Cert (.cer) saved:  ' + $ExportCerPath) -ForegroundColor Green; Write-Host ('  [OK] Valid Until: ' + $cert.NotAfter.ToShortDateString() + ' (' + $YearsValid + ' Years)') -ForegroundColor Cyan; return [PSCustomObject]@{ Success=$true; Base64Cert=[Convert]::ToBase64String($cerBytes); Thumbprint=$cert.Thumbprint; Subject=$cert.Subject; ValidUntil=$cert.NotAfter } } catch { Write-Host ('  [ERROR] ' + $_) -ForegroundColor Red; return [PSCustomObject]@{ Success=$false } } } }; $pfxPath = $env:DEST_PFX_ENV; $pfxDir = Split-Path -Parent $pfxPath; if (-not $pfxDir) { $pfxDir = [Environment]::GetFolderPath('Desktop') }; $deskCerPath = Join-Path $pfxDir 'Shop_Public_DRA.cer'; $deskTxtPath = Join-Path $pfxDir 'Shop_Certificate_Base64.txt'; $deskJsonPath = Join-Path $pfxDir 'branding.sample.json'; $res = New-BitLockerMasterKey -Name $env:KEY_NAME_ENV -Role 'Shop' -YearsValid $y -ExportPfxPath $pfxPath -ExportCerPath $deskCerPath; if ($res.Success) { $certDir = '%~dp0..\certs'; if (-not (Test-Path $certDir)) { New-Item -Path $certDir -ItemType Directory -Force | Out-Null }; Copy-Item $deskCerPath (Join-Path $certDir 'Shop_Public_DRA.cer') -Force -ErrorAction SilentlyContinue; Copy-Item $deskCerPath (Join-Path $certDir 'ShopMasterKey.cer') -Force -ErrorAction SilentlyContinue; Write-Host ('  [OK] Public Cert (.cer) mirrored to: ' + (Join-Path $certDir 'Shop_Public_DRA.cer')) -ForegroundColor Green; try { $recDir = 'C:\SystemRecovery'; if (-not (Test-Path $recDir)) { New-Item -Path $recDir -ItemType Directory -Force | Out-Null }; icacls $recDir /inheritance:r /grant:r 'SYSTEM:(OI)(CI)F' 'Administrators:(OI)(CI)F' >$null 2>&1; Copy-Item $deskCerPath (Join-Path $recDir 'Shop_Public_DRA.cer') -Force -ErrorAction SilentlyContinue; Copy-Item $deskCerPath (Join-Path $recDir 'ShopMasterKey.cer') -Force -ErrorAction SilentlyContinue; Write-Host ('  [OK] Public Cert (.cer) staged to:   ' + (Join-Path $recDir 'Shop_Public_DRA.cer') + ' (Modes 1-4 Ready)') -ForegroundColor Green; } catch {}; if ($res.Base64Cert) { $txtContent = @('================================================================================', ' WINBARS BITLOCKER MASTER RECOVERY KEY - DATA RECOVERY AGENT (DRA) CERTIFICATE', '================================================================================', '[!] CRITICAL SECURITY NOTICE (IF GENERATED ON A CLIENT / CUSTOMER PC):', '    - The Private Key (.pfx) can unlock ANY machine serviced by your shop!', '    - NEVER leave Shop_Master_Private.pfx on a customer or client computer.', '    - MOVE the .pfx to your technician USB flash drive / safe NOW,', '      and DELETE the .pfx file from this client Desktop!', '    - The Public Cert (.cer) is safely staged in C:\SystemRecovery and is secure to leave.', '--------------------------------------------------------------------------------', ('Role:          Shop / Technician Master Key'), ('Subject:       ' + $res.Subject), ('Thumbprint:    ' + $res.Thumbprint), ('Validity:      ' + $y + ' Years (Expires: ' + $res.ValidUntil.ToShortDateString() + ')'), ('Generated:     ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')), '', 'FILES CREATED:', ('- Private Key (.pfx) : ' + $pfxPath + ' (STORE OFFLINE / IN SAFE)'), ('- Public Cert (.cer) : ' + $deskCerPath + ' (SAFE TO DEPLOY TO CLIENT PCS)'), '', '================================================================================', ' BASE64 CERTIFICATE TOKEN (FOR DIRECT EMBEDDING)', '================================================================================', $res.Base64Cert, '', 'HOW TO USE THIS TOKEN:', '1. WEB DEPLOYMENT / RMM (NinjaRMM, Syncro, Datto, etc.):', '   Paste this Base64 string into install.ps1 or your RMM bootstrap script.', '   Client machines will auto-decode and bind the master key without needing', '   to host or download a loose .cer binary.', '', '2. BRANDING / CONFIGURATION (branding.json):', '   Insert this string under MasterCertificateBase64 in branding.json.', '   All client deployments will inherit your master recovery key automatically.', '================================================================================') -join \"`r`n\"; [System.IO.File]::WriteAllText($deskTxtPath, $txtContent); Write-Host ('  [OK] Base64 Token Saved:       ' + $deskTxtPath) -ForegroundColor Green; $sampleJson = @('{', ('  \"CompanyName\": \"' + $env:KEY_NAME_ENV + '\",'), '  \"PhoneNumber\": \"(555) 123-4567\",', '  \"SupportUrl\": \"https://yourshop.com\",', ('  \"MasterCertificateBase64\": \"' + $res.Base64Cert + '\",'), '  \"BrandingToken\": \"\"', '}') -join \"`r`n\"; [System.IO.File]::WriteAllText($deskJsonPath, $sampleJson); Write-Host ('  [OK] Branding Template:        ' + $deskJsonPath) -ForegroundColor Green; Write-Host '`n==============================================================================' -ForegroundColor Red; Write-Host '  CRITICAL SECURITY NOTICE (IF RUNNING ON A CLIENT / CUSTOMER PC):' -ForegroundColor Yellow; Write-Host '==============================================================================' -ForegroundColor Red; Write-Host '  * The Private Key (.pfx) can unlock ANY machine serviced by your shop!' -ForegroundColor White; Write-Host '  * NEVER leave Shop_Master_Private.pfx on a customer or client computer.' -ForegroundColor White; Write-Host '`n  ACTIONS REQUIRED BEFORE CLOSING:' -ForegroundColor Yellow; Write-Host '  1. MOVE Shop_Master_Private.pfx to your technician USB drive or safe NOW.' -ForegroundColor White; Write-Host '  2. DELETE Shop_Master_Private.pfx from this client Desktop!' -ForegroundColor White; Write-Host '  3. The Public Cert (.cer) has been safely staged to C:\SystemRecovery' -ForegroundColor Green; Write-Host '     and is 100% secure to leave on this computer.' -ForegroundColor Green; Write-Host '==============================================================================' -ForegroundColor Red; Write-Host '`n==============================================================================' -ForegroundColor Green; Write-Host '  GENERATION COMPLETE - MASTER KEY READY FOR DEPLOYMENT' -ForegroundColor Green; Write-Host '==============================================================================' -ForegroundColor Green; Write-Host ('  [OK] Private Key (.pfx):  ' + $pfxPath + '  (KEEP SAFE / OFFLINE)') -ForegroundColor White; Write-Host ('  [OK] Public Cert (.cer):  ' + $deskCerPath + '     (Mirrored to certs\ & staged in C:\SystemRecovery)') -ForegroundColor White; Write-Host ('  [OK] Base64 Token:        ' + $deskTxtPath) -ForegroundColor White; Write-Host ('  [OK] Branding Template:   ' + $deskJsonPath) -ForegroundColor White; Write-Host '`n  NOTE: Your BitLocker Master Key is 100% functional standalone.' -ForegroundColor Yellow; Write-Host '  Neither a branding token nor branding.json is required to use your key.' -ForegroundColor Yellow; Write-Host '`n------------------------------------------------------------------------------' -ForegroundColor DarkGray; Write-Host '  OPTIONAL BRANDING CONFIGURATION (branding.json):' -ForegroundColor Cyan; Write-Host '------------------------------------------------------------------------------' -ForegroundColor DarkGray; Write-Host $sampleJson -ForegroundColor White; Write-Host '`n  * To display your shop name and contact info on client screens, place' -ForegroundColor Gray; Write-Host '    branding.json in the WINBARS config directory with your BrandingToken' -ForegroundColor Gray; Write-Host '    ($100 one-time project support donation via PayPal or GitHub Sponsors).' -ForegroundColor Gray; Write-Host '  * Project Repository & Documentation: https://github.com/remarkablepc/WINBARS' -ForegroundColor Cyan; Write-Host '==============================================================================' -ForegroundColor Green; } } }"
goto FINISH

:BUSINESS_KEY
echo.
echo --- BUSINESS / ENTERPRISE CLIENT MASTER KEY ---
set /p COMP_NAME="Enter Company / Organization Name (e.g. Acme Medical Clinic): "
if not defined COMP_NAME set "COMP_NAME=Enterprise Client"

echo.
set /p YEARS_VALID="Enter Certificate Validity in Years [Default: 30 (recommended)]: "
if not defined YEARS_VALID set "YEARS_VALID=30"

echo.
echo Generating Enterprise BitLocker DRA Certificate for '!COMP_NAME!' (!YEARS_VALID! Years)...
echo.

set "COMP_NAME_ENV=!COMP_NAME!"
set "YEARS_VALID_ENV=!YEARS_VALID!"

powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $y = [int]$env:YEARS_VALID_ENV; if ($y -le 0) { $y = 30 }; if (Test-Path '%~dp0..\src\security\ShopBitLocker.ps1') { . '%~dp0..\src\security\ShopBitLocker.ps1' }; if (-not (Get-Command 'New-BitLockerMasterKey' -ErrorAction SilentlyContinue)) { function New-BitLockerMasterKey { param([string]$Name='Enterprise Client',[string]$Role='Business',[int]$YearsValid=30); try { $safeName = ($Name -replace '[^\w\-]', '_').Trim('_'); $desk = [Environment]::GetFolderPath('Desktop'); $cPath = Join-Path $desk ('{0}_Public_DRA.cer' -f $safeName); $pPath = Join-Path $desk ('{0}_Master_Private.pfx' -f $safeName); do { Write-Host ' Enter a master passphrase to protect your Company Private Key (.pfx):' -ForegroundColor Cyan; $p1 = Read-Host -AsSecureString; Write-Host ' Confirm master passphrase:' -ForegroundColor Cyan; $p2 = Read-Host -AsSecureString; $plain1 = [System.Net.NetworkCredential]::new('', $p1).Password; $plain2 = [System.Net.NetworkCredential]::new('', $p2).Password; if (-not $plain1) { Write-Host ' [ERROR] Passphrase cannot be empty. Please try again.`n' -ForegroundColor Red; $m=$false } elseif ($plain1 -ne $plain2) { Write-Host ' [ERROR] Passwords do not match. Please try again.`n' -ForegroundColor Red; $m=$false } else { $m=$true; $secPass=$p1 } } until ($m); if ($YearsValid -le 0) { $YearsValid = 30 }; $notAfter = (Get-Date).AddYears($YearsValid); Write-Host (' Generating Enterprise BitLocker DRA certificate (' + $YearsValid + ' Years)...') -ForegroundColor Cyan; $cert = New-SelfSignedCertificate -Subject ('CN=' + $Name + ' BitLocker DRA') -CertStoreLocation 'Cert:\CurrentUser\My' -KeyExportPolicy Exportable -KeyUsage KeyEncipherment,DataEncipherment -Type DocumentEncryptionCert -NotAfter $notAfter -ErrorAction Stop; [System.IO.File]::WriteAllBytes($pPath, $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $secPass)); $cerBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert); [System.IO.File]::WriteAllBytes($cPath, $cerBytes); try { Remove-Item ('Cert:\CurrentUser\My\' + $cert.Thumbprint) -Force -ErrorAction SilentlyContinue } catch {}; Write-Host ('  [OK] Private Key (.pfx) saved: ' + $pPath) -ForegroundColor Green; Write-Host ('  [OK] Public Cert (.cer) saved:  ' + $cPath) -ForegroundColor Green; Write-Host ('  [OK] Valid Until: ' + $cert.NotAfter.ToShortDateString() + ' (' + $YearsValid + ' Years)') -ForegroundColor Cyan; return [PSCustomObject]@{ Success=$true; Base64Cert=[Convert]::ToBase64String($cerBytes); Thumbprint=$cert.Thumbprint; Subject=$cert.Subject; ValidUntil=$cert.NotAfter; SafeName=$safeName; CerPath=$cPath; PfxPath=$pPath } } catch { Write-Host ('  [ERROR] ' + $_) -ForegroundColor Red; return [PSCustomObject]@{ Success=$false } } } }; $res = New-BitLockerMasterKey -Name $env:COMP_NAME_ENV -Role 'Business' -YearsValid $y; if ($res.Success) { $certDir = '%~dp0..\certs'; if (-not (Test-Path $certDir)) { New-Item -Path $certDir -ItemType Directory -Force | Out-Null }; $repoCer = Join-Path $certDir ('{0}_Public_DRA.cer' -f $res.SafeName); Copy-Item $res.CerPath $repoCer -Force -ErrorAction SilentlyContinue; Write-Host ('  [OK] Public Cert (.cer) mirrored to: ' + $repoCer) -ForegroundColor Green; try { $recDir = 'C:\SystemRecovery'; if (-not (Test-Path $recDir)) { New-Item -Path $recDir -ItemType Directory -Force | Out-Null }; icacls $recDir /inheritance:r /grant:r 'SYSTEM:(OI)(CI)F' 'Administrators:(OI)(CI)F' >$null 2>&1; Copy-Item $res.CerPath (Join-Path $recDir ('{0}_Public_DRA.cer' -f $res.SafeName)) -Force -ErrorAction SilentlyContinue; Copy-Item $res.CerPath (Join-Path $recDir 'Company_Public_DRA.cer') -Force -ErrorAction SilentlyContinue; Copy-Item $res.CerPath (Join-Path $recDir 'CompanyMasterKey.cer') -Force -ErrorAction SilentlyContinue; Write-Host ('  [OK] Public Cert (.cer) staged to:   ' + (Join-Path $recDir 'Company_Public_DRA.cer') + ' (Modes 1-4 Ready)') -ForegroundColor Green; } catch {}; if ($res.Base64Cert) { $desk = [Environment]::GetFolderPath('Desktop'); $txtPath = Join-Path $desk ('{0}_Certificate_Base64.txt' -f $res.SafeName); $txtContent = @('================================================================================', ' ENTERPRISE BITLOCKER RECOVERY KEY - DATA RECOVERY AGENT (DRA) CERTIFICATE', '================================================================================', ('Company/Client: ' + $env:COMP_NAME_ENV), ('Subject:        ' + $res.Subject), ('Thumbprint:     ' + $res.Thumbprint), ('Validity:       ' + $y + ' Years (Expires: ' + $res.ValidUntil.ToShortDateString() + ')'), ('Generated:      ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')), '', 'FILES CREATED:', ('- Private Key (.pfx) : ' + $res.PfxPath + ' (GIVE TO BUSINESS OWNER / KEEP IN VAULT)'), ('- Public Cert (.cer) : ' + $res.CerPath + ' (SAFE TO DEPLOY TO FLEET MACHINES)'), '', '================================================================================', ' BASE64 CERTIFICATE TOKEN (FOR DIRECT EMBEDDING)', '================================================================================', $res.Base64Cert, '', 'HOW TO USE THIS TOKEN:', '1. FLEET DEPLOYMENT / RMM (NinjaRMM, Syncro, Datto, Intune, GPO):', '   Paste this Base64 string into deployment scripts or unattended JSON configs.', '   Machines will decode and bind the DRA without needing loose file transfers.', '================================================================================') -join \"`r`n\"; [System.IO.File]::WriteAllText($txtPath, $txtContent); Write-Host ('  [OK] Base64 Token Saved:       ' + $txtPath) -ForegroundColor Green; Write-Host '`n==============================================================================' -ForegroundColor Green; Write-Host '  GENERATION COMPLETE - ENTERPRISE DATA RECOVERY AGENT (DRA) READY' -ForegroundColor Green; Write-Host '==============================================================================' -ForegroundColor Green; Write-Host ('  [OK] Private Key (.pfx):  ' + $res.PfxPath + '  (OFFLINE VAULT / CISO)') -ForegroundColor White; Write-Host ('  [OK] Public Cert (.cer):  ' + $res.CerPath + '     (Mirrored to certs\ & staged in C:\SystemRecovery)') -ForegroundColor White; Write-Host ('  [OK] Base64 Token:        ' + $txtPath) -ForegroundColor White; Write-Host '`n  CRITICAL NEXT STEPS:' -ForegroundColor Yellow; Write-Host '  1. Move the Private Key (.pfx) to an offline hardware safe or HSM vault.' -ForegroundColor White; Write-Host '  2. Deploy the Public Certificate (.cer) across your fleet via Active' -ForegroundColor White; Write-Host '     Directory GPO, Microsoft Intune, or WINBARS Fleet profiles.' -ForegroundColor White; Write-Host '  3. Base64 token can be embedded directly into unattended deployment scripts.' -ForegroundColor White; Write-Host '==============================================================================' -ForegroundColor Green; } } }"
goto FINISH

:FINISH
echo.
pause
exit /b 0
