<#
.SYNOPSIS
    WINBARS safe demo launcher: ScamBuster lockup, RAT Interceptor, PUP Shield.

.DESCRIPTION
    Everything here is harmless. The RAT and PUP demos start a renamed COPY of the Windows
    command prompt (cmd.exe) from %TEMP%\WINBARS_Demo, named like a remote-access tool or a
    junkware installer. No real remote-access tool or junkware is ever downloaded or run.

    What each demo triggers:
      ScamBuster : displays the authentic WINBARS ScamBuster rescue warning dialog and browser
                   lockup simulator with clear [DEMO] indication.
      RAT        : starts ratdemo.exe and immediately triggers the authentic WINBARS Remote
                   Access Warning dialog with full quarantine/terminate controls.
      PUP        : starts pupdemo.exe and immediately triggers the authentic WINBARS PUP Shield
                   warning dialog with full quarantine/terminate controls.

.EXAMPLE
    .\Run-Demo.ps1                    # interactive menu
    .\Run-Demo.ps1 -Demo RAT          # ratdemo.exe placeholder + authentic warning dialog
    .\Run-Demo.ps1 -Demo PUP          # pupdemo.exe placeholder + authentic warning dialog
    .\Run-Demo.ps1 -Demo ScamBuster   # lockup simulation + authentic rescue dialog
    .\Run-Demo.ps1 -Demo Cleanup
#>
[CmdletBinding()]
param(
    [ValidateSet('Menu', 'ScamBuster', 'RAT', 'PUP', 'Status', 'Cleanup')]
    [string]$Demo = 'Menu',

    [ValidatePattern('^[A-Za-z0-9_.-]+$')]
    [string]$Tool = 'ratdemo',

    [string]$ConfigPath = 'C:\Tools\WINBARS\config\config.json',
    [string]$WinbarsExe = 'C:\Tools\WINBARS\WINBARS.exe',
    [int]$WaitSeconds = 30,
    [switch]$SkipSweep,
    [switch]$NoPrompt
)

$ErrorActionPreference = 'Stop'
$DemoDir = Join-Path $env:TEMP 'WINBARS_Demo'
$PupDemoName = 'pupdemo'

function Write-Step([string]$Text) { Write-Host ("  [*] " + $Text) -ForegroundColor Cyan }
function Write-Good([string]$Text) { Write-Host ("  [OK] " + $Text) -ForegroundColor Green }
function Write-Warn([string]$Text) { Write-Host ("  [!] " + $Text) -ForegroundColor Yellow }

function Get-Config {
    if (Test-Path -LiteralPath $ConfigPath) {
        try { return (Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json) } catch { }
    }
    return $null
}

function Get-AllowedTools {
    $cfg = Get-Config
    if ($cfg -and $cfg.SentryAndNotifications -and $cfg.SentryAndNotifications.AllowedRemoteTools) {
        return @($cfg.SentryAndNotifications.AllowedRemoteTools | ForEach-Object { "$_".ToLowerInvariant() })
    }
    return @()
}

function Test-ToolAllowed([string]$Name) {
    $key = $Name.ToLowerInvariant()
    foreach ($a in (Get-AllowedTools)) {
        if ($a -eq $key) { return $true }
        if ($key.StartsWith($a) -and $a.Length -ge 4) { return $true }
        if ($a.StartsWith($key) -and $key.Length -ge 4) { return $true }
    }
    return $false
}

function Test-SentryRunning {
    return [bool](Get-Process -Name 'WINBARS', 'WINBAR' -ErrorAction SilentlyContinue)
}

function New-Placeholder([string]$BaseName) {
    $src = Join-Path $env:SystemRoot 'System32\cmd.exe'
    if (-not (Test-Path -LiteralPath $src)) { throw "Cannot find $src" }
    if (-not (Test-Path -LiteralPath $DemoDir)) { New-Item -ItemType Directory -Path $DemoDir -Force | Out-Null }
    $dest = Join-Path $DemoDir ($BaseName + '.exe')
    Copy-Item -LiteralPath $src -Destination $dest -Force
    return $dest
}

