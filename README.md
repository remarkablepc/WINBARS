# WINBARS - Windows Backup, Assistance, Recovery & Security Suite (v0.9.5)
### *Built by a computer repair technician to prevent the disasters that bring customers back to the repair counter — 100% free, because peace of mind shouldn't cost a thing.*

<p align="center">
  <a href="https://github.com/remarkablepc/WINBARS/releases/latest"><img src="https://img.shields.io/badge/Release-v0.9.5-0078D4?logo=github&logoColor=white" alt="Latest Release" /></a>
  <a href="https://microsoft.com"><img src="https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?logo=windows&logoColor=white" alt="Windows 10 & 11" /></a>
  <a href="https://microsoft.com"><img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white" alt="PowerShell 5.1+" /></a>
  <img src="https://img.shields.io/badge/Architecture-x64%20%7C%20x86-success" alt="Architecture" />
  <img src="https://img.shields.io/badge/Binary-WINBARS.exe-informational" alt="Standalone Binary" />
  <img src="https://img.shields.io/badge/Agentless%20Native-Mode%200%20Supported-brightgreen" alt="Agentless Zero-Footprint Mode" />
  <img src="https://img.shields.io/badge/License-100%25%20Free%20for%20Personal%20%26%20Commercial%20Use-brightgreen" alt="License" />
  <a href="https://www.paypal.com/ncp/payment/EKH76RTYHH24S"><img src="https://img.shields.io/badge/Say%20Thanks-PayPal-00457C?logo=paypal&logoColor=white" alt="Say Thanks" /></a>
  <a href="https://github.com/sponsors/remarkablepc?utm_source=WINBARS"><img src="https://img.shields.io/badge/Sponsor-GitHub%20Sponsors-EA4AAA?logo=githubsponsors&logoColor=white" alt="GitHub Sponsors" /></a>
</p>

<p align="center">
  <a href="https://github.com/remarkablepc/WINBARS/releases/latest">
    <img src="https://img.shields.io/badge/%E2%9E%9C%20Download%20Latest%20Release-WINBARS%20v0.9.5-2ea44f?style=for-the-badge&logo=windows&logoColor=white" alt="Download Latest Release" height="34" />
  </a>
</p>

