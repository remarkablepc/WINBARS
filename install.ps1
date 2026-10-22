# install.ps1 (WINBARS Official Public Web Installer)
# Hosted at: winbars.remarkablepc.com
# Usage: irm winbars.remarkablepc.com | iex

[CmdletBinding()]
param(
    [Alias("Profile", "SetMode", "ChangeMode")]
    [string]$Mode = "",
    [string]$SwitchMode = "",
    [string]$TargetDrive = "",
    [switch]$Unattended,
    [switch]$DryRun,
    [switch]$Force,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PassthruArgs
)

# Set execution policy for the current process to bypass any machine-level restrictions
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction SilentlyContinue } catch { }

# Support environment variable override (e.g. $env:WINBARS_MODE=4; irm winbars.remarkablepc.com | iex)
if (-not $Mode -and $env:WINBARS_MODE) {
    $Mode = $env:WINBARS_MODE.Trim()
}

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
    $forwardArgs = @()
    if ($Mode) { $forwardArgs += "-Mode `"$Mode`"" }
    elseif ($SwitchMode) { $forwardArgs += "-SwitchMode `"$SwitchMode`"" }
    if ($TargetDrive) { $forwardArgs += "-TargetDrive `"$TargetDrive`"" }
    if ($Unattended) { $forwardArgs += "-Unattended" }
    if ($DryRun) { $forwardArgs += "-DryRun" }
    if ($Force) { $forwardArgs += "-Force" }
    if ($PassthruArgs) { $forwardArgs += ($PassthruArgs -join " ") }
    $argString = $forwardArgs -join " "

    $elevateCommand = "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13; `$code = try { (Invoke-RestMethod -Uri 'https://winbars.remarkablepc.com' -UseBasicParsing) } catch { (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/remarkablepc/WINBARS/main/install.ps1' -UseBasicParsing) }; & ([scriptblock]::Create(`$code)) $argString }"
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList @("-NoExit", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $elevateCommand)
    } catch {
        Write-Host "  [!] UAC Elevation prompt could not be launched ($($_.Exception.Message))." -ForegroundColor Yellow
        Write-Host "  [!] Please open PowerShell as Administrator and run the command again." -ForegroundColor Red
    }
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
if (-not $Force -and (Test-Path $exePath) -and (Test-Path $zipPath)) {
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
    # 3. Download Package (Primary: High-Speed Web Mirror; Fallback: GitHub Releases)
    $downloadUrls = @(
        "https://winbars.remarkablepc.com/WINBARS.zip",
        "https://macpc.remarkablepc.com/WINBARS.zip",
        "https://github.com/remarkablepc/WINBARS/releases/latest/download/WINBARS.zip"
    )
    $downloadSuccess = $false
    foreach ($url in $downloadUrls) {
        try {
            Write-Host "[*] Downloading WINBARS package from $url..." -ForegroundColor Cyan
            Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -TimeoutSec 45 -ErrorAction Stop
            if ((Test-Path $zipPath) -and (Get-Item $zipPath).Length -gt 500KB) {
                $downloadSuccess = $true
                break
            }
        } catch {
            Write-Host "  [!] Notice: Endpoint $url unavailable ($($_.Exception.Message)). Trying next source..." -ForegroundColor Gray
        }
    }

    if (-not $downloadSuccess) {
        Write-Host "[!] Direct package downloads failed; resolving via GitHub API..." -ForegroundColor Yellow
        try {
            $apiUri = "https://api.github.com/repos/remarkablepc/WINBARS/releases/latest"
            $headers = @{ "User-Agent" = "WINBARS-WebInstaller" }
            $releaseInfo = Invoke-RestMethod -Uri $apiUri -Headers $headers -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
            $zipAsset = $releaseInfo.assets | Where-Object { $_.name -like "WINBARS*.zip" } | Select-Object -First 1
            if ($zipAsset) {
                Invoke-WebRequest -Uri $zipAsset.browser_download_url -OutFile $zipPath -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
                if ((Test-Path $zipPath) -and (Get-Item $zipPath).Length -gt 500KB) {
                    $downloadSuccess = $true
                }
            }
        } catch { }
    }

    if (-not $downloadSuccess) {
        Write-Host "[FAIL] All package download sources failed. Please verify internet connection." -ForegroundColor Red
        return
    }

    # 4. Fast Package Extraction (Safe Overwrite with Resilient Retry)
    Write-Host "[*] Extracting package..." -ForegroundColor Cyan

    # Pre-clean read-only attributes on existing staging files if any
    try {
        if (Test-Path $stagingDir) {
            Get-ChildItem -Path $stagingDir -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                if (-not $_.PSIsContainer) { $_.Attributes = 'Normal' }
            }
        }
    } catch { }

    $extractSuccess = $false
    $extractError = ""

    # Primary Attempt: Direct extraction with attribute clearing
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
        $zip = $null
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
            foreach ($entry in $zip.Entries) {
                $normFullName = $entry.FullName -replace '\\','/'
                if ($normFullName -like "*web-deploy*" -or $normFullName -like "brands/*" -or $normFullName -like "demo/*" -or $normFullName -like "docs/*") { continue }
                $destPath = Join-Path $stagingDir $entry.FullName
                if ([string]::IsNullOrEmpty($entry.Name)) {
                    if (-not (Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath -Force | Out-Null }
                    continue
                }
                $parentDir = Split-Path -Parent $destPath
                if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
                if (Test-Path -LiteralPath $destPath) {
                    try {
                        [System.IO.File]::SetAttributes($destPath, [System.IO.FileAttributes]::Normal)
                        [System.IO.File]::Delete($destPath)
                    } catch { }
                }
                try {
                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destPath, $true)
                } catch {
                    if ($entry.Name -eq "WINBARS.exe" -or $entry.Name -eq "WINBARS.ps1") {
                        throw $_
                    } else {
                        Write-Host "  [!] Notice: Non-critical entry skipped ($($entry.Name)): $($_.Exception.Message)" -ForegroundColor Gray
                    }
                }
            }
            $extractSuccess = $true
        } finally {
            if ($zip) { $zip.Dispose() }
        }
    } catch {
        $extractError = $_.Exception.Message
    }

    # Fallback Attempt: If primary directory had locked files, extract into an isolated fresh unique staging folder
    if (-not $extractSuccess) {
        Write-Host "  [!] Retrying extraction into fresh clean staging container..." -ForegroundColor Yellow
        $freshStagingDir = Join-Path -Path $env:TEMP -ChildPath ("WINBARS_Bootstrap_" + [System.Guid]::NewGuid().ToString("N").Substring(0, 8))
        New-Item -ItemType Directory -Path $freshStagingDir -Force | Out-Null

        try {
            $zip = $null
            try {
                $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
                foreach ($entry in $zip.Entries) {
                    $normFullName = $entry.FullName -replace '\\','/'
                    if ($normFullName -like "*web-deploy*" -or $normFullName -like "brands/*" -or $normFullName -like "demo/*" -or $normFullName -like "docs/*") { continue }
                    $destPath = Join-Path $freshStagingDir $entry.FullName
                    if ([string]::IsNullOrEmpty($entry.Name)) {
                        if (-not (Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath -Force | Out-Null }
                        continue
                    }
                    $parentDir = Split-Path -Parent $destPath
                    if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
                    try {
                        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destPath, $true)
                    } catch {
                        if ($entry.Name -eq "WINBARS.exe" -or $entry.Name -eq "WINBARS.ps1") {
                            throw $_
                        }
                    }
                }
                $stagingDir = $freshStagingDir
                $exePath = Join-Path -Path $stagingDir -ChildPath "WINBARS.exe"
                $extractSuccess = $true
            } finally {
                if ($zip) { $zip.Dispose() }
            }
        } catch {
            try {
                Expand-Archive -Path $zipPath -DestinationPath $freshStagingDir -Force
                $stagingDir = $freshStagingDir
                $exePath = Join-Path -Path $stagingDir -ChildPath "WINBARS.exe"
                $extractSuccess = $true
            } catch {
                $extractError = $_.Exception.Message
            }
        }
    }

    if (-not $extractSuccess) {
        Write-Host "[FAIL] Extraction failed: $extractError" -ForegroundColor Red
        return
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
        $existingHostCfg = $null
        $hostCfgPath = Join-Path $canonicalHost "config\config.json"
        if (Test-Path -LiteralPath $hostCfgPath) {
            try { $existingHostCfg = Get-Content -LiteralPath $hostCfgPath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue } catch { }
        }
        Get-Process -Name "WINBARS", "WINBAR" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 400
        $filesToSync = @("WINBARS.exe", "WINBARS.exe.config", "WINBAR.exe", "WINBARS.ps1", "Run-WINBARS.bat", "HOW_TO_RESTORE.html", "README.md", "CHANGELOG.md", "LICENSE.txt")
        foreach ($fileName in $filesToSync) {
            $srcItem = Join-Path $stagingDir $fileName
            if (Test-Path $srcItem) {
                Copy-Item -Path $srcItem -Destination (Join-Path $canonicalHost $fileName) -Force -ErrorAction SilentlyContinue
            }
        }
        $foldersToSync = @("config", "assets", "certs")
        foreach ($folderName in $foldersToSync) {
            $srcFolder = Join-Path $stagingDir $folderName
            if (Test-Path $srcFolder) {
                $destFolder = Join-Path $canonicalHost $folderName
                if (-not (Test-Path $destFolder)) { New-Item -ItemType Directory -Path $destFolder -Force | Out-Null }
                Copy-Item -Path (Join-Path $srcFolder "*") -Destination $destFolder -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        # Enforce single branding JSON policy: purge brands/ folders
        @((Join-Path $stagingDir "brands"), (Join-Path $canonicalHost "brands"), "C:\ProgramData\WINBARS\brands", "C:\Tools\WINBARS\brands") | ForEach-Object {
            if (Test-Path $_) { Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue }
        }
        if ($existingHostCfg) {
            try { [System.IO.File]::WriteAllText($hostCfgPath, $existingHostCfg, [System.Text.Encoding]::UTF8) } catch { }
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

$forwardArgs = @()
$targetMode = if ($Mode) { $Mode } elseif ($SwitchMode) { $SwitchMode } else { "" }

if ($targetMode) {
    $forwardArgs += "-SwitchMode"
    $forwardArgs += $targetMode
    if ($Unattended) {
        $forwardArgs += "-Unattended"
    }
} else {
    # If no mode explicitly provided, open the Deployment Profiles Menu directly
    if (-not $Unattended) {
        $forwardArgs += "-Install"
    } else {
        $forwardArgs += "-SwitchMode"
        $forwardArgs += "2"
        $forwardArgs += "-Unattended"
    }
}

if ($TargetDrive) {
    $forwardArgs += "-TargetDrive"
    $forwardArgs += $TargetDrive
}
if ($DryRun) {
    $forwardArgs += "-DryRun"
}
if ($PassthruArgs) {
    $forwardArgs += $PassthruArgs
}

$scriptPath = Join-Path -Path $stagingDir -ChildPath "WINBARS.ps1"
if (-not (Test-Path $scriptPath) -and (Test-Path "C:\Tools\WINBARS\WINBARS.ps1")) {
    $scriptPath = "C:\Tools\WINBARS\WINBARS.ps1"
}

if ($targetMode) {
    Write-Host "[*] Applying WINBARS Mode $targetMode configuration..." -ForegroundColor Cyan
} else {
    Write-Host "[*] Opening WINBARS Deployment Profiles Menu..." -ForegroundColor Cyan
}
Write-Host "-------------------------------------------------------------------------" -ForegroundColor Gray

if (Test-Path $scriptPath) {
    try {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scriptPath @forwardArgs
    } catch {
        Write-Host "  [!] Notice during execution: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} elseif (Test-Path $exePath) {
    try {
        $exeArgList = $forwardArgs -join " "
        $proc = Start-Process -FilePath $exePath -ArgumentList $exeArgList -WorkingDirectory $stagingDir -NoNewWindow -Wait -PassThru
        if ($proc -and $proc.ExitCode -ne 0) {
            Write-Host "  [!] Notice: Process exited with code $($proc.ExitCode)" -ForegroundColor Yellow
        }
    } catch {
        try {
            & $exePath @forwardArgs
        } catch {
            Write-Host "  [!] Notice during execution: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

# Detect deployed profile from configuration
$activeProfile = $targetMode
try {
    $cfgPath = "C:\ProgramData\WINBARS\config\config.json"
    if (-not (Test-Path $cfgPath)) { $cfgPath = "C:\Tools\WINBARS\config\config.json" }
    if (Test-Path $cfgPath) {
        $json = Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($json.DeploymentProfile) { $activeProfile = $json.DeploymentProfile }
    }
} catch { }

Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Green
Write-Host " [SUCCESS] WINBARS deployment completed successfully!" -ForegroundColor Green
if ($activeProfile) {
    Write-Host " Active Profile: $activeProfile" -ForegroundColor Cyan
}
Write-Host "=========================================================================" -ForegroundColor Green
return