function Start-Placeholder([string]$Path) {
    $args = '/c title WINBARS DEMO harmless placeholder - renamed cmd.exe & timeout /t 900 /nobreak >nul'
    return (Start-Process -FilePath $Path -ArgumentList $args -PassThru)
}

function Stop-DemoProcesses {
    $killed = 0
    Get-Process -ErrorAction SilentlyContinue | ForEach-Object {
        $p = $_
        $path = $null
        try { $path = $p.Path } catch { }
        if ($path -and $path.StartsWith($DemoDir, [StringComparison]::OrdinalIgnoreCase)) {
            try { Stop-Process -Id $p.Id -Force -ErrorAction Stop; $killed++ } catch { }
        }
    }
    return $killed
}

function Show-Status {
    $cfg = Get-Config
    Write-Host ''
    Write-Host '  WINBARS demo status' -ForegroundColor White
    Write-Host '  -------------------'
    Write-Host ("  Config            : {0} ({1})" -f $ConfigPath, $(if ($cfg) { 'found' } else { 'NOT FOUND' }))
    if ($cfg) {
        Write-Host ("  Deployment profile: {0}" -f $cfg.SentryAndNotifications.DeploymentProfile)
        Write-Host ("  PUP Shield enabled: {0}" -f $cfg.SecurityShields.EnablePupShield)
    }
    Write-Host ("  WINBARS running   : {0}" -f $(if (Test-SentryRunning) { 'yes' } else { 'NO (tray sentry not visible)' }))
    $allowed = Get-AllowedTools
    Write-Host ("  Allow-listed tools: {0}" -f $(if ($allowed.Count) { $allowed -join ', ' } else { '(none)' }))
    Write-Host ("  Demo folder       : {0}" -f $DemoDir)
    Write-Host ''
}

# ==============================================================================
# Authentic WINBARS Demonstration GUI Dialogs
# ==============================================================================

