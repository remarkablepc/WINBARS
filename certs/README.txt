==============================================================================
  WINBARS - BITLOCKER DATA RECOVERY AGENT (DRA) CERTIFICATE VAULT
==============================================================================

Place your public BitLocker recovery certificates (*.cer) in this folder:

  certs/
  ├── Shop_Public_DRA.cer          <-- Shop / Technician Master Key
  ├── CompanyMasterKey.cer         <-- Business Client Recovery Key
  └── <ClientName>_Public_DRA.cer  <-- Custom Organization Key

HOW IT WORKS:
- WINBARS automatically scans this folder and enrolls any valid public (.cer)
  keys as authorized BitLocker Data Recovery Agents (DRA) during backup runs.
- If a client PC ever triggers a BitLocker blue-screen lockout, the machine
  can be unlocked using your matching offline Private Key (.pfx) using:
  'tools\Unlock-BitLocker-With-MasterKey.bat'.
- Never place your Private Key (.pfx) here! Keep .pfx files on an offline
  hardware safe or dedicated rescue USB drive.

==============================================================================
