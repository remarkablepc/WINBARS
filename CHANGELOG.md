# Changelog

All notable changes to the **WINBARS** (Windows Backup, Assistance, Recovery & Security) suite are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.9.5] - 2026-09-12

### Added & Enhanced (Feature-Complete Release Candidate)
- **4-Level Disaster Recovery Triage Ladder & macOS-Style Safe Overlay Refresh**:
  - Full interactive integration of Level 3 Non-Destructive Safe Overlay OS Refresh (`dism.exe /Apply-Image` directly over `C:\` preserving `C:\Users` user profiles & personal files, with automated `bcdboot` UEFI bootloader repair).
  - Aligned the interactive technician console menu (`[3] System Recovery`), WinPE rescue batch (`Apply-SystemImage_WinPE.bat`), and disaster recovery documentation to follow the logical 4-tier ladder (Level 1: System Restore, Level 2: RegBack Registry Rollback, Level 3: Safe Overlay Refresh, Level 4: Bare-Metal Clean Wipe).
- **ScamBuster Dynamic Sinkhole & Full-Screen Popup Interceptor**:
  - Dynamically extracts malicious domains from active browser lockup loops and notification prompts.
  - Automatically commits malicious scam domains to the local Windows `hosts` file (`0.0.0.0`) sinkhole to permanently neutralize repeat attack vectors.
  - Defuses Chromium crash-recovery traps so browser relaunches safely without re-arming audio siren extortion.
- **PUP-Guard & Push-Notification Sanitizer**:
  - Automated detection and remediation of rogue browser push notification permissions across Chrome, Edge, and Brave.
  - Deep system inspection of startup run keys, scheduled tasks, and rogue background executables.
- **Smart Drive Warning Engine & Internal Disk Ignore Policy**:
  - Distinguishes between internal secondary drives (e.g., `D:\` secondary SSD) and removable backup media.
  - Eliminates nagging prompt loops on internal disks with permanent "Always ignore this drive" configuration and "Skip this time" prompt actions.
- **Factory Reset & Zero-Drift Mode Switching**:
  - Added `Reset-SuiteConfiguration` and double-clickable `Reset-Suite.bat` / `dist/Reset-Suite.bat` to sweep legacy scheduled tasks, purge runtime caches, and restore clean factory defaults without full uninstallation.
  - Added `Switch-DeploymentMode` and `-SwitchMode <Profile>` to transition cleanly between deployment modes (Mode 0 through Mode 4) with zero configuration drift while honoring technician component overrides.
  - Updated all batch installers (`Install-Mode*.bat`) to accept the `/Reset` flag.
- **WinRE Boot Hooks**:
  - Integrated custom recovery hooks into the Windows Recovery Environment boot menu (`reagentc.exe` / `WinreConfig.xml`) for Managed Workstation modes.

---

## [0.9.1] - 2026-09-12

### Added & Hardened
- **Grade A File Synchronization Engine**:
  - **Smart Exclusion Filters**: Added intelligent `/XF` and `/XD` exclusions for transient lock files (`*.tmp`, `~*`), OS thumbnails & icon locks (`thumbs.db`, `desktop.ini`), virtual memory hives (`pagefile.sys`, `hiberfil.sys`, `swapfile.sys`), and heavy ephemeral web caches (`node_modules`, `AppData\Local\Temp`, `INetCache`).
  - **Exit Code Bitmask Auditing**: Implemented granular Robocopy exit code classification and logging (codes 0–7 classified as successful mirror variants; codes $\ge 8$ logged as actionable errors).
- **Item 4A: Windows Long Path Ceiling Guard (`LongPathsEnabled = 1`)**:
  - Automatically verifies and configures `LongPathsEnabled = 1` in `HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem` across profile setup, AutoHeal, and repair routines to remove the legacy 260-character `MAX_PATH` limitation.
- **Item 4B: Native Bare-Metal Restore Assistant (`Apply-SystemImage_WinPE.bat`)**:
  - Auto-generates an interactive, zero-dependency recovery batch script inside all system image vaults (`C:\SystemImages\` and `D:\SystemImages\`).
  - Provides WinRE/WinPE environment detection, dynamic Windows OS partition discovery (`C:`, `D:`, `E:`), interactive image selection with DISM metadata inspection, explicit confirmation safety prompts, native `dism.exe /Apply-Image`, and automated `bcdboot` bootloader rebuilding.
- **Item 4C: Active VSS Headroom Pre-Flight Guard**:
  - Enforces pre-flight disk free space verification before triggering VSS snapshot creation or System Restore checkpoints. Safely aborts or falls back if `C:\` has $< 2.0$ GB or $< 3.0$ GB free space, preventing VSS crash loops on full SSDs.
- **Item 4D: 4K High-DPI Scaling (Per-Monitor v2)**:
  - Programmatic Win32 P/Invoke `SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)` with fallback to `SetProcessDPIAware()` in `src/gui/tray_code.cs`, delivering pixel-crisp rendering of the Floppy Tray Sentry, Toast alerts, and GUI dashboard across 125%–200% displays even without external `.config` files.
- **Universal "OS & Programs Only" System Image Standard**:
  - Re-engineered DISM image naming to `SystemImage_OS_and_Programs_YYYY-MM-DD_HHmm.wim` (and `..._baseline.wim`) across all profiles.
  - Injected self-describing internal XML metadata into `.wim` headers (`/Name` and `/Description`) explicitly clarifying that the image restores OS, drivers, and software, while personal files are preserved separately in `\Users` on external/secondary storage.
- **Technician Double-Confirmation Safeguard**:
  - Implemented an unskippable two-step confirmation protocol in `Apply-SystemImage_WinPE.bat` and `Save-WinPeRestoreScript` to verify that `C:\Users` client files have been safely backed up before formatting or restoring target drive `C:`.
- **Portable Emergency Disaster Toolkit on External Backup Drives**:
  - Automated staging of `HOW_TO_RESTORE.html` (zero-dependency, responsive offline HTML guide with emergency panic triage cards).
  - Automated staging of `Create-RescueUSB.bat` on the backup drive root across all modes to generate a bootable UEFI WinRE USB from any working PC.
  - Enhanced `README_RECOVERY.txt` with an Emergency Quick-Start triage box at line 1.
- **Batch CLI Switches & Unattended Automation**:
  - Added built-in parameter switches across all 8 batch installers (`/?`, `/Quiet`, `/Vanilla`, `/Brand:`, `/Data:`, `/Image:`, `/Baseline:`, `/Pin:`, `/Label:`), accompanied by comprehensive CLI reference documentation.

---

## [0.9.0] - 2026-09-11

### Added
- **Two-Tier Deployment Spectrum (Stealth vs. Managed Architecture)**:
  - **Tier 1: Stealth / Native Windows Modes (Modes 0, N, 1)**: Leave **0 resident third-party EXEs** and 0 background processes on host `C:\`. All tasks run via 100% native Windows engines (`powershell.exe Checkpoint-Computer`, `robocopy.exe`, `wbadmin.exe`, VSS).
  - **Tier 2: Managed Suite Modes (Modes 2, 3, 4)**: Provisions `WINBARS.exe` to `C:\Tools\WINBARS` with desktop suite integration, universal hotkeys, and sentry monitoring.
- **Mode 1 Stealth Pivot: Universal Service Warranty Baseline**:
  - Repurposed Mode 1 (`SystemUndo`) as a native Windows recovery hardener with **0 resident third-party EXEs**, **0 shortcuts**, and **0 background daemons**.
  - Unthrottles Windows restore point frequency (`SystemRestorePointCreationFrequency = 0`), locks 10% VSS shadow storage quota, enables native RegBack, and schedules daily restore points via native Windows Task Scheduler.
  - Streamlined 1-question installer prompt: optional capture of a permanent baseline bare-metal system image (`C:\SystemImages\_baseline.wim`) when drive `C:` has $\ge 25$ GB free space.
- **Ransomware Canary Shield Matrix**:
  - Documented threat model and honeypot placement across all 6 profiles (external canary for 0/N, shadow quota hardening for 1, local image canary for 2, scheduled pre-sync audit for 3, and real-time honeypot sentinels + Webhook alerts for 4).
- **B-A-R-S Modular Architecture**:
  - Refactored monolithic script into discrete, high-cohesion modules under `src/`:
    - `src/backup/`: Storage drive detection, VSS snapshot engine, manifest exporter, system image engine.
    - `src/assistance/`: Storage advisor, Quick Assist integration, OneDrive nag defuser.
    - `src/recovery/`: Restore point management, disaster recovery orchestration.
    - `src/security/`: Canary guard ransomware detection, Scam Buster rogue ad killer, auto-heal engine.
    - `src/gui/`: Windows Forms tray sentry and status card.
    - `src/cli/`: Console interactive menu and CLI dispatcher.
    - `src/core/`: Suite context, config engine, deployment profiles, shortcuts & startup.
  - Automated module bundler (`tools/bundle.ps1`) with AST validation and UTF-8 BOM enforcement.
- **Configurable Technician Hotkeys & Dynamic Win32 Collision Probing**:
  - Hotkeys (`ProtectionCenterHotkey`, `ScamBusterHotkey`, `QuickAssistHotkey`) configurable in Tech Mode via configuration menu and `config.json`.
  - Dynamic Win32 `ProbeComboAvailable` P/Invoke probe via dummy `RegisterHotKey` / `UnregisterHotKey` on background message-pump threads to avoid key conflicts with active Windows applications (e.g. `Ctrl+Win+Q` Quick Assist).
  - Alt/AltGr keys strictly excluded to prevent dead-key keyboard layout collisions for European and international layouts.

### Improved & Hardened
- **Reliability & Crash Prevention**:
  - Replaced dangerous host-killing `Stop-Process` in `Exit-Suite` with safe exit logic.
  - Eliminated infinite recursion in `Get-SuiteLanguageFolders` via native Windows User Shell Folders registry queries + European multilingual fallback catalog.
  - Hardened multi-monitor bounds checking in Status Card and ScamBuster to prevent off-screen rendering.
  - Safe, non-throwing wrapper in tray sentry initialization preventing unhandled Win32 exceptions on headless/RDP sessions.
- **OneDrive Cloud Backup Prompts Refinement**:
  - Replaced alarmist "Cloud Nag Shield / Defuse" terminology with professional "OneDrive Backup Prompts: [Silenced / Windows Default]".
  - Streamlined profile defaults: Modes 0, N, and 1 preserve native Windows defaults; Modes 2, 3, and 4 silence prompts by default to prevent client confusion.
  - Added on-demand Ransomware Canary verification click handler in GUI Protection Center when Tech Mode is active.

---

## [0.8.4] - 2026-09-08

### Added
- **Language Customization Architecture (`config/languages/`)**:
  - Added extensible JSON language definition catalogs (`en-US.json`, `de-DE.json`, `es-ES.json`, `fr-FR.json`, `it-IT.json`, `pt-BR.json`) enabling technician customization of localized shell folder names and UI strings.
  - `Get-SuiteLanguageFolders` dynamically resolves configured culture, falling back to HKCU User Shell Folders registry queries and standard multilingual catalog.
- **Unbranded External Audit Logging for Zero & Near-Zero Footprint (Modes 0 & N)**:
  - Mode 0 (Zero Footprint) operations write synchronization history unbranded to `<BACKUP_DRIVE>\Backup_Logs\Sync_History.log`.
  - Enforces zero writes to host `C:` (`C:\ProgramData\WINBARS`, user `AppData`, or Windows EventLog), guaranteeing host disk remains 100% pristine.
- **Pre-Flight Menu Toggle Suppression & Defensive Guardrails (Modes 0 & N)**:
  - Pre-flight profile setup screen suppresses daemon and host-modifying toggles in Modes 0 and N: WinPE boot hooks (`[4]`), Drive Prompt daemon (`[5]`), Silent Sentry Hotkeys (`[6]`), ScamBuster Watchdog (`[7]`), Floppy Tray Monitor (`[8]`), Custom Partner Branding (`[9]`), Shortcuts (`[K]`), and Host Log Retention (`[L]`).
  - Option `[3]` (Restore Points) is suppressed exclusively for Mode 0 while remaining available for Mode N.
  - Direct keyboard input for suppressed options is intercepted with informative notices, preventing accidental host modification.

## [0.8.3] - 2026-09-08

### Added
- **Silent Hotkey Sentry for Headless & Disaster Modes (Modes 1–3)**:
  - Universal hotkey access (Ctrl+Win+W for Protection Center / Ctrl+Win+B for ScamBuster) is now supported across Modes 1, 2, and 3 via the lightweight Silent Sentry (WINBARS.exe -Tray -Silent).
  - Runs in the background consuming < 5 MB RAM without placing a floppy disk icon in the system notification tray.
  - Automatically registered at user logon via Register-TrayStartup -Silent whenever the Hotkeys component toggle [6] is active.
- **Multilingual Windows Folder Discovery (Internationalization)**:
  - Native folder localization support for non-English Windows installations (German, Spanish, French, Italian, and Portuguese).
  - Automatically discovers, sizes, and mirrors localized user folders (Dokumente, Documentos, Bilder, Imágenes, Images, Immagini, Musik, Musique, Música, Videos, Vidéos, Descargas, Téléchargements, Scaricati, Transferências, Schreibtisch, Bureau, Escritorio).
  - Integrated dynamic Windows Registry query against HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders to resolve custom and redirected shell folder locations.
  - Standardized across Invoke-RobocopyFallback, Invoke-BackupDrill, Get-DynamicStorageRequirements, Get-DiscoveredBackupSources, and modules/Storage-Advisor.ps1.

### Fixed
- **Standalone Desktop Shortcut Message Pump**:
  - Fixed an issue where launching WINBARS.exe -StatusCard (e.g. clicking the desktop shortcut on Mode 2 laptops) would instantly terminate in 5 ms.
  - ShowStandaloneDialog now properly launches Application.Run(standaloneApp.activeStatusForm) with FormClosed thread termination to provide a robust Windows Forms message pump when running standalone.
- **Pre-Flight CLI Hotkey Option Clarification**:
  - Re-labeled Pre-flight Option [6] to: [6] Universal Shortcut Hotkeys (Ctrl+Win+W / Ctrl+Win+B — Silent Sentry) with default [ON ] across Modes 1–4 and [OFF] for Modes 0 and N.

### Improved & Hardened
- **Reliability & Crash Prevention**:
  - Replaced dangerous host-killing `Stop-Process` in `Exit-Suite` with safe exit logic.
  - Eliminated infinite recursion in `Get-SuiteLanguageFolders` via native Windows User Shell Folders registry queries + European multilingual fallback catalog.
  - Added atomic writes (`Set-WinbarsAtomicFile`) across configuration saves, canary databases, deployment profiles, and OS tracker state files.
  - Hardened headless/unattended execution: guarded all interactive `Read-Host` and WinForms dialogs against input redirection and non-interactive sessions.
  - VSS snapshot retention filtering protects system restore points (`SetType -ne 7`) and persistent snapshots.

## [0.8.2] - 2026-09-08

### Added
- **Master USB Audit Log Vault (`Invoke-MirrorAuditLogToUsb`)**:
  - Automatically mirrors deployment, provisioning, and execution audit logs when operating from removable media.
  - Logs are synchronized to `<USB_ROOT>\WINBARS\Logs\Audits\<COMPUTERNAME>_<USERNAME>_<YYYYMMDD>.log`.
  - Fail-safe implementation: executes silently in protected `try/catch` blocks so write-protected USB media never halts deployments.
- **Pre-Flight Zero-Question Shortcut & Baseline Toggles**:
  - Added single-key `[K]` toggle for Desktop & Start Menu Shortcuts directly in the pre-flight profile configuration menu.
  - Added single-key `[B]` toggle for Immediate Baseline System Image Capture (`.wim`) immediately following deployment.
  - Eliminated sequential interactive `Read-Host` wizard prompts during provisioning.
- **Auto-Enabled Branding Across All Profiles**:
  - Pre-flight profile menu automatically inspects for existing partner or enterprise branding files (`branding.json` or `brands\default\branding.json`).
  - If branding assets are detected, the `Branding` toggle `[9]` is initialized to `[ON ]` across all modes (unless explicitly run with `-Vanilla`).

### Improved
- **Robust Previous Installation Awareness in Any Mode**:
  - `Get-SuiteDeploymentState` now prioritizes canonical local configurations (`C:\Tools\WINBARS\config\config.json`) over transient USB paths.
  - Intelligent Task Signature Auto-Deduction: dynamically classifies active deployments even if task paths change:
    - `hasImg -and -not hasFh` -> **`LocalDisasterGuard`** (Mode 2)
    - `hasRp -and -not hasFh -and -not hasImg` -> **`Minimal`** (Mode 1)
    - `hasFh -and -not state.TrayActive` -> **`HeadlessFull`** (Mode 3)
    - `hasFh` -> **`FullInteractive`** (Mode 4)
  - Seamlessly detects installed state (`IsInstalled = $true`) even when scheduled tasks are on-demand or inactive.
- **Mode 2 Single-Drive Realism & Dynamic Hero Action**:
  - Main Menu Option `[2]` dynamically presents a tailored hero action: `[2] Capture Baseline System Image & Checkpoint Now [DISM .wim -> C:\SystemImages]`.
  - In `Show-BackupNowSubmenu`: Option `[1]` runs bare-metal .wim image, restore point, and S.M.A.R.T. health checks without triggering external drive Robocopy errors.
  - Option `[3]` (File History & Robocopy Sync) explicitly indicates `[N/A in Mode 2 - Requires External Drive]` and safely exits if pressed.
- **Single-Drive Cloaking Guardrail**:
  - Explorer volume cloaking (`[H]`) is safely disabled when the system or target backup drive is `C:`: displayed as `[N/A — Single Drive System (C: cannot be cloaked)]`.
  - Guardrail prevents technicians from accidentally cloaking the active operating system partition.
- **Complete CLI Menu Deduplication**:
  - Main Menu: Eliminated duplicate `[1]` by designating `[L]` to Launch Installed Suite at `C:\Tools\WINBARS`, `[U]` for USB Build Upgrade, and `[I]` for Initial Provisioning.
  - Setup Submenu: Purged redundant `[U]` and `[I]` entries, eliminated duplicate `[H]` cloaking handlers, and wired `[S]` directly to `Invoke-StorageSizingAdvisor`.
- **Strict Shortcut Suppression**:
  - When the Shortcuts component toggle is disabled (`[OFF]`), `Install-WinbarDesktopShortcuts` guarantees 100% suppression: zero desktop shortcuts, zero Start Menu shortcuts, and automatically purges any pre-existing WINBARS Start Menu folders.

## [0.8.1] - Storage Capacity Warning Controls & Realistic Sizing Math

### Added
- **External Drive Capacity Warning Toggle (`EnableDriveCapacityWarnings`)**:
  - Added configuration toggle in `config.json` under `StorageAndHardware`.
  - Added checkbox in WinForms Settings Console (`Ctrl+Win+W`) under *Sentry Notifications & Audio Alarms*.
  - Added Option `[8]` in CLI Setup Submenu `[N]` for instant technician toggle.
  - When disabled, suppresses low-space Action Center toasts and prevents dropping `[!] BACKUP_DRIVE_TOO_SMALL.txt` alarm files.
- **Low Space Warning Threshold (`LowSpaceWarningThresholdGB`)**: Configurable threshold (default: 15 GB) for non-critical drive warnings.

### Improved
- **Realistic Storage Headroom Calculation**:
  - External drives with $\ge 25$ GB free are never flagged as "Too Small" or blocked from starting baseline backup synchronization.
  - `Get-WinbarStorageEstimate`: Sizing recommendation tiers now respect whether bare-metal system images (`EnableExternalImageBackup`) are enabled before computing multi-image retention requirements.
  - Tier capacity ceiling relaxed from 85% to 90%, preventing premature 2 TB tier upgrade recommendations for standard 512 GB / 1 TB backup drives.
- **Automated Regression Suite**: 20 of 20 tests passing in `Test-SuiteHardening.ps1`.

## [0.8.0] - 2026-09-08

### Added
- **Intelligent Runner Location Shift & Execution Handoff**:
  - Automatically detects when WINBARS is launched from portable media (USB flash drive or Desktop) while a canonical installation exists at `C:\Tools\WINBARS`.
  - Seamless background execution handoff: automated, scheduled, and tray sentry tasks (`-Action`, `-Tray`, `-AutoHeal`, `-Unattended`) automatically shift execution to `C:\Tools\WINBARS\WINBARS.exe` so background jobs never depend on removable media.
  - Interactive Location Shift Pivot banner: presents a 1-click prompt to Shift execution to `C:\Tools\WINBARS`, Update the local installation with the USB version, or Continue running portably.
- **Accurate Profile Storage Destination Reflection & Inline Adjustment**:
  - Displays dynamically resolved or configured paths for User Data (`Robocopy` mirror) and Bare-Metal System Images under each deployment profile (`[0]`, `[N]`, `[1]`, `[2]`, `[3]`, `[4]`, and Custom).
  - Explicitly distinguishes `[Configured]` paths saved in `config.json` from `[Auto-Detected]` storage targets and `[Omitted]` components.
  - Pre-Flight profile deployment wizard now features direct inline adjustment keys: `[C]` (Change Drive), `[D]` (Adjust Data Folder), `[I]` (Adjust Image Folder), and `[F]` (Configure Source Folders & User Profiles).
- **Dynamic Status & Path Badges Across CLI Menus**:
  - Added live indicators to Main Menu and Submenu items for Active Profile, Execution Location (`[Installed: C:\Tools\WINBARS]` vs `[Portable Media]`), Registered Task Counts, Target Storage Drive with Free Space, Latest System Restore Point timestamp, S.M.A.R.T. Health, Log Paths, and Cloaking status (`[Drive D: Visible]` vs `[Stealth Active]`).
- **Unified Dual-Progress Bar Architecture**:
  - Combined overall phase progress (0–100%) and step progress (0–100%) with real-time transfer counters, file counts, elapsed time, and immediate defensive `[X] Cancel` abort.
- **Context-Aware Morphing Floating Quick-Action Bar**:
  - Floppy Tray sentry quick bar morphs automatically between 5 idle action buttons and live dual-progress bar monitor reading `active_backup.json` every 500ms.
  - Replaced missing square glyphs ("tofu" boxes) with crisp `Segoe UI Emoji` / `Segoe UI Symbol` font rendering.
- **Tray Sentry Click Debounce**:
  - 220ms timer separates single-click (toggles floating quick bar) from double-click (opens System Health Info Card flicker-free).
- **Cloaked Volume Space Discovery**:
  - Explorer `NoDrives` bitmask inspection allows viewing true free and total space for hidden/cloaked backup volumes.

### Changed
- **CLI Menu Deduplication**:
  - Cleanly decoupled binary provisioning (`[I]` / `[U]`) from Windows Task Scheduler registration (`[1]`).
  - Context-aware main menu hides redundant `[I] Install...` when already executing from `C:\Tools\WINBARS`.
  - Submenu `[1]` renamed to *`Re-Register & Harden Scheduled Tasks`* when already installed.
- **Enterprise Notification Phrasing**:
  - Purged all informal "defuse" references in favor of enterprise standard *`OneDrive Alert Guard Active`*.

---

## [0.7.44] - 2026-09-08

### Added
- **Dynamic Colored Floppy Disk Tray Icons**: High-resolution 256x256 vector-rendered floppy disks generated directly from the C# GDI+ rendering engine for all 5 tray states:
  - `assets/floppy_green.png` (#27AE60 Emerald Green - All Systems Protected)
  - `assets/floppy_purple.png` (#8E44AD Signature Purple - Backup / Sync in Progress)
  - `assets/floppy_blue.png` (#2563EB Classic Blue - Protection Center / Ready)
  - `assets/floppy_yellow.png` (#F1C40F Amber Gold - Drive Unplugged / Notice)
  - `assets/floppy_red.png` (#E74C3C Crimson Red - Drive Failure / Alert)
- **Top-Level Download Hero Box**: Prominent quick-jump download banner and direct release navigation placed at the very top of `README.md`.
- **Curated Repository Topics**: Added 10 GitHub repository topics (`windows-backup`, `disaster-recovery`, `system-restore`, `dism`, `robocopy`, `powershell`, `zero-footprint`, `sysadmin`, `anti-scam`, `bitlocker`).

### Changed
- **Agentless Terminology Clarification**: Formally defined "Zero-Footprint (Mode 0)" as **Agentless / Zero-Resident Footprint**, clarifying that it leaves 0 third-party binaries on `C:\` and 0 background processes while orchestrating native Windows Task Scheduler engines.
- **Git Author Identity**: Enforced `RemarkablePC` and GitHub privacy-compliant author identity across 100% of commit history in both source and release repositories.
- **OneDrive Phrasing**: Polished option `[0]` to *`Silence Deceptive OneDrive 'Not Backed Up' Warnings`*.

---

## [0.7.43] - 2026-09-08

### Added
- **Master Baseline Checkpoint Protection**: Pinned restore points via `-Baseline` switch and interactive wizard. Tagged with `WINBARS Baseline Checkpoint: <label>` and `[📌 BASELINE]` badges in console restore lists.
- **VSS Shadow Quota Auto-Sizing**: Automatically resizes VSS shadow storage quota to at least 15% upon creating a baseline restore point.
- **FIFO Deletion Immunity**: Hardened `Invoke-RestorePointHardener` to skip `/oldest` shadow deletion if the oldest checkpoint is a pinned baseline.
- **Master Bare-Metal Image Creator (`_baseline.wim`)**: Dedicated technician wizard under Option `[B]` to capture permanent hardware baselines alongside restore points.
- **Enhanced Capability Cards**: Added Storage Requirements, Target Persona, Active UI/Hotkeys, and Master Baseline support to `Show-ProfileCapabilityCard`.
- **Mode Icons & Real Floppy Graphics**: Integrated profile icons (⭐, 👻, ⏪, 💽, 🏢, 🛡️, 🛠️) and real floppy disk visuals.

### Changed
- **OneDrive Alert Guard**: Renamed deceptive cloud nag removal to *OneDrive Alert Guard & Local Folder Protection*.
- **Vendor-Neutral Stealth Deployments**: Rephrased Mode N to *Corporate Workstations & Vendor-Neutral Stealth Deployments*.
- **Private Brand Sanitization**: Ensured `brands/` directory is strictly kept local and excluded from public distribution.

---

## [0.7.42] - 2026-09-08

### Fixed
- **C# Tray Settings Thread Safety**: Hardened thread transitions between WinForms notification tray and background sentry threads.
- **Task Scheduler Cadence**: Enforced strict interval checks to eliminate redundant task firings.
- **Mode 0 Sterility Audit**: Audited and confirmed zero residual files left on `C:\` during uninstallation of Mode 0.
- **VSS COM In-Memory Healing**: Added automatic COM registration repair for stuck VSS writers.

---

## [0.7.41] - 2026-09-08

### Added
- **CLI Reference & Parameter Catalog**: Full technical documentation of CLI switches, profile parameters, and environment overrides in `docs/CLI_REFERENCE.md`.
- **Help Subsystem Alignment**: Updated `WINBARS.exe -Help` and console help screens.

---

## [0.7.35] - [0.7.40] - 2026-09-07 to 2026-09-08

### Added
- **Dual Progress Bar GUI**: Added real-time overall progress (0–100%) and step progress bar for on-demand personal file sync passes.
- **ScamBuster Active Watchdog (`Ctrl+Win+B`)**: Background watchdog detecting unauthorized remote access tools (AnyDesk, TeamViewer, RustDesk, ConnectWise) and defusing full-screen browser lockup scareware.
- **Universal Global Hotkeys**: Registered `Ctrl+Win+W` (Protection Center) and `Ctrl+Win+B` (ScamBuster Panic Button).
- **High-DPI Scaling Engine**: Vector rendering and DPI awareness manifests for crystal-clear visuals on 4K / Retina displays.

---

## [0.7.30] - [0.7.34] - 2026-09-05 to 2026-09-06

### Added
- **Drive Stealth & Explorer Cloaking**: Added partition cloaking for backup destination drives to protect from user tampering and ransomware discovery.
- **BitLocker Recovery Key Escrow**: Automatic extraction and secure local backup of BitLocker 48-digit recovery passwords to the backup media.
- **Offline Disaster Recovery Guide (`README_RECOVERY.txt`)**: Placed emergency restoration instructions directly on every backup volume for restoration on any computer without WINBARS.
- **FAT Timestamp Jitter Compensation (`/FFT`)**: Added two-second timestamp granularity support for exFAT and FAT32 external drives.
- **USB-Hosted RegBack**: Offline snapshotting of critical Windows registry hives directly to external storage.

---

## [0.7.20] - [0.7.29] - 2026-09-05

### Added
- **Zero-Footprint Architecture (Mode 0)**: 100% native Windows Task Scheduler automation with 0 resident files on `C:\`.
- **Dynamic Drive Drift Shield**: Automatic detection and re-mapping when external USB drives shift letters (e.g. `D:` to `E:`).
- **Unthrottled System Restore**: Configures `SystemRestorePointCreationFrequency = 0` to bypass Windows 24-hour restore point rate-limiting.
- **Managed Suite Desktop Shortcuts**: Deployed 4 action desktop shortcuts (*WINBARS Protection Center*, *Backup Personal Data*, *Create System Restore Point*, *Create System Image*).

---

## [0.7.1] - [0.7.19] - Initial Foundations

### Added
- **1:1 Robocopy Mirror Engine**: Reliable personal data sync engine with `/ZB` restartable mode and frozen VSS snapshot reads.
- **Bare-Metal DISM Imaging**: System image capture engine creating compressed `.wim` images for complete OS disaster recovery.
- **Console TUI & Interactive Menu**: Unified technician interface for backup passes, profile deployment, and drive inspection.
- **PS2EXE Standalone Compiler**: Self-contained single-file executable packaging with embedded floppy icon.
