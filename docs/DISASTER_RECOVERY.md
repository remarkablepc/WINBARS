# Disaster Recovery, WinRE Blue Screen & Safe Mode Console

## 1. Native Windows RE Blue Screen Integration

When Windows fails to boot, encounters a bootloop, or trips multiple BSODs, Windows automatically enters the native blue **Recovery / Troubleshoot** environment:

`
[ Windows Advanced Options ]
   |
   +--> Troubleshoot
          |
          +--> [ 💾 WINBARS Emergency Resurrection Tool ]
`

### Registered via WinreConfig.xml & reagentc.exe:
In Managed Workstation profiles (Modes 2, 3, and 4), WINBARS registers a native recovery entry into the Windows Recovery Environment (WinRE). Clicking it instantly launches the standalone WINBARS Disaster Recovery Console.

> [!NOTE]
> **Strict Zero-Software Pledge (Modes 0, N, and 1)**: To preserve complete host sterility on corporate workstations and shop bench check-ins, Modes 0, N, and 1 never modify `C:\Recovery\OEM` or inject custom buttons into the Windows boot menu. Systems backed up under Modes 0, N, or 1 boot directly into standard WinRE / WinPE and execute disaster recovery via the standalone rescue scripts on the backup drive.

---

## 2. The Dynamic WinPE / WinRE Disaster Console (Zero False Hope)

WINBARS automatically pre-scans all attached drives in real time to display active backup status badges before any action is selected:

```text
========================================================================
     WINBARS (Windows Backup And Recovery) - WinRE Rescue Console        
========================================================================
 Target Windows OS: C:\Windows (Windows 11 Pro 64-bit)
 Detected Vault(s): D:\WINBARS_Backup (External USB - 465 GB Free)
 
 Live Backup Status:
  • System Restore Checkpoints : [✅ AVAILABLE - 3 Checkpoints Detected]
  • Registry Hive Snapshots    : [✅ AVAILABLE - Latest: Aug 31, 2026 09:15]
  • User File Mirror           : [✅ AVAILABLE - Last Mirror: Aug 31, 2026 14:00]
  • Bare-Metal DISM (.wim)     : [⚠️ NONE FOUND - Connect External Drive]
------------------------------------------------------------------------
 [1] STEP 1 (Safest): 1-Click Registry Hive Rollback [READY]
 [2] STEP 2: Windows System Restore (Native VSS Checkpoint) [READY]
 [3] STEP 3: Bare-Metal DISM System Image (.wim) [NO IMAGE DETECTED]
 [4] BitLocker Recovery: 1-Click Password Unlock & Temporary Suspension
 [5] Personal Files: Extract & Restore Documents from UserBackups [READY]
 [6] Intel RST / VMD Drivers: 1-Click Driver Injection for NVMe/RAID SSDs
 [S] 🔄 Re-Scan Connected Drives / USBs
 [0] Reboot PC to Windows Normally
========================================================================
```

---

---

## 3. The 4-Level Disaster Recovery Triage Ladder

Before executing a full system image restore, always follow the triage ladder from least invasive to most invasive:

| Level | Strategy | Restoration Scope | Risk to `C:\Users` | Target Scenario |
| :--- | :--- | :--- | :--- | :--- |
| **Level 1** | **Native Windows System Restore** | System Files, Drivers & Registry | **0% (Preserved)** | Boot failure following a bad Windows Update, driver conflict, or broken service. |
| **Level 2** | **Offline Registry Rollback (`Restore_Registry_WinPE.bat`)** | Registry Hives (`SYSTEM`, `SOFTWARE`, `SAM`) | **0% (Preserved)** | Corrupted registry hives or bootloops where System Restore fails. |
| **Level 3** | **Non-Destructive Safe Overlay Refresh (Option `[1]`)** | Full OS & Programs (Preserves User Data) | **0% (Preserved)** | Damaged OS binaries, broken component store, malware damage. Refreshes OS & Program Files while keeping `C:\Users` 100% intact. |
| **Level 4** | **Bare-Metal Clean Wipe & Re-Format (Option `[2]`)** | Complete Disk Reformat & Clean Image | **100% Wiped** | SSD replacement, disk migration, or catastrophic ransomware reformat. Requires two-step confirmation. |

---

## 4. Detailed Recovery Pathways

