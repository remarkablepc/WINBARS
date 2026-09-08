# WINBARS Command-Line Interface (CLI) Reference (v0.7.43)

## 1. Quick Syntax Overview

`cmd
WINBARS.exe [-Action <ActionName>] [-Profile <ProfileName>] [Operational Switches]
`

All switches can be passed with standard PowerShell syntax (-Switch) or Windows command prompt syntax (/Switch).

---

## 2. Primary Actions (-Action <name>)

| Action Switch | Description | Automated / Unattended |
| :--- | :--- | :---: |
| -Action FastBackup | Runs daily fast backup pass: mirrors personal files + creates System Checkpoint. [⚡ 1-Click: Backup My Files Now] | WINBARS.exe -Action FastBackup -Unattended |
| -Action RestorePoint | Creates a hardened, atomic Windows System Restore Point checkpoint. Use `-Baseline` for immortal driver/hardware checkpoint. | WINBARS.exe -Action RestorePoint -Baseline -Description "Pre-Driver Fix" |
| -Action FileHistory | Runs multi-threaded unbuffered Robocopy personal file synchronization. | WINBARS.exe -Action FileHistory -Unattended |
| -Action SystemImage | Captures a full bare-metal DISM system image archive (.wim). Use `-Baseline` to tag as permanent master (`_baseline.wim`). | WINBARS.exe -Action SystemImage -Baseline -Unattended |
| -Action All | Runs a complete multi-pass backup (Restore Point, File Mirror, DISM Image). | WINBARS.exe -Action All -Unattended |
| -Action AutoHeal | Runs a 2-second silent scan to self-heal Windows VSS & SystemProtection. | WINBARS.exe -Action AutoHeal -Unattended |
| -Action VerifyFix | Runs full diagnostic self-test and auto-repairs broken scheduled tasks. | WINBARS.exe -VerifyFix |
| -Action Preflight | Evaluates system storage, power state, and volume readiness. | WINBARS.exe -Preflight |
| -Action BackupBCD | Exports atomic BCD boot hive, plaintext audit log, and WinPE rescue batch script. | WINBARS.exe -Action BackupBCD -Unattended |
| -Action UpdateTriggers | Synchronizes installed Task Scheduler triggers to match current config without full reinstall. | WINBARS.exe -Action UpdateTriggers |
| -Action RestoreBCD | Launches interactive BCD bootloader recovery tool. | WINBARS.exe -Action RestoreBCD |

---

## 3. Deployment Profile Selectors (-SetProfile <name>)

WINBARS provides a unified 6-profile deployment architecture (Modes 0, N, 1, 2, 3, 4) plus dynamic Custom Profiles (Mode 5+):

