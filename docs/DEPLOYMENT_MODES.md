# WINBARS Deployment Profiles & Mode Capability Guide

WINBARS is architecturally divided into two distinct tiers: **Tier 1: Native Windows Modes (0, N, 1)** that leave **zero installed software and zero resident third-party EXEs** on the host PC, and **Tier 2: Managed Suite Modes (2, 3, 4)** that provision the local utility (`C:\Tools\WINBARS`) with desktop shortcuts, universal hotkeys, and sentry integration.

---

## 📊 Deployment Mode vs. Feature Capability Matrix

The matrix below outlines exactly what capabilities each deployment profile activates:

| Capability / Feature | Mode 0<br>ZeroFootprint | Mode N<br>NearZero | Mode 1<br>SystemUndo | Mode 2<br>LocalDisasterGuard | Mode 3<br>HeadlessFull | Mode 4<br>TotalProtection |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Reason for Being** | **Forensic Sterility**<br>(Nothing on `C:\`) | **Native Automation**<br>(0 background EXEs) | **Bench Warranty Baseline**<br>(Zero third-party binaries) | **Single-Drive Disaster Recovery**<br>(Local image; no external drive) | **Silent Multi-Drive Automation**<br>(Full backup; zero UI clutter) | **Visual Observability & Control**<br>(Floppy Tray, live GUI & alerts) |
| **What Sits on C:\** | **0 Files** | **Shortcuts Only** | `C:\SystemRecovery\`<br>*(3 text scripts + key; 0 EXEs)* | `C:\Tools\WINBARS\`<br>`C:\SystemRecovery\` | `C:\Tools\WINBARS\`<br>`C:\SystemRecovery\` | `C:\Tools\WINBARS\`<br>`C:\SystemRecovery\` |
| **Where Rescue Scripts Live** | **Backup Drive Only** | **Backup Drive Only** | `C:\SystemRecovery\` *(Local)* | `C:\SystemRecovery\` *(Local)* | **Both** Local & Backup Drive | **Both** Local & Backup Drive |
| **Background RAM** | **0 MB** | **0 MB** | **0 MB** | ~12 MB | ~12 MB | ~16 MB |
| **Resident Processes** | None | None | None | Silent Sentry (Hotkey + Watchdog) | Silent Sentry (Hotkey + Watchdog) | Tray Sentry + Hotkey + Watchdog |
| **WINBARS Branding** | ❌ None | ❌ None | ❌ None | ✅ Yes | ✅ Yes | ✅ Yes |
| **Desktop Shortcuts** | ❌ None | ✅ Native (Unbranded) | ❌ None | ✅ Mode-Aware (No Ext Backup) | ✅ Yes | ✅ Yes |
| **Automated Daily Sync** | ✅ Daily | ✅ Daily | ❌ None | ❌ None | ✅ Daily | ✅ Daily |
| **System Restore (Unthrottled)** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Block Silent Auto-BitLocker** | ❌ None *(0 Host Reg)* | ❌ None *(0 Host Reg)* | ✅ Native Policy | ✅ Native Policy | ✅ Native Policy | ✅ Native Policy |
| **Robocopy 1:1 File Mirror** | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ |
| **30-Day Safety Recycle Bin** | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ |
| **BitLocker Card & Vault** | ✅ Backup Drive | ✅ Backup Drive | Local (C:\SystemRecovery) | ✅ Local (C:\SystemRecovery) | ✅ Both | ✅ Both |
| **Emergency Recovery Launcher** | ✅ Backup Drive | ✅ Backup Drive | ✅ Local (C:\SystemRecovery) | ✅ Local (C:\SystemRecovery) | ✅ Both | ✅ Both |
| **Native WinRE Boot Hook** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **VSS Subsystem Auto-Heal** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Bare-Metal DISM Image** | ✅ Backup Drive | ✅ Backup Drive | Local* | ✅ Local (C:\SystemRecovery) | ✅ Both | ✅ Both |
| **Safe Overlay OS Refresh** | ✅ Backup Drive | ✅ Backup Drive | Local* | ✅ Local (C:\SystemRecovery) | ✅ Both | ✅ Both |
| **Silence OneDrive Cloud Nags** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Ransomware Canary** | ✅ Backup Drive | ✅ Backup Drive | ❌ None | ✅ Local (C:\SystemRecovery) | ✅ Both | ✅ Both |
| **Protection Hotkey (`Ctrl+Win+W`)** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Panic Hotkey (`Ctrl+Win+B`)** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Remote RAT & Scam Watchdog** | ❌ Locked OFF | ❌ Locked OFF | ❌ Locked OFF | ✅ Silent Shield (Default ON) | ✅ Silent Shield (Default ON) | ✅ Visual Sentry (Default ON) |
| **Floppy Tray Sentry** | ❌ Locked OFF | ❌ Locked OFF | ❌ Locked OFF | ⚪ Default OFF (Toggable) | ⚪ Default OFF (Toggable) | 🟢 Default ON (Toggable) |

> **Notes & Operational Explanations**:
> - **Zero Windows Services Architectural Guarantee**: Across **ALL** modes (0 through 4), WINBARS installs **zero Windows Services (`services.msc`)**, zero kernel drivers, and zero system daemons. Modes 0, N, and 1 run with **0 resident background processes / 0 MB RAM** via native Windows Task Scheduler. Modes 2, 3, and 4 run solely as a lightweight user-session background process (`WINBARS.exe`, ~12–16 MB RAM) via `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`, which exits cleanly when the user logs off.
> - `✅` **Active & Scheduled**: Fully configured, scheduled, or monitored under this profile.
> - `❌` **Not Provisioned**: Omitted by design to maintain a strict zero-resident or near-zero footprint policy.
> - `*` **Optional / On-Demand**: Feature is optional during setup (e.g. Mode 1 offers an optional one-time baseline image `_baseline.wim` if host disk space $\ge 25\text{ GB}$).
> - **Terminology Clarification**:
>   - **Backup Drive (Storage Target)**: The dedicated drive/partition where user file mirrors, baseline `.wim` images, and recovery scripts live. Even in Mode 0, this can be an internal secondary drive/partition (e.g. `D:\`, `E:\`) or an external drive. 0 files touch `C:\`.
>   - **WINBARS Util USB (Technician Flash Drive)**: The portable, bootable flash drive holding `WINBARS.exe`, batch installers, and offline WinPE recovery tools.
> - **Rescue .BAT Scripts Placement**: In **Modes 0 and N**, exactly 0 batch scripts or binaries are placed on `C:\`, and **0 files are placed in `C:\SystemRecovery`**. All rescue scripts (`EMERGENCY_RECOVERY.bat`, `Apply-SystemImage_WinPE.bat`) and system images live exclusively on the **Backup Drive**. In **Mode 1**, exactly 3 unbranded emergency files (`EMERGENCY_RECOVERY.bat`, `Restore_Registry_WinPE.bat`, `BitLocker_Recovery_Key.txt`) and any optional baseline image sit in `C:\SystemRecovery\` (keeping `C:\` root completely clean).
> - **Running Safe Overlay from `C:\` in Mode 1**: If Windows fails to boot in Mode 1, you can boot into WinRE Command Prompt (`Shift + F10`) and run `C:\SystemRecovery\Apply-SystemImage_WinPE.bat` directly from `C:\`. The script detects that the image is stored on the target volume (`SAME_DRV = 1`), automatically locks out the destructive reformat option, and safely applies **Option [1] Safe Overlay**—refreshing Windows OS and Program Files while leaving `C:\Users\` 100% intact!
> - **Unthrottled System Restore**: Standard Windows limits restore point creation to once every 24 hours (`SystemRestorePointCreationFrequency = 1440`). WINBARS unthrottles this limit (`Frequency = 0`) so checkpoints are captured whenever requested, while guaranteeing 10%–15% shadow storage headroom so restore points are never purged prematurely.
> - **Safe Overlay OS Refresh**: Allows non-destructive restoration of the Windows OS and Program Files from a `.wim` image directly over `C:\` while leaving `C:\Users\` 100% untouched on disk (Option [1] in `Apply-SystemImage_WinPE.bat`). Available whenever a DISM image is present.
> - **Silence OneDrive Cloud Nags**: Configures group policies and registry flags to silence Windows/OneDrive "Not Backed Up" nagging alerts and prevents OneDrive from hijacking known user folders without user consent. (Active in Managed Modes 2–4).

---

## 🔍 Detailed Profile Breakdown

### Mode 0: `ZeroFootprint` (Strict Corporate Compliance & Audits)
* **What It DOES**:
  * Configures native Windows Task Scheduler to run unthrottled daily System Restore points directly under `NT AUTHORITY\SYSTEM`.
  * Runs daily 1:1 Robocopy mirroring of user profiles to the external backup drive with a 30-day safety isolation bin (`_DeletedArchive`).
  * Runs monthly bare-metal system imaging via native `wbadmin.exe` / DISM to external backup drive.
  * Archives BitLocker 48-digit recovery keys directly to the external USB drive.
  * Dynamically auto-discovers external drive letter drift across reconnects.
* **What It DOES NOT Do**:
  * Places **0 files, 0 scripts, and 0 binaries on `C:\` (and 0 files in `C:\SystemRecovery`)**.
  * Does not install any system tray icon or background sentry.
  * Does not install desktop shortcuts.
* **Best Suited For**: Highly audited enterprise workstations, compliance-sensitive environments, or technicians working on client machines where third-party software installation is strictly prohibited.

---

### Mode N: `NearZeroFootprint` (Stealth Native Automation)
* **What It DOES**:
  * Inherits all automated capabilities of Mode 0.
  * Places three unbranded, native Windows desktop shortcuts for client convenience:
    1. `Backup Personal Files` (Triggers immediate Robocopy mirror).
    2. `Windows System Restore` (Launches native `rstrui.exe`).
    3. `Browse Backup Files` (Resolves the backup drive and opens Windows File Explorer directly into the backed-up user folders).
  * Creates an unbranded Start Menu group: `System Backup & Recovery`.
* **What It DOES NOT Do**:
  * Places **0 files in `C:\SystemRecovery`** (all backup assets live on the external Backup Drive).
  * Leaves **0 background EXEs or running services** on the host.
  * Leaves no WINBARS vendor branding.
* **Best Suited For**: Small business workstations, family computers, and corporate clients where users need 1-click access to backup and restore without third-party vendor branding.

---

### Mode 1: `SystemUndo` (Universal Service Warranty Baseline)
* **What It DOES**:
  * Provides the foundational rapid OS rollback safety net for bench tune-ups.
  * Configures daily unthrottled System Restore checkpoints and expands VSS shadow headroom to 10%.
  * Re-enables automatic registry backups (`EnableRegistryBackup = 1`).
  * Stages exactly 3 generic, unbranded recovery files in `C:\SystemRecovery\`:
    1. `EMERGENCY_RECOVERY.bat` (Interactive triage console: Safe Mode, WinRE, BCD repair, chkdsk).
    2. `Restore_Registry_WinPE.bat` (Offline registry hive rollback from RegBack).
    3. `BitLocker_Recovery_Key.txt` (48-digit plaintext recovery key).
  * Optionally captures an initial offline baseline system image (`_baseline.wim` + `Apply-SystemImage_WinPE.bat`) if free disk space permits ($\ge 25\text{ GB}$).
* **What It DOES NOT Do**:
  * Installs **0 software / 0 resident EXEs / 0 background daemons** (only recovery scripts and an optional baseline image reside in `C:\SystemRecovery\`).
  * **Does not install ScamBuster, hotkeys, or tray monitors**—omitted to maintain total transparency, uphold clean bench standards, and ensure the client's PC remains completely free of third-party software.
  * Does not perform automated external file mirroring (designed for machines serviced without an external drive attached).
* **Best Suited For**: Computer repair shops performing routine cleanups, virus removals, or tune-ups, guaranteeing a 30-day warranty rollback target without needing an external drive left with the client.

---

### Mode 2: `LocalDisasterGuard` (Single-Drive PCs & Laptops)
* **What It DOES**:
  * Provisions `WINBARS.exe` locally to `C:\Tools\WINBARS`.
  * Establishes monthly bare-metal DISM system images stored safely on a dedicated local partition (`C:\SystemRecovery`).
  * Pre-stages `Apply-SystemImage_WinPE.bat` for 1-click offline recovery directly from the WinRE command prompt (`Shift + F10`).
  * Enables universal emergency hotkeys (`Ctrl+Win+B` for ScamBuster and `Ctrl+Win+W` for Protection Center).
  * Silences misleading OneDrive "Not Backed Up" scare banners.
* **What It DOES NOT Do**:
  * Does not run scheduled file mirroring to external storage (optimized for mobile laptops without permanent external drives).
  * Does not load the persistent system tray icon by default (runs hotkey listener only).
* **Best Suited For**: Mobile laptops, students, remote workers, and single-drive systems where external hard drives are rarely or never attached.

---

### Mode 3: `HeadlessFull` (Silent Office Workstations & Clinics)
* **What It DOES**:
  * Full automated backup suite: daily unthrottled restore points, daily Robocopy file mirroring with 30-day retention, and scheduled bare-metal DISM images.
  * Multi-drive rotation support and missing backup drive desktop alerts.
  * Universal emergency hotkeys (`Ctrl+Win+B` / `Ctrl+Win+W`).
  * VSS subsystem self-healing and COM provider auto-repair.
* **What It DOES NOT Do**:
  * Does not display a persistent Floppy Tray Sentry icon in the notification area (operates as a silent background guardian with active Scam & RAT defense).
* **Best Suited For**: Accounting firms, medical clinics, legal offices, and quiet workstations where background protection is essential but tray icons and pop-ups are unwanted.

---

### Mode 4: `TotalProtection` (Visual Observability & Interactive Sentry)
* **What It DOES**:
  * Activates the signature **Floppy Tray Sentry** with dynamic color status (🟢 Green = Protected/Idle, 🟣 Purple = Backup Active, 🟡 Amber = Warning/Notice, 🔴 Red = Attention Required). Note: 🔵 Classic Blue Floppy is the static Application Launcher and Protection Center Hub icon (`app.ico`).
  * Runs the **Real-Time Remote Access RAT Interceptor**: actively monitors for 25+ remote support tools (ScreenConnect, UltraViewer, AnyDesk, TeamViewer, RustDesk) frequently weaponized by phone scammers, presenting an instant `[STOP] Disconnect & Block` prompt.
  * Full desktop shortcuts (Protection Center, Backup Personal Data with live Dual Progress Bar, System Restore, Create System Image).
  * Supports custom shop branding ($100 lifetime shop token) on the dashboard and support cards.
* **What It DOES NOT Do**:
  * Does not install kernel drivers or proprietary background services; runs as a lightweight user-session tray sentry (~16 MB RAM).
* **Best Suited For**: Everyday home users, seniors, family members, VIP workstations, and customers who need visual reassurance, 1-click desktop actions, and active scam protection.

---

## ⚡ One-Click Batch Deployers & Zero-Drift Mode Switching

WINBARS includes standalone batch installers in the repository root and `dist/` for rapid provisioning from a technician USB drive:

| Script | Profile Deployed | Resident Footprint | Unattended Syntax |
| :--- | :--- | :--- | :--- |
| `Install-Mode0-ZeroFootprint.bat` | Mode 0: ZeroFootprint | 0 resident files on `C:\` | `/Quiet /Vanilla /Data:<Path> /Image:<Path>` |
| `Install-ModeN-NearZeroFootprint.bat` | Mode N: NearZeroFootprint | 0 resident EXEs (Unbranded shortcuts) | `/Quiet /Vanilla /Data:<Path> /Image:<Path>` |
| `Install-Mode1-SystemUndo.bat` | Mode 1: SystemUndo | 0 resident EXEs (Native Windows tasks) | `/Quiet /Vanilla /Baseline:Y\|N` |
| `Install-Mode2-LocalDisasterGuard.bat`| Mode 2: LocalDisasterGuard | `C:\Tools\WINBARS` (Local `.wim` image) | `/Quiet /Brand:"Name"` |
| `Install-Mode3-HeadlessFull.bat` | Mode 3: HeadlessFull | `C:\Tools\WINBARS` (Silent automation) | `/Quiet /Brand:"Name" /Data:<Path>` |
| `Install-Mode4-TotalProtection.bat` | Mode 4: TotalProtection | `C:\Tools\WINBARS` (Tray Sentry + Sentry) | `/Quiet /Brand:"Name" /Data:<Path>` |
| `Reset-Suite.bat` | Factory Reset Utility | Clears tasks/sentries; keeps user data | `/Quiet` |

### 🔄 Zero-Drift Mode Switching
Switching between profiles (e.g. from Mode 4 to Mode 1, or Mode 2 to Mode 3) is **completely seamless**:
- Every installer batch file and CLI switch (`WINBARS.exe -SwitchMode <Profile>`) automatically tears down previous background sentries and unregisters stale tasks before applying the newly selected mode.
- This guarantees zero "zombie" scheduled tasks or leftover registry hooks.
- All deployers accept the `/Reset` flag to perform a factory-clean reset before applying the target mode.

---

## 📦 1-Click Custom Profile Batch Generator

For MSPs and technicians managing specialized client environments (e.g., custom drive paths, specific retention schedules, or disabled components):

1. **Configure in GUI or CLI**:
   - Open the Pre-Flight Menu (`[P]`) in the console, toggle components `[0-9]` to your client's exact requirements, and press **`[S]`**.
   - Or via CLI: `WINBARS.exe -ExportCustomProfileInstaller "MedicalClinic"`
2. **Generated Portable Appliance**:
   - Creates a standalone `Install-Custom-<ProfileName>.bat` file alongside `WINBARS.exe`.
   - Embeds the exact configuration into `C:\ProgramData\WINBARS\custom_profiles.json`.
3. **Deploy Anywhere in 15 Seconds**:
   - Copy `Install-Custom-<ProfileName>.bat` and `WINBARS.exe` to a technician USB stick.
   - Plug into any client machine, double-click the `.bat`, and the custom configuration is deployed unattended.
