# WINBARS System Footprint & Security Audit Blueprint

This document provides a factual, line-item specification of every system change, process, scheduled task, registry key, and file location touched by **WINBARS**. It is designed for system administrators, security engineers, and IT auditors who require verifiable technical specifications rather than marketing claims.

---

## 1. Network & Telemetry Footprint: Absolute Zero

WINBARS operates under a strict **Zero-Egress / Air-Gapped** architecture:

| Attribute | Specification | Verification Command / Tool |
| :--- | :--- | :--- |
| **Outbound Telemetry** | **None (0 calls)** | Wireshark, Sysinternals TCPView, or `Get-NetTCPConnection` |
| **Inbound / Listening Ports** | **None (0 open ports)** | `netstat -ano \| findstr LISTENING` |
| **Cloud Accounts / Logins** | **None** | Completely offline operational design |
| **Auto-Update Pings** | **None** | No background network polling |
| **DNS Lookups** | **None** | No external domains resolved |

> [!NOTE]
> WINBARS contains zero telemetry beacons, analytics tracking pings, or mandatory cloud accounts. Brand verification is computed locally using asymmetric ECDSA-SHA256 signatures via native Windows CNG APIs without contacting any license server. Outbound network communication occurs strictly if the administrator configures optional Webhook alert endpoints (Discord, Slack, Teams, or REST in Mode 4) or triggers Microsoft Quick Assist (`Ctrl+Win+Q`).

---

## 2. Kernel & OS Integrity: Zero Drivers, Zero NT Services

Many commercial backup agents install low-level filter drivers to track disk writes, which can introduce kernel panics (BSODs) during major Windows feature updates.

* **Kernel-Mode Drivers**: **0** (No `.sys` drivers, no filesystem mini-filters, no virtual disk drivers across all Modes 0–4).
* **Resident Windows NT Services**: **0** (No background Windows Services installed in `services.msc`). Modes 0–1 maintain 0 resident background processes. Modes 2–4 run a lightweight user-mode desktop sentry (~12–16 MB RAM) launched via standard user Startup without system-level service overhead.
* **Kernel Integrity**: The Windows kernel, HAL, and storage stack remain completely untouched and 100% stock.

---

## 3. Scheduled Tasks Blueprint (`taskschd.msc`)

All recurring automation is registered directly into native Windows Task Scheduler under the standard folder `\WindowsBackup\`. Each task can be inspected, modified, or deleted at any time using standard Windows management tools:

| Task Name | Principal / Privilege | Command Executed | Purpose |
| :--- | :--- | :--- | :--- |
| `\WindowsBackup\SystemRestorePoint` | `NT AUTHORITY\SYSTEM` (Highest) | `powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Checkpoint-Computer ..."` | Creates daily unthrottled System Restore checkpoint; ensures 10% VSS headroom |
| `\WindowsBackup\UserProfileSync` | User or `SYSTEM` | `powershell.exe` / `robocopy.exe /ZB /MT:8` | Differential 1:1 mirror of `C:\Users` with 30-day deletion archiving |
| `\WindowsBackup\SystemImageBackup` | `NT AUTHORITY\SYSTEM` | `wbadmin.exe start backup -backupTarget:...` or `dism.exe /Capture-Image` | Periodic bare-metal disaster image capture |

To inspect these tasks in PowerShell:
```powershell
Get-ScheduledTask -TaskPath "\WindowsBackup\*" | Select-Object TaskName, State, @{N='Command';E={$_.Actions.Execute + " " + $_.Actions.Arguments}} | Format-List
```

---

## 4. Filesystem Footprint by Deployment Mode