| Mode & CLI Name | Aliases | Operational Behavior (`BACKS UP` & `OMITS`) | Resident Footprint | Hotkeys & WinPE Recovery Hooks | Tray & ScamBuster Watchdog |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **Mode 0: `ZeroFootprint`** ⭐ | `0` | **BACKS UP**: Daily System Restore, User Data (Robocopy Mirror + 30-Day Retention), Bare-Metal Image (wbadmin), BitLocker Keys.<br>**OMITS**: Zero files on PC, no tray, no watchdog, no shortcuts. Pure native Windows engine. | **0 Bytes on PC** *(Configured on-demand; automated tasks run autonomously via native Windows engines)* | ❌ Zero host files (Configured on-demand) | ❌ None *(Pure Native Windows Engine)* |
| **Mode N: `NearZeroFootprint`** 👻 | `NearZero`, `N` | **BACKS UP**: Daily System Restore, User Data (Robocopy Mirror to `E:\WindowsBackup\` + 30-Day Retention), Bare-Metal Image (wbadmin), BitLocker Keys.<br>**OMITS**: Zero resident EXEs/daemons on host. Standard unbranded desktop shortcuts (`Backup Personal Files`, `Windows System Restore`, `Browse Backup Files`) + generic `System Backup & Recovery` Start Menu folder. Restores via native Explorer & WinRE. Complete stealth anti-competitor defense. | **0 Resident EXEs** *(100% native Task Scheduler)* | ❌ Zero host EXEs (Native `powershell.exe` & `rstrui.exe` shortcuts) | ❌ None *(Pure Native Windows Engine)* |
| **Mode 1: `SystemUndo`** ⏪ | `Minimal`, `1` | **BACKS UP**: Daily System Restore (unthrottled), VSS Writer Auto-Heal & Shadow Storage Guard, Driver/MSI install checkpoints.<br>**OMITS**: No user data sync, no bare-metal images, no tray, no watchdog. | Local Suite (< 5 MB RAM) | ✅ **WinPE Boot Hooks** • **Panic Hotkey (`Ctrl+Win+B`)** • **Start Menu Suite** | ❌ Silent background execution |
| **Mode 2: `LocalDisasterGuard`** 💽 | `2` | **BACKS UP**: [Mode 1 +] Local secondary/partition bare-metal DISM image (`.wim`) for offline recovery without an external drive.<br>**OMITS**: No external drive sync, no personal file mirror, no tray, no watchdog. | Local Suite | ✅ **WinPE Boot Hooks** • **Panic Hotkey (`Ctrl+Win+B`)** • **Start Menu Suite** • **Desktop System Image** | ❌ Silent background execution |
| **Mode 3: `HeadlessFull`** 🏢 | `3` | **BACKS UP**: [Mode 1 +] Daily differential Robocopy sync, scheduled bare-metal images, multi-drive rotation, **missing drive connection prompts**.<br>**OMITS**: No floppy tray icon, no active ScamBuster watchdog, no desktop GUI. Defaults to Shop Branding (unless `-Vanilla`). | Local Suite | ✅ **WinPE Boot Hooks** • **Panic Hotkey (`Ctrl+Win+B`)** • **Drive Alerts** | ❌ Silent Task Scheduler operation |
| **Mode 4: `TotalProtection`** 🛡️ | `FullInteractive`, `4` | **BACKS UP**: [Mode 3 +] Complete personal files, bare-metal images, restore points, drive alerts.<br>**OMITS**: Zero Omissions (complete interactive protection suite). Defaults to Shop Branding (unless `-Vanilla`). | Local Suite (~18 MB RAM) | ✅ **WinPE Boot Hooks** • **Panic Hotkey (`Ctrl+Win+B`)** • **Protection Center GUI** | ✅ **Floppy Tray Icon** • **ScamBuster Active Watchdog** |
| **Mode 5+: Custom Profiles** 🛠️ | `<Name>`, `5+` | Configured via Pre-Flight builder or `custom_profiles.json`. `BACKS UP` and `OMITS` calculated dynamically based on active component flags. | Configurable | Configurable | Configurable |

### 🎯 Technician Customer Persona Cheat Sheet (3-Second Decision Matrix)
Need to know which profile to pick for a customer in 3 seconds? Use this cheat sheet:

| Profile | Customer / Machine Persona | Real-World Technician Scenario & Why It Fits |
| :--- | :--- | :--- |
| **Mode 0: `ZeroFootprint`** | **Strict Corporate Audits & MSP Sterile Compliance** | Corporate clients or regulated workstations where security policy strictly forbids leaving any third-party files or scripts on `C:\`. The entire runner script and logs reside on the technician's external drive. |
| **Mode N: `NearZeroFootprint`** | **Corporate Clients & Anti-Competitor Stealth Shield** | Corporate clients or businesses burned by prior IT competitors. You want recurring automation without revealing WINBARS to competing IT shops who might try to poach the account. **Zero background EXEs**, native Task Scheduler jobs (`\WindowsBackup\`), generic external folder (`E:\WindowsBackup\`), and generic shortcuts (`System Backup & Recovery`). Restores via native Explorer & WinRE. |
| **Mode 1: `SystemUndo`** ⏪ | **Family Members, Casual Users & Gamers** | Users who don't have an external backup drive but frequently install game mods, experimental drivers, or software that risks Windows stability. Gives them unthrottled daily restore points, VSS auto-healing, and the `Ctrl+Win+B` emergency panic hotkey. |
| **Mode 2: `LocalDisasterGuard`** 💽 | **Road Warriors, Students & Mobile Laptops** | Traveling sales reps and laptop users who rarely plug in an external drive. Backs up a monthly bare-metal DISM system image (`.wim`) to a local recovery partition for full offline restore in the field. |
| **Mode 3: `HeadlessFull`** 🏢 | **Silent Workstations, Accounting & Medical Clinics** | Production office environments (CPA firms, dental clinics, law offices) with dedicated external hard drives. Runs full daily Robocopy sync and bare-metal imaging 100% silently in the background with zero desktop clutter or user prompts—alerting only if the drive is unplugged. |
| **Mode 4: `TotalProtection`** 🛡️ | **Seniors, VIPs & Scam-Prone Non-Technical Clients** | Grandparents, non-technical clients, or high-value VIPs frequently targeted by browser pop-ups, fake virus sirens, and phone support scammers. Features the Floppy Disk Tray icon, active real-time ScamBuster and Remote Tool Interceptor (`[STOP] Disconnect & Block`), live GUI Protection Center, and your shop's emergency support hotline branding. |
| **Mode 5+: `Custom Profiles`** | **Specialized Enterprise & Boutique Deployments** | Tailored multi-drive configurations, specialized network shares, or specific retention tiers configured via `custom_profiles.json` or the Pre-Flight interactive builder. |

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
  * `[0]` Defuse Deceptive OneDrive 'Not Backed Up' Nags
* **Target Drive Selection (`[C]`)**: Inspect available logical drives and change the destination letter.
* **Save as Custom Profile (`[S]`)**: Persist custom component tweaks as a named profile in `custom_profiles.json`.
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
| -SetProfile <Profile> | Applies specified deployment profile (ZeroFootprint, NearZeroFootprint, Minimal, LocalDisasterGuard, HeadlessFull, FullInteractive) non-interactively. |
| -DefuseOneDriveNags | Surgically silences deceptive Windows / OneDrive 'Not Backed Up' scare banners & KFM takeover. |
| -RestoreOneDriveNags | Restores standard Windows / OneDrive notification and folder defaults. |
| -ScamBuster | Terminates rogue browser lockups, silences sirens, and clears reload traps (Ctrl+Win+B). |
| -QuickAssist | Launches Microsoft Quick Assist with store contact branding (Ctrl+Win+Q). |
| -ListBackupDrives | Displays formatted table of all registered backup destinations, total space, free space, roles, and online health. |
| -AddBackupDrive <Path> | Registers a backup destination drive letter (e.g. `E:`) or custom directory path (e.g. `E:\Backups`). |
| -RemoveBackupDrive <Path> [-Force] | Removes a backup destination. Enforces 1-Drive Minimum Guardrail (requires `-Force` for technician override). |
| -SetPrimaryBackupDrive <Path> | Designates a backup drive/path as Primary. |
| -Baseline | Captures an immortal Day-1 baseline restore point or bare-metal system image (`_baseline.wim`). Excluded permanently from retention rotation. |
| -Description <Text> | Specifies a custom hardware or repair label for baseline restore points (e.g., `-Description "Pre-I2C Mouse Fix"`). |
| -MaxRetentionOverride <N> | Overrides default system image retention rotation count (default: 1 on `C:`, 2 on external storage). |
| -StatusCard / -GUI | Opens the GUI Protection Center Live Dashboard (Ctrl+Win+W). |
| -Console / -Menu | Launches the interactive technician CLI console. |
| -Tray | Launches the background Floppy Tray Sentry in the Windows notification area. |
| -InstallTray | Registers Floppy Tray Sentry to start automatically at user logon. |
| -UninstallTray | Removes Floppy Tray Sentry from Windows startup. |
| -CreateShortcuts | Creates Desktop Shortcuts (4 Action shortcuts in Managed mode; native schtasks shortcuts in Zero-Footprint). |
| -ToggleDriveCloaking | Toggles backup drive letter visibility in Windows Explorer ('This PC') on/off. |
| -HideBackupDrive | Cloaks the backup target drive letter in Windows Explorer via native NoDrives policy. |
| -ShowBackupDrive | Uncloaks and restores backup target drive visibility in Windows Explorer. |
| -EmergencyCard | Generates printable BitLocker Disaster Recovery Emergency Card (.html). |
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
| -Help / -? | Displays full command-line reference directly in the terminal. |

---

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
* **Silent Bare-Metal Local Fallback (`C:\SystemImages`)**: If no secondary or external drive is attached during a scheduled image pass, WINBARS captures the bare-metal DISM image cleanly to `C:\SystemImages` without raising false-alarm warning toasts.

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