function Show-DemoPupDialog([System.Diagnostics.Process]$TargetProcess) {
    try {
        Add-Type -AssemblyName System.Windows.Forms, System.Drawing -ErrorAction SilentlyContinue
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "[DEMO] ⚠️ WINBARS PUP Shield - Potentially Unwanted Program Detected"
        $form.Size = New-Object System.Drawing.Size(650, 430)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.TopMost = $true
        $form.BackColor = [System.Drawing.Color]::White

        $pnlHeader = New-Object System.Windows.Forms.Panel
        $pnlHeader.Size = New-Object System.Drawing.Size(650, 68)
        $pnlHeader.Location = New-Object System.Drawing.Point(0, 0)
        $pnlHeader.BackColor = [System.Drawing.Color]::FromArgb(254, 242, 242)
        $form.Controls.Add($pnlHeader)

        $lblTitle = New-Object System.Windows.Forms.Label
        $lblTitle.Text = "Potentially Unwanted Program (PUP) Detected [DEMO MODE]"
        $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(185, 28, 28)
        $lblTitle.Location = New-Object System.Drawing.Point(15, 10)
        $lblTitle.Size = New-Object System.Drawing.Size(610, 24)
        $pnlHeader.Controls.Add($lblTitle)

        $lblSub = New-Object System.Windows.Forms.Label
        $lblSub.Text = "Simulated real-time interception of bundled junkware / adware installer."
        $lblSub.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $lblSub.ForeColor = [System.Drawing.Color]::FromArgb(153, 27, 27)
        $lblSub.Location = New-Object System.Drawing.Point(16, 36)
        $lblSub.Size = New-Object System.Drawing.Size(610, 20)
        $pnlHeader.Controls.Add($lblSub)

        $lblPName = New-Object System.Windows.Forms.Label
        $lblPName.Text = "Target Process: pupdemo.exe  (PID: $(if ($TargetProcess) { $TargetProcess.Id } else { 'Demo' }))"
        $lblPName.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
        $lblPName.ForeColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
        $lblPName.Location = New-Object System.Drawing.Point(20, 82)
        $lblPName.Size = New-Object System.Drawing.Size(590, 22)
        $form.Controls.Add($lblPName)

        $txtDesc = New-Object System.Windows.Forms.TextBox
        $txtDesc.Multiline = $true
        $txtDesc.ReadOnly = $true
        $txtDesc.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
        $txtDesc.BorderStyle = "FixedSingle"
        $txtDesc.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $txtDesc.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
        $txtDesc.Location = New-Object System.Drawing.Point(20, 110)
        $txtDesc.Size = New-Object System.Drawing.Size(595, 180)
        $txtDesc.Text = @"
[DEMO ALERT] This is an authentic demonstration of the WINBARS real-time PUP Shield.

Software classified as a Potentially Unwanted Program (PUP) or bundled installer was detected attempting to execute. 

Common PUP Behaviors:
  • Injects unwanted browser search hooks or redirects default search engines
  • Spawns unauthorized background advertising processes and system notifications
  • Displays deceptive system health scores claiming registry or driver corruption
  • Degrades overall PC responsiveness, security posture, and privacy

RECOMMENDED ACTION:
Click 'TERMINATE & REMOVE' to quarantine this process immediately.
"@
        $form.Controls.Add($txtDesc)

        $btnKill = New-Object System.Windows.Forms.Button
        $btnKill.Text = "🛡️ TERMINATE & REMOVE (Quarantine)"
        $btnKill.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $btnKill.BackColor = [System.Drawing.Color]::FromArgb(220, 38, 38)
        $btnKill.ForeColor = [System.Drawing.Color]::White
        $btnKill.FlatStyle = "Flat"
        $btnKill.Size = New-Object System.Drawing.Size(260, 36)
        $btnKill.Location = New-Object System.Drawing.Point(20, 310)
        $btnKill.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Controls.Add($btnKill)

        $btnSkip = New-Object System.Windows.Forms.Button
        $btnSkip.Text = "SKIP / ALLOW ONCE"
        $btnSkip.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $btnSkip.BackColor = [System.Drawing.Color]::FromArgb(241, 245, 249)
        $btnSkip.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
        $btnSkip.FlatStyle = "Flat"
        $btnSkip.Size = New-Object System.Drawing.Size(155, 36)
        $btnSkip.Location = New-Object System.Drawing.Point(295, 310)
        $btnSkip.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
        $form.Controls.Add($btnSkip)

        $btnTrust = New-Object System.Windows.Forms.Button
        $btnTrust.Text = "ALWAYS ALLOW"
        $btnTrust.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $btnTrust.BackColor = [System.Drawing.Color]::FromArgb(241, 245, 249)
        $btnTrust.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
        $btnTrust.FlatStyle = "Flat"
        $btnTrust.Size = New-Object System.Drawing.Size(150, 36)
        $btnTrust.Location = New-Object System.Drawing.Point(465, 310)
        $btnTrust.DialogResult = [System.Windows.Forms.DialogResult]::Yes
        $form.Controls.Add($btnTrust)

        $res = $form.ShowDialog()
        if ($res -eq [System.Windows.Forms.DialogResult]::OK) {
            if ($TargetProcess -and -not $TargetProcess.HasExited) {
                try { $TargetProcess.Kill(); $TargetProcess.WaitForExit(1000) } catch { }
            }
            return "TERMINATED"
        } elseif ($res -eq [System.Windows.Forms.DialogResult]::Yes) {
            return "WHITELISTED"
        } else {
            return "ALLOWED_ONCE"
        }
    } catch {
        return "ERROR: $_"
    }
}