WINBARS is designed with flexible operational boundaries. If strict security policy mandates zero third-party software on internal disks, Mode 0 leaves zero files on `C:\`.

| Deployment Mode | Files on `C:\` | Resident Processes | Location of Tools & Logs |
| :--- | :--- | :--- | :--- |
| **Mode 0 (`ZeroFootprint`)** | **0 bytes** (Zero files) | **0 resident processes** | Everything resides on external backup drive (`D:\Backup_Logs\`) |
| **Mode N (`NearZeroFootprint`)** | Desktop shortcuts only | **0 resident processes** | External backup drive + native `rstrui.exe` / Explorer shortcuts |
| **Mode 1 (`SystemUndo`)** | Emergency scripts (+ optional baseline `.wim`) | **0 resident processes** | `C:\SystemRecovery\` (Generic unbranded .bat scripts); 0 EXEs |
| **Mode 2 (`LocalDisasterGuard`)** | Local Suite (~2 MB) | Silent Hotkey Sentry (`-Tray -Silent`, ~12 MB RAM; registers `Ctrl+Win+B` / `Ctrl+Win+W`) | `C:\Tools\WINBARS\WINBARS.exe` |
| **Mode 3 (`HeadlessFull`)** | Local Suite (~2 MB) | Silent Hotkey Sentry (`-Tray -Silent`, ~12 MB RAM; registers `Ctrl+Win+B` / `Ctrl+Win+W` & drive alerts) | `C:\Tools\WINBARS\WINBARS.exe` |
| **Mode 4 (`TotalProtection`)** | Local Suite (~2 MB) | Interactive Floppy Tray Sentry (`-Tray`, ~16 MB RAM; visible notification icon + GUI + ScamBuster) | `C:\Tools\WINBARS\WINBARS.exe` + Startup link |

### Filesystem Paths (When Modes 2–4 Installed):
* **Executable & Config**: `C:\Tools\WINBARS\` (`WINBARS.exe`, `config.json`, `branding.json`, `deployment.log`)
* **Local Recovery Vault**: `C:\SystemRecovery\` (Contains local `.wim` image captures and emergency .bat tools, protected by Windows ACLs)
* **VSS Snapshot Junctions**: `C:\ProgramData\WINBARS\VssMount_*` (Temporary directory junctions created *only* during active Robocopy passes, deleted immediately upon completion)

---

## 5. Registry Modifications

WINBARS modifies only standard, documented Windows operational flags:

1. **System Restore Frequency Throttling**:
   * Path: `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore`
   * Value: `SystemRestorePointCreationFrequency = 0` (DWORD)
   * *Rationale*: By default, Windows 10/11 blocks creating restore points more than once every 24 hours. Setting this to `0` restores unthrottled checkpoint creation on demand.
2. **Automated Registry Backups (RegBack)**:
   * Path: `HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager`
   * Value: `EnableRegistryBackup = 1` (DWORD)
   * *Rationale*: Re-enables native Windows automatic offline registry hive archiving deprecated in Windows 10 1803+.
3. **Tray / Hotkey Sentry Startup (Modes 2, 3, and 4)**:
   * Path: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`
   * Value: `WINBARSTray = "C:\Tools\WINBARS\WINBARS.exe -Tray"` (Mode 4) or `WINBARSTray = "C:\Tools\WINBARS\WINBARS.exe -Tray -Silent"` (Modes 2 & 3)
   * *Rationale*: In Mode 4, provides the visible floppy notification area icon and real-time dashboard. In Modes 2 and 3, runs as a silent background sentry to register global panic/recovery hotkeys (`Ctrl+Win+B`, `Ctrl+Win+W`) and missing drive connection alerts without showing a tray icon.