### Path 1: 1-Click Offline Registry Hive Rollback
* **Problem**: A corrupt registry key, botched driver update, or malware infection causes an immediate Blue Screen on boot (SYSTEM_THREAD_EXCEPTION_NOT_HANDLED, BAD_SYSTEM_CONFIG_INFO).
* **WINBARS Action**: Automatically locates the most recent pristine atomic registry snapshot from `C:\ProgramData\WINBARS\RegBack\` or `D:\WINBARS_Backup\RegBack\` and safely swaps the live hives (SYSTEM, SOFTWARE, SAM, SECURITY, DEFAULT) without touching personal data.

### Path 2: Windows System Restore Point Rollback
* **Problem**: A broken update, corrupted driver swap (e.g. I2C HID touchpad/mouse), or conflicting software requires rolling back system state.
* **Guarantee**: Reverts Windows system files, drivers, and registry. **Documents, desktop files, family photos, and user downloads are 100% untouched.**
* **Baseline Immunity (`[📌 BASELINE]`)**: Checkpoints captured via the Technician Baseline tool (`-Action RestorePoint -Baseline`) are explicitly tagged with `[📌 BASELINE]`. WINBARS enforces expanded VSS shadow quota (15%) and skips baseline points during automated pruning to protect critical hardware checkpoints.

### Path 3: The Two-Tier DISM Restoration Engine (`Apply-SystemImage_WinPE.bat`)
* **Problem**: Operating system corruption, broken system files, or total SSD replacement.
* **The "OS & Programs Only" Standard (`SystemImage_OS_and_Programs_*.wim`)**:
  - WINBARS deliberately separates operating system state from personal user data. System images capture the Windows OS, system drivers, `Program Files`, `ProgramData`, and user registry hives (`NTUSER.DAT`, `AppData\Roaming`), yielding a fast, clean 15–25 GB bootable image.
  - Personal user files (Documents, Desktop, Pictures, Videos, Downloads) are mirrored separately via multi-threaded Robocopy directly into `\Users\` on the backup drive.
* **Two Restoration Strategies in WinPE**:
  1. **Option `[1]` Safe Overlay (In-Place OS Refresh) [RECOMMENDED]**:
     - Uses `dism.exe /Apply-Image` directly over the target drive without formatting.
     - Refreshes core Windows binaries, system drivers, and Program Files from the `.wim` archive.
     - Leaves `C:\Users\` 100% untouched on disk—no secondary data restore required!
  2. **Option `[2]` Bare-Metal Clean Wipe (Re-Format & Clean Apply)**:
     - Formats target drive `C:\` before applying the `.wim` image.
     - Enforces a mandatory **two-step confirmation protocol** (`STEP 1/2` and `STEP 2/2`) to confirm client files in `C:\Users` are safe or backed up before wiping.
     - Single-drive collision guard: Automatically locked if the source `.wim` is on the same partition (`C:`).
* **The 2-Step Resurrection Workflow (for New Drives / Option [2])**:
  1. **Step 1 (Base or Baseline Image)**: Uses standard Microsoft `dism.exe /Apply-Image` to lay down the OS and applications, followed by `bcdboot` UEFI bootloader reconfiguration.
     - **Master Baseline Option (`_baseline.wim`)**: Roll back to the original clean master / factory state created on Day 1. Baseline images are permanently immune to rotation pruning.
     - **Latest Rolling Image**: Roll back to the most recent daily/weekly system image.
  2. **Step 2 (Latest User File Sync)**: After DISM finishes, copy the client's verified files from `\Users\` on the backup drive back into the restored user profiles.

### Path 4: Intel RST / VMD Storage Driver Injector
* **Problem**: In modern 11th-14th Gen Intel laptops, Intel Volume Management Device (VMD / RST RAID) prevents standard WinPE from seeing internal NVMe SSDs (drive shows as missing).
* **WINBARS Action**: Auto-scans connected USB drives and driver repositories for Intel RST VMD `.inf` drivers and injects them live into the WinPE session via `drvload.exe`, making all internal drives immediately visible.

---

## 4. Troubleshooting Missing Backups in WinPE
If an option displays `[NO BACKUP DETECTED]` or `[Last Backup: Never]`:
1. **Plug in External Drive**: Ensure your external USB hard drive or flash drive is connected.
2. **Re-Scan**: Press **`[S]`** in the menu to refresh drive letters and scan all connected volumes.
3. **Storage Controller Check**: If your internal SSD or external drive is not visible, press **`[6]`** to inject Intel RST / VMD storage drivers.

---

## 5. The Portable Backup Drive Disaster Kit (Every Mode)

Regardless of whether a machine was protected via Mode 0, N, 1, 2, 3, or 4, every external backup drive is automatically provisioned with a self-contained emergency disaster recovery kit on its root directory:

| File on Backup Drive | Purpose | How to Use |
| :--- | :--- | :--- |
| **`HOW_TO_RESTORE.html`** | Offline interactive recovery guide with triage cards | Double-click on any working PC, Mac, or mobile phone. |
| **`README_RECOVERY.txt`** | Plain-text emergency triage and step-by-step restoration ledger | Open in Notepad on any machine. |
| **`Create-RescueUSB.bat`** | Turnkey bootable UEFI WinRE flash drive creator | Right-click $\rightarrow$ Run as administrator on any working Windows PC. |
| **`Toggle_Backup_Drive_Visibility.bat`** | Stealth toggle to cloak or uncloak backup drive in Explorer | Right-click $\rightarrow$ Run as administrator to toggle Explorer drive letters. |
| **`Backup_Logs\Registry_Snapshots\Latest\Restore_Registry_WinPE.bat`** | 1-click WinRE offline registry hive rollback script | Run from WinRE Command Prompt (`Shift + F10`) to cure bootloops. |
| **`SystemImages\Apply-SystemImage_WinPE.bat`** | Turnkey DISM bare-metal image restoration with double confirmation | Run from WinRE Command Prompt to restore entire OS & application state. |
| **`BitLocker_Recovery_Key.txt`** | Plaintext emergency 48-digit BitLocker numerical passwords | Open to unlock BitLocker-encrypted drives. |