<div align="center">

  **[📥 Download Complete Package (`WINBARS-v0.9.5.zip`)](https://github.com/remarkablepc/WINBARS/releases/latest)** &nbsp;&bull;&nbsp; **[📦 All Releases](https://github.com/remarkablepc/WINBARS/releases)** &nbsp;&bull;&nbsp; **[📜 Changelog](CHANGELOG.md)** &nbsp;&bull;&nbsp; **[📋 Release Notes](https://github.com/remarkablepc/WINBARS/releases/tag/v0.9.5)**

  <br>

  ✨ **[🍏 Non-Destructive "macOS-Style" Windows OS Refresh: Repair Windows without wiping personal files ➔](#macos-style-safe-overlay)**<br>
  🚨 **[🛡️ Scam Buster & RAT Interceptor: Instant Screen Unfreeze & Scam Defense ➔](#scambuster-rat-interceptor)**<br>
  🧰 **[🛠️ Boot-Failure Safety Net: 1-Click WinRE Rescue When Windows Won't Boot ➔](#boot-recovery-safety-net)**
</div>

---

> [!IMPORTANT]
> ### 💡 The Core Principle: Orchestration & Hardening, Not Proprietary Bloat
> Microsoft Windows already contains 30 years of battle-tested, kernel-level recovery engines: **Robocopy, Volume Shadow Copies (VSS), DISM bare-metal imaging, and Task Scheduler**. 
> 
> The flaw has never been the engines—it's that Windows leaves them uncoordinated: updates quietly disable File History, restore points are throttled to once every 24 hours, and USB drive letter changes halt backups without alert.
> 
> **WINBARS coordinates, schedules, and hardens these native Windows tools so disaster recovery actually works when disaster strikes.**
> 
> 🛡️ **Zero Lock-In & Verifiable Host Footprint**: Backups are standard Windows files and native `.wim` images. WINBARS is never required to restore your system. It installs 0 kernel drivers, 0 Windows NT services, and zero unsolicited network telemetry. See the [System Footprint & Security Audit Blueprint](docs/SYSTEM_FOOTPRINT.md).

<p align="center">
  <img src="assets/screenshot.png" alt="WINBARS Protection Center and Sentry Dashboard" width="820" />
  <br>
  <em>WINBARS Protection Center Live Dashboard (Ctrl+Win+W), Floppy Tray Sentry, and Quick-Action Bar</em>
</p>

---

## 📑 Table of Contents

1. [💔 Why WINBARS Was Born: 6 Real-World Nightmares](#why-winbars-was-born-6-real-world-nightmares)
2. [🛡️ Key Protections at a Glance](#key-protections-at-a-glance)
   - 🍏 [macOS-Style Non-Destructive OS Refresh](#macos-style-safe-overlay)
   - 🚨 [Scam Buster & Remote Access RAT Interceptor](#scambuster-rat-interceptor)
   - 🧰 [Boot-Failure Safety Net & Emergency Recovery](#boot-recovery-safety-net)
3. [💡 Why WINBARS is Different: The 4 Guarantees](#why-winbars-is-different-the-4-guarantees)
4. [🚀 Choose Your Protection Profile (Decision Matrix)](#choose-your-protection-profile)
5. [💾 Floppy Tray Sentry & Global Hotkeys](#floppy-tray-sentry--global-hotkeys)
6. [⚡ Quick Start (3 Steps)](#quick-start-in-3-steps)
7. [❓ Frequently Asked Questions (FAQ)](#frequently-asked-questions-faq)
8. [🏷️ Shop White-Labeling & Community Sponsorship](#shop-white-labeling--community-sponsorship)
9. [📚 Complete Technical Documentation Directory](#technical-documentation-directory)
10. [📋 Requirements & License](#requirements--license)

---

<a id="why-winbars-was-born-6-real-world-nightmares"></a>
## 💔 Why WINBARS Was Born: 6 Real-World Nightmares

If you have ever repaired Windows PCs for clients, friends, or family, you already know these six heartbreaking scenarios:

### 1. The "Windows 11 Silent File History Death"
> *"A customer’s hard drive died a year after upgrading to Windows 11, only to discover that **Microsoft had silently turned off File History during the upgrade with zero warning**. An entire year of irreplaceable family photos and business files was lost because Windows never said a word."*

### 2. *"There is NEVER a Restore Point When You Actually Need One!"*
> *"A bad update causes a blue screen, but System Restore is completely empty. Between Microsoft's arbitrary 24-hour throttling, silent shadow storage exhaustion, and Windows Update wiping old checkpoints, the restore point list is almost always a ghost town when disaster strikes."*

### 3. The "Surprise BitLocker" Catch-22
> *"New laptops now quietly encrypt themselves out of the box without handing the owner their 48-digit recovery key. When a routine BIOS update trips the TPM chip, the user is greeted by a blue lockout screen—and can't retrieve the key online because their two-factor authentication code is sent to the locked computer."*

### 4. The Phone Scam, Browser Siren & Remote Control Trap
> *"A full-screen popup freezes the screen with blaring audio sirens: 'VIRUS DETECTED — CALL MICROSOFT.' Panicked and unable to close the browser, everyday users call the number on screen and let offshore scammers connect via **UltraViewer, ScreenConnect, or AnyDesk**—tools so pervasive in scam call centers that UltraViewer's uninstaller literally asks: 'Did a scammer tell you to install this?' Victims watch helplessly as their bank accounts are drained while traditional antivirus sits completely silent."*

### 5. The "No Rescue USB When Windows Won't Boot" Catch-22
> *"When Windows gets stuck in a bootloop, every guide says: 'Insert your Recovery USB drive.' But everyday users never make a recovery drive while their PC is working—and once Windows refuses to boot, they can't create one. They are trapped simply because recovery tools were never pre-staged before the crash."*

### 6. The "Wipe & Reinstall" Trap: Losing Every App & Setting
> *"When Windows gets corrupted, the standard big-box verdict is always: 'Wipe the drive and start over.' Even if personal documents are saved, the user loses every installed program, customized preference, and printer driver—spending weeks hunting down lost software licenses and reinstalling their digital life."*

---

### 💬 A Note from the Creator: Dedicated to My Customers

> *"This project is dedicated to the many customers who have trusted me with their computers over the years.
>
> I didn't build WINBARS to sell a subscription, push cloud storage, or start a software company. I built it because after years of running a computer repair shop, I got tired of watching preventable computer disasters hurt good people.
>
> I watched families lose decades of photos because Windows silently stopped backing up. I watched people get locked out of their own laptops by surprise BitLocker prompts without a key. I watched perfectly healthy systems get wiped clean by big-box repair benches because there was no restore plan. And I watched terrified seniors lose money to scam call centers because Windows gave them no way to break out of a browser lockup.
>
> WINBARS is the tool I wished every customer already had running before they walked into my shop. It is completely free, closed-source freeware, with zero cloud telemetry and zero ads. If it saves your family photos, keeps you out of a scammer's hands, or saves you an expensive repair bill, it has done its job."*
>
> — **David Hewitt**, Creator of WINBARS (RemarkablePC)

---

<a id="key-protections-at-a-glance"></a>
## 🛡️ Key Protections at a Glance

WINBARS unifies **B**ackup, **A**ssistance, **R**ecovery, and **S**ecurity into a single, cohesive safety net. Here are three of its unique standout capabilities:

<a id="macos-style-safe-overlay"></a>
### 🍏 1. Non-Destructive "macOS-Style" Safe Overlay OS Refresh
On a Mac, booting into Recovery Mode and choosing **"Reinstall macOS"** refreshes core system files and default apps while leaving your user account, desktop files, and personal data 100% untouched. For 30 years, Windows users have been denied this simplicity—forced to choose between a destructive disk wipe or an in-place upgrade that fails if Windows won't boot.

**WINBARS brings true macOS-style non-destructive recovery to Windows**: Because WINBARS bare-metal `.wim` images cleanly capture Windows OS binaries, drivers, and Program Files while excluding `\Users`, selecting **Option [1] Safe Overlay** in `Apply-SystemImage_WinPE.bat` refreshes your entire operating system and programs safely in-place while leaving **`C:\Users\` (all documents, photos, desktop profiles, and browser data) 100% untouched on disk**—no secondary data restore required!

<a id="scambuster-rat-interceptor"></a>
### 🚨 2. Scam Buster & Remote Access RAT Interceptor
* **Instant Browser Freeze Escape (`Ctrl + Win + B`)**: Instantly closes rogue full-screen browser traps across 25+ browsers, silences audio sirens, and clears Chromium crash-recovery flags to prevent reload loops.
* **Real-Time Remote Access Interceptor**: Continuously watches for 25+ remote control tools frequently weaponized by phone and pop-up scammers (AnyDesk, TeamViewer, UltraViewer, ScreenConnect, RustDesk, etc.). When an unauthorized remote tool launches, an urgent interception banner appears with an unmissable **`[STOP] Disconnect & Block`** button.
* **OneDrive Alert Guard**: Silences deceptive Windows 10/11 "Not Backed Up" scare banners and halts Known Folder Move (KFM) hijacking of Documents, Desktop, and Pictures without breaking normal OneDrive sync.

<a id="boot-recovery-safety-net"></a>
### 🧰 3. Boot-Failure Safety Net & 1-Click WinRE Rescue
* **Native WinRE Troubleshoot Hook (Modes 2–4)**: An "Emergency Resurrection Tool" button is pre-staged directly into the native Windows Recovery Environment Troubleshoot menu (`reagentc.exe /setcustomtarget /path C:\Recovery\OEM`) before disaster strikes—accessible on boot crashes without needing a rescue USB. (In Modes 0, N, and 1, rescue tools run cleanly from the **Backup Drive** or via WinRE Command Prompt `Shift + F10` to maintain zero software footprint on `C:\`).
* **1-Click Next-Boot WinRE Trigger (`reagentc /boottore`)**: If Windows behaves erratically, a single click reboots the computer directly into WinRE on the next boot, automatically returning to normal fast boot afterward.
* **Emergency Recovery Launcher (`EMERGENCY_RECOVERY.bat`)**: A single, guided rescue entry point on the backup drive. Auto-detects the Windows drive, checks physical drive health (S.M.A.R.T.), repairs corrupted BCD bootloaders, and guides you through the least-invasive recovery ladder.
* **BitLocker Emergency Cards**: Generates printable offline cards with your 48-digit numerical recovery key, plus AES-256 encrypted vaults on the backup drive.

---

<a id="why-winbars-is-different-the-4-guarantees"></a>
## 💡 Why WINBARS is Different: The 4 Guarantees

Traditional backup suites focus on complex schedules and proprietary archives. WINBARS focuses on **human-centered outcomes**:

1. **Zero Proprietary Vendor Lock-In**:
   Your personal files are mirrored 1:1 into standard Windows folders with original filenames. Plug your backup drive into **any PC, Mac, Chromebook, or Linux computer** and immediately drag-and-drop your files without installing WINBARS or any third-party software.
2. **100% Free Forever (No Subscriptions)**:
   No 30-day trials, no paywalled recovery features, and no recurring monthly invoices. Complete protection is 100% free for personal and commercial use.
3. **Zero Kernel Drivers / Zero System Service Bloat**:
   WINBARS installs 0 kernel-mode filter drivers and 0 Windows NT services (`services.msc`). Modes 0–1 maintain 0 resident background processes, while Modes 2–4 run a lightweight user-mode desktop sentry (~12–16 MB RAM) via standard Startup. Unlike proprietary backup agents that can trigger blue screens during major Windows 11 feature upgrades, WINBARS relies exclusively on native, battle-tested Windows Win32 APIs.
4. **Defends Where Antivirus Can't**:
   Phone scammers and pop-up boiler rooms don't use viruses—they use social engineering and legitimate, digitally signed remote tools (AnyDesk, UltraViewer). Because these tools are legitimate, antivirus software ignores them. WINBARS detects and stops them in real time.

> 🔍 *Want a full technical breakdown? See the [Architectural Comparison vs. Acronis, Macrium, and Native Windows](docs/COMPARISON.md).*

---

<a id="choose-your-protection-profile"></a>
## 🚀 Choose Your Protection Profile

WINBARS provides 6 tailored deployment profiles to fit any home, business, or repair bench workflow:

| Profile | Best For | What It Protects & Hardens | What Sits on `C:\` | Rescue Scripts |
| :--- | :--- | :--- | :--- | :---: |
| **Mode 0: `ZeroFootprint`** ⭐ | **Corporate Audits & Compliance** | Daily System Restore + Robocopy file mirror (30-day retention) + bare-metal image + BitLocker keys. | **0 Files**<br>*(100% sterile)* | **Backup Drive Only** |
| **Mode N: `NearZeroFootprint`** 👻 | **Workstations & Vendor-Neutral Setups** | Mode 0 + generic unbranded desktop & Start Menu shortcuts (*System Backup & Recovery*). | **Shortcuts Only**<br>*(Desktop & Start Menu)* | **Backup Drive Only** |
| **Mode 1: `SystemUndo`** ⏪ | **Shop Bench Tune-Ups & Routine Service** | **The Universal Service Warranty**: Daily unthrottled System Restore, 10% VSS quota, and RegBack. | **1 BAT File (+ WIM)\***<br>*(In `C:\SystemImages`)* | `C:\SystemImages`* or Backup Drive |
| **Mode 2: `LocalDisasterGuard`** 💽 | **Mobile Laptops, Students & Single-Drive PCs** | Mode 1 + local bare-metal DISM image (`.wim`) for offline recovery while traveling without an external drive. | **Local Suite**<br>*(C:\Tools\WINBARS)* | `C:\SystemImages` & Backup Drive |
| **Mode 3: `HeadlessFull`** 🏢 | **Quiet Workstations, Accounting & Clinics** | Mode 1 + daily external Robocopy file sync + scheduled bare-metal images + missing drive alerts. | **Local Suite**<br>*(C:\Tools\WINBARS)* | Both Local & Backup Drive |
| **Mode 4: `TotalProtection`** 🛡️ | **Everyday Users, Family & Seniors** | Mode 3 + signature Floppy Tray Sentry + active ScamBuster RAT interceptor + live GUI. | **Full Suite**<br>*(C:\Tools\WINBARS + Tray)* | Both Local & Backup Drive |

> `*` **Note on Mode 1**: The baseline `.wim` and rescue `.bat` are only staged in `C:\SystemImages\` if disk space $\ge 25\text{ GB}$; otherwise, Mode 1 leaves 0 files on `C:\` and relies exclusively on native Windows System Restore.
>
> 💡 **Taxonomy: "Backup Drive" vs. "WINBARS Util USB"**:
> - **Backup Drive (Storage Destination)**: The dedicated volume where backups, baseline `.wim` images, and recovery scripts live. Even in Mode 0, this can be an internal secondary drive or dedicated partition (e.g. `D:\`, `E:\`, secondary SATA/NVMe SSD) or an external USB hard drive. In Modes 0 & N, exactly 0 backup files or persistent executables touch `C:\`.
> - **WINBARS Util USB (Technician Flash Drive)**: The portable, bootable technician USB drive carrying `WINBARS.exe`, one-click installers, and WinPE offline recovery tools.
> - **Where do recovery scripts live?** In **Modes 0 & N**, exactly 0 batch scripts touch `C:\`—all rescue tools (`EMERGENCY_RECOVERY.bat`, `Apply-SystemImage_WinPE.bat`) live exclusively on the **Backup Drive**. In **Mode 1**, if a baseline image is captured, `Apply-SystemImage_WinPE.bat` sits in `C:\SystemImages\` where you can run it directly from a WinRE Command Prompt (`Shift + F10`) to execute a non-destructive Safe Overlay OS refresh.
>
> 🔍 *Need the granular 22-feature comparison matrix and custom profile generator details? See [Deployment Profiles in Detail](docs/DEPLOYMENT_MODES.md).*

### ⚡ 1-Click Batch Installers & Utilities
Each mode includes a double-clickable batch installer for rapid deployment from a technician flash drive:
- `Install-Mode0-ZeroFootprint.bat` &nbsp;&bull;&nbsp; `Install-ModeN-NearZeroFootprint.bat`
- `Install-Mode1-SystemUndo.bat` &nbsp;&bull;&nbsp; `Install-Mode2-LocalDisasterGuard.bat`
- `Install-Mode3-HeadlessFull.bat` &nbsp;&bull;&nbsp; `Install-Mode4-TotalProtection.bat`
- `Whitelist-WINBARS.bat` *(Windows Defender Whitelist Utility: adds folder & process exclusions to prevent false alerts)*
- `Reset-Suite.bat` *(Factory Reset Utility: cleanly wipes tasks and sentries while preserving client data)*

---

<a id="floppy-tray-sentry--global-hotkeys"></a>
## 💾 Floppy Tray Sentry & Global Hotkeys

In **Mode 4 (`TotalProtection`)**, WINBARS places a classic floppy disk icon in the system notification area that dynamically reflects system health at a glance:

| Tray Floppy | Status | Meaning |
| :---: | :--- | :--- |
| <img src="assets/floppy_green.png" width="18" height="18" valign="middle" alt="Green Floppy" /> 🟢 | **Emerald Green** | **All Systems Protected**: Daily restore points active, file backups up to date. |
| <img src="assets/floppy_purple.png" width="18" height="18" valign="middle" alt="Purple Floppy" /> 🟣 | **Signature Purple** | **Backup in Progress**: Active file mirror, restore point, or image creation. |
| <img src="assets/floppy_blue.png" width="18" height="18" valign="middle" alt="Blue Floppy" /> 🔵 | **Classic Blue** | **Protection Center Ready**: Idle, healthy system state. |
| <img src="assets/floppy_yellow.png" width="18" height="18" valign="middle" alt="Amber Floppy" /> 🟡 | **Amber Gold** | **Notice / Local Mode**: External backup drive unplugged or backup due. |
| <img src="assets/floppy_red.png" width="18" height="18" valign="middle" alt="Red Floppy" /> 🔴 | **Crimson Red** | **Attention Required**: S.M.A.R.T. disk degradation or backup task issue. |

### ⌨️ Universal Global Hotkeys
Available in Modes 2 through 4 for emergency assistance:
* **`Ctrl + Win + W` $\rightarrow$ WINBARS Protection Center**: Opens the live System Health dashboard, backup status, and 1-click tools.
* **`Ctrl + Win + B` $\rightarrow$ Emergency Scam Buster**: Instantly closes frozen full-screen browsers, kills audio sirens, and clears crash-reload loops.
* **`Ctrl + Win + Q` $\rightarrow$ Quick Assist Remote Support**: Displays verified support details before launching Microsoft Quick Assist for remote screen sharing.

---

<a id="quick-start-in-3-steps"></a>
## ⚡ Quick Start (3 Steps)

1. **Download & Extract**:
   Download the latest [`WINBARS-v0.9.5.zip`](https://github.com/remarkablepc/WINBARS/releases/latest) and extract it to a USB flash drive or your computer.
2. **Launch Setup**:
   Right-click `Run-WINBARS.bat` and select **Run as administrator** (or run `WINBARS.exe`).
3. **Select Your Mode**:
   Choose your preferred deployment profile (e.g., press `[1]` for Zero-Footprint, or double-click `Install-Mode4-TotalProtection.bat` for full interactive protection).

> 💡 *For unattended batch flags and command-line automation, see the [CLI Reference](docs/CLI_REFERENCE.md).*

<details>
<summary><b>🛠️ Click to expand Quick CLI & Automation Reference</b></summary>
<br>

| Operational Domain | Command Syntax | Description |
| :--- | :--- | :--- |
| **⚡ 1-Click Backup** | `WINBARS.exe -Action FastBackup` | Mirrors personal files + creates System Checkpoint. |
| **📊 Visual Backup** | `WINBARS.exe -Action FastBackup -ShowProgress` | Launches live Dual Progress Bar in real-time. |
| **🛡 System Checkpoint** | `WINBARS.exe -Action RestorePoint` | Creates unthrottled atomic System Restore Point. |
| **💾 Bare-Metal Image** | `WINBARS.exe -Action SystemImage` | Captures DISM `.wim` image to target or `C:\SystemImages`. |
| **📦 Complete Backup** | `WINBARS.exe -Action All` | Runs full 3-tier pass (Restore Point + Files + Image). |
| **🚀 Deploy Mode 0** | `WINBARS.exe -Profile ZeroFootprint` | 100% native Windows automation (0 files on `C:\`). |
| **👻 Deploy Mode N** | `WINBARS.exe -Profile NearZeroFootprint` | Stealth native automation with unbranded shortcuts. |
| **⏪ Deploy Mode 1** | `WINBARS.exe -Profile SystemUndo` | Daily System Restore hardening + VSS auto-heal. |
| **💽 Deploy Mode 2** | `WINBARS.exe -Profile LocalDisasterGuard` | Mode 1 + local recovery partition DISM image (`.wim`). |
| **🏢 Deploy Mode 3** | `WINBARS.exe -Profile HeadlessFull` | Mode 1 + daily external Robocopy file sync + image archive. |
| **🛡️ Deploy Mode 4** | `WINBARS.exe -Profile TotalProtection` | Mode 3 + Floppy Tray Sentry + ScamBuster watchdog + GUI. |
| **🔄 Switch Mode** | `WINBARS.exe -SwitchMode <Profile>` | Zero-drift transition: tears down old tasks cleanly. |
| **🧹 Factory Reset** | `WINBARS.exe -ResetSuite` | Clears scheduled tasks and configs to factory defaults. |
| **🚨 ScamBuster** | `WINBARS.exe -ScamBuster` | Terminates browser lockups and clears sirens (`Ctrl+Win+B`). |
| **📋 Emergency Card** | `WINBARS.exe -EmergencyCard` | Generates printable BitLocker Emergency Card (`.html`). |
| **🧰 Boot Recovery** | `WINBARS.exe -BootRecoveryMenu` | Reboots directly into WinRE on next startup. |
| **🧹 Complete Removal** | `WINBARS.exe -Uninstall` | Cleanly removes all scheduled tasks, shortcuts, and sentry. |

```cmd
REM --- Unattended Technician Batch Examples ---
Install-Mode1-SystemUndo.bat /Baseline:Y /Quiet
Install-Mode0-ZeroFootprint.bat /Data:D:\UserData /Image:D:\Images /Quiet /Vanilla
Install-Mode4-TotalProtection.bat /Brand:"TechPros" /Quiet
Uninstall.bat /Quiet
```

> 📖 *For complete command parameters and trigger switches, see the [Full CLI Reference](docs/CLI_REFERENCE.md).*

</details>

---

<a id="frequently-asked-questions-faq"></a>
## ❓ Frequently Asked Questions (FAQ)

### Q: Why isn't WINBARS open-source?
Keeping **WINBARS** closed-source is fundamentally about **protecting the integrity of the project, preventing predatory paywalls, and ensuring user safety**:
* **Preventing Exploitation & Predatory Paywalls**: In the Windows recovery and utility ecosystem, high-utility open-source tools are frequently cloned, bundled into ad-supported download wrappers, or rebranded under predatory monthly "PC Cleaner / Driver Booster" subscriptions that exploit non-technical users for free native Windows capabilities. Keeping the orchestrator compiled ensures WINBARS remains clean, local, and 100% free.
* **Not About Hiding Code**: This decision isn't about hiding how the tool works—WINBARS orchestrates transparent, standard Microsoft system components (`VSS`, `DISM`, `Robocopy`, `WMI`, and `Task Scheduler`). It is about preventing unauthorized third parties from commercially exploiting, paywalling, or tampering with this work.
* **Tamper-Proof Reliability**: Packaging as an immutable standalone executable (`WINBARS.exe`) prevents well-meaning users or rogue scripts from corrupting recovery logic, eliminates PowerShell `ExecutionPolicy` friction, and guarantees identical, reliable behavior across client workstations.

### 🛡️ The Third Path: Auditable Closed Source
Rather than forcing a false choice between an opaque black-box (with proprietary drivers and secret cloud telemetry) and easily exploited open-source scripts, WINBARS pioneered **Auditable Closed Source**:
* **Zero Kernel Drivers Across All Modes**: WINBARS installs 0 kernel-mode filter drivers (`.sys` files) on any system, eliminating driver-level BSODs during Windows 11 feature updates.
* **Zero Windows Services**: WINBARS never installs a background NT service in `services.msc`. Modes 0–1 maintain 0 resident processes. Modes 2–4 run a lightweight user-mode desktop sentry (~12–16 MB RAM) loaded via standard user Startup without system-level service overhead.
* **Transparent Host Orchestration**: Every scheduled task, personal file mirror, and WinPE disaster recovery script executes standard, verifiable native Windows utilities (`robocopy.exe`, `dism.exe`, `vssadmin.exe`, `reagentc.exe`).
* **Line-by-Line Native Command Audit**: Every command and syntax pattern WINBARS executes is published in our [Native Windows Command Audit Reference (docs/SYSTEM_FOOTPRINT.md#8)](docs/SYSTEM_FOOTPRINT.md#8-complete-native-windows-engine--command-execution-reference). Technicians and enterprise auditors can independently verify every single operation in real time using Microsoft Sysinternals Process Monitor (`procmon.exe`).

### Q: Where are the Ransomware Canary honeypot files located, and can I delete them?
* **Locations**: When Canary Guard is active, WINBARS places a small, hidden honeypot decoy file (`.winbar_canary.dat`) in the roots of standard user libraries (`Desktop`, `Documents`, `Pictures`, `Music`, `Videos`, `Downloads`), `C:\Users\Public\Documents`, and at the root of the **Backup Drive**. On remote network shares, it deploys `.winbars_remote_canary.sha256`.
* **Purpose**: These decoy files contain known cryptographic SHA-256 integrity tokens. Because ransomware typically sweeps and encrypts user folders alphabetically, altering or encrypting any canary file trips an instant tripwire alarm.
* **Do NOT Manually Delete Them**: Deleting or altering a canary file causes WINBARS to treat the event as an active ransomware compromise, instantly suspending scheduled backups and isolating network shares to prevent compromised files from overwriting your pristine archives. If tripped accidentally, reset it anytime via `WINBARS.exe -CanaryReset`.

### Q: Is WINBARS really 100% free?
**Yes.** WINBARS is completely free for both personal and commercial use. There are no paid tiers, no ad popups, and no recurring subscriptions. Computer repair shops can optionally purchase a $100 one-time lifetime branding token to display their own shop logo and phone number, which directly funds continued development.

### Q: Can I restore my files if WINBARS is uninstalled or my PC dies?
**Yes, 100%.** WINBARS never traps your files inside proprietary containers (`.mrimg`, `.tibx`). Backed-up files in `UserBackups\` are standard Windows files that can be browsed and copied on any PC, Mac, or Linux computer. System images are standard Microsoft DISM `.wim` files readable by official Windows installation media.

### Q: Does a System Restore Point delete my personal files?
**No.** System Restore reverts Windows system files, drivers, and registry hives. Your documents, photos, desktop files, downloads, and personal folders are **never touched, overwritten, or deleted** by a System Restore.

### Q: Does WINBARS send data to the cloud or collect telemetry?
**No. Absolutely zero unsolicited telemetry.** WINBARS operates under a strict offline policy: 0 tracking beacons, 0 analytics pings, 0 auto-update polling, and 0 mandatory user accounts. All branding cryptographic verification is performed 100% offline via local ECDSA signatures. Outbound network traffic occurs strictly when the user or administrator explicitly configures an optional webhook endpoint (Discord/Slack/Teams) for emergency canary/failure alerts, or initiates Microsoft Quick Assist (`Ctrl+Win+Q`).

### Q: How does WINBARS handle cloud backups?
Rather than forcing you into complicated AWS S3, Wasabi, or Azure portals with secret keys and monthly egress fees, WINBARS works with the tools you already have: simply select your local **Dropbox, Google Drive, OneDrive, or Sync.com** folder as a backup destination. WINBARS handles the frozen snapshot and 30-day retention, while your official cloud app securely syncs the files off-site.

---

<a id="shop-white-labeling--community-sponsorship"></a>
## 🏷️ Shop White-Labeling & Community Sponsorship

For independent repair shops, system integrators, and MSPs: community sponsorship of **$100 (one-time lifetime token)** funds continued development of WINBARS.

In appreciation, RemarkablePC provides an offline, digitally signed `branding.json` token that seamlessly integrates your shop's identity across client-facing dialogs:
* Your shop name and support phone number on the Protection Center dashboard (`Ctrl+Win+W`).
* Verified technician contact card preceding Microsoft Quick Assist (`Ctrl+Win+Q`).
* Custom emergency contact info on printed BitLocker recovery cards.
* Instructions on Scam Buster intercept alerts to call your verified shop hotline.

> 💼 *Learn more in the [Shop White-Labeling Guide](docs/WHITE_LABELING.md) or visit the [Sponsorship Portal](https://www.paypal.com/ncp/payment/EKH76RTYHH24S).*

---

<a id="technical-documentation-directory"></a>
## 📚 Technical Documentation Directory

For in-depth architectural blueprints, security audits, and WinPE restore manuals, explore the guides in [`/docs/`](docs/):

* 📐 **[Architecture & Design Philosophy](docs/ARCHITECTURE.md)**: Native engine orchestration, VSS mountpoints, and modular engine design.
* 🚀 **[Deployment Profiles & Capability Matrix](docs/DEPLOYMENT_MODES.md)**: Granular 22-feature comparison matrix and custom profile generator.
* 👻 **[Agentless Zero-Footprint Deep Dive](docs/ZERO_FOOTPRINT.md)**: 12 Core Pillars, 5 failure-mode defenses, and filesystem layouts.
* ⚖️ **[Architectural Comparison](docs/COMPARISON.md)**: Detailed comparison vs. Acronis, Macrium, and native Windows.
* 🔍 **[System Footprint & Security Audit Blueprint](docs/SYSTEM_FOOTPRINT.md)**: Line-item verification of every task, file, registry key, and Sysinternals audit guide.
* 🚑 **[WinRE Blue Screen & Disaster Recovery Manual](docs/DISASTER_RECOVERY.md)**: Step-by-step restoration procedures, BCD rebuilding, and Safe Overlay OS refresh.
* 🛑 **[Scam Sentry & Remote Access Interceptor](docs/SCAM_SENTRY.md)**: Deep dive into browser unfreezing, domain sinkholing, and remote tool interception.
* 🔑 **[BitLocker AES-256 Disaster Vault Guide](docs/BITLOCKER_VAULT.md)**: Automated key discovery, vault encryption, and printable recovery cards.
* ⌨️ **[Command-Line CLI & Batch Reference](docs/CLI_REFERENCE.md)**: Complete parameter reference, batch launcher flags, and unattended syntax.
* 🏷️ **[Shop White-Labeling Guide](docs/WHITE_LABELING.md)**: Customizing branding, contact cards, and deployment token staging.

---

<a id="requirements--license"></a>
## 📋 Requirements & License

* **Operating System**: Windows 10 (1809+), Windows 11 (all versions), Windows Server 2016/2019/2022/2025.
* **Engine Framework**: Microsoft PowerShell 5.1+, WMI/CIM, Volume Shadow Copy Service (VSS), DISM (`dism.exe`), Robocopy (`robocopy.exe`).
* **Hardware S.M.A.R.T.**: Compatible with NVMe SSDs, SATA SSDs, and mechanical drives.
* **Binary Size**: Standalone executable $\approx 640$ KB with zero external runtime dependencies.
* **License**: Closed-Source Freeware. 100% free for personal, non-profit, educational, and commercial use. See [LICENSE](LICENSE) for terms.