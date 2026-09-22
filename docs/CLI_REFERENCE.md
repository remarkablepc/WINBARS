# WINBARS Command-Line Interface (CLI) Reference (v0.9.7-beta)

## 1. Quick Syntax Overview

```cmd
WINBARS.exe [-CLI | -GUI] [-Action <ActionName>] [-SetProfile <ProfileName>] [Operational Switches]
```

All switches can be passed with standard PowerShell syntax (`-Switch`) or Windows command prompt syntax (`/Switch`).

### 🖥️ Primary Interface Modes & Smart Launch Defaults

| Mode Switch | Aliases | Description |
| :--- | :--- | :--- |
| **`-CLI`** ⭐ | `-Console`, `-Menu` | Launches the interactive Technician Console Menu with real-time host inspection, dynamic USB tools, and full subsystem access. |
| **`-GUI`** 🪟 | `-StatusCard`, `-Status` | Launches the visual Protection Center Live Dashboard (`Ctrl+Win+W`) with 1-click backups, live health gauges, and system recovery tools. |

> [!TIP]
> **Context-Aware Smart Default Launch**:
> - **Portable Media / USB / IRM Download**: Running `WINBARS.exe` with no switches automatically detects that the executable is running outside `C:\Tools\WINBARS` and defaults to **`-CLI`** (interactive technician mode).
> - **Local Installation (`C:\Tools\WINBARS`)**: Running `WINBARS.exe` with no switches automatically defaults to **`-GUI`** (Protection Center Live Dashboard for clients and end users).

---

## 2. Primary Actions (-Action <name>)

| Action Switch | Description | Automated / Unattended |
| :--- | :--- | :---: |
| -Action FastBackup | Runs daily fast backup pass: mirrors personal files + creates System Checkpoint. [⚡ 1-Click: Backup My Files Now] | WINBARS.exe -Action FastBackup -Unattended |
| -Action RestorePoint | Creates a hardened, atomic Windows System Restore Point checkpoint. Use `-Baseline` for permanent driver/hardware checkpoint. | WINBARS.exe -Action RestorePoint -Baseline -Description "Pre-Driver Fix" |
| -Action FileHistory | Runs multi-threaded unbuffered Robocopy personal file synchronization. | WINBARS.exe -Action FileHistory -Unattended |
| -Action SystemImage | Captures a full bare-metal DISM system image archive (.wim). Use `-Baseline` to tag as permanent master (`_baseline.wim`). | WINBARS.exe -Action SystemImage -Baseline -Unattended |
| -Action CaptureVolumeImage | Captures a standalone DISM image (`.wim`) of any drive or volume (secondary drives, data volumes, OS) with VSS freeze & loop guard. | WINBARS.exe -Action CaptureVolumeImage -CaptureVolume D: -ImageDestination E:\Images\Data.wim |
| -Action All | Runs a complete multi-pass backup (Restore Point, File Mirror, DISM Image). | WINBARS.exe -Action All -Unattended |
| -Action AutoHeal | Runs a silent scan to self-heal Windows VSS & SystemProtection. | WINBARS.exe -Action AutoHeal -Unattended |
| -Action Diagnostics | Runs profile-aware feature diagnostics audit across 12 subsystems with structured PASS / WARN / FAIL / N/A scorecard. | WINBARS.exe -Action Diagnostics |
| -Action VerifyFix | Runs full diagnostic self-test and auto-repairs broken scheduled tasks. | WINBARS.exe -VerifyFix |
| -Action Preflight | Evaluates system storage, power state, and volume readiness. | WINBARS.exe -Preflight |
| -Action BackupBCD | Exports atomic BCD boot hive, plaintext audit log, and WinPE rescue batch script. | WINBARS.exe -Action BackupBCD -Unattended |
| -Action UpdateTriggers | Synchronizes installed Task Scheduler triggers to match current config without full reinstall. | WINBARS.exe -Action UpdateTriggers |
| -Action RestoreBCD | Launches interactive BCD bootloader recovery tool. | WINBARS.exe -Action RestoreBCD |

---

## 3. Deployment Profile Selectors (-SetProfile <name>)

WINBARS provides a unified 6-profile deployment architecture cleanly divided into **Stealth Native Modes (0, N, 1)** leaving 0 resident EXEs, and **Managed Suite Modes (2, 3, 4)** with desktop integration:

### 🛡️ Deployment Profiles & Architecture Spectrum