4. **Explorer Drive Cloaking (Optional / Technician-Toggled)**:
   * Path: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer`
   * Value: `NoDrives` (DWORD bitmask)
   * *Rationale*: Visually conceals the backup drive letter in Windows Explorer ("This PC") to prevent accidental user deletion or confusion. Tasks and Robocopy continue accessing the volume normally.
5. **Silence OneDrive Cloud Nags (Modes 2, 3, and 4)**:
   * Path: `HKLM:\SOFTWARE\Policies\Microsoft\OneDrive`, `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`
   * Values: `KFMBlockOptIn = 1`, `ShowSyncProviderNotifications = 0`
   * *Rationale*: Suppresses deceptive "Your PC is not backed up" notification nags and prevents automatic hijacking of standard user folders into OneDrive cloud sync. Purely optional and reversible anytime via `WINBARS.exe -RestoreOneDrivePrompts`.

---

## 6. The Sysadmin Verification Guide

You do not need to trust the binary—you can verify its operational integrity directly using standard Microsoft and Sysinternals tools:

### Step 1: Verify Zero Network Egress
Open an elevated PowerShell prompt while `WINBARS.exe` is running:
```powershell
Get-NetTCPConnection | Where-Object { $_.OwningProcess -in (Get-Process WINBARS -ErrorAction SilentlyContinue).Id }
```
*Expected Result*: Returns nothing (`$null`). Zero active, listening, or outbound TCP/UDP endpoints.

### Step 2: Verify Zero Kernel Drivers
Check active filesystem filter drivers:
```cmd
fltmc filters
```
*Expected Result*: Only native Microsoft drivers (`WdFilter`, `FileInfo`, `Volume`, etc.) appear. Zero third-party filter drivers registered by WINBARS.

### Step 3: Inspect Scheduled Task Integrity
Open Windows Task Scheduler GUI:
```cmd
taskschd.msc
```
Navigate to **Task Scheduler Library $\rightarrow$ WindowsBackup**. Select any task and view the **Actions** tab. You will see plain calls to `powershell.exe Checkpoint-Computer`, `robocopy.exe`, or `wbadmin.exe`.

---

## 7. Zero Vendor Lock-In: The "Life After WINBARS" Test

The ultimate verification of any backup utility is whether you can recover your data if the software disappears completely:

* **File Recovery**: Plug your backup drive into any computer (Windows, macOS, or Linux). Your files are stored in 100% standard, uncompressed NTFS directories under `D:\Users\<Username>\`. Drag-and-drop your files directly in standard File Explorer.
* **System Image Recovery**: Images in `D:\SystemRecovery\` (or `C:\SystemRecovery\`) are standard Microsoft DISM `.wim` files. Boot any standard Windows 10/11 Installation USB to WinRE and restore via:
  ```cmd
  dism.exe /Apply-Image /ImageFile:D:\SystemRecovery\_baseline.wim /Index:1 /ApplyDir:C:\
  ```
* **System Restore Points**: Points are native Windows Volume Shadow Copies. Revert directly via `rstrui.exe` or WinRE System Restore wizard.
* **BitLocker Recovery**: Keys are archived as plaintext `.txt` files and offline `.html` documents readable on any smartphone, tablet, or web browser.

**WINBARS is never required to restore your data.**

---

## 8. Complete Native Windows Engine & Command Execution Reference

To guarantee 100% transparency and provide a verifiable audit trail for security compliance and sysadmin inspection, the following table documents every native Windows system utility and kernel engine WINBARS invokes, the exact argument syntax, and the operational/security rationale:

| Native Windows Binary | Exact Command Syntax / Pattern | Operational & Defensive Rationale |
| :--- | :--- | :--- |
| **`robocopy.exe`** | `"$src" "$dest" /E /ZB /COPY:DAT /DCOPY:DAT /R:1 /W:2 /XJ /XA:O /MT:8` | Unbuffered 1:1 mirror using backup intent (`/ZB`), symlink loop protection (`/XJ`), multi-threading (`/MT:8`), and offline cloud stub exclusion (`/XA:O`) to prevent runaway OneDrive/Dropbox placeholder downloads. |
| **`vssadmin.exe`** | `resize shadowstorage /for=C: /on=C: /maxsize=15%` | Dynamically allocates Volume Shadow Copy headroom to prevent Windows from silently dropping restore points or failing VSS writer snapshots under low disk headroom. |
| **`vssadmin.exe`** | `list shadows /for=C:` / `delete shadows /for=C: /oldest` | Audits existing shadow storage and prunes expired or orphaned non-WINBARS shadow copies during automated maintenance. |
| **`dism.exe`** | `/Capture-Image /ImageFile:"$wim" /CaptureDir:C:\ /Name:"$tag" /Compress:fast /CheckIntegrity /Verify` | Captures crash-consistent, non-proprietary Microsoft `.wim` bare-metal images with multi-pass SHA-256 integrity hashing and block-level verification. |
| **`dism.exe`** | `/Apply-Image /ImageFile:"$wim" /Index:1 /ApplyDir:C:\ /CheckIntegrity /Verify` | Restores standard `.wim` images to internal target partitions during bare-metal disaster recovery or Safe Overlay OS Refreshes. |
| **`reagentc.exe`** | `/enable`<br>`/info` | Audits and automatically re-enables the Windows Recovery Environment (WinRE) if Windows Update or a third-party tool disabled it. |
| **`WinreConfig.xml`** | `C:\Recovery\OEM\WinreConfig.xml` | Stages the WinRE GUI boot hook configuration, adding a native "Emergency Resurrection Tool" button inside the Troubleshoot menu for Modes 2, 3, and 4. |
| **`reagentc.exe`** | `/boottore` | Configures Windows Boot Manager to restart directly into the Windows Recovery Environment on the very next boot without requiring BIOS navigation. |
| **`bcdedit.exe`** | `/set {bootmgr} displaybootmenu yes /timeout 2` | *[Tech Only]* Configures an optional 2-second boot manager countdown window to allow entering recovery mode during startup hangs. |
| **`bcdedit.exe`** | `/set {default} bootmenupolicy Legacy` | *[Tech Only]* Restores the classic Windows 7-style `F8` Safe Mode boot prompt policy on Windows 10 and 11. |
| **`bcdedit.exe`** | `/export "$dest\BCD_backup"` / `/import "$dest\BCD_backup"` | Exports and restores atomic binary BCD bootloader hives to prevent unbootable startup configuration corruption. |
| **`bcdboot.exe`** | `"$targetWin" /l en-us` | Rebuilds corrupt EFI and BCD system partitions from the target Windows directory (`\Windows\System32\ntoskrnl.exe`) in offline WinPE environments. |
| **`wbadmin.exe`** | `start backup -backupTarget:"$target" -include:C: -allCritical -quiet` | Native Windows Server & Client image engine utilized for scheduled bare-metal system backups in Mode 0 and 3. |
| **`wbadmin.exe`** | `start systemstaterecovery -version:$version -quiet` | Restores system state and Active Directory / SAM database consistency in enterprise workstations. |
| **`schtasks.exe`** | `/create /tn "\WindowsBackup\$taskName" /ru "NT AUTHORITY\SYSTEM" /sc daily ...` | Registers native Windows scheduled jobs directly into the `\WindowsBackup\` Task Scheduler container with highest administrative integrity. |
| **`rstrui.exe`** | `/offline:$winDrive\Windows` | Launches the native Windows System Restore GUI targeted against an offline OS drive from within the WinPE/WinRE shell. |
| **`chkdsk.exe`** | `"$drive" /f /r` | Scans and repairs dirty NTFS volumes and bad disk sectors prior to bare-metal image deployment. |
| **`wmic.exe` / CIM** | `diskdrive get status` / `Get-PhysicalDisk` | Queries hardware S.M.A.R.T. predictive failure counters to warn technicians if the physical drive is dying before attempting software repairs. |
| **`powershell.exe`** | `Checkpoint-Computer -Description "$desc" -RestorePointType "MODIFY_SETTINGS"` | Creates native Windows System Restore checkpoints via native WMI provider with unthrottled frequency. |
| **`regsvr32.exe`** | `/s ole32.dll`, `/s vss_ps.dll`, `/s swprv.dll` | Re-registers native Windows VSS COM providers in memory during VSS auto-healing without requiring an OS restart. |

> 🛡️ **Verifiable Compliance Guarantee**: Every command above is standard Microsoft Windows tooling. You can audit every execution in real-time via Sysinternals Process Monitor (`procmon.exe`) filtered by `Process Name is WINBARS.exe`.
