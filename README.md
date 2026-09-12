# WINBARS - Windows Backup, Assistance, Recovery & Security Suite (v0.9.0)
### *WINBARS helps prevent the reasons people lose their files, lose access to their computers, lose money to scammers, and lose hours rebuilding Windows.*

<p align="center">
  <a href="https://github.com/remarkablepc/WINBARS/releases/latest"><img src="https://img.shields.io/badge/Release-v0.9.0-0078D4?logo=github&logoColor=white" alt="Latest Release" /></a>
  <a href="https://microsoft.com"><img src="https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?logo=windows&logoColor=white" alt="Windows 10 & 11" /></a>
  <a href="https://microsoft.com"><img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white" alt="PowerShell 5.1+" /></a>
  <img src="https://img.shields.io/badge/Architecture-x64%20%7C%20x86-success" alt="Architecture" />
  <img src="https://img.shields.io/badge/Binary-WINBARS.exe-informational" alt="Standalone Binary" />
  <img src="https://img.shields.io/badge/Agentless%20Native-Mode%200%20Supported-brightgreen" alt="Agentless Zero-Footprint Mode" />
  <img src="https://img.shields.io/badge/License-100%25%20Free%20for%20Personal%20%26%20Commercial%20Use-brightgreen" alt="License" />
  <a href="https://www.paypal.com/ncp/payment/EKH76RTYHH24S"><img src="https://img.shields.io/badge/Say%20Thanks-PayPal-00457C?logo=paypal&logoColor=white" alt="Say Thanks" /></a>
  <a href="https://github.com/sponsors/remarkablepc"><img src="https://img.shields.io/badge/Sponsor-GitHub%20Sponsors-EA4AAA?logo=githubsponsors&logoColor=white" alt="GitHub Sponsors" /></a>
</p>

<p align="center">
  <a href="https://github.com/remarkablepc/WINBARS/releases/latest">
    <img src="https://img.shields.io/badge/%E2%9E%9C%20Download%20Latest%20Release-WINBARS%20v0.9.0-2ea44f?style=for-the-badge&logo=windows&logoColor=white" alt="Download Latest Release" height="34" />
  </a>
</p>