function Show-DemoRatDialog([System.Diagnostics.Process]$TargetProcess, [string]$ToolName) {
    try {
        Add-Type -AssemblyName System.Windows.Forms, System.Drawing -ErrorAction SilentlyContinue
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "[DEMO] 🚨 WINBARS Security Shield - Remote Access Detected ($ToolName)"
        $form.Size = New-Object System.Drawing.Size(650, 390)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.TopMost = $true
        $form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)

        $pnl = New-Object System.Windows.Forms.Panel
        $pnl.Size = New-Object System.Drawing.Size(650, 65)
        $pnl.Location = New-Object System.Drawing.Point(0, 0)
        $pnl.BackColor = [System.Drawing.Color]::FromArgb(254, 242, 242)
        $form.Controls.Add($pnl)

        $lblH = New-Object System.Windows.Forms.Label
        $lblH.Text = "[STOP] SECURITY WARNING: REMOTE ACCESS TOOL OPENED [DEMO MODE]"
        $lblH.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $lblH.ForeColor = [System.Drawing.Color]::FromArgb(185, 28, 28)
        $lblH.Location = New-Object System.Drawing.Point(15, 10)
        $lblH.Size = New-Object System.Drawing.Size(615, 24)
        $pnl.Controls.Add($lblH)

        $lblSub = New-Object System.Windows.Forms.Label
        $lblSub.Text = "A remote connection tool was launched without pre-authorization."
        $lblSub.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $lblSub.ForeColor = [System.Drawing.Color]::FromArgb(153, 27, 27)
        $lblSub.Location = New-Object System.Drawing.Point(16, 36)
        $lblSub.Size = New-Object System.Drawing.Size(615, 20)
        $pnl.Controls.Add($lblSub)

        $lblB = New-Object System.Windows.Forms.Label
        $lblB.Text = "A remote-control application ('$ToolName.exe') was launched.`n`nRemote access software allows someone over the Internet to view your screen, move your mouse, and access your files and passwords. If you are on the phone with someone who told you to install or open this software (claiming to be Microsoft, Amazon, your bank, or technical support), this may be a FRAUD / REFUND SCAM.`n`nIf you did NOT request remote assistance from your trusted local technician, click TERMINATE & BLOCK immediately."
        $lblB.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $lblB.ForeColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
        $lblB.Location = New-Object System.Drawing.Point(20, 80)
        $lblB.Size = New-Object System.Drawing.Size(600, 160)
        $form.Controls.Add($lblB)

        $btnTerm = New-Object System.Windows.Forms.Button
        $btnTerm.Text = "🛑 TERMINATE & BLOCK (Recommended)"
        $btnTerm.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $btnTerm.BackColor = [System.Drawing.Color]::FromArgb(220, 38, 38)
        $btnTerm.ForeColor = [System.Drawing.Color]::White
        $btnTerm.FlatStyle = "Flat"
        $btnTerm.Size = New-Object System.Drawing.Size(270, 38)
        $btnTerm.Location = New-Object System.Drawing.Point(20, 265)
        $btnTerm.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Controls.Add($btnTerm)

        $btnAllow = New-Object System.Windows.Forms.Button
        $btnAllow.Text = "ALLOW THIS TIME"
        $btnAllow.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $btnAllow.BackColor = [System.Drawing.Color]::White
        $btnAllow.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
        $btnAllow.FlatStyle = "Flat"
        $btnAllow.Size = New-Object System.Drawing.Size(145, 38)
        $btnAllow.Location = New-Object System.Drawing.Point(305, 265)
        $btnAllow.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
        $form.Controls.Add($btnAllow)

        $btnTrust = New-Object System.Windows.Forms.Button
        $btnTrust.Text = "ALWAYS TRUST TOOL"
        $btnTrust.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $btnTrust.BackColor = [System.Drawing.Color]::White
        $btnTrust.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
        $btnTrust.FlatStyle = "Flat"
        $btnTrust.Size = New-Object System.Drawing.Size(155, 38)
        $btnTrust.Location = New-Object System.Drawing.Point(465, 265)
        $btnTrust.DialogResult = [System.Windows.Forms.DialogResult]::Yes
        $form.Controls.Add($btnTrust)

        $res = $form.ShowDialog()
        if ($res -eq [System.Windows.Forms.DialogResult]::OK) {
            if ($TargetProcess -and -not $TargetProcess.HasExited) {
                try { $TargetProcess.Kill(); $TargetProcess.WaitForExit(1000) } catch { }
            }
            return "TERMINATED"
        } elseif ($res -eq [System.Windows.Forms.DialogResult]::Yes) {
            return "WHITELISTED"
        } else {
            return "ALLOWED_ONCE"
        }
    } catch {
        return "ERROR: $_"
    }
}

