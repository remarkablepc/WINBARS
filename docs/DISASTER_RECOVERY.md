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

### Registered via WinreConfig.xml & 
eagentc.exe:
WINBARS auto-registers a custom recovery entry into the Windows Recovery Environment (WinRE). Clicking it instantly launches the standalone WINBARS Disaster Recovery Console.

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

## 3. Detailed Recovery Pathways

### Path 1: 1-Click Offline Registry Hive Rollback
* **Problem**: A corrupt registry key, botched driver update, or malware infection causes an immediate Blue Screen on boot (SYSTEM_THREAD_EXCEPTION_NOT_HANDLED, BAD_SYSTEM_CONFIG_INFO).
* **WINBARS Action**: Automatically locates the most recent pristine atomic registry snapshot from `C:\ProgramData\WINBARS\RegBack\` or `D:\WINBARS_Backup\RegBack\` and safely swaps the live hives (SYSTEM, SOFTWARE, SAM, SECURITY, DEFAULT) in under 3 seconds.

### Path 2: Windows System Restore Point Rollback
* **Problem**: A broken update, corrupted driver swap (e.g. I2C HID touchpad/mouse), or conflicting software requires rolling back system state.
* **Guarantee**: Reverts Windows system files, drivers, and registry. **Documents, desktop files, family photos, and user downloads are 100% untouched.**
* **Baseline Immunity (`[📌 BASELINE]`)**: Checkpoints captured via the Technician Baseline tool (`-Action RestorePoint -Baseline`) are explicitly tagged with `[📌 BASELINE]`. WINBARS enforces expanded VSS shadow quota (15%) and skips baseline points during automated pruning to protect critical hardware checkpoints.

### Path 3: The 2-Step Bare-Metal Resurrection Workflow
* **Problem**: Complete drive corruption or total replacement of a failed SSD.
* **The 2-Step Solution**:
  1. **Step 1 (Base or Baseline Image)**: Uses standard Microsoft `dism.exe /Apply-Image` to apply the full bootable operating system partition back to disk, followed by `bcdboot` EFI bootloader repair.
     - **Master Baseline Option (`_baseline.wim`)**: Roll back to the original clean master / factory state created on Day 1. Baseline images are permanently immune to rotation pruning.
     - **Latest Rolling Image**: Roll back to the most recent daily/weekly system image.
  2. **Step 2 (Latest User File Sync)**: After DISM finishes, WINBARS automatically detects if more recent user files exist in `UserBackups/` (from daily/hourly Robocopy mirrors) and prompts the technician/user to restore them, ensuring zero data loss between the base image date and the disaster date.

### Path 4: Intel RST / VMD Storage Driver Injector
* **Problem**: In modern 11th-14th Gen Intel laptops, Intel Volume Management Device (VMD / RST RAID) prevents standard WinPE from seeing internal NVMe SSDs (drive shows as missing).
* **WINBARS Action**: Auto-scans connected USB drives and driver repositories for Intel RST VMD `.inf` drivers and injects them live into the WinPE session via `drvload.exe`, making all internal drives immediately visible.

---

## 4. Troubleshooting Missing Backups in WinPE
If an option displays `[NO BACKUP DETECTED]` or `[Last Backup: Never]`:
1. **Plug in External Drive**: Ensure your external USB hard drive or flash drive is connected.
2. **Re-Scan**: Press **`[S]`** in the menu to refresh drive letters and scan all connected volumes.
3. **Storage Controller Check**: If your internal SSD or external drive is not visible, press **`[6]`** to inject Intel RST / VMD storage drivers.