<div align="center">

  **[📥 Download Complete Package (`WINBARS-v0.9.0.zip`)](https://github.com/remarkablepc/WINBARS/releases/latest)** &nbsp;&bull;&nbsp; **[📦 All Releases](https://github.com/remarkablepc/WINBARS/releases)** &nbsp;&bull;&nbsp; **[📜 Changelog](CHANGELOG.md)** &nbsp;&bull;&nbsp; **[📋 Release Notes](https://github.com/remarkablepc/WINBARS/releases/tag/v0.9.0)**

</div>

---

> [!IMPORTANT]
> ### 💡 The Architectural Principle: Orchestration & Hardening, Not Proprietary Bloat
> WINBARS does not replace Windows with proprietary background bloatware or unproven file-sync daemons that lock your data behind recurring subscriptions. Microsoft Windows already contains 30 years of battle-tested, kernel-level recovery engines: **Robocopy, Volume Shadow Copies (VSS), DISM bare-metal imaging, wbadmin, and Task Scheduler**.
> 
> The fatal flaw has never been the native engines—it is that Windows leaves them uncoordinated and unmonitored: Windows Update silently disables File History, VSS writers crash without alert, restore points are throttled to once every 24 hours, and USB drive letter drift halts scheduled backups.
> 
> **WINBARS is the resilient orchestration and auto-healing layer that configures, schedules, monitors, and hardens these native Windows engines—ensuring your disaster recovery actually works when disaster strikes.**
>
> **WINBARS does not replace Windows recovery technologies. It makes sure they actually work when you need them.**
>
> 🛡️ **Zero Lock-In & Verifiable Host Footprint**: Every backup is 100% standard Windows files, native DISM `.wim` images, and raw VSS checkpoints—WINBARS is never required to restore your system. WINBARS installs 0 kernel drivers, 0 background services, and opens 0 network connections. See the [System Footprint & Security Audit Blueprint](docs/SYSTEM_FOOTPRINT.md).

<p align="center">
  <img src="assets/screenshot.png" alt="WINBARS Protection Center and Sentry Dashboard" width="820" />
  <br>
  <em>WINBARS Protection Center Live Dashboard (Ctrl+Win+W), Floppy Tray Sentry, and Quick-Action Bar</em>
</p>

---

> [!TIP]
> ### 📦 100% Standalone Portable Executable (`WINBARS.exe`)
> WINBARS is distributed as a **single, self-contained standalone executable** (`WINBARS.exe`) with embedded floppy icon.
> - **Zero Runtimes / Zero Installers**: Requires no third-party runtimes, no Python, no Node, and no MSI installer. It runs natively using Windows 10/11 built-in PowerShell 5.1 and .NET WinForms.
> - **Run Portably or Provision Locally**: Run directly from a technician's USB thumb drive or portable folder, or provision permanently to `C:\Tools\WINBARS` with a single click.
> - **Flexible Footprint**: Choose between full interactive real-time protection (Mode 4), background automation (Modes 1–3), or strict **Agentless Zero-Footprint Mode (Mode 0)** leaving **0 resident third-party binaries and 0 background processes on `C:\`**.
> - **Transparent Audit Ledger (`deployment.log`)**: All configuration changes and uninstallation operations are streamed live to the console in green/yellow/red and appended to `deployment.log`.

---

## 📑 Table of Contents

0. [📜 Changelog & Version History](CHANGELOG.md)
1. [💔 Why WINBARS Was Born: 4 Real-World Nightmares](#why-winbars-was-born-4-real-world-nightmares)
2. [🛡️ How WINBARS Solves Each Problem](#how-winbars-solves-each-problem)
3. [⚖️ Market Comparison: WINBARS vs. Legacy Backup Suites](#market-comparison-winbars-vs-legacy-backup-suites)
4. [💾 Floppy Tray Sentry & 1-Click Desktop Shortcuts](#floppy-tray-sentry--1-click-desktop-shortcuts)
5. [🚀 6 Deployment Profiles (Including Zero & Near-Zero Footprint)](#6-deployment-profiles-including-zero--near-zero-footprint)
6. [❓ Frequently Asked Questions (FAQ)](#frequently-asked-questions-faq)
7. [👻 Deep Dive: The Zero-Footprint Architecture (0 Resident Files)](#deep-dive-the-zero-footprint-architecture-0-resident-files)
8. [🛡️ Enterprise Auditability & Tamper-Proof Architecture](#enterprise-auditability--tamper-proof-architecture)
9. [⌨️ Universal Global Hotkeys](#universal-global-hotkeys)
10. [🔒 Novice Protection & Technician Mode](#novice-protection--technician-mode)
11. [🚀 Quick Start & CLI Reference](#quick-start--cli-reference)
12. [🏷️ White-Labeling & The \$100 Lifetime Shop Branding Perk](#white-labeling--the-100-lifetime-shop-branding-perk)
13. [📚 Technical Documentation Directory](#technical-documentation-directory)
14. [📋 Technical Requirements](#technical-requirements)
15. [⚖️ Legal & Process Interception Disclaimer](#legal--process-interception-disclaimer)

---

## 💔 Why WINBARS Was Born: 4 Real-World Nightmares

If you have ever repaired Windows PCs for clients, friends, or family, you already know these four heartbreaking scenarios:

### 1. The "Windows 11 Silent File History Death"
> *"A customer came into a repair shop whose SSD abruptly died. They had set up Windows File History years ago and faithfully left their external hard drive plugged in every day. But when the drive was inspected, the customer discovered that **the day they upgraded from Windows 10 to Windows 11, Microsoft silently disabled File History with ZERO warnings or error dialogs**. The customer lost an entire year of irreplaceable family photos and business files because Windows never said a word."*

### 2. *"There is NEVER a Restore Point When You Actually Need One!"*
> *"Every technician has lived this: a bad update or corrupted driver causes a blue screen, but System Restore is completely empty. In standard Windows, Windows Update frequently purges restore points, the Volume Shadow Copy service (VSS) silently exhausts its storage quota, and Windows limits restore points to once every 24 hours. When disaster strikes, the restore point list is a ghost town."*

### 3. The "Surprise BitLocker" Catch-22
> *"Modern laptops (Dell, HP, Lenovo) now turn on BitLocker encryption out of the box. Users have **zero idea their drive is encrypted** and never backed up the 48-digit numerical recovery key. When a BIOS update or crash trips the TPM chip, they are greeted by a blue recovery screen demanding 48 digits. Worse, they cannot access their Microsoft Account 2FA code because their phone needs an email confirmation code sent to the very PC that is locked!"*

### 4. The $5,000 Phone Scam & Browser Trap
> *"Every week, everyday computer users and seniors freeze in panic when a full-screen browser trap takes over their screen ('VIRUS DETECTED! CALL MICROSOFT AT 1-800...') accompanied by blaring audio sirens. Trapped by browser reload loops and hidden taskbars, they call the number on screen and let offshore scam call centers install remote control tools, drain their savings, or lock their computer. Windows provides zero proactive defense against these social engineering traps."*

---

### 💬 A Note from the Creator: Why WINBARS Exists

> *"I didn't build WINBARS because I wanted another utility.*
>
> *I built it because I got tired of watching preventable computer disasters hurt good people.*
>
> *I watched customers lose family photos because a backup silently stopped working.*
>
> *I watched people get locked out of their own computers because BitLocker was enabled and they never knew they needed a recovery key.*
>
> *I watched perfectly usable systems get wiped and rebuilt because there was no restore point, no system image, and no recovery plan.*
>
> *And I watched scammers use fear, sirens, and fake warnings to steal money from people who simply didn't know where to turn for help.*
>
> *After seeing the same problems year after year, I decided to build the tool I wished every customer already had installed.*
>
> *That tool became WINBARS."*
>
> — **RemarkablePC**, Creator of WINBARS

---


## 🛡️ How WINBARS Solves Each Problem

Rather than trapping your data in fragile, proprietary backup formats, **WINBARS coordinates and hardens the native utilities already built into Windows**:

### 1. Automated System Restore Point Hardening
* **Always Unthrottled**: Disables Microsoft's 24-hour frequency throttling so checkpoints are created whenever requested.
* **Automatic Storage Management**: Automatically manages and allocates VSS shadow storage on `C:\` (15% capacity) so restore points are never purged prematurely.
* **Service Self-Healing**: Automatically tests and resets stuck VSS writers (`vssadmin list writers`) in under two seconds.
* **100% Personal File Safety**: System Restore reverts Windows system files, drivers, and registry hives. **Your personal documents, desktop files, photos, and downloads are never touched, overwritten, or deleted.**

### 2. Smart File Mirroring with 30-Day Accidental Deletion Protection
* **Multi-Threaded Robocopy Engine**: Uses native, unbuffered `robocopy.exe /ZB /MT:8` as the primary file backup engine, superseding deprecated File History.
* **Clean 1:1 Folder Mirror**: Backs up your files directly to `D:\WINBARS_Backup\UserBackups\` with original filenames and folder structures intact.
* **30-Day Safety Recycle Bin (`_DeletedArchive`)**: If you delete or rename a file on your computer, WINBARS moves the previous backup copy into an isolated 30-day safety folder before mirroring. Accidental deletions can be restored with a single click.
* **Multi-User Account Protection**: Automatically backs up all user accounts on the machine (`C:\Users`), not just the active user.

### 3. Browser Profile & Desktop Email Preservation
* **100% Local Continuity**: Preserves bookmarks, extensions, and local configuration for Google Chrome, Microsoft Edge, Mozilla Firefox, Brave, and other Gecko/Chromium browsers.
* **Desktop Mail Protection**: Automatically captures Microsoft Outlook local `.pst` archives and Mozilla Thunderbird mailbox stores.
* **Privacy Guarantee**: Data is stored **100% locally on your backup drive**. WINBARS never reads, decrypts, uploads, or transmits personal browsing history or account passwords to any cloud service.

### 4. BitLocker Recovery Card & Emergency Vault
* **Printable Emergency Card (`BitLocker_Emergency_Card.html`)**: Generates a clean, segmented, easy-to-read emergency card containing your exact 48-digit BitLocker recovery key so you are never locked out.
* **AES-256 Disaster Vault**: Securely archives recovery keys to `D:\WINBARS_Backup\BitLocker_Keys\BitLocker_Vault.enc` using PBKDF2 (100,000 iterations) and HMAC-SHA256.
* **1-Click WinRE / WinPE Unlock**: If a PC fails to boot, enter your Windows user password in the WinRE recovery console to unlock `C:\` and temporarily suspend BitLocker for one reboot, bypassing the 48-digit prompt.

### 5. Scam Buster & Remote Access Interceptor
* **Instant Scam Freeze (`Ctrl + Win + B` or `Ctrl + Win + K`)**: Immediately closes rogue full-screen browser traps across 25+ browsers, silences audio sirens, and clears session crash reload loops.
* **Real-Time Remote Access Interceptor**: Continuously monitors for 25+ remote access tools frequently weaponized by phone and pop-up scammers (AnyDesk, TeamViewer, ScreenConnect, UltraViewer, RustDesk, LogMeIn, SupRemo, etc.). When a remote tool launches, an urgent interception dialog appears with 4 user choices:
  1. **`[STOP] Disconnect & Block`**: Instantly kills the remote software process and drops the connection immediately.
  2. **`Allow Once`**: Grants temporary permission for the current session only without persisting changes.
  3. **`Always Allow (Whitelist)`**: Permanently whitelists the application on this machine so authorized tools (e.g. corporate IT) launch without prompts.
  4. **`Snooze 2 Hrs (Tech Working)`**: Temporarily mutes the interceptor for 120 minutes while a trusted repair technician performs service, automatically re-arming sentry mode once the timer elapses.
* **Notification Spam Defuser**: Surgically purges rogue Web Push notification subscriptions from scam domains without affecting legitimate notifications (Gmail, calendar, news).
* **Architecture Note on Profiles**: The active real-time ScamBuster and Remote Tool Interceptor sentry runs continuously in **Profile 4 (`FullInteractive`)**. In **Profiles 1–3 and Zero-Footprint**, the system maintains **0 resident background processes**; ScamBuster can be triggered on-demand via shortcut, hotkey, or directly from the technician's USB drive.

### 6. OneDrive Alert Guard & Local Folder Protection
* **Silences Deceptive "Not Backed Up" Scare Banners**: Windows 10 and 11 frequently inject confusing yellow and red warning cards in Windows Settings Home and File Explorer claiming your PC is "not backed up" simply because you do not pay for a Microsoft OneDrive cloud subscription. WINBARS defuses these banners so clients and family members are never misled.
* **Blocks Known Folder Move (KFM) Hijacking**: OneDrive periodically displays aggressive wizards urging users to "back up" their Desktop, Documents, and Pictures. If clicked, OneDrive silently diverts local folders into Microsoft's free 5 GB cloud container, quickly runs out of space, and begins holding file saving hostage behind a Microsoft 365 paywall. WINBARS enforces `KFMBlockOptIn = 1` to halt these takeover prompts.
* **100% Non-Destructive**: Normal OneDrive file synchronization is never disabled or broken. Users who legitimately use OneDrive for school, work, or team sharing continue to enjoy full functionality. Only deceptive upsell banners, library hijacking, and takeover prompts are silenced.
* **Deployment Profile Rules**: **Enabled by default across ALL deployment modes (Modes 0 through 4 and Custom Profiles)**, because every mode provides complete, verified WINBARS protection. Mode 0 (`ZeroFootprint`) maintains its strict 0-file guarantee because registry policies place **0 executable files on disk**. Technicians can toggle it `[OFF]` via key `[0]` on the Pre-Flight screen if desired.

### 7. Master Baseline Checkpoints & Bare-Metal Images (`_baseline.wim`)
* **Technician Hardware & Driver Staging**: Before attempting risky hardware or driver replacements (such as conflicting I2C HID touchscreen/touchpad drivers, GPU firmware updates, or network stack overrides), technicians can capture a dedicated **Baseline System Restore Point** (`WINBARS.exe -Action RestorePoint -Baseline -Description "Pre-I2C Driver Fix"`).
* **`[📌 BASELINE]` Visual Badging**: Baseline checkpoints are explicitly badged across all WINBARS repair menus and the WinRE blue screen recovery console, ensuring technicians can immediately identify known-good master states before testing experimental vendor drivers.
* **VSS Shadow Headroom Expansion**: Baseline creation automatically sizes the VSS shadow quota (15%) and instructs WINBARS retention routines to skip the baseline during FIFO pruning to maximize checkpoint longevity.
* **Permanent Bare-Metal System Image (`_baseline.wim`)**: Capturing a bare-metal image with `-Baseline` creates `SystemImage_YYYY-MM-DD_HHmmss_baseline.wim`. These master factory setup images are permanently immune to rotation pruning on both `C:\SystemImages` and external storage, providing an indestructible rollback target even if Windows VSS is eventually purged by major OS feature updates.

---

### 🔧 Technical Resiliency Engine: 5 Failure-Mode Defenses

To guarantee enterprise-grade survivability without bloated third-party drivers or black-box agents, WINBARS incorporates five specialized defensive engineering patterns:

1. **Mid-Sync Disconnect Defense (USB Yank / Sudden Power Loss)**:
   - **Atomic Staging (Write-Temp-Then-Swap)**: All JSON configurations, manifests, and telemetry are written to .tmp.<guid>, verified for byte-size, and swapped atomically (Set-WinbarsAtomicFile in PowerShell, WinbarsIO.SafeWriteAllText in C#).
   - **Robocopy Restartable Mode (/ZB)**: Uses packet-level restartable mode with automatic backup token fallback. If a 40 GB Outlook .pst or virtual disk is disconnected mid-stream, Robocopy resumes from the exact packet on the next pass rather than restarting from zero.
   - **Transaction Canary (.winbars_sync_in_progress)**: Dropped at the target drive root before mirroring starts. If an abrupt disconnect occurs, WINBARS detects the canary on the next boot, alerts the desktop, and executes a full recovery sweep.

2. **Orphaned VSS & Junction Point Hygiene**:
   - **Strict try/finally Lifecycle**: Snapshot creation, junction mounts (C:\ProgramData\WINBARS\VssMount_*), read routing, and teardowns are enclosed in an unskippable try { ... } finally { Dismount-Vss; Remove-Canary } construct.
   - **Startup Garbage Collector (Clean-OrphanedVssMounts)**: Proactively scans for and unmounts lingering directory junctions via native cmd /c rmdir, and purges unmanaged temporary shadow copies older than 24 hours.
   - **Native COM Self-Repair (Repair-WinbarsVssSubsystem)**: If third-party backup software leaves broken COM provider keys, WINBARS re-registers native Windows VSS DLLs (ole32.dll, vss_ps.dll, swprv.dll) in-memory without requiring an OS reboot.

3. **Process Locking & Migration Data Clash Shield**:
   - **Frozen VSS Snapshot Reads**: Bypasses live locks on open Outlook PSTs, Edge/Chrome databases, and Word/Excel documents during backups.
   - **Test-ConflictingProcessesForRestore**: Before restoring browser profiles, email stores, or AppData, WINBARS intercepts running applications (chrome, msedge, firefox, outlook, thunderbird, excel, winword, qbw32) and prompts for clean shutdown to eliminate silent SQLite/PST corruption.

4. **Drive Letter Drift & Volume Collision Immunity**:
   - **6-Tier Hardware Auto-Discovery Hierarchy**: Dynamically resolves target drives across reboots and USB hub changes (Volume GUID -> Serial -> Label -> Directory Structure -> Preferred Letter -> First Ready External). Never breaks when Windows shifts D: to E:.

5. **Silent Task Failure Defense Under SYSTEM**:
   - **Windows Application Event Log**: Automatically logs Event IDs 1001 (Success), 1002 (Failure), and 1003 (Warning) directly under Source WINBARS in eventvwr.msc.
   - **Session 0 to Desktop IPC Incident Queue**: Background scheduled tasks write structured failure telemetry to incidents.json. The user-session desktop Tray Sentry polls this queue and triggers native Windows balloon/toast notifications (notifyIcon.ShowBalloonTip).
   - **Remote SMB / UNC & Cloud Canary Mirroring**: Verifies unbuffered .winbars_remote_canary.sha256 tokens on network NAS targets, disconnecting the share (net use ... /delete) if tampering is detected to halt ransomware lateral spread.

---

## ⚖️ Market Comparison: WINBARS vs. Legacy Backup Suites

| Feature / Capability | WINBARS (v0.8.0) | Acronis Cyber Protect | Macrium Reflect (v8/v10) | Veeam Agent Windows | Windows Native Alone |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Pricing & Licensing** | **100% Free** *(+$100 Lifetime Shop Branding)* | $50–$189/yr per PC (Sub) | $79–$139 (Perpetual / EOL Free) | Free / $50+ annual | Included with Windows |
| **Architectural Model** | **100% Native OS Engines** (Zero Resident) | Heavy Proprietary Daemons | Proprietary CBT Filter | Proprietary CBT Driver (`VeeamFSR`) | Native Windows |
| **Vendor File Format Lock-In** | **Zero Lock-In** (1:1 NTFS Mirror + `.wim`) | **Total Lock-In** (`.tibx` archives) | **Total Lock-In** (`.mrimg` archives) | **Total Lock-In** (`.vbk` archives) | None (Timestamp suffixes) |
| **Recovery Without Software** | ✅ **Drag-and-drop on any PC/Mac/Linux** | ❌ Requires Acronis installed | ❌ Requires Macrium installed | ❌ Requires Veeam installed | ⚠️ Partial (Catalog dependent) |
| **Resident RAM & CPU Footprint** | **0 MB** *(Modes 0–3)* / ~18 MB *(Mode 4)* | ~650 MB – 1.2 GB (8-12 daemons) | ~120 MB (2 services) | ~250 MB (3 services) | Dynamic OS Cache |
| **Kernel Drivers & BSOD Risk** | **Zero Kernel Drivers** (100% Native API) | ⚠️ High (Prone to upgrade BSODs) | ⚠️ Medium (CBT filter driver) | ⚠️ Medium (CBT filter driver) | Native Windows Drivers |
| **Agentless / Zero-Resident Footprint** | ✅ **Supported (Mode 0)**: 0 installed binaries & 0 resident processes on host | ❌ Impossible | ❌ Impossible | ❌ Impossible | ❌ Not available |
| **Abrupt USB Disconnect & Crash Safety**| ✅ **Atomic Staging + Robocopy `/ZB` + Canary** | Proprietary Journaling | Delta Index (can corrupt on pull) | Transaction Log | ❌ Truncates open PST/DBs |
| **VSS Engine & COM Self-Repair** | ✅ **Frozen Snapshot Reads + In-Memory Repair** | Proprietary VSS Provider | Proprietary CBT & VSS Writer | Proprietary CBT VSS Engine | ⚠️ Fragile (Silent failure) |
| **Target Storage Agnostic** | ✅ **USB, Internal, NAS, UNC, S3 Mounts** | Proprietary Cloud or Local | Local / NAS (Proprietary) | Local / NAS (Proprietary) | USB / Dedicated Share |
| **Ransomware Canary Defense** | ✅ **Dual-Layer Honeypot + Remote Canary Mirror**| Active Protection (Behavioral) | Guardian (Volume Lock) | None (Relies on immutability) | None |
| **Active Tech Scam & Siren Shield**| ✅ **Built-in ScamBuster (`Ctrl+Win+B`)** | ❌ None | ❌ None | ❌ None | ❌ None |
| **Remote Access RAT Interceptor** | ✅ **Detects AnyDesk, TeamViewer, RustDesk** | ❌ None | ❌ None | ❌ None | ❌ **Blindspot** (Signed tools allowed) |
| **Dynamic Drive Drift Shield** | ✅ **6-Tier Auto-Discovery (`D:` $\rightarrow$ `E:`)** | ⚠️ Often halts until reconfigured | ⚠️ Reconfiguration needed | ⚠️ Reconfiguration needed | ❌ Completely halts backups |
| **White-Label Branding for Repair Shops** | ✅ **1-Time $100 Lifetime Token** (Unlimited PCs) | ❌ White-labeling costs $10k+ / MSP | ❌ None | ❌ None | ❌ None |

#### 🔑 Key Takeaways:
1. **Vs. Macrium Reflect & Acronis Cyber Protect**:
   * *The Problem*: Legacy backup giants lock your irreplaceable files inside massive, proprietary container files (`.mrimg` or `.tibx`). If the software license lapses, or if the container suffers a 1-byte CRC corruption, your entire backup is lost. Furthermore, their kernel filter drivers frequently cause boot-loop Blue Screens after major Windows 11 feature upgrades.
   * *The WINBARS Advantage*: WINBARS creates transparent, standard 1:1 file mirrors and native Microsoft `.wim` images. You can plug your external hard drive into **any computer on earth** and immediately browse, copy, and restore your files in Windows Explorer or macOS Finder without installing a single piece of software.
2. **Vs. Native Windows Tools Alone**:
   * *The Problem*: Windows includes File History, System Restore, and `wbadmin`, but Microsoft has left them unmaintained. File History was silently disabled in Windows 11 upgrades without notifying users; System Restore is throttled to once every 24 hours; VSS writers lock up; and external drive letter changes (`D:` moving to `E:`) silently cause backups to fail indefinitely.
   * *The WINBARS Advantage*: WINBARS acts as the intelligent conductor: it self-heals VSS writers, removes the 24-hour throttle, guarantees shadow storage headroom, auto-discovers shifted drive letters, and safely preserves deleted files in a 30-day safety recycle bin.
3. **The Tech-Scam Blindspot (Why WINBARS Complements, Not Replaces, Antivirus)**:
   * *Important Distinction*: **WINBARS is not an antivirus or anti-malware suite, and it does not replace Windows Defender or your existing AV software.** Instead, it defends against an entirely different threat vector that antivirus engines fundamentally cannot address: social engineering and weaponized legitimate tools.
   * *The Problem*: Modern phone scammers and pop-up boiler rooms **do not use malware or viruses**. They create full-screen browser traps with blaring audio sirens, convincing victims to call a toll-free number. The scammer instructs the victim to download legitimate, digitally signed commercial remote support tools (AnyDesk, TeamViewer, ScreenConnect, UltraViewer). Because these tools are legitimate and digitally signed, antivirus software correctly permits them.
   * *The WINBARS Sentry Layer*: WINBARS operates as an assistive safety layer alongside your antivirus: an instant browser freeze hotkey (`Ctrl+Win+B`) that terminates full-screen traps and audio loops across 25+ browsers, and a real-time Remote Access Interceptor that catches AnyDesk/TeamViewer launches and gives the user an unmistakable **`[STOP] Disconnect & Block`** button.

---

## 💾 Floppy Tray Sentry & 1-Click Desktop Shortcuts

The background system tray icon renders a classic floppy disk that dynamically changes color to reflect system status at a glance:

| Tray Floppy | State Name | What It Means |
| :---: | :--- | :--- |
| <img src="assets/floppy_green.png" width="18" height="18" valign="middle" alt="Emerald Green Floppy" /> 🟢 | **Emerald Green** | **All Systems Protected**: Daily restore points active, file backups up to date, and canaries intact. |
| <img src="assets/floppy_purple.png" width="18" height="18" valign="middle" alt="Signature Purple Floppy" /> 🟣 | **Signature Purple** | **Backup or Sync in Progress (Action Color)**: Purple is the suite's signature action color. Indicates an active file mirror, system restore point creation, or system image capture. Returns to 🟢 when complete. |
| <img src="assets/floppy_blue.png" width="18" height="18" valign="middle" alt="Classic Blue Floppy" /> 🔵 | **Classic Blue** | **Protection Center / Ready**: Idle state for the Protection Center and desktop utilities. |
| <img src="assets/floppy_yellow.png" width="18" height="18" valign="middle" alt="Amber Gold Floppy" /> 🟡 | **Amber Gold** | **Notice / Local Mode**: External backup drive is unplugged (local snapshot active) or backup is due. |
| <img src="assets/floppy_red.png" width="18" height="18" valign="middle" alt="Crimson Red Floppy" /> 🔴 | **Crimson Red** | **Attention Required**: S.M.A.R.T. drive degradation, NTFS bad block event, or service failure. |

### 🖥️ 1-Click Desktop Shortcuts

#### Managed Suite Profiles (Installed Mode)
When deployed in Managed mode (`FullInteractive`), WINBARS provisions up to 4 self-elevating desktop shortcuts:
* **`WINBARS Protection Center` (<img src="assets/app_icon.png" width="18" height="18" valign="middle" alt="Blue Floppy" /> **Classic Blue Floppy Disk**)**:
  * Opens the live System Health dashboard displaying backup status, restore points, S.M.A.R.T. disk telemetry, and BitLocker keys.
* **`Backup Personal Data` (<img src="assets/app_backup_preview.png" width="18" height="18" valign="middle" alt="Purple Floppy" /> **Signature Purple Floppy Disk**)**:
  * Double-clicking immediately launches the **Dual Progress Bar Window** (Overall Completion 0–100% + Active Step Progress) for an on-demand personal file and profile mirror pass.
* **`Create System Restore Point` (🛡️ Windows Security Shield)**:
  * Immediately captures an unthrottled System Restore Point with native toast confirmation.
* **`Create System Image` (💽 System Drive Image)**:
  * Immediately launches DISM bare-metal system imaging.

#### Near-Zero Footprint Profile (Stealth Native Automation)
When deployed in Near-Zero Footprint mode (`[N]`), WINBARS leaves **0 background EXEs or running daemons** on the target PC while giving the customer standard, unbranded desktop links:
* **`Backup Personal Files` (<img src="assets/app_backup_preview.png" width="18" height="18" valign="middle" alt="Purple Floppy" /> **Signature Purple Floppy Disk**)**: Triggers native robocopy sync pass.
* **`Windows System Restore` (<img src="assets/app_icon.png" width="18" height="18" valign="middle" alt="Blue Floppy" /> **Classic Blue Floppy Disk**)**: Launches native `rstrui.exe` for instant OS rollback.
* **`Browse Backup Files` (📁 Windows Folder Icon)**: Double-clicking dynamically resolves the backup drive letter and opens Windows File Explorer directly into the backed-up `Users` folder. Users can easily browse and drag-and-drop restored files with zero third-party tools.
* **Start Menu Folder (`System Backup & Recovery`)**: Generic unbranded Start Menu group containing 5 native Windows tools (*Backup Personal Files*, *Windows System Restore*, *Create System Image*, *Browse Backup Files*, *All-In-One Backup & Recovery*). For business and corporate clients where third-party utility branding is restricted. Uses 100% native Windows Task Scheduler and generic shortcuts (`System Backup & Recovery`) so the automation blends seamlessly into Windows as a built-in system capability.

#### Agentless Zero-Footprint Profile (Mode 0 — Pure Native Mode)
When deployed in Agentless Zero-Footprint mode (`[0]`), WINBARS leaves **0 resident binaries or background daemons on `C:\`**. All scheduled backup tasks execute autonomously via native Windows Task Scheduler (`robocopy.exe`, `wbadmin.exe`, VSS), requiring **zero resident software and no USB drive to remain connected**. On-demand technician tasks and configuration adjustments can be run at any time directly from the technician's portable USB drive.

### ⚙️ Modern Tabbed Settings & Protection Console (Tray Sentry)

Accessible by clicking the **Gear icon** in the Floating Quick-Action Bar or selecting **Protection Settings...** from the Tray Sentry menu:

```
┌─ WINBARS — Settings & Protection Console ───────────────────────────────┐
│ [>>] Active Profile: [Mode 4 — Total Protection (Full Sentry + Tray)]   │
├─────────────────────────────────────────────────────────────────────────┤
│ [ General ]  [ Schedules ]  [ Disk Management ]                         │
├─────────────────────────────────────────────────────────────────────────┤
│ GENERAL TAB:                                                            │
│   • [v] Show System Tray Icon in taskbar notification area              │
│         (Tip: When hidden, Ctrl+Win+W or relaunch WINBARS to restore)   │
│         • Mode 0/N Guardrail: Disabled/Locked to preserve 0 host files  │
│         • Mode 3 <-> 4 Bridge: Checking elevates to Mode 4; unchecking  │
│           cleanly returns profile to Mode 3 (Headless Full)             │
│   • [v] Enable Floating Quick-Action Bar on tray click                  │
│   • Notification Level: [ Warnings & Errors Only (Recommended — Quiet) ]│
│     [!] Security Guardrail: Warnings and error alerts cannot be disabled│
│   • [v] Enable audible alarms for critical ransomware & security alerts │
│                                                                         │
│ SCHEDULES TAB (Timing Adjustments Only — Never Disables):               │
│   • Restore Point Time (HH:mm) & Cadence (Daily / 3-Day / Weekly)       │
│   • Daily File Sync / FileHistory Mirror Time (HH:mm)                   │
│   • Bare-Metal DISM System Image Time (HH:mm) & Monthly Day (1–28)      │
│   • Auto-Sync: Saving immediately refreshes Windows Task Scheduler      │
│                                                                         │
│ DISK MANAGEMENT TAB (With 1-Drive Minimum Guardrail):                   │
│   • Interactive ListView: Target Path, Label, Role (Primary), Status    │
│   • Add Destination: Supports drive letters (E:) and paths (E:\Backups) │
│     • Mode 1/2 Elevation: Adding a destination prompts to enable file   │
│       sync and elevates profile to Mode 4 (or Mode 3 if headless)       │
│   • Set as Primary: Promotes any selected destination to Primary        │
│   • Remove Destination: Guardrail prevents removing the final drive     │
│     (Technician override permitted in Tech Mode with warning prompt)    │
│   • Silent Local Fallback: If no drive attached, bare-metal images save │
│     silently to C:\SystemImages without false-alarm warning toasts      │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 🛡️ Built-in Security Guardrails & Fallbacks:
1. **Never-Mute Guardrail for Errors & Warnings**: Standard settings strictly prohibit turning off warning or error alerts. Users can select between *Warnings & Errors Only (Recommended — Quiet)* and *All Notifications (Detailed)*, eliminating dangerous silent failure traps.
2. **System Tray Icon Visibility Toggle**: Users who prefer a clean notification area can hide the tray icon. The sentry displays a confirmation reminding them of the `Ctrl+Win+W` universal hotkey, while background scheduling, hotkey interceptors, and USB patrols remain active.
3. **1-Drive Minimum Guardrail & Technician Override**: Ordinary users cannot delete the last configured backup drive. In Tech Mode (or via CLI `-RemoveBackupDrive "D:" -Force`), technicians can clear drives when decommissioning or re-imaging a machine.
4. **Silent Bare-Metal Local Fallback (`C:\SystemImages`)**: If no secondary or external drive is attached during a scheduled image pass, WINBARS captures the bare-metal DISM image cleanly to `C:\SystemImages` at `INFO` level without raising false-alarm warning toasts.
5. **Frozen VSS Snapshot Capture**: Bare-metal DISM captures are bound to a temporary Volume Shadow Copy mount (`New-VssSnapshotMount`), guaranteeing 100% crash consistency and completely bypassing open-file lock collisions.


### 📊 Smart On-Demand Progress Engine
* **Desktop Shortcut**: Shows the live Dual Progress Bar immediately from start to finish (`-ShowProgress`).
* **Tray Menu & Automated Backups**: Run quietly in the background without stealing window focus. The tray icon turns **🟣 Purple**, and the top menu item dynamically shows `🟣 Status: Backup in Progress (X%)... Click to Show`. Clicking it opens the progress window on demand.

---

### 🚀 6 Deployment Profiles: The Two-Tier Architecture Split

WINBARS is architecturally divided into two distinct tiers: **Stealth / Native Windows Modes (0, N, 1)** that leave **zero resident third-party EXEs** on the host machine, and **Managed Suite Modes (2, 3, 4)** that provision the local executable (`C:\Tools\WINBARS`) with desktop shortcuts and sentry integration:

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                       WINBARS DEPLOYMENT SPECTRUM                                           │
├──────────────────────────────────────────────────────────────┬──────────────────────────────────────────────┤
│          TIER 1: STEALTH / NATIVE WINDOWS MODES              │          TIER 2: MANAGED SUITE MODES         │
│               (0 Resident Third-Party EXEs)                  │         (Local Suite in C:\Tools\WINBARS)    │
├──────────────────────────────┬───────────────────────────────┼──────────────────────────────┬───────────────┤
│ Mode 0: ZeroFootprint        │ Strict corporate compliance;  │ Mode 2: LocalDisasterGuard   │ Local bare-   │
│                              │ 0 resident files on C:\       │                              │ metal image + │
│                              │                               │                              │ desktop suite │
├──────────────────────────────┼───────────────────────────────┼──────────────────────────────┼───────────────┤
│ Mode N: NearZeroFootprint    │ Stealth native automation;    │ Mode 3: HeadlessFull         │ Silent daily  │
│                              │ generic unbranded shortcuts   │                              │ Robocopy +    │
│                              │                               │                              │ drive alerts  │
├──────────────────────────────┼───────────────────────────────┼──────────────────────────────┼───────────────┤
│ Mode 1: SystemUndo           │ Universal Service Warranty;   │ Mode 4: TotalProtection      │ Full suite +  │
│         (Stealth Hardener)   │ 0 EXEs, 0 shortcuts, daily    │                              │ Floppy Tray + │
│                              │ restore points + opt. image   │                              │ ScamBuster    │
└──────────────────────────────┴───────────────────────────────┴──────────────────────────────┴───────────────┘
```

### 📊 Unified Mode Matrix

| Profile & Mode | Target Persona | What It Protects | Footprint & Recovery Hooks | Resident Files |
| :--- | :--- | :--- | :--- | :---: |
| **Mode 0: `ZeroFootprint`** ⭐ | Strict Corporate Audits & MSP Compliance | Daily System Restore Point + Robocopy File Mirror (30-day retention) + Bare-Metal Image (`wbadmin`) + BitLocker Keys | Automated tasks run 100% via native Windows engines (`robocopy.exe`, `wbadmin.exe`, VSS) with zero USB required after setup | **0 Resident Files** *(0 bytes on C:)* |
| **Mode N: `NearZeroFootprint`** 👻 | Corporate Workstations & Vendor-Neutral Deployments | Mode 0 + generic unbranded desktop shortcuts (`Backup Personal Files`, `Windows System Restore`, `Browse Backup Files`) + unbranded Start Menu (`System Backup & Recovery`) | Automated via native Task Scheduler; restores via standard Explorer, `rstrui.exe`, and WinRE | **0 Resident EXEs** *(Generic Shortcuts Only)* |
| **Mode 1: `SystemUndo`** ⏪ | **Service Warranty Baseline & Bench Tune-Up** | **The Universal Service Warranty**: Daily unthrottled System Restore points, VSS writer auto-healing, 10% shadow storage headroom, driver/MSI checkpoints, and optional local baseline system image (`C:\SystemImages\_baseline.wim`) | Pure native Windows Task Scheduler automation (`powershell.exe Checkpoint-Computer`, `Set-Service`, `vssadmin`); WinRE detects restore points & `.wim` image | **0 Resident EXEs** *(100% Native Windows Hardening)* |
| **Mode 2: `LocalDisasterGuard`** 💽 | Traveling Laptops & Students (No External Drive) | Mode 1 + Local Partition Bare-Metal DISM Image (`.wim`) for offline recovery without external drive | Start Menu `WINBARS` Suite • Desktop `Create System Image` • `Ctrl+Win+W` On-Demand • Panic Hotkey (`Ctrl+Win+B`) • WinPE Boot Hooks | Local Suite (`C:\Tools\WINBARS`) |
| **Mode 3: `HeadlessFull`** 🏢 | Quiet Offices, CPAs & Medical Clinics (Has Drive) | Mode 1 + Daily Robocopy User File Sync + Scheduled Bare-Metal Images + Missing Drive Alerts | Silent background Task Scheduler execution • `Ctrl+Win+W` On-Demand • Panic Hotkey (`Ctrl+Win+B`) • WinPE Boot Hooks | Local Suite (`C:\Tools\WINBARS`) |
| **Mode 4: `TotalProtection`** 🛡️ | Seniors, VIPs & Scam-Prone Non-Technical Clients | Mode 3 + Complete Interactive Suite: Live Protection Center GUI + Floppy Tray Icon + ScamBuster Real-Time RAT Interceptor | Full interactive real-time protection • Floppy Tray Sentry • Scam Sentry • `Ctrl+Win+W` Protection Center | Local Suite (~18 MB RAM) |
| **Mode 5+: Custom Profiles** 🛠️ | Specialized Enterprise & Boutique Deployments | Dynamically selected components via `custom_profiles.json` or Pre-Flight toggle screen (`[0-9]`) | Configurable per-profile | Configurable |

---

### 🎯 Technician Customer Persona Cheat Sheet (3-Second Decision Matrix)
Need to know which profile to pick for a customer in 3 seconds? Use this cheat sheet:

| Profile Mode | Best For | Technician Rationale |
| :--- | :--- | :--- |
| **Mode 0: `ZeroFootprint`** | **Strict Corporate Audits & MSP Sterile Compliance** | Corporate clients or regulated workstations where security policy strictly forbids leaving any third-party files or scripts on `C:\`. The entire runner script and logs reside on the technician's external drive. |
| **Mode N: `NearZeroFootprint`** | **Corporate Workstations & Vendor-Neutral Stealth Deployments** | For business and corporate clients where third-party utility branding is restricted. Uses 100% native Windows Task Scheduler and generic shortcuts (`System Backup & Recovery`) so the automation blends seamlessly into Windows as a built-in system capability. **Zero background EXEs**, native Task Scheduler jobs (`\WindowsBackup\`), generic external folder (`E:\WindowsBackup\`), and generic native tools. Restores via native Explorer, `rstrui.exe`, & WinRE. |
| **Mode 1: `SystemUndo`** ⏪ | **Standard Bench Tune-Ups & Routine Warranty Service** | **The Universal Service Warranty Baseline**: Designed for standard bench tune-ups and hardware repairs. Hardens Windows' native recovery engines (unthrottles restore point frequency, locks 10% VSS shadow storage headroom, and enables native RegBack) with an optional 1-click baseline image. Operates with **zero third-party resident binaries and zero shortcuts**, delivering dependable rollback protection without introducing software overhead. |
| **Mode 2: `LocalDisasterGuard`** 💽 | **Road Warriors, Students & Mobile Laptops** | Traveling sales reps and laptop users who rarely plug in an external drive, but *want* on-demand desktop recovery shortcuts. Configures recurring monthly bare-metal DISM system images (`.wim`) to a local recovery partition with desktop suite integration and emergency hotkeys. |
| **Mode 3: `HeadlessFull`** 🏢 | **Silent Workstations, Accounting & Medical Clinics** | Production office environments (CPA firms, dental clinics, law offices) with dedicated external hard drives. Runs full daily Robocopy sync and bare-metal imaging 100% silently in the background with zero desktop clutter or user prompts—alerting only if the drive is unplugged. |
| **Mode 4: `TotalProtection`** 🛡️ | **Seniors, VIPs & Scam-Prone Non-Technical Clients** | Grandparents, non-technical clients, or high-value VIPs frequently targeted by browser pop-ups, fake virus sirens, and phone support scammers. Features the Floppy Disk Tray icon, active real-time ScamBuster and Remote Tool Interceptor (`[STOP] Disconnect & Block`), live GUI Protection Center, and your shop's emergency support hotline branding. |
| **Mode 5+: `Custom Profiles`** | **Specialized Enterprise & Boutique Deployments** | Tailored multi-drive configurations, specialized network shares, or specific retention tiers configured via `custom_profiles.json` or the Pre-Flight interactive builder. |

---

### 🪤 Ransomware Canary Shield Matrix: Who Gets What Protection?

| Profile Mode | Target Storage Monitored | Canary Placement | Detection & Enforcement Mechanism |
| :--- | :--- | :--- | :--- |
| **Mode 0 (`ZeroFootprint`)** | External Backup Drive | `.winbar_canary.dat` on external drive root | Cryptographic hash verified before and after each Robocopy file mirror pass. |
| **Mode N (`NearZeroFootprint`)** | External Backup Drive (`E:\WindowsBackup`) | `.winbar_canary.dat` on external drive root | Pre/post-sync integrity verification on every scheduled mirror run. |
| **Mode 1 (`SystemUndo` - Stealth)** | Internal System Drive (`C:`) | *None (0 resident background processes)* | **VSS Shadow Storage Quota Hardening**: Locks shadow storage headroom (10%) so ransomware cannot easily exhaust System Protection capacity. |
| **Mode 2 (`LocalDisasterGuard`)** | Local Image Archive (`C:\SystemImages`) | `C:\SystemImages\.winbar_canary.dat` | Inspected during scheduled bare-metal image capture passes and on-demand health audits. |
| **Mode 3 (`HeadlessFull`)** | External Backup Volumes & Shares | Multi-Target `.winbar_canary.dat` + `.winbars_remote_canary.sha256` | Daily automated pre-sync audit. If canary fails, aborts file sync immediately and disconnects network share. |
| **Mode 4 (`TotalProtection`)** | Local + All External & Network Targets | Real-time Honeypot Sentinels | **Continuous Real-Time Monitoring**: Floppy Tray Sentry actively watches tripwire tokens; triggers immediate desktop Toast alert, siren alarm, and Webhook dispatch (Discord/Slack/Teams). |

---

### 💡 Cumulative Architecture: Key Distinctions
* **Cumulative Tiering**:
  * **Stealth Modes (0, N, 1)** require zero resident third-party binaries on `C:\`.
  * **Mode 1 (`SystemUndo`)** establishes the rapid OS rollback foundation: unthrottled daily restore points, automated VSS self-healing, native Windows Task Scheduler automation, and an optional permanent baseline system image (`C:\SystemImages\_baseline.wim` if disk space $\ge 25$ GB).
  * **Mode 2 (`LocalDisasterGuard`)** builds on Mode 1 by provisioning `WINBARS.exe` to `C:\Tools\WINBARS`, adding desktop suite access, universal hotkeys (`Ctrl+Win+B` / `Ctrl+Win+W`), and monthly bare-metal DISM system images (`.wim`).
  * **Mode 3 (`HeadlessFull`)** adds automated differential Robocopy file sync to external drives, multi-drive rotation, and missing drive connection prompts.
  * **Mode 4 (`TotalProtection`)** adds the persistent Floppy Disk Tray sentry in the notification area, active real-time ScamBuster remote tool interceptor, and organization partner branding.
* **Universal Hotkey Sentry**:
  * In **Modes 2 through 4**, the emergency panic hotkey (`Ctrl+Win+B`) and Protection Center hotkey (`Ctrl+Win+W`) are available.
  * In **Stealth Modes (0, N, 1)**, strict 0-resident-binary policy is enforced: zero resident processes running in the background.
* **ScamBuster & Remote Access Interceptor**:
  * **Mode 4 (`FullInteractive`)** is the **only** profile that maintains an active, continuous background sentry listening for browser sirens and intercepting unauthorized remote access tools (AnyDesk, TeamViewer, UltraViewer, RustDesk) in real time.
* **GUI Dialog Availability Across All Profiles**:
  * Regardless of which profile is installed, whenever `WINBARS.exe` is launched directly (or with `-GUI` / `-StatusCard`), it immediately opens the **Protection Center Live Dashboard**. The dashboard includes a live **Installation & Profile Status Banner** (`✔ INSTALLED` or `⚠ NOT INSTALLED • Running from USB / Portable`) indicating the active profile.

*Switch profiles anytime via `WINBARS.exe -SetProfile <ProfileName>` or through the interactive technician menu (`[P]`).*

### 📋 Profile Capabilities Breakdown (Info Modal & CLI Inspector)

WINBARS provides a comprehensive breakdown for each of the 6 deployment styles explaining **What it DOES**, **What it Does NOT Do**, and **Togglable Settings**:

* **In the GUI Protection Center**:
  Click the deployment profile pill (`▶ [Profile Name]`) in the status bar to launch the interactive **Deployment Profile Capabilities Breakdown** modal with multi-tab comparisons across all 6 profiles (Modes 0, N, 1, 2, 3, and 4).
* **In the CLI Profile Manager (`[P]`)**:
  * Selecting any profile (0–4 and Mode N) presents the detailed capability card and prompts for explicit confirmation (`Apply Profile X to this machine? (Y/n)`) before executing changes.
  * Press **`[I]`** to inspect or compare all 6 profiles sequentially or individually without applying them.

---

## ❓ Frequently Asked Questions (FAQ)

### Q: Why isn't WINBARS open-source?
WINBARS is distributed as a pre-compiled, self-contained standalone executable (`WINBARS.exe`) for two core reasons:
* **Preventing Predatory Exploitation**: In the Windows utility ecosystem, open-source recovery scripts are frequently cloned, bundled into ad-supported download wrappers, or repackaged into predatory monthly "driver booster" subscriptions that exploit everyday users for free native Windows capabilities. Keeping the orchestrator compiled ensures WINBARS remains clean, local, and 100% free.
* **Tamper-Proof Reliability**: Distributing as an immutable binary prevents well-meaning users or rogue scripts from corrupting recovery logic, eliminates PowerShell `ExecutionPolicy` friction, and guarantees identical, reliable behavior across client workstations.

**Can I audit what WINBARS does?**  
Yes, completely. WINBARS operates with full host transparency: zero outbound network connections, zero kernel filter drivers, and all recurring operations run through native Windows Task Scheduler using standard Windows binaries (`robocopy.exe`, `wbadmin.exe`, `powershell.exe`). You can independently inspect every task, file, and registry key—see the [System Footprint & Security Audit Blueprint](docs/SYSTEM_FOOTPRINT.md).

### Q: Why is WINBARS distributed as a compiled standalone executable (`WINBARS.exe`)?
1. **Resilience Against Accidental Modification**: Packaging as a standalone application protects mission-critical automation from well-meaning end users, family members, or tier-1 support technicians who might inadvertently right-click "Edit", introduce syntax errors, or break recovery schedules.
2. **Zero Scripting & Policy Friction**: Bypasses PowerShell Execution Policy restrictions (`Restricted`, `AllSigned`) out-of-the-box. Users and technicians can run it immediately without modifying system security policies or opening PowerShell command consoles.
3. **Turnkey Technician Deployment**: Everything is self-contained in a single executable under 1 MB. No Python runtimes, no Node.js bloat, and no multi-file dependency trees. Copy `WINBARS.exe` to a USB drive and protect any machine in 15 seconds.
4. **Distinct System & Process Identity**: Windows Task Scheduler, Defender, and Task Manager see a distinct, named application (`WINBARS.exe`) with dedicated tray icons and process accounting, rather than an anonymous background PowerShell host.

### Q: Is WINBARS sending any data to the cloud, or using telemetry?
**No. Absolutely zero.** WINBARS operates under a strict, verifiable zero-telemetry policy:
* **Zero Telemetry**: No tracking scripts, no analytics pings, no advertising SDKs, and no usage monitoring.
* **Zero Cloud Dependence**: No online accounts, no email signups, and no cloud logins required.
* **100% Offline & Air-Gapped Capable**: Works completely offline. Every backup, restore point, log file, and BitLocker recovery key remains strictly on your local PC and your personal external storage drive.

### Q: Can I restore my files if WINBARS is uninstalled or if my PC dies?
**Yes, 100%. This is the "Zero Vendor Lock-In" guarantee.**
WINBARS never traps your data inside proprietary container files:
* Mirrored files in `D:\WINBARS_Backup\UserBackups\` are standard Windows files. You can plug your backup drive into **any PC, Mac, or Linux computer** and drag-and-drop your files directly.
* System images are standard Microsoft DISM `.wim` files readable by native Windows setup media.
* BitLocker recovery cards are standard offline `.html` documents you can view in any browser.

### Q: Does a System Restore Point affect my personal files?
**No, absolutely not.** System Restore Points in WINBARS use native Windows Volume Shadow Copies (`rstrui.exe`, `Checkpoint-Computer`). They function 100% like traditional Windows System Restore points: they revert Windows system files, drivers, and registry settings, but your personal documents, family photos, desktop files, downloads, and emails are **never modified or removed** by a System Restore.

---

## 👻 Deep Dive: The Agentless Zero-Footprint Architecture (0 Resident Binaries)

The **Zero-Footprint profile** was engineered specifically for computer repair technicians, managed service providers (MSPs), and power users who need to set up bulletproof, recurring disaster protection on a customer's or family member's PC **without leaving third-party background software, resident executables, or persistent scripts on the target machine (`C:\`)**.

Everything needed to perform daily backups, resolve drive shifts, log history, and execute emergency rollbacks lives **directly on the external backup storage drive**.

### 🌟 12 Core Pillars of the Zero-Footprint Engine:

1. **0 Resident Third-Party Binaries on Target Machine (`C:\`) (Agentless Native Design)**:
   * No `WINBARS.exe`, no background daemons, and no persistent scripts are installed on the internal system drive.
   * The primary automated runner script (`Run-ZeroFootprintSync.ps1`) and backup logs (`Sync_History.log`) reside entirely within `D:\Backup_Logs\` on the external backup drive.
2. **100% Native Windows Task Scheduler Automation**:
   * Uses standard Windows tasks registered cleanly in `\WindowsBackup\` running with `NT AUTHORITY\SYSTEM` (highest integrity):
     * **`\WindowsBackup\SystemRestorePoint`**: Runs daily at configured time + system startup. Disables Windows 24-hour throttling (`SystemRestorePointCreationFrequency = 0`) and guarantees 10% VSS shadow storage headroom.
     * **`\WindowsBackup\UserProfileSync`**: Runs daily to mirror `C:\Users` (and any configured secondary drives) directly to the external drive.
     * **`\WindowsBackup\SystemImageBackup`**: Runs monthly via native `wbadmin.exe` capturing bare-metal DISM system images.
3. **Dynamic Drive Drift Shield (Auto-Discovery)**:
   * When external USB drives are unplugged and reconnected, Windows often reassigns them different drive letters (e.g. `D:` shifts to `E:` or `F:`).
   * The Task Scheduler command and the sync runner dynamically query `Win32_LogicalDisk` for the signature marker (`\Backup_Logs\Run-ZeroFootprintSync.ps1` or `.winbars_target`), automatically resolving the active drive letter on the fly with zero dropped backups.
4. **Smart 1:1 Robocopy Mirror with Active Volume Shadow Copy (VSS) Snapshot Mount**:
   * **Bypassing In-Use & Exclusively Locked Files**: Traditional live mirroring with `robocopy.exe /ZB` uses backup semantics to bypass NTFS ACLs, but it can still fail on exclusively locked files (such as active Outlook `.pst`/`.ost` stores, running browser SQLite databases like Chrome/Edge `History` and `Cookies`, active accounting databases, or running VM disks).
   * **Automated VSS Mountpoint (`mklink /D`)**: WINBARS automatically binds live Robocopy passes directly to a temporary Volume Shadow Copy snapshot mount (`New-VssSnapshotMount` via `Win32_ShadowCopy` and `mklink /D`). Robocopy mirrors cleanly from the frozen VSS snapshot volume, guaranteeing 100% consistent, non-corrupted reads of active databases with zero locked-file errors. Once the mirror pass completes, the temporary junction and shadow copy are cleanly unmounted and released.
   * **Accidental Deletion Protection (`_DeletedArchive`)**: Before mirroring, a non-destructive pre-scan moves any files deleted or modified on the PC into timestamped isolation folders (`_DeletedArchive\YYYY-MM-DD\`). Expired archives (> 30 days) are pruned automatically.
   * **Low Disk Space Headroom Guard**: If the backup drive drops below 10 GB free, an accelerated prune cleans archives older than 7 days; if space drops below 2 GB, the sync pauses safely to protect data integrity.
5. **Conflict-Safe Smart Swap & Race Condition Shield**:
   * **Bi-Directional USB Editing**: If a user or technician edits or creates documents directly on the external backup drive while away from the office, WINBARS detects the newer timestamp upon connection.
   * **Active File-In-Use Detection (Race Condition Shield)**: Before touching any file on the PC, WINBARS performs an active kernel sharing test (`[System.IO.File]::Open` with exclusive lock detection).
     * **When the PC Document is Open/Locked**: If a user left a document open in Word, Excel, or another program on the PC while editing a copy on the USB, WINBARS **never overwrites or moves** the live document. Instead, it saves the newer USB version alongside it as:
       `FileName (Conflict from USB - <COMPUTERNAME> - YYYY-MM-DD_HHmmss).ext`, logs a clear warning, and raises a Windows Toast notification.
     * **When the PC Document is Closed**: The older PC version is safely archived with machine identity as:
       `FileName (Older PC Copy - <COMPUTERNAME> - YYYY-MM-DD).ext` and mirrored into `_DeletedArchive`, before promoting the newer USB file to active and updating Windows Explorer Recent shortcuts.
6. **USB-Hosted RegBack & Native WinPE Rescue Script**:
   * Every backup pass creates an offline, atomic registry hive snapshot (`SYSTEM`, `SOFTWARE`, `SAM`, `SECURITY`, `DEFAULT`) in `D:\Backup_Logs\Registry_Snapshots\Latest\`.
   * **WinPE / WinRE Rescue Script (`Restore_Registry_WinPE.bat`)**: A standalone, zero-dependency batch script generated directly inside the registry snapshots folder. If Windows blue-screens or fails to boot, open Command Prompt in Windows Recovery Environment, run the script from the USB, and restore clean registry hives in 5 seconds with dynamic Windows drive detection.
   * Enables native Windows automatic RegBack key (`EnableRegistryBackup = 1`).
7. **Boot Configuration Data (BCD) Backup & 1-Click WinRE Rescue Subsystem**:
   * Generates atomic binary BCD hives (`BCD_Backup`) and plaintext human-readable configuration ledgers (`BCD_Configuration_Audit.txt`) alongside System Restore points, DISM system images, and on external USB drives (`Boot_Rescue\`).
   * **1-Click WinRE Rescue Batch Script (`Restore_BCD_WinPE.bat`)**: Located right inside the rescue directory. Resolves BSOD bootloops, corrupted BCD stores, and missing bootloader entries directly from Windows Recovery Environment Command Prompt. Features dynamic Windows drive letter detection (`TARGET_WIN`), pre-restore rollback backup, direct BCD import, and automated `bcdboot` fallback rebuilding.
8. **Automated BitLocker Recovery Key Archival**:
   * Automatically discovers active BitLocker encryption keys across all fixed drives and archives the 48-digit numerical passwords to `D:\BitLocker_Recovery_Key.txt` and `D:\Backup_Logs\BitLocker_Recovery_Key.txt`.
   * If a motherboard swap, TPM glitch, or BIOS update locks the machine, the user can read their recovery password from the USB drive on any phone, tablet, or secondary PC.
9. **Explorer Cloaking & Drive Stealth Architecture**:
   * Prevents non-technical users from accidentally deleting backup files or getting confused by external drive letters by hiding the backup volume in Windows Explorer (`This PC`) via native `NoDrives` policy.
   * Scheduled tasks, Robocopy, and wbadmin continue accessing the cloaked drive normally in the background.
   * **1-Click USB Toggle Script (`Toggle_Backup_Drive_Visibility.bat`)**: Located right on the root of the USB drive. Anyone with physical access can double-click this script to instantly cloak or uncloak the drive on any PC without installing any software.
10. **Unbranded Disaster Recovery & Restoration Guide (`README_RECOVERY.txt`)**:
   * A clear, unbranded plain-text document created at the root of the backup drive detailing step-by-step instructions for 1:1 file restoration, recovering deleted files from `_DeletedArchive`, running WinRE registry rollback, and bare-metal imaging.
11. **Configurable Native Toast Notifications**:
    * Clean Windows 10/11 native toast notifications without any background processes:
      * **`All`** (Recommended Default): Toast notifications on backup completion, warnings, or errors.
      * **`WarningsAndErrors`**: Completely silent on success; notifies only if an error or low space occurs.
      * **`Disabled`** (Stealth Mode): 0 notifications; all execution details logged strictly to file.
12. **Technician Audit Profile & USB Adjustment Menu**:
    * Setup saves client metadata to `ZeroFootprint_Profiles\<COMPUTERNAME>.json` on the technician's USB drive.
    * Reconnecting the USB drive to the workstation and launching WINBARS automatically detects the machine's profile and opens the **Zero-Footprint Adjustment Menu** (`[P]`), allowing quick adjustments to sources, schedules, notification modes, drive cloaking, or clean uninstallation.

---

## 🛡️ Enterprise Auditability & Tamper-Proof Architecture

Power users and system administrators can understandably be skeptical of closed-source system utilities that run with elevated privileges (`NT AUTHORITY\SYSTEM`). WINBARS disarms this concern by maintaining an uncompromising architectural boundary between its **orchestration wrapper** and the **native host operations** it registers:

### 1. Transparent Host Auditability Over Code Secrecy
* While the compilation wrapper is packaged as a standalone binary to protect project integrity, **the operations WINBARS schedules on the target machine are completely transparent, un-obfuscated, and independently auditable**.
* WINBARS installs zero proprietary background services, zero kernel-mode filter drivers, and zero network telemetry hooks.
* Technicians can open Windows Task Scheduler (`taskschd.msc`), navigate to `\WindowsBackup\`, and inspect every registered job, schedule trigger, command line, and execution argument.
* On the backup target drive, every generated helper script (`Run-ZeroFootprintSync.ps1`, `Run-ManualTask.ps1`, `Toggle_Backup_Drive_Visibility.bat`, `README_RECOVERY.txt`) is 100% human-readable plaintext. There are no proprietary database blobs—all data remains 1:1 accessible using native Windows tools.

### 2. The "Tamper-Proof" Bench Appliance Angle
* In bench operations, IT support shops and MSPs face a frustrating reliability problem: well-meaning clients, curious power users, or junior staff inspecting exposed `.ps1` or `.bat` script files, accidentally deleting a quotation mark or altering arguments, and silently killing automated disaster recovery schedules for months.
* Packaging WINBARS as an immutable standalone executable (`WINBARS.exe`) provides a **tamper-proof operational appliance**. It protects the client from accidentally breaking their own disaster recovery setup, eliminates PowerShell `ExecutionPolicy` conflicts (`Restricted` / `AllSigned`), and guarantees deterministic execution across reboots.
* **System Footprint & Verification**: For the line-item inventory of every file path, registry key, scheduled task, and a 60-second Sysinternals verification guide, see the [System Footprint & Security Audit Blueprint](docs/SYSTEM_FOOTPRINT.md).

---

## ⌨️ Universal Global Hotkeys

WINBARS uses the non-conflicting `Ctrl + Win` modifier family for instant emergency access:

* **`Ctrl + Win + W` $\rightarrow$ WINBARS Protection Center**:
  Summons the live system health dashboard displaying restore point age, backup status, storage health, and one-click quick actions.
  *(If another application claims this shortcut, WINBARS automatically cascades to `Ctrl + Win + P` $\rightarrow$ `Ctrl + Alt + W` without errors).*
* **`Ctrl + Win + B` $\rightarrow$ Emergency Scam Buster**:
  Instantly closes rogue browser lockups, silences audio sirens, defuses Chromium crash loops, and terminates weaponized remote access tools across 25+ web browsers.
* **`Ctrl + Shift + F12` $\rightarrow$ Quick Assist Remote Support**:
  Launches native Microsoft Quick Assist (`quickassist.exe`) for fast, authorized remote screen-sharing with a trusted technician or family member. (Default updated to eliminate conflict with native Windows Quick Assist).
* **Technician Mode Configurable Hotkeys**:
  All three hotkeys can be customized in Tech Mode (`config.json` -> `Hotkeys` or CLI Setup Menu) with dynamic Win32 collision probing (`Test-HotkeyComboAvailable`). Alt/AltGr combinations are strictly barred to prevent international keyboard layout dead-key conflicts.
* **Technician Mode & Tech Console**:
  Novice-safe by default. Unlocked inside the Protection Center dialog by pressing `Ctrl + T` or triple-clicking (3x) the status bar/pill.

---

## 🔒 Novice Protection & Technician Mode

To prevent accidental misconfiguration or confusion when end users and novices access the Protection Center GUI (`Ctrl + Win + W`):

1. **Hidden Advanced Menu by Default**:
   * The advanced `⚙ Tech Console` link and CLI access are hidden by default when the dialog opens. Novices see a clean, friendly interface with simple 1-click actions (*Create Backup Now*, *Emergency System Restore*, *Restore Files*, *Settings*, and *BitLocker Recovery Keys*).
2. **Unlocking Technician Mode**:
   * **Mouse**: Triple-click (3x) the status bar/pill (`✔ INSTALLED` / `⚠ NOT INSTALLED`).
   * **Keyboard**: Press `Ctrl + T` while the Protection Center dialog is focused.
3. **Unlocked State & Instant Relocking**:
   * Once unlocked, the status bar shifts to amber: `[TECH MODE UNLOCKED] • Click to Lock` and reveals the `⚙ Tech Console` link.
   * **1-Click Lock**: Clicking the amber pill/bar immediately locks Technician Mode back to safe Novice Mode.
   * **Per-Session Security**: Technician Mode is strictly in-memory and is never persisted to disk. Closing and reopening the dialog always resets it back to protected Novice Mode.

---

## 🚀 Quick Start & CLI Reference

### 0. Turnkey One-Click Batch Launchers (`.bat`)
For rapid field deployment from a technician flash drive, WINBARS includes standalone batch scripts that execute common actions with 0–2 questions:

| Batch Launcher | Target Profile / Operation | Prompts | Unattended Switches |
| :--- | :--- | :---: | :--- |
| **`Run-WINBARS.bat`** | Main Interactive Technician Launcher & Self-Elevation | Menu | N/A (Interactive Hub) |
| **`Install-Mode0-ZeroFootprint.bat`** | Mode 0: Zero Footprint (100% native Windows automation) | 2 | `/?`, `/Quiet`, `/Vanilla`, `/Data:<Path>`, `/Image:<Path>` |
| **`Install-ModeN-NearZeroFootprint.bat`** | Mode N: Near-Zero Footprint (Stealth native automation) | 2 | `/?`, `/Quiet`, `/Vanilla`, `/Data:<Path>`, `/Image:<Path>` |
| **`Install-Mode1-SystemUndo.bat`** | Mode 1: System Undo (Daily restore points & VSS auto-heal) | **1** | `/?`, `/Quiet`, `/Vanilla`, `/Baseline:Y\|N` |
| **`Install-Mode2-LocalDisasterGuard.bat`** | Mode 2: Local Disaster Guard (Local partition DISM image) | **0** | `/?`, `/Quiet`, `/Vanilla`, `/Brand:"Name"` |
| **`Install-Mode3-HeadlessFull.bat`** | Mode 3: Headless Full (Silent Robocopy + images) | 2 | `/?`, `/Quiet`, `/Vanilla`, `/Brand:"Name"`, `/Data:<Path>`, `/Image:<Path>` |
| **`Install-Mode4-TotalProtection.bat`** | Mode 4: Total Protection (Tray sentry + Scam Buster) | 2 | `/?`, `/Quiet`, `/Vanilla`, `/Brand:"Name"`, `/Data:<Path>`, `/Image:<Path>` |
| **`Capture-Baseline.bat`** | Capture Permanent Baseline System Image (`_baseline.wim`) | 1 | `/?`, `/Quiet`, `/Pin:Y\|N`, `/Label:"Text"` |
| **`Create-RestorePoint.bat`** | Immediate Atomic System Restore Point | **0** | `/?`, `/Quiet`, `/Pin:Y\|N`, `/Label:"Text"` |
| **`Toggle_Backup_Drive_Visibility.bat`** | Cloak or Unhide Backup Volume in File Explorer | **0** | `/?` |
| **`Uninstall.bat`** | Complete Suite & Task Removal | **0** | `/?`, `/Quiet` |

> 💡 **Batch Script CLI Syntax**: All installers support `/?` for built-in help, `/Quiet` for unattended execution, `/Vanilla` for unbranded deployment, and `/Brand:"Name"` to apply shop branding. See the [Full CLI Reference](docs/CLI_REFERENCE.md) for 1-line automation examples.

### 1. Technician Launcher Menu (`Run-WINBARS.bat`)
When running from a USB drive or local technician directory, launch `Run-WINBARS.bat` for the streamlined 6-option operational menu:

```text
============================================================
  WINBARS - WINDOWS BACKUP, ASSISTANCE, RECOVERY & SECURITY
============================================================
 Current Location: E:\WINBARS
 Branding Status:  -Branded (or -Vanilla)
============================================================
 SELECT ACTION:
============================================================
 [1] Deploy Zero-Footprint Profile (0 resident files on PC) [Default]
 [2] Launch Technician Interactive Console & Setup Wizard
 [3] Run Backup Now (On-Demand File Mirror & Restore Point)
 [4] Disaster Recovery Center (WinPE / Blue Screen / File Restore)
 [5] Toggle Backup Drive Visibility (Explorer Cloak)
 [6] Open WINBARS Protection Center (GUI Dashboard)
 [I] Install / Provision Suite to C:\Tools\WINBARS
 [0] Exit
============================================================
```
* **Option 1 (Zero-Footprint)**: Deploys 100% native Windows Task Scheduler automation (`\WindowsBackup\`) with 0 resident files on `C:\`. Runs completely unbranded.
* **Option 2 (Technician Console)**: Detects if `branding.json` is present and prompts the technician whether to apply shop branding or deploy vanilla. Also prompts to provision locally to `C:\Tools\WINBARS` if desired.
* **Option 3 (On-Demand Backup)**: Executes an immediate unbuffered Robocopy file mirror and unthrottled System Restore Point with the Dual Progress Bar.
* **Option 4 (Disaster Recovery)**: Launches the emergency restoration and WinPE recovery center.
* **Option 5 (Toggle Cloaking)**: Toggles backup drive letter visibility in Windows Explorer (`This PC`) using native `NoDrives` policy.
* **Option 6 (GUI Dashboard)**: Opens the interactive Protection Center live health dashboard.

### 2. Interactive Console Dashboard
Double-click `WINBARS.exe` or select Option 2 to launch the technician console:

```text
==========================================================
   WINBARS - Windows Backup, Assistance, Recovery & Security Suite (v0.9.0)
==========================================================
 Active Deployment Profile : [FullInteractive]
 Runner Execution Location : [C:\Tools\WINBARS]

 [P] Deployment Profile & Silent Mode Manager   [FullInteractive]
 [U] Quick In-Place Suite Update & Task Refresh [C:\Tools\WINBARS • v0.9.0]
 [1] Suite Setup, Auto-Heal & Task Management   [4/4 Tasks Active]
 [2] Run Backup Passes Now (On-Demand)          [Target: D:\ (207.2 GB Free)]
 [3] System Recovery & File Restoration Helpers [WINBARS_Baseline_2026-09-08_1510]
 [4] Self-Diagnostics & System Health Check     [Hardware S.M.A.R.T. & VSS]
 [5] Log Management & Retention Utilities       [Logs: C:\ProgramData\WINBARS\Logs]
 [6] Ransomware Canary Shield & Alert Guard     [Alert Guard Active]
 [H] Toggle Backup Destination Drive Cloaking   [Drive D: Visible]
 [0] Exit Suite
 [5] Log Management & Retention Utilities
 [6] Ransomware Canary Shield & Webhook Alerting
 [H] Command-Line Reference & Syntax Help
 [0] Exit Suite
```

### 3. Visual Quick-Scan CLI Reference

| Operational Domain | Command Syntax | Description & Execution Details |
| :--- | :--- | :--- |
| **⚡ 1-Click Backup** | WINBARS.exe -Action FastBackup | Runs quiet fast backup (mirrors personal files + creates System Checkpoint). |
| **📊 Visual Backup** | WINBARS.exe -Action FastBackup -ShowProgress | Launches live Dual Progress Bar showing file & byte-level sync in real-time. |
| **🛡 System Checkpoint** | WINBARS.exe -Action RestorePoint | Creates hardened, unthrottled atomic Windows System Restore Point. |
| **💾 Bare-Metal Image** | WINBARS.exe -Action SystemImage | Captures crash-consistent DISM .wim bare-metal image to target or C:\SystemImages. |
| **📦 Complete Backup** | WINBARS.exe -Action All | Runs full 3-tier pass (Restore Point + Personal File Mirror + DISM Image). |
| **🚀 Deploy Mode 0** | WINBARS.exe -Profile ZeroFootprint | Deploys 100% native Windows automation with **0 resident files on C:\**. |
| **👻 Deploy Mode N** | WINBARS.exe -Profile NearZeroFootprint | Deploys stealth native automation with **0 background EXEs** and unbranded shortcuts. |
| **🛡 Deploy Mode 1** | WINBARS.exe -Profile SystemUndo | Deploys daily System Restore hardening + VSS auto-heal (rapid OS rollback). |
| **🛡 Deploy Mode 2** | WINBARS.exe -Profile LocalDisasterGuard | Mode 1 + local recovery partition bare-metal DISM image (laptops/single-drive). |
| **🛡 Deploy Mode 3** | WINBARS.exe -Profile HeadlessFull | Mode 1 + daily external Robocopy file sync + image archive (silent workstations). |
| **🛡 Deploy Mode 4** | WINBARS.exe -Profile TotalProtection | Mode 3 + signature Floppy Tray Sentry + ScamBuster active watchdog + GUI. |
| **👁 Cloak Drive** | WINBARS.exe -ToggleDriveCloaking | Toggles backup target drive visibility in Windows Explorer (*This PC*). |
| **💾 Disk Destinations** | WINBARS.exe -ListBackupDrives | Displays formatted table of registered destinations, capacity, and online health. |
| **➕ Add Destination** | WINBARS.exe -AddBackupDrive E: | Registers backup destination (E: or custom directory E:\Backups). |
| **➖ Remove Target** | WINBARS.exe -RemoveBackupDrive D: [-Force] | Removes target (enforces 1-drive minimum; -Force for technician override). |
| **🔄 Refresh Triggers** | WINBARS.exe -Action UpdateTriggers | Dynamically updates Task Scheduler triggers to match current schedule. |
| **🚨 ScamBuster** | WINBARS.exe -ScamBuster | Terminates browser lockups, silences sirens, and clears crash loops (Ctrl+Win+B). |
| **📋 Emergency Card** | WINBARS.exe -EmergencyCard | Generates printable BitLocker Disaster Recovery Emergency Card (.html). |
| **🖥 Quick Assist** | WINBARS.exe -QuickAssist | Launches Microsoft Quick Assist with store technician branding (Ctrl+Win+Q). |
| **📊 Protection Center** | WINBARS.exe -GUI / -StatusCard | Opens Protection Center Live Dashboard (Ctrl+Win+W). |
| **🧹 Complete Removal** | WINBARS.exe -Uninstall | Cleanly removes all scheduled tasks, desktop shortcuts, and tray sentry. |

### 4. Raw Command-Line Terminal Reference


```cmd
REM --- Quick Diagnostics & Status ---
WINBARS.exe -StatusCard                         REM Open GUI Protection Center (Ctrl+Win+W)
WINBARS.exe -Diagnose                           REM Run full system diagnostics and S.M.A.R.T. health check
WINBARS.exe -Docs                               REM Open Interactive Technical Manual Hub

REM --- On-Demand Backups ---
WINBARS.exe -Action FastBackup                  REM Run quiet 1-click backup (Files + Restore Point)
WINBARS.exe -Action FastBackup -ShowProgress    REM Run backup with visual Dual Progress Bar
WINBARS.exe -Action All                         REM Full backup (Files + Restore Point + DISM Image)
WINBARS.exe -Action RestorePoint                REM Create hardened System Restore Point immediately
WINBARS.exe -Action SystemImage                 REM Capture bare-metal DISM system image (.wim)

REM --- Deployment Profiles & Zero-Footprint ---
WINBARS.exe -Profile ZeroFootprint              REM Deploy 100% Native Zero-Footprint (0 resident files on PC)
WINBARS.exe -Profile NearZeroFootprint          REM Deploy Near-Zero Footprint Profile (Stealth Native Automation)
WINBARS.exe -Install -Profile ZeroFootprint     REM Setup Zero-Footprint tasks in \WindowsBackup\
WINBARS.exe -Install -Profile NearZeroFootprint REM Setup Near-Zero tasks with unbranded shortcuts
WINBARS.exe -Install -Profile HeadlessFull      REM Install Managed Suite in completely silent headless mode
WINBARS.exe -Install                            REM Install Managed Suite (FullInteractive with tray & shortcuts)

REM --- Drive Stealth & Explorer Cloaking ---
WINBARS.exe -ToggleDriveCloaking                REM Toggle backup drive visibility in 'This PC' (Show / Hide)
WINBARS.exe -HideBackupDrive -Target D:          REM Cloak backup drive letter in Windows Explorer
WINBARS.exe -ShowBackupDrive -Target D:          REM Uncloak and restore backup drive visibility in Explorer

REM --- Multi-Destination Disk Management ---
WINBARS.exe -ListBackupDrives                   REM Display formatted table of registered destinations & health
WINBARS.exe -AddBackupDrive E:                  REM Register a new backup drive letter
WINBARS.exe -AddBackupDrive "E:\Backups"        REM Register a custom directory destination
WINBARS.exe -SetPrimaryBackupDrive E:           REM Designate a drive as Primary backup destination
WINBARS.exe -RemoveBackupDrive "E:\Backups"     REM Remove destination (enforces 1-drive minimum)
WINBARS.exe -RemoveBackupDrive D: -Force        REM Technician override to clear all drives (decommissioning)

REM --- Dynamic Schedule Synchronization ---
WINBARS.exe -Action UpdateTriggers              REM Refresh Task Scheduler triggers to match current config

REM --- Emergency Tools ---
WINBARS.exe -ScamBuster                         REM Kill rogue browser lockups and clear crash loops (Ctrl+Win+B)
WINBARS.exe -EmergencyCard                      REM Open printable BitLocker recovery card
WINBARS.exe -QuickAssist                        REM Launch native Microsoft Quick Assist remote support (Ctrl+Win+Q)

REM --- System Tray & Desktop Shortcuts ---
WINBARS.exe -Tray                               REM Launch background Floppy Tray Sentry
WINBARS.exe -CreateShortcuts                    REM Install 4 Action Desktop Shortcuts (Managed Suite)
WINBARS.exe -Uninstall                          REM Cleanly remove all tasks, shortcuts, and tray sentry
```

---

## 🏷️ White-Labeling & Community Shop Sponsorship ($100 One-Time Token)

### Custom Shop Identity & Direct Client Support Channels

For independent repair shops, system integrators, and MSPs, keeping your contact information front-and-center ensures clients reach your bench when issues arise rather than falling prey to online search scams or fake tech support call centers.

Community sponsorship of **$100 (one-time)** funds continued development and open-source maintenance of the WINBARS project. As an appreciation perk for sponsoring shops, RemarkablePC issues a digitally signed, offline `branding.json` token that seamlessly integrates your shop's identity into client-facing components.

```
   ┌────────────────────────────────────────────────────────┐
   │           Protected by ACME Computer Repair            │
   │     Managed Safeguards, System Recovery & Security     │
   ├────────────────────────────────────────────────────────┤
   │  [Call Support: 555-0199]   [Visit Helpdesk Web]       │
   │  [Launch Remote Support]    [Backup Personal Data]     │
   └────────────────────────────────────────────────────────┘
```

### 💼 Technical Integration & Architecture

1. **Air-Gapped Cryptographic Signature (ECDSA-SHA256)**:
   * Your branding token is cryptographically signed using an asymmetric ECDSA-SHA256 key pair and AES-256 integrity checks.
   * Signature verification runs **100% locally and offline** via native Windows `.NET / CNG` cryptographic APIs.
   * Zero outbound telemetry, zero licensing servers, and zero connectivity dependencies. Deployments remain fully valid indefinitely, even in isolated air-gapped environments.

2. **Client-Facing Integration Touchpoints**:
   * **Protection Center (`Ctrl + Win + W`)**: Displays your shop name, hotline, and emergency contact details on the main dashboard header and assistance tabs.
   * **Direct Remote Support**: Connects the client directly to your shop's preferred remote assistance platform or Microsoft Quick Assist pre-populated with your technician instructions.
   * **BitLocker Emergency Recovery Card**: Formatted emergency key printouts embed your shop's support contact and recovery instructions.
   * **Scam Sentry Interceptor (Mode 4)**: Unsolicited remote access alerts instruct the user to immediately disconnect and dial your verified shop hotline.

3. **Perpetual Technician Usage**:
   * A single token covers all workstations serviced by your bench or shop without per-seat license counts or renewal subscriptions.

### 🛠️ Obtaining and Deploying a Shop Token

1. **Request a Token**: Visit the [RemarkablePC Community Sponsorship Portal](https://www.paypal.com/ncp/payment/EKH76RTYHH24S) and provide your shop name, support phone number, and helpdesk URL.
2. **Receive `branding.json`**: You will receive a validated, digitally signed token file tailored to your organization.
3. **Deploy via USB Bench Toolkit**:
   * Place `branding.json` in the root folder alongside `WINBARS.exe`.
   * When launching `Run-WINBARS.bat` or applying deployment profiles, WINBARS automatically detects, validates, and installs the shop branding token into `C:\Tools\WINBARS\branding.json`.
   * Branded identity can also be bundled directly into standalone technician builds using the `-BrandingPath` parameter.

---

## 📚 Technical Documentation Directory

For complete architectural diagrams, WinRE configuration guides, and implementation specifications, see the documentation files in [`/docs/`](docs/):

* 📐 [Architecture & Data Flow Manual](docs/ARCHITECTURE.md)
* 🔍 [System Footprint & Security Audit Blueprint](docs/SYSTEM_FOOTPRINT.md)
* 🔑 [BitLocker AES-256 Disaster Vault Guide](docs/BITLOCKER_VAULT.md)
* 🛑 [Scam Sentry & Remote Access Interceptor](docs/SCAM_SENTRY.md)
* 🚑 [WinRE Blue Screen & Disaster Recovery Manual](docs/DISASTER_RECOVERY.md)
* ⌨️ [Full Command-Line CLI Reference](docs/CLI_REFERENCE.md)
* 🏷️ [White-Labeling & Store Branding Guide](docs/WHITE_LABELING.md)

---

## 📋 Technical Requirements

* **Operating System**: Windows 10 (1809+), Windows 11 (all versions), Windows Server 2016/2019/2022/2025.
* **Engine Framework**: Microsoft PowerShell 5.1+, Windows Management Instrumentation (WMI/CIM), Volume Shadow Copy Service (VSS), DISM (`dism.exe`), Robocopy (`robocopy.exe`).
* **Hardware S.M.A.R.T.**: Works with NVMe SSDs, SATA SSDs, and mechanical hard drives via native Windows storage drivers.
* **Binary Size**: Standalone executable $\approx 640$ KB with zero external runtime dependencies.

---

## ⚖️ Legal & Process Interception Disclaimer

WINBARS is an orchestration and disaster recovery framework that automates and hardens native Windows system utilities (DISM, VSS, WMI, Robocopy, BitLocker, and WinRE). 

WINBARS also provides proactive end-user defense mechanisms:
1. **Scam Buster Emergency Kill Switch (`Ctrl+Win+B`)**: Instantly terminates active browser processes to break malicious full-screen locking scripts, audio siren loops, and tech-support scams.
2. **Remote Access Interceptor**: Detects newly launched third-party remote administration tools (such as AnyDesk, TeamViewer, UltraViewer, ScreenConnect, and RustDesk) and presents an immediate confirmation banner to the local user.

### Operation Under Explicit Human Direction
* **Human Agency**: All process terminations and remote tool disconnects executed by WINBARS operate **strictly at the explicit direction and affirmative consent of the local user** (e.g., manually depressing hotkeys or clicking `[STOP] Disconnect & Block`), or according to policies configured by the system administrator.
* **Audit Trail**: Every intercept event, user response (`[STOP] Disconnect & Block`, `[Allow Once]`, `[Always Whitelist]`, `[Snooze]`), and emergency browser kill action is permanently recorded with microsecond timestamps in `C:\ProgramData\WINBARS\Logs\Security_Audit.log` and on the connected backup drive (`Backup_Logs\Security_Audit.log`). This provides an immutable, tamper-evident audit record proving that any interrupted session was user-initiated rather than rogue automation.
* **Session State Protection**: When Scam Buster terminates browser processes, it defuses the Chromium crash-recovery loop (`"exit_type": "Normal"`) and stages session state files into `%LOCALAPPDATA%\WINBARS\BrowserSessionRescue\` rather than permanently deleting them, preventing malicious scam loops from reopening while preserving legitimate work for technician recovery.
### 🛡️ Disclaimer of Warranties & Limitation of Liability

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

IN NO EVENT SHALL THE AUTHOR, COPYRIGHT HOLDERS, OR CONTRIBUTORS BE LIABLE FOR ANY CLAIM, DAMAGES, LOSS OF DATA, SYSTEM DOWNTIME, CORRUPTION, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

ALL BACKUPS, RESTORES, PROCESS TERMINATIONS, AND DISASTER RECOVERY DRILLS ARE EXECUTED AT THE USER'S OWN DISCRETION AND RISK. USERS AND SYSTEM ADMINISTRATORS REMAIN SOLELY RESPONSIBLE FOR INDEPENDENTLY VERIFYING ARCHIVE INTEGRITY, BACKUP SCHEDULE CADENCE, AND STORAGE HARDWARE READINESS.

* **No Obligation of Support or Maintenance**: WINBARS is distributed free of charge. The author and copyright holders have no obligation to provide technical support, customer assistance, maintenance, patches, or future updates. Any technical advice, documentation, or guidance provided is offered purely as a courtesy without warranty or service level agreement (SLA) of any kind.

---

## 📄 Software License (Closed-Source Freeware)

WINBARS is licensed as **100% Free for Personal & Commercial Use** under proprietary freeware terms:
* **Freeware / Unlocked**: All backup, bare-metal imaging, registry restoration, BitLocker vaulting, canary sentinels, and emergency features are 100% unlocked and free of artificial paywalls or nagware.
* **Closed-Source Executable Wrapper**: The compiled binary (`WINBARS.exe`) and system tray sentry are proprietary freeware. Decompilation, disassembly, reverse engineering, and standalone resale are prohibited.
* **Transparent Host Orchestration**: All Task Scheduler jobs, WinPE rescue scripts, and backup orchestrations deployed to target systems consist of transparent, un-obfuscated scripts that IT technicians can inspect and verify.
* **Sponsor Branding Perk** *(Minimum $100 donation)*: While donations and sponsorships of any amount are welcome, commercial IT repair shops and MSPs who sponsor the project at the $100+ tier may optionally receive a cryptographically signed Shop Branding Token (`WINBARS-TOK-...`) via the [White-Labeling checkout portal](#white-labeling--the-100-lifetime-shop-branding-perk) to display their custom shop branding in the UI across unlimited client machines. All core features remain 100% functional without a token.
* See [LICENSE.txt](LICENSE.txt) for complete legal terms.


### 🧱 B-A-R-S Modular Refactor & Technician Hotkey Engine (v0.9.0)
- **Modular Domain Architecture**: Codebase decomposed into discrete domain modules under `src/` (Backup, Assistance, Recovery, Security, GUI, CLI, Core) with automated zero-dependency single-file bundling.
- **Dynamic Hotkey Collision Probing**: Tech-mode configurable hotkeys with live Win32 P/Invoke probing to guarantee zero conflicts with Windows reserved shortcuts and international AltGr layouts.
- **Comprehensive Reliability Hardening**: Atomic state and configuration saves, headless execution guards, and recursive path protection.

### 🛡️ Master USB Audit Vault & Technician Field Automation (v0.8.2)
- **Automatic USB Audit Vault**: Automatically mirrors deployment and execution logs back to your master technician flash drive under `WINBARS\Logs\Audits\<PC>_<USER>_<YYYYMMDD>.log`.
- **Intelligent Install Awareness**: Instantly detects pre-existing installations across all modes (`Minimal`, `LocalDisasterGuard`, `HeadlessFull`, `FullInteractive`) with automated task signature deduction.
- **Mode 2 Single-Drive Realism**: Tailors hero action `[2]` and on-demand passes for single-drive laptops (`C:\SystemImages`), omitting irrelevant external drive checks.
- **Zero-Question Installer**: Seamless pre-flight toggles for `[K]` Shortcuts, `[B]` Immediate Baseline Image Capture, and auto-initialized `[9]` Branding.
- **Single-Drive Cloaking Guardrail**: Prohibits cloaking `C:` to ensure operating system drive visibility is always preserved.