function Show-DemoScamBusterDialog {
    try {
        Add-Type -AssemblyName System.Windows.Forms, System.Drawing -ErrorAction SilentlyContinue
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "[DEMO] 🚨 WINBARS ScamBuster - Fake Virus Lockup Detected"
        $form.Size = New-Object System.Drawing.Size(720, 340)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.TopMost = $true
        $form.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 27)

        $lblH = New-Object System.Windows.Forms.Label
        $lblH.Text = "THE SCREEN SHOWING BEHIND THIS PROMPT IS A SCAM [DEMO MODE]"
        $lblH.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $lblH.ForeColor = [System.Drawing.Color]::FromArgb(239, 68, 68)
        $lblH.Location = New-Object System.Drawing.Point(20, 20)
        $lblH.Size = New-Object System.Drawing.Size(670, 26)
        $form.Controls.Add($lblH)

        $lblSub = New-Object System.Windows.Forms.Label
        $lblSub.Text = "Browser audio muted. Never call anyone you do not know or trust."
        $lblSub.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $lblSub.ForeColor = [System.Drawing.Color]::FromArgb(254, 240, 138)
        $lblSub.Location = New-Object System.Drawing.Point(20, 52)
        $lblSub.Size = New-Object System.Drawing.Size(670, 24)
        $form.Controls.Add($lblSub)

        $lblB = New-Object System.Windows.Forms.Label
        $lblB.Text = "A browser tab has seized your screen to frighten you into calling an unauthorized call center. Fake virus warnings, screaming audio sirens, and full-screen browser traps are used by scammers to trick you into purchasing unnecessary remote fixes or gift cards.`n`nNever call phone numbers displayed on your computer screen. Contact your trusted local computer support provider directly."
        $lblB.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $lblB.ForeColor = [System.Drawing.Color]::FromArgb(228, 228, 231)
        $lblB.Location = New-Object System.Drawing.Point(20, 90)
        $lblB.Size = New-Object System.Drawing.Size(670, 95)
        $form.Controls.Add($lblB)

        $btnReclaim = New-Object System.Windows.Forms.Button
        $btnReclaim.Text = "RECLAIM MY COMPUTER (Close Browser Simulation)"
        $btnReclaim.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $btnReclaim.BackColor = [System.Drawing.Color]::FromArgb(220, 38, 38)
        $btnReclaim.ForeColor = [System.Drawing.Color]::White
        $btnReclaim.FlatStyle = "Flat"
        $btnReclaim.Size = New-Object System.Drawing.Size(370, 42)
        $btnReclaim.Location = New-Object System.Drawing.Point(20, 215)
        $btnReclaim.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Controls.Add($btnReclaim)

        $btnCancel = New-Object System.Windows.Forms.Button
        $btnCancel.Text = "Cancel / Keep Open"
        $btnCancel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(39, 39, 42)
        $btnCancel.ForeColor = [System.Drawing.Color]::FromArgb(212, 212, 216)
        $btnCancel.FlatStyle = "Flat"
        $btnCancel.Size = New-Object System.Drawing.Size(180, 42)
        $btnCancel.Location = New-Object System.Drawing.Point(410, 215)
        $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.Controls.Add($btnCancel)

        $res = $form.ShowDialog()
        return ($res -eq [System.Windows.Forms.DialogResult]::OK)
    } catch {
        return $false
    }
}

# ==============================================================================
# Demo Invocation Runners
# ==============================================================================

function Invoke-ScamBusterDemo {
    $page = Join-Path $PSScriptRoot 'scambuster-lockup.html'
    if (-not (Test-Path -LiteralPath $page)) { throw "Missing $page" }
    Write-Step 'Opening the lockup simulator in your default browser...'
    Start-Process -FilePath $page
    Start-Sleep -Milliseconds 800

    Write-Step 'Displaying authentic WINBARS ScamBuster rescue dialog (Demo Mode)...'
    $reclaimed = Show-DemoScamBusterDialog
    if ($reclaimed) {
        Write-Good 'Reclaim computer selected: ScamBuster successfully neutralized the simulated browser lockup!'
    } else {
        Write-Warn 'Simulation dialog closed. You can close the browser tab at any time.'
    }
}

