# Agentless Zero-Footprint Architecture & Technical Resiliency

The **Agentless Zero-Footprint profile (Mode 0)** and **Near-Zero Footprint profile (Mode N)** were engineered specifically for computer repair technicians, managed service providers (MSPs), and security auditors who require recurring, resilient disaster protection on a customer's or corporate workstation **without leaving third-party background software, resident executables, or persistent scripts on the target machine (`C:\`)**.

All automated routines execute autonomously via native Windows Task Scheduler using standard Windows binaries (`robocopy.exe`, `wbadmin.exe`, `vssadmin.exe`, `powershell.exe`). All auxiliary scripts, logs, and configuration state reside **strictly on the external backup storage drive**.

---

## 🌟 12 Core Pillars of the Zero-Footprint Engine

### 1. 0 Resident Third-Party Binaries on Target Machine (`C:\`)
* No `WINBARS.exe`, no background daemons, and no persistent scripts reside on `C:\`.
* The primary automated runner script (`Run-ZeroFootprintSync.ps1`) and backup logs (`Sync_History.log`) reside entirely within `\Backup_Logs\` on the external backup drive.
* If the external backup drive is unplugged, the target host contains zero resident third-party code.

### 2. 100% Native Windows Task Scheduler Automation
* Tasks are registered cleanly in the root `\WindowsBackup\` folder executing under `NT AUTHORITY\SYSTEM`:
  * **`\WindowsBackup\SystemRestorePoint`**: Runs daily at configured time + system startup. Disables Windows 24-hour throttling (`SystemRestorePointCreationFrequency = 0`) and guarantees 10%–15% VSS shadow storage headroom.
  * **`\WindowsBackup\UserProfileSync`**: Runs daily to mirror `C:\Users` (and any configured secondary paths) directly to the external drive.
  * **`\WindowsBackup\SystemImageBackup`**: Runs monthly via native `wbadmin.exe` capturing bare-metal DISM system images.

### 3. Dynamic Drive Drift Shield (Hardware Auto-Discovery)
* When external USB drives are unplugged and reconnected, Windows often reassigns different drive letters (e.g. `D:` shifts to `E:` or `F:`).
* The Task Scheduler runner dynamically queries `Win32_LogicalDisk` for the signature marker (`\Backup_Logs\Run-ZeroFootprintSync.ps1` or `.winbars_target`), automatically resolving the active drive letter on the fly with zero dropped backups.

### 4. Smart 1:1 Robocopy Mirror with Active Volume Shadow Copy (VSS) Mount
* **Bypassing Exclusively Locked Files**: Robocopy `/ZB` uses backup privilege tokens to bypass NTFS ACLs, but it cannot read files held under exclusive write locks by active applications (e.g., active Outlook `.pst`/`.ost` stores, running browser SQLite databases like Chrome/Edge `History`, or active virtual disks).
* **Automated VSS Mountpoint (`mklink /D`)**: WINBARS automatically binds live Robocopy passes directly to a temporary Volume Shadow Copy snapshot mount (`New-VssSnapshotMount` via `Win32_ShadowCopy` and `mklink /D`).
* Robocopy mirrors cleanly from the frozen snapshot volume, guaranteeing 100% consistent reads with zero locked-file errors. Once the mirror pass completes, the temporary junction and shadow copy are cleanly dismounted and released.
* **Accidental Deletion Protection (`_DeletedArchive`)**: Before mirroring, a non-destructive pre-scan moves any files deleted or modified on the PC into timestamped isolation folders (`_DeletedArchive\YYYY-MM-DD\`). Expired archives (> 30 days) are pruned automatically.
* **Low Disk Space Headroom Guard**: If the backup drive drops below 10 GB free, an accelerated prune cleans archives older than 7 days; if space drops below 2 GB, the sync pauses safely to protect data integrity.

### 5. Conflict-Safe Smart Swap & Race Condition Shield
* **Bi-Directional USB Editing**: When users edit documents directly on the external backup drive while away from the office, WINBARS detects the newer timestamp upon connection.
* **Active File-In-Use Detection (Race Condition Shield)**: Before moving or replacing any file on the PC, WINBARS performs an active kernel file-sharing test (`[System.IO.File]::Open` checking for sharing violations).
  * **If Document Is Open/Locked on PC**: If the user left the document open in Word or Excel on the PC while editing a copy on the USB, WINBARS **never overwrites or moves** the live document. Instead, it generates a machine-identity and timestamped conflict copy alongside it:
    `FileName (Conflict from USB - <COMPUTERNAME> - YYYY-MM-DD_HHmmss).ext`, logs a warning, and issues a native Windows Toast alert.
  * **If Document Is Closed**: The older PC copy is safely archived as:
    `FileName (Older PC Copy - <COMPUTERNAME> - YYYY-MM-DD).ext` and mirrored into `_DeletedArchive`, before promoting the newer USB file to active.

### 6. USB-Hosted RegBack & Native WinPE Rescue Script
* Every backup pass creates an offline, atomic registry hive snapshot (`SYSTEM`, `SOFTWARE`, `SAM`, `SECURITY`, `DEFAULT`) in `D:\Backup_Logs\Registry_Snapshots\Latest\`.
* **WinPE / WinRE Rescue Script (`Restore_Registry_WinPE.bat`)**: A standalone, zero-dependency batch script generated directly inside the registry snapshots folder. If Windows blue-screens or fails to boot, open Command Prompt in Windows Recovery Environment (`Shift + F10`), run the script from the USB, and restore clean registry hives in 5 seconds with dynamic Windows drive detection.
* Enables native Windows automatic RegBack key (`EnableRegistryBackup = 1`).

### 7. Boot Configuration Data (BCD) Backup & 1-Click WinRE Rescue Subsystem
* Generates atomic binary BCD hives (`BCD_Backup`) and plaintext human-readable configuration ledgers (`BCD_Configuration_Audit.txt`) alongside System Restore points and on external USB drives (`Boot_Rescue\`).
* **1-Click WinRE Rescue Batch Script (`Restore_BCD_WinPE.bat`)**: Resolves BSOD bootloops, corrupted BCD stores, and missing bootloader entries directly from Windows Recovery Environment Command Prompt with dynamic drive detection and automated `bcdboot` fallback rebuilding.

### 8. Automated BitLocker Recovery Key Archival
* Automatically discovers active BitLocker encryption keys across all fixed drives and archives the 48-digit numerical passwords to `D:\BitLocker_Recovery_Key.txt` and `D:\Backup_Logs\BitLocker_Recovery_Key.txt`.
* If a motherboard swap, TPM glitch, or BIOS update locks the machine, the user can read their recovery password from the USB drive on any smartphone, tablet, or secondary PC.

### 9. Explorer Cloaking & Drive Stealth Architecture
* Prevents non-technical users from accidentally deleting backup files or getting confused by external drive letters by hiding the backup volume in Windows Explorer (`This PC`) via native `NoDrives` policy.
* Scheduled tasks, Robocopy, and `wbadmin` continue accessing the cloaked drive normally in the background.
* **1-Click USB Toggle Script (`Toggle_Backup_Drive_Visibility.bat`)**: Located right on the root of the USB drive. Anyone with physical access can double-click this script to instantly cloak or uncloak the drive on any PC without installing any software.

### 10. Unbranded Disaster Recovery Guide (`README_RECOVERY.txt`)
* A clear, unbranded plain-text document created at the root of the backup drive detailing step-by-step instructions for 1:1 file restoration, recovering deleted files from `_DeletedArchive`, running WinRE registry rollback, and bare-metal imaging.

### 11. Configurable Native Toast Notifications
* Clean Windows 10/11 native toast notifications without any background processes:
  * **`All`** (Default): Toast notifications on backup completion, warnings, or errors.
  * **`WarningsAndErrors`**: Completely silent on success; notifies only if an error or low space occurs.
  * **`Disabled`** (Stealth Mode): Zero notifications; all execution details logged strictly to file.

### 12. Technician Audit Profile & USB Adjustment Menu
* Setup saves client metadata to `ZeroFootprint_Profiles\<COMPUTERNAME>.json` on the technician's USB drive.
* Reconnecting the USB drive to the workstation and launching WINBARS automatically detects the machine's profile and opens the **Zero-Footprint Adjustment Menu** (`[P]`), allowing quick adjustments to sources, schedules, notification modes, drive cloaking, or clean uninstallation.

---

## 🔧 Technical Resiliency Engine: 5 Failure-Mode Defenses

To guarantee enterprise-grade survivability without bloated third-party drivers or black-box agents, WINBARS incorporates five defensive engineering patterns:

1. **Mid-Sync Disconnect Defense (USB Yank / Sudden Power Loss)**:
   - **Atomic Staging (Write-Temp-Then-Swap)**: All JSON configurations, manifests, and telemetry are written to `.tmp.<guid>`, verified for byte-size, and swapped atomically.
   - **Robocopy Restartable Mode (`/ZB`)**: Uses packet-level restartable mode with automatic backup token fallback. If a 40 GB Outlook `.pst` or virtual disk is disconnected mid-stream, Robocopy resumes from the exact packet on the next pass rather than restarting from zero.
   - **Transaction Canary (`.winbars_sync_in_progress`)**: Dropped at the target drive root before mirroring starts. If an abrupt disconnect occurs, WINBARS detects the canary on the next boot, alerts the desktop, and executes a full recovery sweep.

2. **Orphaned VSS & Junction Point Hygiene**:
   - **Strict `try/finally` Lifecycle**: Snapshot creation, junction mounts (`C:\ProgramData\WINBARS\VssMount_*`), read routing, and teardowns are enclosed in an unskippable `try { ... } finally { Dismount-Vss; Remove-Canary }` construct.
   - **Startup Garbage Collector (`Clean-OrphanedVssMounts`)**: Proactively scans for and unmounts lingering directory junctions via native `cmd /c rmdir`, and purges unmanaged temporary shadow copies older than 24 hours.
   - **Native COM Self-Repair (`Repair-WinbarsVssSubsystem`)**: If third-party backup software leaves broken COM provider keys, WINBARS re-registers native Windows VSS DLLs (`ole32.dll`, `vss_ps.dll`, `swprv.dll`) in-memory without requiring an OS reboot.

3. **Process Locking & Migration Data Clash Shield**:
   - **Frozen VSS Snapshot Reads**: Bypasses live locks on open Outlook PSTs, Edge/Chrome databases, and Word/Excel documents during backups.
   - **Conflict Interception**: Before restoring browser profiles, email stores, or AppData, WINBARS intercepts running applications (`chrome`, `msedge`, `firefox`, `outlook`, `thunderbird`, `excel`, `winword`) and prompts for clean shutdown to eliminate silent SQLite/PST corruption.

4. **Drive Letter Drift & Volume Collision Immunity**:
   - **6-Tier Hardware Auto-Discovery Hierarchy**: Dynamically resolves target drives across reboots and USB hub changes (Volume GUID $\rightarrow$ Serial $\rightarrow$ Label $\rightarrow$ Directory Structure $\rightarrow$ Preferred Letter $\rightarrow$ First Ready External). Never breaks when Windows shifts `D:` to `E:`.

5. **Silent Task Failure Defense Under SYSTEM**:
   - **Windows Application Event Log**: Automatically logs Event IDs 1001 (Success), 1002 (Failure), and 1003 (Warning) directly under Source `WINBARS` in `eventvwr.msc`.
   - **Session 0 to Desktop IPC Incident Queue**: Background scheduled tasks write structured failure telemetry to `incidents.json`. The user-session desktop Tray Sentry polls this queue and triggers native Windows balloon/toast notifications (`notifyIcon.ShowBalloonTip`).
   - **Remote SMB / UNC & Cloud Canary Mirroring**: Verifies unbuffered `.winbars_remote_canary.sha256` tokens on network NAS targets, disconnecting the share (`net use ... /delete`) if tampering is detected to halt ransomware lateral spread.

---

## 📁 Low-Level Filesystem Layout

### External Backup Drive (`E:\`)
```text
E:\ (External Backup Storage Drive)
│
├── 📄 EMERGENCY_RECOVERY.bat          <-- Single guided emergency recovery entry point
├── 📄 RECOVERY_START_HERE.bat         <-- Convenient pointer directly launching EMERGENCY_RECOVERY
├── 📄 README_RECOVERY.txt             <-- Clean plaintext offline restoration instructions
├── 📄 HOW_TO_RESTORE.html             <-- Interactive offline HTML rescue walkthrough
├── 📄 Toggle_Backup_Drive_Visibility.bat <-- 1-Click script to cloak or uncloak backup drive
│
├── 📁 UserBackups\                    <-- Uncompressed 1:1 file mirror (browse on any PC/Mac/Linux)
│   ├── Desktop\
│   ├── Documents\
│   ├── Pictures\
│   ├── Videos\
│   ├── Music\
│   └── AppData_Local_Custom\         <-- Browser profiles (Chrome, Edge, Firefox) & Outlook PST stores
│
├── 📁 _DeletedArchive\                <-- 30-day safety isolation for deleted or modified files
│   └── YYYY-MM-DD\
│
├── 📁 BitLocker_Keys\                 <-- Offline BitLocker emergency cards & encrypted vault
│   ├── BitLocker_Emergency_Card.html  <-- Printable card with exact 48-digit numerical recovery key
│   └── BitLocker_Vault.enc            <-- AES-256 encrypted key vault
│
├── 📁 Boot_Rescue\                    <-- BCD store backups and 1-click bootloader repair
│   ├── BCD_Backup                     <-- Binary BCD hive snapshot
│   ├── BCD_Configuration_Audit.txt    <-- Plaintext bootloader configuration ledger
│   └── Restore_BCD_WinPE.bat          <-- WinPE 1-click BCD import & bcdboot rebuilding assistant
│
├── 📁 SystemImages\                   <-- DISM Bare-Metal Images (OS, Drivers & Program Files Only)
│   ├── SystemImage_OS_and_Programs_YYYY-MM-DD.wim
│   ├── SystemImage_OS_and_Programs_baseline.wim
│   └── Apply-SystemImage_WinPE.bat    <-- 2-step confirmed WinPE restore tool
│
└── 📁 Backup_Logs\                    <-- Robocopy sync logs and offline registry snapshots
    ├── Sync_History.log               <-- Append-only Robocopy mirror ledger
    ├── Run-ZeroFootprintSync.ps1      <-- (Used in Mode 0/N: Host C: remains 100% sterile)
    └── Registry_Snapshots\
        ├── Latest\ (SYSTEM, SOFTWARE, SAM, SECURITY, DEFAULT)
        └── Restore_Registry_WinPE.bat  <-- 1-click WinPE offline registry rollback
```

### Host Machine Footprint (`C:\`)
* **In Mode 0 / Mode N / Mode 1 (Tier 1: Native Windows)**:
  * Exactly **0 resident third-party binaries or background daemons** on `C:\`.
  * Mode 0: 0 bytes on `C:\`.
  * Mode N: 3 generic unbranded shortcuts on Desktop.
  * Mode 1: 0 installed files; only registers unthrottled System Protection in Windows Task Scheduler.
* **In Modes 2, 3, 4 (Tier 2: Managed Suite)**:
  * Application binaries: `C:\Tools\WINBARS\WINBARS.exe` (< 1 MB).
  * Shared configuration & audit logs: `C:\ProgramData\WINBARS\`.
  * Local recovery image (Mode 2): `C:\SystemImages\`.
