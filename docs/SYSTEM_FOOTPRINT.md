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
> WINBARS contains zero web-phone hooks or remote API dependencies. Even cryptographic brand verification (`branding.json`) is computed locally using asymmetric ECDSA-SHA256 signatures via native Windows CNG APIs without contacting any license server.

---

## 2. Kernel & OS Integrity: Zero Drivers, Zero Services

Many commercial backup agents install low-level filter drivers to track disk writes, which can introduce kernel panics (BSODs) during major Windows feature updates.

* **Kernel-Mode Drivers**: **0** (No `.sys` drivers, no filesystem mini-filters, no virtual disk drivers).
* **Resident Windows Services**: **0** (No background Windows Services installed in `services.msc`).
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
| **Mode 1 (`SystemUndo`)** | Optional baseline `.wim` | **0 resident processes** | `C:\SystemImages\_baseline.wim` (native DISM image); 0 EXEs |
| **Mode 2 (`LocalDisasterGuard`)** | Local Suite (~2 MB) | On-demand only | `C:\Tools\WINBARS\WINBARS.exe` |
| **Mode 3 (`HeadlessFull`)** | Local Suite (~2 MB) | Background tasks only | `C:\Tools\WINBARS\WINBARS.exe` |
| **Mode 4 (`TotalProtection`)** | Local Suite (~2 MB) | `WINBARS.exe` Tray Sentry (~18 MB RAM) | `C:\Tools\WINBARS\WINBARS.exe` + Startup link |

### Filesystem Paths (When Modes 2–4 Installed):
* **Executable & Config**: `C:\Tools\WINBARS\` (`WINBARS.exe`, `config.json`, `branding.json`, `deployment.log`)
* **Local Recovery Vault**: `C:\SystemImages\` (Contains local `.wim` image captures, protected by Windows ACLs)
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
3. **Tray Startup (Mode 4 Only)**:
   * Path: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`
   * Value: `WINBARSTray = "C:\Tools\WINBARS\WINBARS.exe -Tray"`
   * *Rationale*: Starts the Floppy Tray Sentry and ScamBuster watchdog upon user login.
4. **Explorer Drive Cloaking (Optional / Technician-Toggled)**:
   * Path: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer`
   * Value: `NoDrives` (DWORD bitmask)
   * *Rationale*: Visually conceals the backup drive letter in Windows Explorer ("This PC") to prevent accidental user deletion or confusion. Tasks and Robocopy continue accessing the volume normally.

---

## 6. The 60-Second Sysadmin Verification Guide

You do not need to trust the binary—you can verify its operational integrity in under a minute using standard Microsoft and Sysinternals tools:

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
* **System Image Recovery**: Images in `D:\SystemImages\` or `C:\SystemImages\` are standard Microsoft DISM `.wim` files. Boot any standard Windows 10/11 Installation USB to WinRE and restore via:
  ```cmd
  dism.exe /Apply-Image /ImageFile:D:\SystemImages\_baseline.wim /Index:1 /ApplyDir:C:\
  ```
* **System Restore Points**: Points are native Windows Volume Shadow Copies. Revert directly via `rstrui.exe` or WinRE System Restore wizard.
* **BitLocker Recovery**: Keys are archived as plaintext `.txt` files and offline `.html` documents readable on any smartphone, tablet, or web browser.

**WINBARS is never required to restore your data.**