| Mode & CLI Name | Aliases | Operational Behavior (`BACKS UP` & `OMITS`) | Resident Footprint | Hotkeys & WinPE Recovery Hooks | Tray & ScamBuster Watchdog |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **Mode 0: `ZeroFootprint`** ⭐ | `0` | **BACKS UP**: Daily System Restore, User Data (Robocopy Mirror + 30-Day Retention), Bare-Metal Image (wbadmin), BitLocker Keys.<br>**OMITS**: Zero files on PC, no health check task, no tray, no watchdog, no shortcuts. Pure native Windows engine. | **0 Bytes on PC** *(Configured on-demand; automated tasks run autonomously via native Windows engines)* | ❌ Zero host files (Configured on-demand) | ❌ None *(Pure Native Windows Engine)* |
| **Mode N: `NearZeroFootprint`** 👻 | `NearZero`, `N` | **BACKS UP**: Daily System Restore, Windows Health Check (Daily 03:00 AM), User Data (Robocopy Mirror to `E:\WindowsBackup\` + 30-Day Retention), Bare-Metal Image (wbadmin), BitLocker Keys.<br>**OMITS**: Zero resident EXEs/daemons on host. Standard unbranded desktop shortcuts (`Backup Personal Files`, `Windows System Restore`, `Browse Backup Files`) + generic `System Backup & Recovery` Start Menu folder. Restores via native Explorer & WinRE. Complete vendor-neutral stealth deployment. | **0 Resident EXEs** *(100% native Task Scheduler)* | ❌ Zero host EXEs (Native `powershell.exe` & `rstrui.exe` shortcuts) | ❌ None *(Pure Native Windows Engine)* |
| **Mode 1: `SystemUndo`** ⏪ *(Stealth Hardener)* | `Minimal`, `1` | **BACKS UP**: Daily System Restore (unthrottled), Windows Health Check (Daily 03:00 AM with pre-scan checkpoint), VSS Shadow Storage Guard, Driver/MSI install checkpoints, Local Baseline System Image (`C:\SystemRecovery\_baseline.wim` if disk $\ge 25$ GB free).<br>**OMITS**: Zero resident EXEs, no shortcuts, no tray, no watchdog, no third-party branding. 100% native Windows Task Scheduler. | **0 Resident EXEs** *(100% Native Windows Hardening)* | ❌ Zero host hooks *(Native WinRE detects restore points & `.wim` automatically)* | ❌ None *(Pure Native Windows Engine)* |
| **Mode 2: `LocalDisasterGuard`** 💽 | `2` | **BACKS UP**: [Mode 1 +] Windows Health Check (Weekly on 30m idle), Local secondary/partition bare-metal DISM image (`.wim`) for offline recovery without an external drive.<br>**OMITS**: No external drive sync, no personal file mirror, no tray. | Local Suite (`~12 MB RAM`) | ✅ **Native WinRE Boot Hook** • **Protection Hotkey (`Ctrl+Win+W`)** • **Panic Hotkey (`Ctrl+Win+B`)** • **Desktop Suite** | ✅ **Silent Scam & RAT Watchdog** (Tray OFF) |
| **Mode 3: `HeadlessFull`** 🏢 | `3` | **BACKS UP**: [Mode 2 +] Daily differential Robocopy sync, scheduled bare-metal images (`.wim` to both local & USB), multi-drive rotation, **missing drive connection prompts**.<br>**OMITS**: No floppy tray icon, no desktop GUI. Defaults to Shop Branding (unless `-Vanilla`). | Local Suite (`~12 MB RAM`) | ✅ **Native WinRE Boot Hook** • **Protection Hotkey (`Ctrl+Win+W`)** • **Panic Hotkey (`Ctrl+Win+B`)** • **Drive Alerts** | ✅ **Silent Scam & RAT Watchdog** (Tray OFF) |
| **Mode 4: `TotalProtection`** 🛡️ | `FullInteractive`, `4` | **BACKS UP**: [Mode 3 +] Complete personal files, bare-metal images (`.wim` to both local & USB), restore points, drive alerts, Windows Health Check (Weekly on 30m idle).<br>**OMITS**: Zero Omissions (complete interactive protection suite). Defaults to Shop Branding (unless `-Vanilla`). | Local Suite (`~16 MB RAM`) | ✅ **Native WinRE Boot Hook** • **Protection Hotkey (`Ctrl+Win+W`)** • **Panic Hotkey (`Ctrl+Win+B`)** • **Protection Center GUI** | ✅ **Floppy Tray Icon** • **ScamBuster Active Watchdog** |
| **Mode 5+: Custom Profiles** 🛠️ | `<Name>`, `5+` | Configured via Pre-Flight builder or `custom_profiles.json`. `BACKS UP` and `OMITS` calculated dynamically based on active component flags. | Configurable | Configurable | Configurable |

---

### 🎯 Technician Customer Persona Cheat Sheet (Quick-Scan Decision Matrix)
Need to know which profile to pick for a customer at a glance? Use this cheat sheet:

| Profile | Customer / Machine Persona | Real-World Technician Scenario & Why It Fits |
| :--- | :--- | :--- |
| **Mode 0: `ZeroFootprint`** | **Strict Corporate Audits & MSP Sterile Compliance** | Corporate clients or regulated workstations where security policy strictly forbids leaving any third-party files or scripts on `C:\`. The entire runner script and logs reside on the technician's external drive. |
| **Mode N: `NearZeroFootprint`** | **Corporate Workstations & Vendor-Neutral Stealth Deployments** | For business and corporate clients where third-party utility branding is restricted. Uses 100% native Windows Task Scheduler and generic shortcuts (`System Backup & Recovery`) so the automation blends seamlessly into Windows as a built-in system capability. **Zero background EXEs**, native Task Scheduler jobs (`\WindowsBackup\`), generic external folder (`E:\WindowsBackup\`), and generic native tools. Restores via native Explorer, `rstrui.exe`, & WinRE. |
| **Mode 1: `SystemUndo`** ⏪ | **Standard Bench Tune-Ups & Routine Warranty Service** | **The Universal Service Warranty Baseline**: Designed for standard bench tune-ups and hardware repairs. Hardens Windows' native recovery engines (unthrottles restore point frequency, locks 10% VSS shadow storage headroom, and enables native RegBack) with an optional baseline image. Operates with **zero third-party resident binaries and zero shortcuts**, delivering dependable rollback protection without introducing software overhead. |
| **Mode 2: `LocalDisasterGuard`** 💽 | **Road Warriors, Students & Mobile Laptops** | Traveling sales reps and laptop users who rarely plug in an external drive, but *want* on-demand desktop recovery shortcuts. Configures recurring monthly bare-metal DISM system images (`.wim`) to a local recovery partition with desktop suite integration and emergency hotkeys. |
| **Mode 3: `HeadlessFull`** 🏢 | **Silent Workstations, Accounting & Medical Clinics** | Production office environments (CPA firms, dental clinics, law offices) with dedicated external hard drives. Runs full daily Robocopy sync and bare-metal imaging 100% silently in the background with zero desktop clutter or user prompts—alerting only if the drive is unplugged. |
| **Mode 4: `TotalProtection`** 🛡️ | **Seniors, VIPs & Scam-Prone Non-Technical Clients** | Grandparents, non-technical clients, or high-value VIPs frequently targeted by browser pop-ups, fake virus sirens, and phone support scammers. Features the Floppy Disk Tray icon, active real-time ScamBuster and Remote Tool Interceptor (`[STOP] Disconnect & Block`), live GUI Protection Center, and your shop's emergency support hotline branding. |
| **Mode 5+: `Custom Profiles`** | **Specialized Enterprise & Boutique Deployments** | Tailored multi-drive configurations, specialized network shares, or specific retention tiers configured via `custom_profiles.json` or the Pre-Flight interactive builder. |

---

### 🪤 Ransomware Canary Shield Matrix: Who Gets What Protection?

| Profile Mode | Target Storage Monitored | Canary Placement | Detection & Enforcement Mechanism |
| :--- | :--- | :--- | :--- |
| **Mode 0 (`ZeroFootprint`)** | External Backup Drive | `.winbar_canary.dat` on external drive root | Cryptographic hash verified before and after each Robocopy file mirror pass. |
| **Mode N (`NearZeroFootprint`)** | External Backup Drive (`E:\WindowsBackup`) | `.winbar_canary.dat` on external drive root | Pre/post-sync integrity verification on every scheduled mirror run. |
| **Mode 1 (`SystemUndo` - Stealth)** | Internal System Drive (`C:`) | *None (0 resident background processes)* | **VSS Shadow Storage Quota Hardening**: Locks shadow storage headroom so ransomware cannot easily exhaust System Protection capacity. |
| **Mode 2 (`LocalDisasterGuard`)** | Local Image Archive (`C:\SystemRecovery`) | `C:\SystemRecovery\.winbar_canary.dat` | Inspected during scheduled bare-metal image capture passes and on-demand health audits. |
| **Mode 3 (`HeadlessFull`)** | External Backup Volumes & Shares | Multi-Target `.winbar_canary.dat` + `.winbars_remote_canary.sha256` | Daily automated pre-sync audit. If canary fails, aborts file sync immediately and disconnects network share. |
| **Mode 4 (`TotalProtection`)** | Local + All External & Network Targets | Real-time Honeypot Sentinels | **Continuous Real-Time Monitoring**: Floppy Tray Sentry actively watches tripwire tokens; triggers immediate desktop Toast alert, siren alarm, and Webhook dispatch (Discord/Slack/Teams). |


### ⚡ Pre-Flight Quick Defaults Review Screen
Whenever a profile is selected interactively (Modes 0–4 or 5+):
* **1-Key Default Execution**: Pressing **`[ENTER]`** immediately applies the profile using hardened system defaults with zero unnecessary prompts.
* **Component Toggling (`1-9`)**: Press any number to toggle individual components in memory:
  * `[1]` User Data Sync (Robocopy Mirror + 30-Day Retention)
  * `[2]` Bare-Metal System Image (DISM / VHDX)
  * `[3]` Restore Point Hardening & VSS Auto-Heal Sentry
  * `[4]` WinPE Offline Boot Recovery Hooks
  * `[5]` External Drive Connection Prompt (Alerts if USB Missing)
  * `[6]` Emergency Panic Hotkeys (`Ctrl+Win+B` / Desktop Helper)
  * `[7]` ScamBuster Active Remote Access Watchdog
  * `[8]` Floppy Disk Notification Tray Monitor
  * `[9]` Custom Partner Branding & Organization Assets
  * `[0]` Silence Deceptive OneDrive 'Not Backed Up' Warnings
  * `[E]` Block Silent BitLocker Device Encryption (`PreventDeviceEncryption`)
* **Target Storage Drive Selection (`[C]`)**: Inspect available logical drives and switch between storage devices (with automatic free space and volume label calculation).
* **Adjust User Data Destination Folder (`[D]`)**: Customize the target directory for personal documents and Robocopy synchronization (stored in `config.json` as `[Configured]`).
* **Adjust System Image Destination Folder (`[I]`)**: Designate custom folders for bare-metal DISM / wbadmin system image archives.
* **Configure Source Folders & User Profiles (`[F]`)**: Launches the interactive folder picker (`Show-FolderSelectionMenu`) to selectively include or exclude user accounts, Public folders, or accounting databases.
* **Save as Custom Profile (`[S]`)**: Persist custom component tweaks and destination paths as a named profile in `custom_profiles.json`.
* **Custom Profile Manager (`[M]`)**: Submenu to Add (`[A]`), Edit (`[E]`), Delete (`[D]`), or Open in Notepad (`[O]`).

### 💡 Key Profile Distinctions:
* **Cumulative Tiering**: Modes 1–4 build sequentially upon one another. Mode 1 is the OS rapid rollback engine; Mode 2 adds local bare-metal DISM imaging for laptops without external drives; Mode 3 adds external Robocopy syncing and missing drive alerts; Mode 4 adds the Floppy Tray sentry and ScamBuster active watchdog. Mode 0 and Mode N provide pure native Windows Task Scheduler automation with 0 resident background EXEs.
* **Branding Rules**: Modes 1–4 default to **Shop Branded** (using `brands/default.json` or `branding.json`) unless `-Vanilla` is explicitly passed. Modes 0 and N are strictly 100% unbranded / stealth.
* **Floppy Disk Icon Roles**:
  * <img src="assets/app_icon.png" width="18" height="18" valign="middle" alt="Blue Floppy" /> **Classic Blue Floppy (`app.ico`)**: Protection Center Hub, Suite Manager, System Recovery.
  * <img src="assets/app_backup_preview.png" width="18" height="18" valign="middle" alt="Purple Floppy" /> **Signature Purple Floppy (`app_backup.ico`)**: Backup Action / Data Sync (`Backup Personal Files`, `Fast Backup`).
* **Dynamic System-Derived Storage Sizing & USB Insertion Filter**:
  * Calculates real required storage directly from the system: measures actual size of `C:\Users` (+ 25% buffer for 30-day retention) and actual used space on `C:\` (at 60% WIM compression + 15 GB buffer).
  * Automatically caches real requirements in `storage_requirements.json` so the tray sentry evaluates attached media in microseconds.
  * Silently ignores under-sized USB flash drives (e.g. if the system needs 300 GB, any 32 GB or 64 GB USB drive is ignored with zero annoying popups).
  * Prompts with reassuring clarity: explicitly states that WINBARS is **100% Safe & Non-Destructive**, creates a separate folder, and will **NEVER format the drive or delete existing files**.
* **Configurable Default Brand in `config.json`**:
  * Set `"DefaultBrand": "Vanilla"` (or `"Unbranded"`) to enforce generic unbranded operation across all profiles by default.
  * Set `"DefaultBrand": "MyBrand.json"` to load a specific brand file without renaming files.
  * Set `"DefaultBrand": "Auto"` to preserve smart brand detection (`last_brand.txt` -> `brands/default.json` -> `branding.json`).
* **Dynamic File Restoration Explorer Shortcut (`Browse Backup Files`)**:
  * Double-clicking opens Windows File Explorer directly to the mirrored backup folder (`\WindowsBackup\Users` or `\WINBARS_Backups\UserBackups`).
  * Resolves external drive letter dynamically, adapting to drive letter drift with standard Windows Folder icon (`shell32.dll,3`).
* **Emergency Panic Hotkeys (`Ctrl+Win+B`)**: Active in Modes 1 through 4 (and custom profiles where enabled, with `Ctrl+Alt+B` fallback). In Mode 0 (`ZeroFootprint`), zero host files or shortcuts are created to maintain complete host sterility.
* **GUI Dialog & Profile Capabilities Breakdown**: Launching `WINBARS.exe` or `WINBARS.exe -GUI` opens the Protection Center Live Dashboard. The status pill reflects the installed mode. Pressing `[I]` in the CLI menu inspects detailed capability cards for all profiles.

*Example*: `WINBARS.exe -SetProfile ZeroFootprint` (or `-SetProfile 0`)  
*Example*: `WINBARS.exe -SetProfile NearZeroFootprint` (or `-SetProfile N`)  
*Example*: `WINBARS.exe -SetProfile SystemUndo` (or `-SetProfile 1`)  
*Example*: `WINBARS.exe -SetProfile TotalProtection` (or `-SetProfile 4`)  
*Example*: `WINBARS.exe -GUI` (Opens Protection Center on any PC)

---

## 4. Emergency & Special Operations

| Operational Switch | Purpose & Execution Details |
| :--- | :--- |
| -Update / -Upgrade | In-Place Suite Upgrade Engine: terminates running instances to release locks, copies updated binaries/modules, refreshes tasks, and relaunches sentry. |
| -ResetSuite / -ResetConfig | Factory Reset & Reprovisioning Engine: unregisters all scheduled tasks, sentries, run keys, and clears config.json back to pristine state without deleting application binaries or customer backups. |
| -SwitchMode <Profile> | Seamless Mode Switch: cleans prior mode tasks and sentries to prevent drift, then applies and arms the newly chosen profile. |
| -SetProfile <Profile> | Applies specified deployment profile (ZeroFootprint, NearZeroFootprint, Minimal, LocalDisasterGuard, HeadlessFull, FullInteractive) non-interactively (automatically routes via SwitchMode). |
| -DefuseOneDriveNags | Surgically silences deceptive Windows / OneDrive 'Not Backed Up' scare banners & KFM takeover. |
| -RestoreOneDriveNags | Restores standard Windows / OneDrive notification and folder defaults. |
| -ScamBuster | Terminates rogue browser lockups, silences sirens, and clears reload traps (Ctrl+Win+B). |
| -QuickAssist | Displays verified shop contact & security warning dialog, then launches Microsoft Quick Assist (Ctrl+Win+Q). |
| -ListBackupDrives | Displays formatted table of all registered backup destinations, total space, free space, roles, and online health. |
| -AddBackupDrive <Path> | Registers a backup destination drive letter (e.g. `E:`) or custom directory path (e.g. `E:\Backups`). |
| -RemoveBackupDrive <Path> [-Force] | Removes a backup destination. Enforces 1-Drive Minimum Guardrail (requires `-Force` for technician override). |
| -SetPrimaryBackupDrive <Path> | Designates a backup drive/path as Primary. |
| -Baseline | Captures a permanent Day-1 baseline restore point or bare-metal system image (`_baseline.wim`). Excluded permanently from retention rotation. |
| -Description <Text> | Specifies a custom hardware or repair label for baseline restore points (e.g., `-Description "Pre-I2C Mouse Fix"`). |
| -GUI / -StatusCard | Opens the visual GUI Protection Center Live Dashboard (Ctrl+Win+W). Aliases: `-StatusCard`, `-Status`. |
| -CLI / -Console | Launches the interactive technician CLI console menu. Aliases: `-Console`, `-Menu`. |
| -Uninstall | Unregisters all suite scheduled tasks, desktop & Start Menu shortcuts, WinRE recovery hooks, and tray sentry autostart. |
| -Tray | Launches the background Floppy Tray Sentry in the Windows notification area. |
| -InstallTray | Registers Floppy Tray Sentry to start automatically at user logon. |
| -UninstallTray | Removes Floppy Tray Sentry from Windows startup. |
| -CreateShortcuts | Creates Desktop Shortcuts (4 Action shortcuts in Managed mode; native schtasks shortcuts in Zero-Footprint). |
| -ToggleDriveCloaking | Toggles backup drive letter visibility in Windows Explorer ('This PC') on/off. |
| -HideBackupDrive | Cloaks the backup target drive letter in Windows Explorer via native NoDrives policy. |
| -ShowBackupDrive | Uncloaks and restores backup target drive visibility in Windows Explorer. |
| -EmergencyCard | Generates printable BitLocker Disaster Recovery Emergency Card (.html). |
| -BlockSilentBitLocker | Sets native Windows policy `PreventDeviceEncryption = 1` in `HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker` to block silent 24H2 Device Encryption. |
| -AllowSilentBitLocker | Removes `PreventDeviceEncryption` policy, restoring native Windows automatic BitLocker Device Encryption behavior. |
| -UnlockBitLocker | Launches 1-Click WinPE/Live BitLocker password unlock wizard. |
| -BitLocker | Auto-archives AES-256 BitLocker encrypted vault (BitLocker_Vault.enc). |
| -BackupBCD | Exports Boot Configuration Data binary hive, audit log, and generates Restore_BCD_WinPE.bat. |
| -RestoreBCD | Launches the interactive BCD recovery tool to restore clean bootloader state. |
| -StorageEstimate | Runs Dynamic Storage Sizing Advisor and recommends commercial drive tiers. |
| -RescuePartition | Opens the Hidden Local Rescue Partition Manager. |
| -CanaryDeploy | Seeds cryptographic Ransomware Honeypot Canaries across user directories. |
| -CanaryVerify | Audits SHA-256 integrity of all deployed Canary Honeypots. |
| -CanaryReset | Clears Canary emergency suspension lock after resolving a security event. |
| -VerifyBackup | Runs automated sandbox extraction drill to test backup archives. |
| -TestWebhook | Sends test alert payload to Discord, Slack, Teams, or custom REST endpoints. |
| -CleanLogs | Enforces log retention policy and purges expired historical logs. |
| -RebootToRecovery | Reboots directly into Windows RE Blue Screen environment. |
| -RebootToSafeMode | Reboots directly into Windows Safe Mode. |
| -CaptureVolumeImage | Captures a standalone DISM image (.wim) of any drive or volume with VSS snapshot freeze. |
| -CaptureVolume <Drive> | Specifies source volume to capture (e.g. `D:`, `E:`, `C:`). Used with `-Action CaptureVolumeImage`. |
| -ImageDestination <Path> | Specifies full destination `.wim` file path (e.g. `E:\Images\DataVolume.wim`). |
| -Compression <fast\|max\|none> | Sets DISM image compression level (default: `fast`). |
| -NoVss | Bypasses VSS snapshot creation during volume imaging (direct volume capture). |
| -Diagnose / -Diagnostics / -HealthCheck | Runs feature diagnostics audit across 12 subsystems with structured PASS / WARN / FAIL / N/A scorecard. |
| -AsJson | Emits machine-readable JSON array of subsystem diagnostic results (for GUI, monitoring, or ticketing). |
| -Help / -? | Displays full command-line reference directly in the terminal. |

---

### 🩺 System Diagnostics & Feature Audit Engine (`-Action Diagnostics`)

WINBARS features a built-in diagnostic and health auditing engine designed for bench handoffs, MSP compliance, and routine verification. Running `WINBARS.exe -Action Diagnostics` evaluates 12 critical subsystems:

1. **Physical Storage (S.M.A.R.T.)**: Storage controller events, bad block anomalies, and filesystem write responsiveness.
2. **VSS Providers & Collision Guard**: Verifies Microsoft Software Shadow Copy provider is active and detects conflicting 3rd-party backup filter drivers.
3. **System Restore Point Engine**: Checks unthrottled creation frequency (`0m`) and latest checkpoint freshness.
4. **User Data Mirror (Robocopy)**: Profile-aware inspection of backup target media, folder structure, and file synchronization timestamps.
5. **Bare-Metal DISM System Image**: Scans local recovery partitions and external targets for valid bare-metal `.wim` archives.
6. **Task Scheduler Automation**: Audits registered scheduled tasks against the active deployment profile (omits optional tasks without false alarm warnings).
7. **WinRE Blue-Screen Recovery Hook**: Validates Windows RE status and Safe Overlay recovery engine staging (`C:\SystemRecovery\Apply-SystemImage_WinPE.bat`).
8. **BitLocker Vault & Master DRA**: Verifies 48-digit numerical recovery key vault archiving and Enterprise Data Recovery Agent (DRA) certificate enrollment.
9. **Ransomware Canary Tripwires**: Audits cryptographic SHA-256 integrity tokens across monitored local directories and backup repository roots.
10. **Scam Sentry & RAT Interceptor**: Scans running processes for 25+ remote control tools (ScreenConnect, AnyDesk, UltraViewer, TeamViewer) weaponized by scammers.
11. **PUP Guard & Antivirus Sentry**: Checks for blacklisted Potentially Unwanted Programs and alerts on conflicting dual-antivirus installations.
12. **BCD Bootloader & EFI Integrity**: Inspects Windows Boot Manager and `{current}` boot records via `bcdedit`.

**Profile-Aware `[ N/A ]` Tagging:**
Unlike generic tools that trigger false alarms on missing components, WINBARS understands the intentional omissions of each profile. For example, in **Mode 1 (`SystemUndo`)**, Robocopy file sync, external drive checks, and tray sentry daemons are cleanly tagged as **`[ N/A ] (Omitted by design)`** rather than warnings or failures.

**CLI & GUI Access:**
- **Console**: Run `WINBARS.exe -Action Diagnostics` or select Option `[4]` in the interactive CLI menu.
- **Machine-Readable JSON**: Run `WINBARS.exe -Action Diagnostics -AsJson -Unattended`.
- **GUI Interface**: Open via Floppy Tray Menu -> **Advanced Menu** -> `🩺 Run System Diagnostics & Feature Audit...` or through **Documentation & Technical Manuals** -> `Run System Diagnostics...`. Includes 1-click **Copy Report to Clipboard** for pasting into customer repair tickets.

### 💽 Arbitrary Volume Imaging Engine (`-CaptureVolumeImage`)

Technicians can capture a standalone bare-metal DISM `.wim` image of any connected drive or partition (secondary drives, database disks, SD cards, or OS partitions):

```cmd
REM Capture drive D: to an external backup drive with fast compression and VSS snapshot:
WINBARS.exe -Action CaptureVolumeImage -CaptureVolume D: -ImageDestination E:\SystemImages\Data_D.wim

REM Capture secondary drive E: with maximum compression:
WINBARS.exe -Action CaptureVolumeImage -CaptureVolume E: -ImageDestination F:\Backups\DriveE.wim -Compression max
```

**Guardrails & Architecture:**
- **Circular Imaging Protection**: Destination file path is strictly prohibited from residing on the volume being captured, preventing disk-exhaustion runaway loops.
- **VSS Frozen Snapshot Mounting**: Live volumes are frozen and mounted as read-only volume shadow snapshots (`\\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy...`), allowing DISM to capture open databases, locked registry hives, and active user files without corruption.
- **Interactive GUI Integration**: Accessible via the Floppy Tray Menu (**More Backup Options** -> **Capture Custom Volume Image...**) and the Technician Advanced Menu (**Capture Volume Image of Any Drive (DISM)...**), with live DISM percentage progress bars.

## 5. Modern Tabbed Settings & Protection Console

Accessible from the Floppy Tray Sentry menu (**Protection Settings...**), the Quick-Action Bar gear icon, or via `Ctrl+Win+W`:

### Tab 1: ⚙ General
* **Active Deployment Profile Header**: Displays prominent banner with current profile (`Mode 4 — Total Protection`, `Mode 3 — Headless Full`, `Mode 0 — Zero-Footprint Sentry`, etc.).
* **System Tray Icon Visibility**: Checkbox to show/hide the notification area icon with `Ctrl+Win+W` safety net.
  * **Mode 0 & Mode N Compliance Guardrail**: In Zero-Footprint modes, this toggle is disabled and locked:  
    `🔒 Zero-Footprint Mode: Tray sentry disabled to preserve 0 host files.`
  * **Mode 3 ↔ Mode 4 Seamless Profile Bridge**: Checking the tray icon in Mode 3 (`HeadlessFull`) smoothly elevates the profile to Mode 4 (`TotalProtection`). Unchecking returns it to Mode 3.
* **Floating Quick-Action Bar**: Toggle touch-friendly 5-button desktop strip.
* **Notification Guardrail**: Warning and error alerts cannot be disabled in standard mode.
* **Audible Alarms**: Toggle siren sounds for ScamBuster and Canary trips.

### Tab 2: 🕒 Schedules
* **Timing Customization**: Adjust execution hours (HH:mm 24-hr) for Restore Points, Daily Personal File Sync, and Bare-Metal DISM Images.
* **Cadence Controls**: Daily, Every 3 Days, or Weekly restore point frequency.
* **Auto-Sync Engine**: Saving settings automatically refreshes Task Scheduler triggers via `-Action UpdateTriggers`. Tasks are permanently protected against disabling.

### Tab 3: 💾 Disk Management & Destinations
* **Interactive Destination Table**: Lists all registered targets with Target Path, Volume Label, Role (`Primary` vs `Secondary`), and live Online/Offline status.
* **Add Destination Wizard**: Supports drive letters (`E:`, `E`) and custom directory targets (`E:\Backups`).
  * **Mode 1 & Mode 2 Personal File Sync Elevation**: If an external destination is added in Mode 1 or 2, WINBARS prompts to enable daily personal file synchronization and elevates the profile to Mode 4 (or Mode 3 if headless).
* **Set as Primary**: Promotes any selected destination to Primary backup target.
* **1-Drive Minimum Guardrail**: Standard users cannot remove the last configured backup destination.
* **Technician Override**: Technicians in Tech Mode (or via `-RemoveBackupDrive <Path> -Force`) can bypass the guardrail with explicit confirmation when decommissioning or re-imaging a machine.
* **Silent Bare-Metal Local Fallback (`C:\SystemRecovery`)**: If no secondary or external drive is attached during a scheduled image pass, WINBARS captures the bare-metal DISM image cleanly to `C:\SystemRecovery` without raising false-alarm warning toasts.

---

## 6. Dynamic Per-Profile Action Buttons & Drive Intelligence

In WINBARS v0.7.43, primary execution buttons dynamically morph to reflect the active profile and external storage availability:

| Profile | Backup Drive State | Status Card Hero Button (`Ctrl+Win+W`) | Floating Quick Bar | Tray Context Menu |
| :--- | :--- | :--- | :--- | :--- |
| **Mode 4: `TotalProtection`** 🛡️ | Drive Connected | `▶ Backup My Files Now` | `🛡 Backup Files` | `⚡ Backup My Files Now (Files + Checkpoint)` |
| **Mode 3: `HeadlessFull`** 🏢 | Drive Connected | `▶ Backup My Files Now` | `🛡 Backup Files` | `⚡ Backup My Files Now (Files + Checkpoint)` |
| **Mode 2: `LocalDisasterGuard`** 💽 | Drive Connected (`D:`) | `▶ Capture Full Disaster Image` | `🛡 Disaster Image` | `⚡ Capture Full Disaster Image (DISM to D: + Checkpoint)` |
| **Mode 2: `LocalDisasterGuard`** 💽 | No External Drive | `▶ Capture System Image & Checkpoint` | `🛡 Capture Image` | `⚡ Capture System Image & Checkpoint (DISM Local + Restore Point)` |
| **Mode 1: `SystemUndo`** ⏪ | Drive Connected (`D:`) | `▶ Create System Checkpoint Now` | `🛡 Checkpoint` | `⚡ Create System Checkpoint Now (Registry + Restore Point to D:)` |
| **Mode 1: `SystemUndo`** ⏪ | No External Drive | `▶ Create Restore Point Now` | `🛡 Create Point` | `⚡ Create Restore Point Now (System Undo Baseline)` |
| **Mode 0: `ZeroFootprint`** | USB / Target Attached | `▶ Run Zero-Footprint Backup Now` | `🛡 Zero Backup` | `⚡ Run Zero-Footprint Backup Now (Files + Checkpoint to D:)` |
| **Mode N: `NearZeroFootprint`** | USB / Target Attached | `▶ Run Near-Zero Backup Now` | `🛡 Near-Zero Backup` | `⚡ Run Near-Zero Backup Now (Files + Checkpoint to D:)` |

### ⚡ Non-Technical Elevation Badge (Modes 1 & 2)
When an external backup drive is detected online in Mode 1 or Mode 2, the Status Card displays:
`[⚡ Backup Drive (D:) Ready — Click to Enable Daily Personal File Backup]`
Clicking this badge prompts the user to enable daily personal file backups and seamlessly promotes the installation to Mode 4 (`TotalProtection`).

---

## 5. Intelligent Runner Location Shift & Execution Handoff

WINBARS features centralized execution handoff logic to prevent common field problems where technicians or users run from a portable USB drive on a computer where WINBARS is already permanently provisioned:

* **Automated & Scheduled Task Handoff**:
  When invoked via automated switches (`-Action`, `-Tray`, `-AutoHeal`, `-Unattended`) from a removable drive (e.g. `E:\WINBARS\WINBARS.exe`), WINBARS automatically inspects `C:\Tools\WINBARS\WINBARS.exe`. If a permanent local installation exists, execution is transparently transferred to the local binary with all arguments preserved. This guarantees that background jobs and Windows Task Scheduler triggers **never fail or get stranded** when the USB drive is detached.

* **Interactive Location Shift Pivot**:
  When launched interactively from a portable drive on an already-provisioned PC, WINBARS presents an instant 1-click pivot banner:
  1. `[1] Shift to Installed Suite at C:\Tools\WINBARS (Recommended)`: Launches the local installation and terminates the portable process.
  2. `[2] Update Local Installation with this USB Version`: Overwrites local binaries in `C:\Tools\WINBARS` with the updated files from the USB drive and refreshes scheduled tasks.
  3. `[3] Continue Running Portably from USB`: Operates in temporary Zero-Footprint mode without touching the local install.

* **Task Scheduler Permanent Anchoring**:
  Regardless of where `Install-SuiteTasks` is invoked from, registered scheduled tasks (`\WinRestoreBackup\`) are always anchored to the permanent local binary (`C:\Tools\WINBARS\WINBARS.exe`).

---

## 7. Storage Capacity Warning & Low Space Alert Controls

WINBARS features flexible capacity alert controls to prevent intrusive alarms when using high-capacity external drives:

* **Realistic Headroom Guard**:
  External drives with **$\ge 25$ GB free** (such as drives with 356 GB available) are never flagged as "Too Small" or blocked from baseline file synchronization.
* **Image-Aware Sizing Math**:
  Drive tier recommendations dynamically check whether external system images are enabled (`EnableExternalImageBackup`). For routine personal file synchronization, multi-image DISM retention is omitted from the base calculation, preventing premature 2 TB tier recommendations.
* **Drive Capacity Warnings Toggle (`EnableDriveCapacityWarnings`)**:
  - **WinForms GUI**: Accessible in **Settings** (`Ctrl+Win+W`) -> **General** -> **Sentry Notifications & Audio Alarms** via the checkbox:
    `[x] Enable external backup drive capacity & low-space warnings`
  - **CLI Submenu**: Accessible via Setup Menu -> **`[N]` Sentry, Notifications & Security Protection Settings** -> Option **`[8]`**:
    `[8] Backup Drive Capacity Warnings: [ENABLED / DISABLED (Suppress Alerts)]`
  - **When Disabled**:
    - Suppresses "Backup Drive Low on Space" Action Center toasts and balloon tips.
    - Suppresses generation of `[!] BACKUP_DRIVE_TOO_SMALL.txt` warning notes.
    - Allows baseline backup passes to proceed smoothly down to the physical safety corruption floor ($> 2$ GB).

### Removable Media & Technician Audit Logging
When operating from a technician USB drive, WINBARS automatically records and aggregates all audit trails:
- **Master USB Audit Vault**: Appends all provisioning, mode changes, and execution results to:
  `{USB_DRIVE}:\WINBARS\Logs\Audits\<COMPUTERNAME>_<USERNAME>_<YYYYMMDD>.log`
- **Pre-Flight Menu Toggles**:
  - `[K]` : Toggle Desktop & Start Menu Shortcuts (Clean placement vs 100% stealth suppression)
  - `[B]` : Toggle Immediate Baseline Image Capture (`.wim`) upon deployment
  - `[9]` : Auto-enabled Custom Partner Branding when `branding.json` is present
- **Single-Drive Cloaking Guardrail**:
  - Drive cloaking (`[H]`) is automatically disabled on systems without a dedicated secondary partition or external drive to protect system visibility.

---

## 8. Turnkey One-Click Batch Launchers (`.bat`)

WINBARS includes pre-packaged Windows Command Scripts (`.bat`) in `installers/` and `tools/` for rapid technician field deployment and USB usage without launching the full interactive menu:

| Batch Launcher | Target Profile / Operation | CLI Equivalent | Interactive Prompts | Unattended Switches Supported |
| :--- | :--- | :--- | :---: | :--- |
| `Run-WINBARS.bat` | Main Interactive Launcher & Privilege Escalation | `WINBARS.exe` | Menu | N/A (Interactive Hub) |
| `installers/Install-Mode0-ZeroFootprint.bat` | Mode 0: Zero Footprint (100% native Windows engines) | `-SetProfile ZeroFootprint -Vanilla -Unattended` | 2 | `/?`, `/Quiet`, `/Vanilla`, `/Data:<Path>`, `/Image:<Path>` |
| `installers/Install-ModeN-NearZeroFootprint.bat` | Mode N: Near-Zero Footprint (Stealth native automation) | `-SetProfile NearZeroFootprint -Vanilla -Unattended` | 2 | `/?`, `/Quiet`, `/Vanilla`, `/Data:<Path>`, `/Image:<Path>` |
| `installers/Install-Mode1-SystemUndo.bat` | Mode 1: System Undo (Daily restore points & VSS auto-heal) | `-SetProfile Minimal -Vanilla -Unattended` | **1** | `/?`, `/Quiet`, `/Vanilla`, `/Baseline:Y\|N` |
| `installers/Install-Mode2-LocalDisasterGuard.bat` | Mode 2: Local Disaster Guard (Local partition DISM image) | `-SetProfile LocalDisasterGuard -Vanilla -Unattended` | **0** | `/?`, `/Quiet`, `/Vanilla`, `/Brand:"Name"` |
| `installers/Install-Mode3-HeadlessFull.bat` | Mode 3: Headless Full (Silent Robocopy + images) | `-SetProfile HeadlessFull -Vanilla -Unattended` | 2 | `/?`, `/Quiet`, `/Vanilla`, `/Brand:"Name"`, `/Data:<Path>`, `/Image:<Path>` |
| `installers/Install-Mode4-TotalProtection.bat` | Mode 4: Total Protection (Tray sentry + Scam Buster) | `-SetProfile TotalProtection -Vanilla -Unattended` | 2 | `/?`, `/Quiet`, `/Vanilla`, `/Brand:"Name"`, `/Data:<Path>`, `/Image:<Path>` |
| `installers/Uninstall.bat` | Complete Suite & Task Removal | `-Uninstall -Unattended` | **0** | `/?`, `/Quiet` |
| `tools/Capture-Baseline.bat` | Capture Permanent Baseline System Image (`_baseline.wim`) | `-Action SystemImage -Baseline -Unattended` | 1 | `/?`, `/Quiet`, `/Pin:Y\|N`, `/Label:"Text"` |
| `tools/Create-RestorePoint.bat` | Immediate Atomic System Restore Point | `-Action RestorePoint -Unattended` | **0** | `/?`, `/Quiet`, `/Pin:Y\|N`, `/Label:"Text"` |
| `tools/Toggle_Backup_Drive_Visibility.bat` | Cloak or Unhide Backup Volume in File Explorer | `-ToggleDriveCloaking` | **0** | `/?` |
| `tools/Apply-SystemImage_WinPE.bat` | WinRE / WinPE Bare-Metal System Image Restore | N/A (Native DISM / BCDBoot) | Dynamic | Interactive |
| `tools/Create-RescueUSB.bat` | Create Dedicated UEFI Bootable Rescue USB Media | `-RescueUsb` | 1 | `/?`, `/Quiet`, `/Drive:<Letter>`, `/DryRun` |
| `tools/Reset-Suite.bat` | Factory Reset Configuration & Tasks (Re-provision PC) | `-ResetSuite -Unattended` | 1 | `/?`, `/Quiet`, `/Force` |
| `tools/Generate-MasterKey.bat` | Generate BitLocker DRA Master Key Pair | `-GenerateMasterKey` | Dynamic | Interactive |
| `tools/Unlock-BitLocker-With-MasterKey.bat` | Unlock BitLocker Volume via Master Key (.pfx) | `-UnlockMasterKey` | Dynamic | Interactive |
| `tools/Verify-MasterKey-Password.bat` | Safely Verify Master Key (.pfx) Passphrase | N/A (Offline validation) | Dynamic | Interactive |
| `tools/Whitelist-WINBARS.bat` | Configure Windows Defender Whitelist Exclusions | N/A (Defender Exclusions) | **0** | `/?`, `/Quiet` |

### Batch Switch Reference Guide

All batch installers accept standard Windows command syntax (case-insensitive):

| Switch | Description | Example |
| :--- | :--- | :--- |
| **`/?`** or **`/Help`** | Displays built-in usage and parameter help banner. | `installers\Install-Mode4-TotalProtection.bat /?` |
| **`/Quiet`** or **`/Q`** | Non-interactive mode; suppresses pause prompts and executes unattended. | `installers\Install-Mode1-SystemUndo.bat /Quiet` |
| **`/Reset`** | Factory resets prior tasks, drive pairings & config before applying target mode. | `installers\Install-Mode3-HeadlessFull.bat /Reset /Quiet` |
| **`/Vanilla`** | Enforces unbranded deployment even if a `branding.json` token is present. | `installers\Install-Mode3-HeadlessFull.bat /Vanilla /Quiet` |
| **`/Brand:"Name"`** | Applies a specific branding token (e.g. `Acme`, `Acme.json`, or `"C:\Keys\shop.json"`). | `installers\Install-Mode4-TotalProtection.bat /Brand:"Acme PC" /Quiet` |
| **`/Data:<Path>`** | Sets target directory or drive for personal user files. Accepts drive letters (`D:`) or full paths (`"D:\Backups"`). | `installers\Install-Mode0-ZeroFootprint.bat /Data:D:\UserData /Quiet` |
| **`/Image:<Path>`** | Sets target directory or drive for bare-metal DISM system images. Accepts drive letters (`E:`) or full paths (`"E:\Images"`). | `installers\Install-Mode3-HeadlessFull.bat /Image:E:\Images /Quiet` |
| **`/Baseline:Y\|N`** | Enables (`Y`) or skips (`N`) capturing an immediate baseline system image during Mode 1 setup. | `installers\Install-Mode1-SystemUndo.bat /Baseline:Y /Quiet` |
| **`/Pin:Y\|N`** | Pins the restore point permanently against rolling retention FIFO purge. | `tools\Create-RestorePoint.bat /Pin:Y /Label:"Pre-Tuneup" /Quiet` |
| **`/Label:"Text"`** | Attaches a custom description label to the restore point or baseline image. | `tools\Capture-Baseline.bat /Label:"Clean_Install_Win11" /Quiet` |

### 1-Line Field Automation Examples
```cmd
REM Unattended Mode 0 (Zero-Footprint) targeting drive D: for both data and bare-metal images:
installers\Install-Mode0-ZeroFootprint.bat /Data:D: /Image:D: /Quiet /Vanilla

REM Silent Mode 1 (System Undo) bench warranty tune-up with permanent baseline image:
installers\Install-Mode1-SystemUndo.bat /Baseline:Y /Quiet

REM Branded Mode 4 deployment for client workstation with custom backup locations:
installers\Install-Mode4-TotalProtection.bat /Data:D:\UserData /Image:D:\Images /Brand:"TechPros" /Quiet

REM Non-interactive complete uninstallation and task cleanup:
installers\Uninstall.bat /Quiet
```

---

## 9. Technician Hotkey Configuration & Dynamic Win32 Collision Probing

In `v0.9.0`, hotkeys are fully customizable via Tech Mode in `config.json` (`Hotkeys` section) or via CLI Setup Menu (`[N] Sentry, Notifications & Security Protection Settings` -> Option `[K]`):

### Default Hotkeys
- **Protection Center Dashboard**: `Ctrl+Win+W`
- **Scam Buster Emergency Break**: `Ctrl+Win+B`
- **Quick Assist Remote Support**: `Ctrl+Win+Q` *(Fallback: `Ctrl+Win+A`)*

### Dynamic Collision Probing (`Test-HotkeyComboAvailable`)
Before binding hotkeys, the Floppy Tray Sentry runs an unmanaged Win32 P/Invoke probe (`RegisterHotKey` / `UnregisterHotKey` against a hidden message window):
- **Conflict Prevention**: If a key combination is already reserved by Windows or another application (e.g. `Ctrl+Win+Q` reserved by Microsoft Quick Assist), WINBARS detects the collision and prevents silent registration failures.
- **AltGr Protection**: `Alt` and `Ctrl+Alt` combinations are strictly prohibited by policy to prevent collision with dead-key accents on European and international keyboard layouts.

---

## 11. Windows Health Check (SFC / DISM)

On-demand and scheduled system file integrity scanning using native Windows tools (`sfc.exe` → `DISM.exe`).

| Switch | Parameters | Description |
| :--- | :--- | :--- |
| `-WindowsHealthCheck` | — | Runs SFC + optional DISM scan interactively with live progress window. Respects `IntervalDays` frequency cap. |
| `-CheckWindowsHealth` | — | Alias for `-WindowsHealthCheck`. |
| `-EnableHealthCheck` | — | Enables the scheduled Windows Health Check task (writes `WindowsHealthCheck.Enabled = true` to config and re-registers Task Scheduler task). |
| `-DisableHealthCheck` | — | Disables the scheduled task and writes `WindowsHealthCheck.Enabled = false` to config. |
| `-NoHealthCheckRestorePoint` | — | Disables creation of the safety restore point checkpoint before running SFC/DISM scans. |
| `-ConfigureHealthCheck` | `-HealthCheckInterval <days>` | Sets minimum days between health check runs (`IntervalDays`). |
| `-ConfigureHealthCheck` | `-HealthCheckTime <HH:mm>` | Sets fixed daily trigger time for Modes 1-4 and Mode N (e.g. `03:00`). |
| `-ConfigureHealthCheck` | `-HealthCheckIdle <minutes>` | Sets idle threshold in minutes before triggering a run when in Idle mode (e.g. `15`, `30`, `45`, `60`). |
| `-ConfigureHealthCheck` | `-HealthCheckMode <mode>` | Sets trigger mode: `Daily`, `Weekly`, or `Idle`. |

### Scheduled Task Details

| Mode | Task Path | Task Name | Trigger |
| :--- | :--- | :--- | :--- |
| **Mode 0** | *None* | *None* | ❌ Forensic Sterility (0 host tasks) |
| **Mode N** | `\WindowsBackup\` | `WindowsHealthCheck` | Daily at `ScheduledTime` (default 03:00, configurable) |
| **Mode 1** | `\WinRestoreBackup\` | `WinRestoreBackup_WindowsHealthCheck` | Daily at `ScheduledTime` (default 03:00, configurable) |
| **Mode 2** | `\WinRestoreBackup\` | `WinRestoreBackup_WindowsHealthCheck` | Configurable: Daily, Weekly, or Idle (default 30m idle) |
| **Mode 3** | `\WinRestoreBackup\` | `WinRestoreBackup_WindowsHealthCheck` | Configurable: Daily, Weekly, or Idle (default 30m idle) |
| **Mode 4** | `\WinRestoreBackup\` | `WinRestoreBackup_WindowsHealthCheck` | Configurable: Daily, Weekly, or Idle (default 30m idle) |

All tasks run as `NT AUTHORITY\SYSTEM`, `RunLevel = Highest`, `StartWhenAvailable = false` (skip if missed).

---

## 12. Windows Event Log Integration

WINBARS writes structured events to the Windows Application Event Log for auditing and fleet management.

| Switch | Parameters | Description |
| :--- | :--- | :--- |
| `-EnableEventLog` | — | Enables Event Log writes (`EventLog.Enabled = true`). |
| `-DisableEventLog` | — | Disables Event Log writes (`EventLog.Enabled = false`). |
| `-ConfigureEventLog` | `-SourceName <name>` | Sets the Event Log source name (e.g. `"TechPros PC Care"`). Re-registers the source if admin elevation is available. |

### Mode Defaults

| Mode | Event Log Default | Source Registration |
| :--- | :--- | :--- |
| Mode 0 | ❌ OFF (cannot be enabled) | Never registered (zero-footprint contract) |
| Mode N | ✅ ON | Registered at deployment |
| Mode 1 | ✅ ON | Registered at deployment |
| Mode 2 | ✅ ON | Registered at deployment |
| Mode 3 | ✅ ON | Registered at deployment |
| Mode 4 | ✅ ON | Registered at deployment |

---

## 13. Routine Backup & Restore Point Schedule Configuration

Quickly reconfigure routine daily restore points and sync schedules for Modes 1-4 and Mode N without re-running interactive setup.

| Switch | Parameters | Description |
| :--- | :--- | :--- |
| `-ConfigureSchedule` / `-SetSchedule` | `-DailyTime <HH:mm>` | Sets the daily restore point execution time in 24-hr format (e.g. `09:00`, `21:30`). Updates Task Scheduler immediately. |
| `-ConfigureSchedule` / `-SetSchedule` | `-Frequency <Daily\|Weekly\|Startup>` | Sets the recurrence trigger for restore points. |

### Source Name Resolution Priority

1. `EventLog.SourceName` in `config.json` (explicit override)
2. `Branding.ShopName` in `config.json` (white-label branding token)
3. Default: `"WINBARS"`

> 📖 *For the complete Event ID table and health check escalation diagram, see [Windows Health Check](WINDOWS_HEALTH_CHECK.md).*

