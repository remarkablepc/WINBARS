# install.ps1 (WINBARS Official Public Web Installer)
# Hosted at: winbars.remarkablepc.com
# Usage: irm winbars.remarkablepc.com | iex

[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PassthruArgs
)

# Enforce TLS 1.2 / TLS 1.3 & Disable Progress Bar Bottlenecks
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
$ProgressPreference = 'SilentlyContinue'

# Fallback for remaining arguments if invoked via scriptblock or iex
if (-not $PassthruArgs -and $args) {
    $PassthruArgs = $args
}

# Auto-adjust console buffer and window size for optimal menu display
try {
    if ($Host.UI.RawUI) {
        $rawUI = $Host.UI.RawUI
        $maxW = $rawUI.MaxPhysicalWindowSize.Width
        $maxH = $rawUI.MaxPhysicalWindowSize.Height
        $targetW = [Math]::Min([Math]::Max($rawUI.WindowSize.Width, 110), $maxW)
        $targetH = [Math]::Min([Math]::Max($rawUI.WindowSize.Height, 48), $maxH)
        if ($targetW -gt $rawUI.BufferSize.Width -or 500 -gt $rawUI.BufferSize.Height) {
            $rawUI.BufferSize = New-Object System.Management.Automation.Host.Size([Math]::Max($rawUI.BufferSize.Width, $targetW), [Math]::Max($rawUI.BufferSize.Height, 500))
        }
        $rawUI.WindowSize = New-Object System.Management.Automation.Host.Size($targetW, $targetH)
    }
} catch { }

Write-Host ""
Write-Host '  __        _____ _   _ ____    _    ____  ____  ' -ForegroundColor Cyan
Write-Host '  \ \      / /_ _| \ | | __ )  / \  |  _ \/ ___| ' -ForegroundColor Cyan
Write-Host '   \ \ /\ / / | ||  \| |  _ \ / _ \ | |_) \___ \ ' -ForegroundColor Cyan
Write-Host '    \ V  V /  | || |\  | |_) / ___ \|  _ < ___) |' -ForegroundColor Cyan
Write-Host '     \_/\_/  |___|_| \_|____/_/   \_\_| \_\____/ ' -ForegroundColor Cyan
Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "  WINBARS - Windows Backup, Assistance, Recovery and Security Suite      " -ForegroundColor White
Write-Host "  Community Field-Testing Release | Supervised Deployment Recommended   " -ForegroundColor Yellow
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host " NOTICE: Feature complete and available for community / bench testing.   " -ForegroundColor DarkYellow
Write-Host " Production fleet deployment experience has not yet been established.    " -ForegroundColor DarkYellow
Write-Host " Use at your own discretion and maintain independent secondary backups.  " -ForegroundColor DarkYellow
Write-Host "-------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host " [TRANSPARENCY] Live Command-Echo is ACTIVE (CLI mode only) during beta. " -ForegroundColor Cyan
Write-Host " All native DISM, Robocopy, and VSS commands are printed before run.     " -ForegroundColor Cyan
Write-Host " Toggle anytime in config/config.json ('EchoNativeCommands') or -NoEcho. " -ForegroundColor DarkGray
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Require Administrator Privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] Administrator privileges required. Requesting elevation..." -ForegroundColor Yellow
    $argString = if ($PassthruArgs) { $PassthruArgs -join " " } else { "" }
    $elevateCommand = "& { try { irm winbars.remarkablepc.com | iex } catch { irm https://raw.githubusercontent.com/remarkablepc/WINBARS/main/install.ps1 | iex } } $argString"
    Start-Process powershell.exe -Verb RunAs -ArgumentList @("-NoExit", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $elevateCommand)
    return
}

# 2. Stage Working Directory
$stagingDir = Join-Path -Path $env:TEMP -ChildPath "WINBARS_Bootstrap"
if (-not (Test-Path $stagingDir)) {
    New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null
}

$zipPath = Join-Path -Path $stagingDir -ChildPath "WINBARS-Latest.zip"
$exePath = Join-Path -Path $stagingDir -ChildPath "WINBARS.exe"

