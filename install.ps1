# install.ps1 (WINBARS Official Public Web Installer)
# Hosted at: https://raw.githubusercontent.com/remarkablepc/WINBARS/main/install.ps1
# Usage: irm https://raw.githubusercontent.com/remarkablepc/WINBARS/main/install.ps1 | iex

[CmdletBinding()]
param(
    [Alias("Profile", "SetMode", "ChangeMode")]
    [string]$Mode = "",
    [string]$SwitchMode = "",
    [string]$TargetDrive = "",
    [switch]$Unattended,
    [Alias("AllowRAT", "WhitelistRATs")]
    [string[]]$WhitelistRAT = @(),
    [switch]$AllowRunningRATs,
    [switch]$DryRun,
    [switch]$Force,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PassthruArgs
)

# Support environment variable override (e.g. $env:WINBARS_MODE=4; irm https://raw.githubusercontent.com/remarkablepc/WINBARS/main/install.ps1 | iex)
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
    if ($WhitelistRAT) { $forwardArgs += "-WhitelistRAT `"$($WhitelistRAT -join ',')`"" }
    if ($AllowRunningRATs) { $forwardArgs += "-AllowRunningRATs" }
    if ($DryRun) { $forwardArgs += "-DryRun" }
    if ($Force) { $forwardArgs += "-Force" }
    if ($PassthruArgs) { $forwardArgs += ($PassthruArgs -join " ") }
    $argString = $forwardArgs -join " "

    $elevateCommand = "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13; `$code = (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/remarkablepc/WINBARS/main/install.ps1' -UseBasicParsing); & ([scriptblock]::Create(`$code)) $argString }"
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
        $foldersToSync = @("config", "assets", "brands", "docs", "certs", "tools", "installers")
        foreach ($folderName in $foldersToSync) {
            $srcFolder = Join-Path $stagingDir $folderName
            if (Test-Path $srcFolder) {
                $destFolder = Join-Path $canonicalHost $folderName
                if (-not (Test-Path $destFolder)) { New-Item -ItemType Directory -Path $destFolder -Force | Out-Null }
                Copy-Item -Path (Join-Path $srcFolder "*") -Destination $destFolder -Recurse -Force -ErrorAction SilentlyContinue
            }
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

# 6.8. Smart Live Remote Session Detection & Whitelisting (Friendly-Fire Prevention)
$knownRatMap = @{
    "AnyViewer"        = @("anyviewer", "amanhlp")
    "Remote Utilities" = @("rutserv", "rfusclient", "rutview", "rmanservice")
    "ScreenConnect"    = @("screenconnect")
    "AnyDesk"          = @("anydesk")
    "TeamViewer"       = @("teamviewer")
    "RustDesk"         = @("rustdesk")
    "UltraViewer"      = @("ultraviewer")
    "Splashtop"        = @("splashtop", "srserver", "srfeature")
    "Zoho Assist"      = @("zohours", "zohomeeting")
    "Parsec"           = @("parsecd")
    "LogMeIn"          = @("logmein", "lmiguardian")
    "ConnectWise"      = @("connectwise")
    "DWService"        = @("dwagsvc")
    "AeroAdmin"        = @("aeroadmin")
    "MeshCentral"      = @("meshagent")
}

$detectedActiveTools = [System.Collections.Generic.List[string]]::new()
try {
    $procs = Get-Process -ErrorAction SilentlyContinue | ForEach-Object { $_.ProcessName.ToLower() }
    foreach ($kv in $knownRatMap.GetEnumerator()) {
        foreach ($pat in $kv.Value) {
            if ($procs -contains $pat -or ($procs | Where-Object { $_ -like "$pat*" })) {
                if (-not $detectedActiveTools.Contains($kv.Key)) {
                    $detectedActiveTools.Add($kv.Key)
                }
                break
            }
        }
    }
} catch { }

$whitelistDir = "C:\ProgramData\WINBARS"
$whitelistFile = Join-Path $whitelistDir "rat_whitelist.json"
if (-not (Test-Path $whitelistDir)) { New-Item -ItemType Directory -Path $whitelistDir -Force | Out-Null }

# Explicit Whitelist entries from CLI
if ($WhitelistRAT -and $WhitelistRAT.Count -gt 0) {
    try {
        $existing = @()
        if (Test-Path $whitelistFile) {
            $raw = Get-Content -Path $whitelistFile -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($raw) { $existing = @($raw) }
        }
        foreach ($w in $WhitelistRAT) {
            $wClean = $w.Trim()
            $procMatches = if ($knownRatMap.ContainsKey($wClean)) { $knownRatMap[$wClean] } else { @($wClean.ToLower()) }
            $existing = @($existing | Where-Object { $_.Name -ne $wClean })
            $existing += [PSCustomObject]@{
                Name      = $wClean
                Processes = $procMatches
                Reason    = "Installer CLI Parameter"
                DateAdded = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                AddedBy   = [System.Environment]::UserName
            }
            Write-Host "  [OK] Whitelisted remote tool: $wClean" -ForegroundColor Green
        }
        $existing | ConvertTo-Json -Depth 4 | Set-Content -Path $whitelistFile -Encoding UTF8 -Force
    } catch { }
}

# Live Session Detection & Prompt / Auto-Whitelist
if ($detectedActiveTools.Count -gt 0) {
    $toolsListStr = ($detectedActiveTools -join ", ")
    $shouldWhitelistActive = $false

    if ($Unattended -or $AllowRunningRATs -or [Console]::IsInputRedirected) {
        $shouldWhitelistActive = $true
        Write-Host "  [!] Live Remote Session Active: $toolsListStr" -ForegroundColor Yellow
        Write-Host "  [OK] Auto-whitelisting session to prevent accidental disconnect." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "=========================================================================" -ForegroundColor Yellow
        Write-Host " [!] ACTIVE REMOTE SUPPORT SESSION DETECTED                              " -ForegroundColor Yellow
        Write-Host "=========================================================================" -ForegroundColor DarkYellow
        Write-Host " Detected live remote session: $toolsListStr" -ForegroundColor White
        Write-Host " WINBARS ScamBuster includes automated fraud defense that severs         " -ForegroundColor DarkGray
        Write-Host " unauthorized remote tools. To keep your current session connected,      " -ForegroundColor DarkGray
        Write-Host " this tool should be whitelisted.                                        " -ForegroundColor DarkGray
        Write-Host "-------------------------------------------------------------------------" -ForegroundColor DarkGray
        $userResp = Read-Host " Whitelist '$toolsListStr' now? [Y/n] (Default: Y)"
        if (-not $userResp -or $userResp.Trim().ToLower() -eq 'y' -or $userResp.Trim().ToLower() -eq 'yes') {
            $shouldWhitelistActive = $true
        }
    }

    if ($shouldWhitelistActive) {
        try {
            $existing = @()
            if (Test-Path $whitelistFile) {
                $raw = Get-Content -Path $whitelistFile -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
                if ($raw) { $existing = @($raw) }
            }
            $allProcsToWhitelist = [System.Collections.Generic.List[string]]::new()
            foreach ($dt in $detectedActiveTools) {
                $procMatches = if ($knownRatMap.ContainsKey($dt)) { $knownRatMap[$dt] } else { @($dt.ToLower()) }
                foreach ($pm in $procMatches) { if (-not $allProcsToWhitelist.Contains($pm)) { $allProcsToWhitelist.Add($pm) } }
                $existing = @($existing | Where-Object { $_.Name -ne $dt })
                $existing += [PSCustomObject]@{
                    Name      = $dt
                    Processes = $procMatches
                    Reason    = "Live Session Active During Installation"
                    DateAdded = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                    AddedBy   = [System.Environment]::UserName
                }
            }
            $existing | ConvertTo-Json -Depth 4 | Set-Content -Path $whitelistFile -Encoding UTF8 -Force

            # Also sync into config.json AllowedRemoteTools
            $cfgCandidates = @(
                (Join-Path $stagingDir "config\config.json"),
                "C:\Tools\WINBARS\config\config.json"
            )
            foreach ($cfgPath in $cfgCandidates) {
                if (Test-Path $cfgPath) {
                    try {
                        $cfgContent = Get-Content $cfgPath -Raw -ErrorAction SilentlyContinue
                        if ($cfgContent) {
                            foreach ($pm in $allProcsToWhitelist) {
                                $entry = "`"$pm`""
                                if ($cfgContent -notmatch $entry) {
                                    $cfgContent = $cfgContent -replace '("AllowedRemoteTools"\s*:\s*\[)', "`$1`r`n                                                              $entry,"
                                }
                            }
                            Set-Content -Path $cfgPath -Value $cfgContent -Encoding UTF8 -Force
                        }
                    } catch { }
                }
            }

            if (-not $WhitelistRAT) { $WhitelistRAT = @() }
            foreach ($dt in $detectedActiveTools) {
                if ($WhitelistRAT -notcontains $dt) { $WhitelistRAT += $dt }
            }

            Write-Host "  [OK] Successfully whitelisted active remote session ($toolsListStr)." -ForegroundColor Green
        } catch { }
    }
}

# 7. Execute WINBARS with Passed Arguments
Write-Host "[OK] Launching WINBARS Control Console..." -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------" -ForegroundColor Gray

Set-Location -LiteralPath $stagingDir -ErrorAction SilentlyContinue

$forwardArgs = @()
$targetMode = if ($Mode) { $Mode } elseif ($SwitchMode) { $SwitchMode } else { "" }
if ($targetMode) {
    $forwardArgs += "-SwitchMode $targetMode"
}
if ($TargetDrive) {
    $forwardArgs += "-TargetDrive `"$TargetDrive`""
}
if ($Unattended) {
    $forwardArgs += "-Unattended"
}
if ($WhitelistRAT) {
    $forwardArgs += "-WhitelistRAT `"$($WhitelistRAT -join ',')`""
}
if ($AllowRunningRATs) {
    $forwardArgs += "-AllowRunningRATs"
}
if ($DryRun) {
    $forwardArgs += "-DryRun"
}
if ($PassthruArgs) {
    $forwardArgs += ($PassthruArgs -join " ")
}

if ($forwardArgs.Count -gt 0) {
    $argList = $forwardArgs -join " "
    Write-Host "[*] Executing: $exePath $argList" -ForegroundColor Cyan
    $proc = Start-Process -FilePath $exePath -ArgumentList $argList -WorkingDirectory $stagingDir -NoNewWindow -Wait -PassThru
    exit $proc.ExitCode
} else {
    Start-Process -FilePath $exePath -WorkingDirectory $stagingDir
}

