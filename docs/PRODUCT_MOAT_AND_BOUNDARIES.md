# WINBARS & WINTools — Product Moat, Boundaries & Sterility Charter

This charter defines the strict architectural boundaries, sterility contracts, and separation of concerns between **WINTools**, **WINBARS Suite**, and **WINBARS Guard**. 

Every contributor, technician, and automated code review pipeline must enforce these boundaries to prevent feature drift, protect product identities, and preserve user trust.

---

## 🏛️ The Three Product Identities

```
+──────────────────────────────────────────────────────────────────────────+
|                        THE THREE PRODUCT IDENTITIES                      |
+──────────────────────────────────────────────────────────────────────────+

1. WINTOOLS (The Surgical Scalpel)
   • Identity: On-demand technician emergency room & bench repair workbench.
   • License / Distribution: Open Source, portable USB execution.
   • Primary User: Bench technicians, computer repair shop owners, field IT.
   • Core Task: Live surgical repairs (RAT forensic purge, driver doctor, 
     offline password unlock, profile migration, system repair).

2. WINBARS SUITE (The Architect's Deployment Matrix)
   • Identity: Scriptable multi-tier OS disaster recovery & backup engine.
   • License / Distribution: Free for personal/commercial use, standalone ZIP / IRM.
   • Primary User: MSPs, repair shops, fleet administrators, power users.
   • Core Task: Automated multi-tier disaster recovery (Modes 0, N, 1, 2, 3, 4).

3. WINBARS GUARD (The Silent Seatbelt)
   • Identity: Consumer disaster prevention and emergency recovery companion.
   • License / Distribution: $14.99 One-Time Purchase on Microsoft Store (MSIX).
   • Primary User: Everyday PC owners, families, non-technical consumers.
   • Core Task: Quiet, set-and-forget protection (Smart drive detection, 
     BitLocker key rescue, F4 startup recovery, Ctrl+Win+B alarm defusal).
+──────────────────────────────────────────────────────────────────────────+
```

---

## 🚧 Rule 1: The WINTools Moat (Surgical Scalpel, Not a Daemon)

