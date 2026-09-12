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
  -> Follow Section 3 below to run Restore_Registry_WinPE.bat.

Hard drive failed, replaced, or needs full bare-metal OS recovery?
  -> Follow Section 5 below to run Apply-SystemImage_WinPE.bat.

Need a bootable Windows Recovery USB drive on any computer?
  -> Follow Section 6 below to run Create-RescueUSB.bat.

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
     a. Boot your PC into the Windows Recovery Environment (WinRE / Advanced Startup).
     b. Select 'Troubleshoot' -> 'Advanced options' -> 'Command Prompt'.
     c. Find the drive letter assigned to this USB drive (type 'D:' or 'E:' and press Enter).
     d. Run:
          Backup_Logs\Registry_Snapshots\Latest\Restore_Registry_WinPE.bat
     e. Press 'Y' to restore clean offline registry hives (SYSTEM, SOFTWARE, SAM, SECURITY, DEFAULT).
     f. Type 'exit' and restart Windows.

4. DAILY SYSTEM RESTORE POINTS:
   - System Restore Points are automatically created daily and at startup on your PC.
   - To roll back system files and drivers from Windows:
     Press Win+R -> type 'rstrui.exe' -> press Enter -> choose a restore point.

5. BARE-METAL SYSTEM IMAGE RESTORE (OS & Installed Programs):
   - WIM images are stored in '\SystemImages\' (e.g. SystemImage_OS_and_Programs_*.wim).
   - What this image restores: Windows Operating System, system drivers, and installed software.
   - CRITICAL TECHNICIAN SAFEGUARD:
     Applying this image will OVERWRITE and re-format drive C:\.
     Personal user files (Docs, Desktop, Pictures) are stored separately in '\Users\'
     on this external backup drive. If target drive C: is still readable, verify or copy
     any un-synced client data from C:\Users before applying the image!
   - To perform a turnkey bare-metal restore:
     a. Boot PC from Windows Setup USB or Rescue USB (WinRE Command Prompt).
     b. Switch to this drive: 'D:' or 'E:' -> 'cd SystemImages'.
     c. Run 'Apply-SystemImage_WinPE.bat'.
     d. Follow the two-step verification prompts to confirm client data is safe,
        then apply the image to the target drive.

6. CREATING A BOOTABLE RESCUE USB (On Any Working PC):
   - If the crashed computer won't boot and you lack a Windows Setup USB:
     a. Plug this backup drive and any blank USB flash drive (4GB+) into a working PC.
     b. Right-click 'Create-RescueUSB.bat' on the root of this drive and select
        'Run as administrator'.
     c. Follow the prompt to turn the flash drive into a UEFI-bootable WinRE rescue USB.

7. BITLOCKER DISASTER RECOVERY KEYS:
   - If Windows prompts for a 48-digit BitLocker numerical recovery password:
     Open 'BitLocker_Recovery_Key.txt' or 'Backup_Logs\BitLocker_Recovery_Key.txt' on
     this drive to retrieve your recovery password.

8. SHOWING / HIDING THIS BACKUP DRIVE IN WINDOWS EXPLORER:
   - To toggle whether this backup drive is visible or cloaked in 'This PC':
     Right-click 'Toggle_Backup_Drive_Visibility.bat' and select 'Run as administrator'.

9. CONFIGURATION & PROFILE ADJUSTMENTS:
   - To change backup sources, schedules, or notification modes, connect this drive
     and run 'Run-WINBARS.bat' (or 'WINBARS.exe').

================================================================================
Zero vendor lock-in. 100% offline and private.
================================================================================
