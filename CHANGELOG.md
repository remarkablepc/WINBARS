# Changelog

All notable changes to the **WINBARS** (Windows Backup, Assistance, Recovery & Security) suite are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
