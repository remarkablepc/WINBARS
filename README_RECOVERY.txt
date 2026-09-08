================================================================================
          WINDOWS DISASTER RECOVERY & FILE RESTORATION INSTRUCTIONS
================================================================================
This backup drive uses 100% native Windows tools (Robocopy + VSS + wbadmin).
Zero proprietary software is required to access or restore your data.
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

5. BARE-METAL SYSTEM IMAGE RESTORE:
   - Full bare-metal system images are stored in '\WindowsImageBackup\'.
   - To perform a complete bare-metal recovery:
     Boot from standard Windows 10/11 installation media or WinRE, select
     'Troubleshoot' -> 'Advanced options' -> 'System Image Recovery', and select this drive.

6. BITLOCKER DISASTER RECOVERY KEYS:
   - If Windows prompts for a 48-digit BitLocker numerical recovery password:
     Open 'BitLocker_Recovery_Key.txt' or 'Backup_Logs\BitLocker_Recovery_Key.txt' on
     this drive to retrieve your recovery password.

7. SHOWING / HIDING THIS BACKUP DRIVE IN WINDOWS EXPLORER:
   - To toggle whether this backup drive is visible or cloaked in 'This PC':
     Right-click 'Toggle_Backup_Drive_Visibility.bat' and select 'Run as administrator'.

8. CONFIGURATION & PROFILE ADJUSTMENTS:
   - To change backup sources, schedules, or notification modes, connect this drive
     and run 'Run-WINBARS.bat' (or 'WINBARS.exe').

================================================================================
Zero vendor lock-in. 100% offline and private.
================================================================================