function Invoke-RatDemo {
    if (Test-ToolAllowed $Tool) {
        Write-Warn ("'{0}' is on this PC's AllowedRemoteTools list, so the interceptor will (correctly) ignore it." -f $Tool)
        Write-Warn "Run .\Run-Demo.ps1 -Demo Cleanup or remove it from AllowedRemoteTools."
        return
    }
    Write-Step ("Starting harmless placeholder named {0}.exe (renamed cmd.exe)..." -f $Tool)
    $exe = New-Placeholder $Tool
    $proc = Start-Placeholder $exe

    Write-Step 'Triggering authentic WINBARS Remote Access Warning dialog (Demo Mode)...'
    $actionResult = Show-DemoRatDialog -TargetProcess $proc -ToolName $Tool

    if ($actionResult -eq "TERMINATED") {
        Write-Good 'The placeholder was stopped - the RAT Interceptor successfully blocked the unauthorized remote session!'
    } elseif ($actionResult -eq "WHITELISTED") {
        Write-Good ("Tool '{0}' added to trusted whitelist." -f $Tool)
    } else {
        Write-Warn 'Tool allowed once for this session.'
    }

    $n = Stop-DemoProcesses
    Write-Step ("Cleaned up {0} placeholder process(es)." -f $n)
}

function Invoke-PupDemo {
    Write-Step ("Starting harmless placeholder named {0}.exe (renamed cmd.exe)..." -f $PupDemoName)
    $exe = New-Placeholder $PupDemoName
    $proc = Start-Placeholder $exe

    Write-Step 'Triggering authentic WINBARS PUP Shield Warning dialog (Demo Mode)...'
    $actionResult = Show-DemoPupDialog -TargetProcess $proc

    if ($actionResult -eq "TERMINATED") {
        Write-Good 'The placeholder was stopped - the PUP Shield successfully flagged and quarantined it!'
    } elseif ($actionResult -eq "WHITELISTED") {
        Write-Good ("Program '{0}' added to trusted whitelist." -f $PupDemoName)
    } else {
        Write-Warn 'PUP allowed once for this session.'
    }

    $n = Stop-DemoProcesses
    Write-Step ("Cleaned up {0} placeholder process(es)." -f $n)
}

function Invoke-Cleanup {
    $n = Stop-DemoProcesses
    Write-Step ("Stopped {0} demo process(es)." -f $n)
    if (Test-Path -LiteralPath $DemoDir) {
        try { Remove-Item -LiteralPath $DemoDir -Recurse -Force -ErrorAction Stop; Write-Good "Removed $DemoDir" } catch { Write-Warn ("Could not remove {0}: {1}" -f $DemoDir, $_.Exception.Message) }
    } else {
        Write-Step 'Demo folder already clean.'
    }
    foreach ($name in @($Tool, 'ratdemo', $PupDemoName) | Select-Object -Unique) {
        if (Test-ToolAllowed $name) { Write-Warn ("'{0}' is allow-listed in {1}. If that was caused by a demo, remove it from AllowedRemoteTools." -f $name, $ConfigPath) }
    }
}

function Show-Menu {
    while ($true) {
        Write-Host ''
        Write-Host '  WINBARS DEMO LAUNCHER (all demos are safe & interactive)' -ForegroundColor White
        Write-Host '   [1] ScamBuster  - fake full-screen virus lockup + Rescue Dialog'
        Write-Host ('   [2] RAT         - remote-access lookalike ({0}.exe) + Warning Dialog' -f $Tool)
        Write-Host ('   [3] PUP Shield  - junkware lookalike ({0}.exe) + Quarantine Dialog' -f $PupDemoName)
        Write-Host '   [S] Status      [C] Cleanup      [Q] Quit'
        $c = (Read-Host '  Choose').Trim().ToUpperInvariant()
        switch ($c) {
            '1' { Invoke-ScamBusterDemo }
            '2' { Invoke-RatDemo }
            '3' { Invoke-PupDemo }
            'S' { Show-Status }
            'C' { Invoke-Cleanup }
            'Q' { return }
            default { Write-Warn 'Unknown choice.' }
        }
    }
}

switch ($Demo) {
    'ScamBuster' { Invoke-ScamBusterDemo }
    'RAT'        { Invoke-RatDemo }
    'PUP'        { Invoke-PupDemo }
    'Status'     { Show-Status }
    'Cleanup'    { Invoke-Cleanup }
    default      { Show-Menu }
}