$skipDownload = $false
if ((Test-Path $exePath) -and (Test-Path $zipPath)) {
    try {
        $exeSize = (Get-Item $exePath).Length
        $age = (Get-Date) - (Get-Item $exePath).LastWriteTime
        if ($exeSize -gt 500KB -and $age.TotalMinutes -lt 15) {
            Write-Host "[*] Reusing cached WINBARS package ($([math]::Round($age.TotalMinutes, 1))m old)..." -ForegroundColor Green
            $skipDownload = $true
        }
    } catch { }
}

if (-not $skipDownload) {
    # 3. Download Official Vanilla Package from GitHub Releases
    $downloadUrl = "https://github.com/remarkablepc/WINBARS/releases/latest/download/WINBARS.zip"
    Write-Host "[*] Downloading latest WINBARS release from GitHub CDN..." -ForegroundColor Cyan

    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
    } catch {
        Write-Host "[!] Direct CDN download failed; resolving via GitHub API..." -ForegroundColor Gray
        try {
            $apiUri = "https://api.github.com/repos/remarkablepc/WINBARS/releases/latest"
            $headers = @{ "User-Agent" = "WINBARS-WebInstaller" }
            $releaseInfo = Invoke-RestMethod -Uri $apiUri -Headers $headers -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
            $zipAsset = $releaseInfo.assets | Where-Object { $_.name -like "WINBARS*.zip" } | Select-Object -First 1
            if ($zipAsset) {
                Invoke-WebRequest -Uri $zipAsset.browser_download_url -OutFile $zipPath -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
            }
        } catch {
            Write-Host "[FAIL] Download failed: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }

    # 4. Fast Package Extraction (Safe Overwrite)
    Write-Host "[*] Extracting package..." -ForegroundColor Cyan
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
        $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
        foreach ($entry in $zip.Entries) {
            if ($entry.Name -like "*.zip") { continue }
            $destPath = Join-Path $stagingDir $entry.FullName
            if ([string]::IsNullOrEmpty($entry.Name)) {
                if (-not (Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath -Force | Out-Null }
                continue
            }
            $parentDir = Split-Path -Parent $destPath
            if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destPath, $true)
        }
        $zip.Dispose()
    } catch {
        try {
            Expand-Archive -Path $zipPath -DestinationPath $stagingDir -Force
        } catch {
            Write-Host "[FAIL] Extraction failed: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }
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

# 6.5. Synchronize Canonical Host Installation if C:\Tools\WINBARS exists
$canonicalHost = "C:\Tools\WINBARS"
if (Test-Path $canonicalHost) {
    Write-Host "[*] Upgrading installed suite files at $canonicalHost..." -ForegroundColor Cyan
    try {
        Get-Process -Name "WINBARS", "WINBAR" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 400
        foreach ($entryName in @("WINBARS.exe", "WINBARS.exe.config", "WINBAR.exe", "WINBARS.ps1", "Run-WINBARS.bat", "config", "assets", "brands", "docs", "certs")) {
            $srcItem = Join-Path $stagingDir $entryName
            if (Test-Path $srcItem) {
                Copy-Item -Path $srcItem -Destination (Join-Path $canonicalHost $entryName) -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        $exePath = Join-Path $canonicalHost "WINBARS.exe"
        $stagingDir = $canonicalHost
        Write-Host "  [OK] Successfully synchronized latest release to $canonicalHost" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Notice during host installation upgrade: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 7. Execute WINBARS with Passed Arguments
Write-Host "[OK] Launching WINBARS Control Console..." -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------" -ForegroundColor Gray

Set-Location -LiteralPath $stagingDir -ErrorAction SilentlyContinue

if ($PassthruArgs -and $PassthruArgs.Count -gt 0) {
    $argList = $PassthruArgs -join " "
    $proc = Start-Process -FilePath $exePath -ArgumentList $argList -WorkingDirectory $stagingDir -NoNewWindow -Wait -PassThru
    exit $proc.ExitCode
} else {
    $proc = Start-Process -FilePath $exePath -WorkingDirectory $stagingDir -NoNewWindow -Wait -PassThru
    exit $proc.ExitCode
}
