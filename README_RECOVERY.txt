================================================================================
          WINDOWS DISASTER RECOVERY & FILE RESTORATION INSTRUCTIONS
================================================================================
This backup drive uses 100% native Windows tools (Robocopy + VSS + DISM + wbadmin).
Zero proprietary software is required to access or restore your data.
================================================================================

================================================================================
                    EMERGENCY QUICK-START (PANIC TRIAGE)
================================================================================
Need your personal files on another computer?
  -> Go directly to the '\Users\' folder on this drive and drag-and-drop.

Windows blue-screens, crashes, or won't start?
  -> Follow Section 3 below to run EMERGENCY_RECOVERY.bat.

Hard drive failed, replaced, or needs full bare-metal OS recovery?
  -> Follow Section 5 below to run EMERGENCY_RECOVERY.bat or Apply-SystemImage_WinPE.bat.

Need a bootable Windows Recovery USB drive on any computer?
  -> Follow Section 6 below to run Create-RescueUSB.bat (makes this drive bootable non-destructively).

Prefer a friendly visual guide with clickable sections?
  -> Double-click 'HOW_TO_RESTORE.html' on the root of this backup drive!
================================================================================

1. RESTORING USER FILES & FOLDERS (100% Native - No Software Needed):
   - Open the 'Users' folder on this drive.
   - All desktop files, documents, downloads, pictures, and data are stored in
     standard Windows NTFS format with original filenames intact.
   - Simply drag and drop any file or folder back to your PC, Mac, or Linux computer.

2. RESTORING ACCIDENTALLY DELETED OR MODIFIED FILES (Safety Recycle Bin & Smart Swap):
   - If a file was deleted or replaced on your computer within the last 30 days,
     it is safely preserved in:
       '\_DeletedArchive\YYYY-MM-DD\'
   - Smart Swap Conflict Shield: If a document was edited on this USB while open
     on your PC, WINBARS never overwrites your active file. It saves a timestamped
     conflict version alongside it:
       'Filename (Conflict from USB - <PC-Name> - YYYY-MM-DD_HHmmss).ext'
   - If the PC file was closed, the previous version is preserved as:
     'Filename (Older PC Copy - <PC-Name> - YYYY-MM-DD).ext'

3. EMERGENCY BLUE SCREEN / UNBOOTABLE REGISTRY RECOVERY:
   - If Windows fails to boot due to a corrupt driver, bad update, or registry damage:
     a. Boot your PC into the Windows Recovery Environment (WinRE / Advanced Startup)
        or boot directly from this drive if configured as a Bootable Backup Drive.
     b. Select 'Troubleshoot' -> 'Advanced options' -> 'Command Prompt' (or press Shift + F10).
     c. Visual Explorer Trick: If unsure what drive letter this backup drive has,
        type 'notepad' and press Enter. In Notepad, click File -> Open and set
        "Files of type" to "All Files (*.*)" to graphically see all drives and letters!
     d. Run:
          D:\EMERGENCY_RECOVERY.bat   (or E:\EMERGENCY_RECOVERY.bat)
     e. Select Option [1] Offline Registry Rollback. WINBARS will automatically restore
        clean offline registry hives (SYSTEM, SOFTWARE, SAM, SECURITY, DEFAULT).
     f. Type 'exit' and restart Windows.

4. DAILY SYSTEM RESTORE POINTS:
   - System Restore Points are automatically created daily and at startup on your PC.
   - To roll back system files and drivers from Windows:
     Press Win+R -> type 'rstrui.exe' -> press Enter -> choose a restore point.

5. BARE-METAL SYSTEM IMAGE RESTORE (OS & Installed Programs):
   - WIM images are stored in '\SystemRecovery\' (or legacy '\SystemImages\') (e.g. SystemImage_OS_and_Programs_*.wim).
   - What this image restores: Windows Operating System, system drivers, and installed software.
   - Two Flexible Recovery Modes Provided:
     * OPTION [1] Safe Overlay (macOS-Style Non-Destructive Refresh):
       Applies Windows OS and Program Files from the .wim while leaving 'C:\Users\'
       100% UNTOUCHED on disk! Perfect when Windows is corrupted or damaged but client
       data is still on drive C:.
     * OPTION [2] Bare-Metal Clean Wipe & Re-Format:
       Completely wipes and re-formats drive C: before applying the image. Use for drive
       replacements (new SSDs) or catastrophic malware. Enforces mandatory two-step
       confirmation before wiping.
   - To perform an image restore:
     a. Boot PC into WinRE/WinPE (via Windows Setup USB, Rescue USB, or Bootable Backup Drive).
     b. Open Command Prompt (Shift + F10) and run 'D:\EMERGENCY_RECOVERY.bat' (or 'D:\SystemRecovery\Apply-SystemImage_WinPE.bat').
     c. Select Option [1] Safe Overlay (data safe) or Option [2] Clean Wipe.

6. ALL-IN-ONE BOOTABLE BACKUP DRIVE OR DEDICATED RESCUE USB:
   - You can make this backup drive ITSELF bootable without losing any existing backups!
     a. Plug this backup drive into any working PC (or your own).
     b. Right-click 'Create-RescueUSB.bat' on the root of this drive and select
        'Run as administrator'.
     c. Select this drive: WINBARS will non-destructively carve out a 2 GB FAT32 UEFI
        Boot Partition (WINBARS_BOOT) alongside your backups.
     d. Or select a separate blank USB flash drive (4GB+) to create a dedicated technician tool.

7. BITLOCKER DISASTER RECOVERY KEYS:
   - If Windows prompts for a 48-digit BitLocker numerical recovery password:
     Check 'BitLocker_Recovery_Key.txt' (or encrypted escrow 'BitLocker_Recovery_Key.enc' /
     'BitLocker_Recovery_Key.aes') on this drive. If encrypted under HIPAA zero-plaintext
     compliance, contact your technician or use your local recovery PIN to decrypt.

8. SHOWING / HIDING THIS BACKUP DRIVE IN WINDOWS EXPLORER:
   - To toggle whether this backup drive is visible or cloaked in 'This PC':
     Right-click 'Toggle_Backup_Drive_Visibility.bat' and select 'Run as administrator'.

9. CONFIGURATION & PROFILE ADJUSTMENTS:
   - To change backup sources, schedules, or notification modes, connect this drive
     and run 'Run-WINBARS.bat' (or 'WINBARS.exe').

================================================================================
Zero vendor lock-in. 100% offline and private.
================================================================================
