# install.ps1 (WINBARS Official Public Web Installer)
# Hosted at: winbars.remarkablepc.com
# Usage: irm winbars.remarkablepc.com | iex

[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PassthruArgs
)

# Enforce TLS 1.2 / TLS 1.3
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "  WINBARS - Windows Backup, Assistance, Recovery and Security Suite      " -ForegroundColor White
Write-Host "  Community Field-Testing Release | Supervised Deployment Recommended   " -ForegroundColor Yellow
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host " NOTICE: Feature complete and available for community / bench testing.   " -ForegroundColor DarkYellow
Write-Host " Production fleet deployment experience has not yet been established.    " -ForegroundColor DarkYellow
Write-Host " Use at your own discretion and maintain independent secondary backups.  " -ForegroundColor DarkYellow
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Require Administrator Privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] Administrator privileges required. Requesting elevation..." -ForegroundColor Yellow
    $argString = if ($PassthruArgs) { $PassthruArgs -join " " } else { "" }
    $elevateCommand = "& { try { irm winbars.remarkablepc.com | iex } catch { irm https://raw.githubusercontent.com/remarkablepc/WINBARS/main/tools/web-deploy/public-winbars/install.ps1 | iex } } $argString"
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$elevateCommand`""
    return
}

# 2. Stage Working Directory
$stagingDir = Join-Path -Path $env:TEMP -ChildPath "WINBARS_Bootstrap"
if (Test-Path $stagingDir) {
    Remove-Item -Path $stagingDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

$zipPath = Join-Path -Path $stagingDir -ChildPath "WINBARS-Latest.zip"

# 3. Download Official Vanilla Package from GitHub Releases
Write-Host "[*] Fetching latest official release from GitHub..." -ForegroundColor Cyan
$downloadUrl = $null
$versionTag = "latest"

try {
    $apiUri = "https://api.github.com/repos/remarkablepc/WINBARS/releases/latest"
    $headers = @{ "User-Agent" = "WINBARS-WebInstaller" }
    $releaseInfo = Invoke-RestMethod -Uri $apiUri -Headers $headers -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    $versionTag = $releaseInfo.tag_name
    $zipAsset = $releaseInfo.assets | Where-Object { $_.name -like "WINBARS*.zip" } | Select-Object -First 1
    if ($zipAsset) {
        $downloadUrl = $zipAsset.browser_download_url
    }
} catch {
    Write-Host "[!] GitHub API rate-limited; falling back to direct release download..." -ForegroundColor Gray
}

if (-not $downloadUrl) {
    $downloadUrl = "https://github.com/remarkablepc/WINBARS/releases/latest/download/WINBARS.zip"
}

Write-Host "[*] Downloading WINBARS ($versionTag)..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
} catch {
    Write-Host "[FAIL] Download failed: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# 4. Extract Package
Write-Host "[*] Extracting package..." -ForegroundColor Cyan
try {
    Expand-Archive -Path $zipPath -DestinationPath $stagingDir -Force
} catch {
    Write-Host "[FAIL] Extraction failed: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# 5. Remove Zone.Identifier / Mark Safe
Get-ChildItem -Path $stagingDir -Recurse | Unblock-File -ErrorAction SilentlyContinue

# 6. Locate Target Binary
$exePath = Join-Path -Path $stagingDir -ChildPath "WINBARS.exe"
if (-not (Test-Path $exePath)) {
    $nested = Get-ChildItem -Path $stagingDir -Recurse -Filter "WINBARS.exe" -File | Select-Object -First 1
    if ($nested) {
        $exePath = $nested.FullName
        $stagingDir = Split-Path -Parent $exePath
    }
}

if (-not (Test-Path $exePath)) {
    Write-Host "[FAIL] WINBARS.exe not found in downloaded package." -ForegroundColor Red
    return
}

# 7. Execute WINBARS with Passed Arguments
Write-Host "[OK] Launching WINBARS Control Console..." -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------" -ForegroundColor Gray

if ($PassthruArgs -and $PassthruArgs.Count -gt 0) {
    Start-Process -FilePath $exePath -ArgumentList $PassthruArgs -Wait
} else {
    Start-Process -FilePath $exePath
}