* **Bench-Only Scope**: WINTools is strictly an **interactive, on-demand bench toolkit**. It is executed while the technician is actively servicing the computer.
* **HARD LIMIT — No Automated Backup Schedulers**: WINTools must **NEVER** install recurring background backup tasks, automated daily file synchronization loops, or volume shadow daemons. Automated scheduling belongs exclusively to WINBARS.
* **HARD LIMIT — No Persistent Desktop Tray Sentry**: WINTools must **NEVER** leave a resident notification area (system tray) icon on the host machine.
* **Permitted Resident Sentry (The Single Exception)**: WINTools may install `winscambuster.ps1` as a post-repair safeguard for victims of tech support scams. This watchdog listens for `Ctrl + Win + B` and kills browser lockup loops.
* **Audit Logging Standard**: WINTools logs to both the technician USB (`tickets\`) and `C:\ProgramData\WINTools\tickets\` to maintain an indisputable machine service flight record for shop warranty and repair history.

---

## 🛡️ Rule 2: WINBARS Suite Sterility & Mode Contracts

WINBARS Suite is divided into two distinct tiers: **Native Windows Tiers (Modes 0, N, 1)** and **Managed Suite Tiers (Modes 2, 3, 4)**. The contracts governing each mode are inviolable:

### Mode 0 (`ZeroFootprint`) — Absolute Host Sterility
* **Contract**: Leaves **0 files, 0 scripts, 0 folders, and 0 registry keys** on `C:\`.
* **Receipts & Escrow**: Must live **100% on the external USB / Backup Drive**. Writing to `C:\ProgramData`, `AppData`, or `C:\SystemRecovery` is a strict violation.
* **Bootloader**: BCD is strictly untouched. Zero startup hotkeys registered.

### Mode N (`NearZeroFootprint`) — Unbranded Native Automation
* **Contract**: Leaves **0 background EXEs, 0 services, and 0 vendor branding** on `C:\`.
* **Allowed Host Presence**: Only native Windows desktop shortcuts and native Scheduled Tasks under `NT AUTHORITY\SYSTEM`.
* **Receipts & Escrow**: Kept exclusively on the external USB / Backup Drive. `C:\SystemRecovery` is never created.

### Mode 1 (`SystemUndo`) — Universal Warranty Baseline
* **Contract**: Leaves **0 third-party binaries, 0 EXEs, and 0 background sentries** on `C:\`.
* **Allowed Host Presence**: Stages native unbranded batch scripts and BitLocker text records in `C:\SystemRecovery\`.
* **ScamBuster & Hotkeys**: Strictly omitted to guarantee clean bench warranty compliance.
* **Storage Target**: Internal disk only. No external backup drive required.

### Modes 2 & 3 (`LocalDisasterGuard` & `HeadlessFull`) — Silent Guardians
* **Contract**: Built for mobile laptops (Mode 2) and silent office workstations (Mode 3).
* **Tray Sentry Policy**: The persistent Floppy Tray Sentry is **HARD-LOCKED OFF**. 
* **User Interface**: Does not clutter the notification area. Provides an **On-Demand Info Dialog & Settings** launched strictly via Start Menu / maintenance shortcuts.
* **Scam Watchdog**: ScamBuster watchdog runs silently in the background (~25–35 MB RAM).

### Mode 4 (`Total Guard`, formerly `TotalProtection`) — Full Observability
* **Contract**: The flagship deployment tier. Activates the signature multi-color Floppy Tray Sentry, full desktop shortcuts, dual-drive mirroring, and deep technician CLI controls.

### 📌 The F4 Startup Recovery Key Policy
* **Active in Modes 2, 3, 4, and WINBARS Guard**: Registers BCD customaction `0x100004` (with `0x100007` F7 fallback) to stage one-touch startup recovery into WinRE.
* **Strictly Omitted in Modes 0, N, and 1**: To honor the zero-footprint and native Windows bootloader guarantee, Modes 0, N, and 1 must **never** modify `{bootmgr}`.

---

## 💎 Rule 3: WINBARS Guard Consumer Transparency & Anti-Bloat

* **100% Consumer-Facing**: Built for retail buyers on the Microsoft Store ($14.99 one-time).
* **HARD LIMIT — Zero Hidden Menus or Backdoors**: WINBARS Guard must contain **no secret developer menus, no hidden hotkeys (`Ctrl+Shift+T`), and no backdoor CLI switchboards**. Undisclosed capabilities violate consumer trust and Store policies.
* **HARD LIMIT — Never Claim to be an Antivirus (AV)**: Guard is a **disaster prevention and emergency recovery tool**. It does not scan for virus definitions and must never market itself as an AV replacement. It works alongside Windows Defender.
* **HARD LIMIT — Zero End-User Upsell**: Emergency defusal screens (`Ctrl + Win + B`) must never display advertisements, purchase links, or upsells. The end-user dialog is 100% dedicated to calming the user and showing trusted local support information.
* **Featherweight Native Footprint**: Built with native Windows Presentation Foundation (WPF/XAML) using ~25–35 MB of RAM. Zero Chromium/Electron/WebView2 background runtimes.

---

## 🔍 Automated Moat Drift Verification

Run `tools/Test-ProductMoat.ps1` before any major release or commit. The test suite automatically validates:
1. WINTools contains zero automated backup scheduler tasks.
2. Mode 0 and Mode N contain zero write calls to `C:\ProgramData` or local disk paths.
3. Mode 1 contains zero ScamBuster or third-party binary installations.
4. Modes 2 and 3 enforce `EnableTraySentry = $false`.
5. BCD modifications for F4 startup key are skipped on Modes 0, N, and 1.
6. WINBARS Guard consumer manifests contain zero hidden CLI or backdoor triggers.
