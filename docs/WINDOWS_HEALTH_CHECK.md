# WINBARS Windows Health Check (SFC / DISM)

WINBARS includes a proactive **Windows System File Integrity scanner** that automatically runs Microsoft's native `sfc.exe` (System File Checker) and escalates to `DISM /RestoreHealth` when SFC cannot repair corruption on its own. Results are logged to the Windows Event Viewer and a local state file, with live progress bars available on-demand.

---

## How It Works: The Pre-Scan Checkpoint & Escalation Ladder

```
                    ┌─────────────────────────────┐
                    │  Invoke-WindowsHealthCheck  │
                    │  (Scheduled or On-Demand)   │
                    └──────────────┬──────────────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │ STEP 0: Safety Checkpoint   │
                    │ (Atomic System Restore Pt)  │
                    └──────────────┬──────────────┘
                                   │
                         ┌─────────▼─────────┐
                         │  sfc /scannow      │
                         │  (native Windows)  │
                         └─────────┬──────────┘
               ┌───────────────────┼───────────────────────┐
          Exit 0                Exit 1                  Exit 2
        (No corruption)     (Found & Fixed)      (Found, Cannot Fix)
               │                   │                       │
        ✅ DONE            ✅ DONE — repaired     ⬇ DISM Escalation
        EV: 1011           EV: 1012              ┌──────────────────┐
                                                 │ DISM /RestoreHealth│
                                                 │ (native Windows)   │
                                                 └────────┬──────────┘
                                              ┌───────────┴────────────┐
                                         Success                    Failure
                                         EV: 1014                EV: 1015
                                      ✅ Repaired             ❌ Technician
                                                               Required
```

---

## Structured Windows Event IDs

All health check events are written to the **Windows Application Event Log** under the configured source name (default: `WINBARS`):

| Event ID | Type | Meaning |
| :---: | :--- | :--- |
| **1010** | Information | Windows Health Check started |
| **1011** | Information | SFC completed — no corruption found |
| **1012** | Warning | SFC found and repaired file corruption |
| **1013** | Warning | SFC found corruption it could NOT repair — escalating to DISM |
| **1014** | Information | DISM RestoreHealth completed successfully |
| **1015** | Error | DISM RestoreHealth FAILED — technician action required |

> [!TIP]
> Filter the Application log in Event Viewer by Source = `WINBARS` (or your shop name) and Event IDs `1010–1015` to audit all health check runs across a fleet of managed PCs.

---

## Schedule Configuration

Health check scheduling is mode-aware and fully configurable in `config/config.json` under the `WindowsHealthCheck` block:

```json
"WindowsHealthCheck": {
    "Enabled":                   true,
    "ScheduleMode":              "Daily",
    "ScheduledTime":             "03:00",
    "IntervalDays":              1,
    "SkipIfMissed":              true,
    "IdleMinutesBeforeRun":      30,
    "CreatePreScanRestorePoint": true,
    "EscalateToDismOnFailure":   true
}
```

| Setting | Default | Description |
| :--- | :---: | :--- |
| `Enabled` | `true` | Enable or disable scheduled health check runs. |
| `ScheduleMode` | `"Daily"` | Recurrence trigger mode: `"Daily"`, `"Weekly"`, or `"Idle"`. Available across Modes 1–4 and Mode N. |
| `ScheduledTime` | `"03:00"` | Daily or Weekly trigger time in 24-hr format (HH:mm). |
| `IntervalDays` | `1` | Minimum days between runs (frequency cap). |
| `SkipIfMissed` | `true` | If the machine was off at trigger time, skip this cycle rather than running on next wakeup. |
| `IdleMinutesBeforeRun` | `30` | Minutes of system idle before triggering a run when in Idle mode (15, 30, 45, 60 min). |
| `CreatePreScanRestorePoint` | `true` | Creates an atomic System Restore Point rollback checkpoint prior to system file repairs. |
| `EscalateToDismOnFailure` | `true` | Automatically run DISM when SFC reports unfixable corruption. |

### Trigger Flexibility Across Modes

| Mode | Default Trigger | Configurable Options | SkipIfMissed |
| :--- | :--- | :--- | :---: |
| **Mode 0** | — (Forensic Sterility) | Omitted by design (0 host tasks) | — |
| **Mode N** | Fixed daily time (03:00 AM) | Daily / Weekly at any HH:mm | ✅ |
| **Mode 1** | Fixed daily time (03:00 AM) | Daily / Weekly at any HH:mm | ✅ |
| **Mode 2** | System idle (30 min) | Daily / Weekly / Idle (15–60m) | ✅ |
| **Mode 3** | System idle (30 min) | Daily / Weekly / Idle (15–60m) | ✅ |
| **Mode 4** | System idle (30 min) | Daily / Weekly / Idle (15–60m) | ✅ |

---

## GUI & Protection Center Integration

1. **Status Card Carousel (Card 3)**:
   - Displays live `Windows Health:` line with real-time status:
     - `[OK] Clean (Daily 03:00)` or `[OK] Repaired (Checkpoint Saved)` (Forest Green)
     - `[!] Corruption Detected` (Amber Warning)
     - `[N/A] Mode 0 (Forensic Sterility)` (Slate Gray)
   - Dynamic real-time timer updates without restarting the tray app.

2. **System Health & Canary Forensics Menu**:
   - Menu item: `Windows Integrity & Health Check (SFC/DISM)...`
   - Opens the interactive Windows Health configuration dialog.

3. **Technician Settings Menu**:
   - Menu item: `Windows Health Check Schedule...`
   - Allows changing Mode (`Daily`, `Weekly`, `On System Idle`), Time (`HH:mm`), Idle Threshold (`15m`–`60m`), and Pre-Scan Restore Point checkpoint.
   - Includes 1-click `Run Scan Now` button.

4. **System Diagnostics & Feature Audit**:
   - Check 13 evaluates Windows file integrity, Task Scheduler registration, and recent scan logs.
   - Outputs scorecard `[PASS]` / `[WARN]` / `[FAIL]`.

---

## Event Log Integration

Health check results (and all other significant WINBARS actions) are written to the Windows Application Event Log. The Event Log source name is configured in `config/config.json`:

```json
"EventLog": {
    "Enabled":    true,
    "SourceName": "WINBARS"
}
```

| Setting | Default | Description |
| :--- | :---: | :--- |
| `Enabled` | `true` | Enable/disable all Event Log writes from WINBARS. Default OFF for Mode 0 only. |
| `SourceName` | `"WINBARS"` | The Event Log source name. If `Branding.ShopName` is set, that takes precedence unless `SourceName` is explicitly set. |

> [!IMPORTANT]
> The Event Log source must be registered once in the Windows registry under `HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application\<SourceName>`. WINBARS handles this automatically at deployment time (elevation exists at that moment). Subsequent writes from Task Scheduler require **zero elevation**.

### Full Event ID Reference

| Event ID | Type | Meaning |
| :---: | :--- | :--- |
| **100** | Information | General informational event |
| **101** | Warning | General warning event |
| **1000** | Information | WINBARS mode deployed / activated |
| **1001** | Information | Backup completed successfully |
| **1002** | Error | Backup failed |
| **1010** | Information | Windows Health Check started |
| **1011** | Information | SFC — no corruption found |
| **1012** | Warning | SFC found and repaired corruption |
| **1013** | Warning | SFC found corruption SFC could not repair (DISM escalation) |
| **1014** | Information | DISM RestoreHealth completed successfully |
| **1015** | Error | DISM RestoreHealth FAILED — technician action required |
| **1020** | Information | BitLocker DRA guard enrolled |
| **1030** | Warning | ScamBuster blocked a remote tool |
| **9000** | Information | WINBARS mode removed / uninstalled |

---

## On-Demand Usage

Run a Windows Health Check interactively at any time with a live progress window:

```cmd
WINBARS.exe -WindowsHealthCheck
```

- Shows a **GDI+ progress window** during the run.
- SFC phase: **indeterminate (marquee)** progress bar — SFC does not emit real-time percentages.
- DISM phase: **real-time percentage** progress bar — DISM stdout is parsed live.
- Displays a summary dialog on completion: clean, repaired, or failed.
- Respects the `IntervalDays` frequency cap. Use `-Force` to override.

### Headless (Scheduled) Mode
When invoked from Task Scheduler (`-Unattended` flag):
- Runs completely silently with no UI.
- Logs results to Event Viewer and state file.
- On DISM failure (Modes 2–4): sends a Windows toast notification to the desktop.

---

## CLI Configuration Reference

```cmd
# Run on-demand with progress UI
WINBARS.exe -WindowsHealthCheck

# Enable or disable scheduled health check
WINBARS.exe -EnableHealthCheck
WINBARS.exe -DisableHealthCheck

# Change interval (days between runs)
WINBARS.exe -ConfigureHealthCheck -Interval 14

# Change scheduled time (Modes N and 1 only)
WINBARS.exe -ConfigureHealthCheck -Time 02:00

# Change idle threshold (Modes 2-4 only)
WINBARS.exe -ConfigureHealthCheck -IdleMinutes 45

# Enable / disable Event Log integration
WINBARS.exe -EnableEventLog
WINBARS.exe -DisableEventLog

# Set white-label Event Log source name
WINBARS.exe -ConfigureEventLog -SourceName "TechPros PC Care"
```

---

## State File

The health check writes a small JSON state file after each run to enforce the `IntervalDays` frequency cap:

- **Modes 2–4**: `C:\ProgramData\WINBARS\health_check_state.json`
- **Modes N / 1**: External backup drive `WINBARS_Logs\health_check_state.json` (falls back to `C:\SystemRecovery\health_check_state.json`)

```json
{
    "LastRunTime":  "2026-09-21 03:04:17",
    "LastResult":   "Healthy",
    "SfcExitCode":  "0",
    "DismResult":   "NotRun",
    "MachineName":  "DESKTOP-ABC123"
}
```

`LastResult` values: `Healthy`, `RepairedViaSfc`, `RepairedViaDism`, `Failed`, `Unknown`.

---

## Known Limitations

- **SFC progress**: `sfc.exe` does not emit real-time percentage output. The progress bar during SFC phase is indeterminate (marquee). Total duration is typically 5–20 minutes.
- **DISM network dependency**: `DISM /RestoreHealth` downloads repair files from Windows Update. On machines with broken Windows Update or no internet, DISM may fail with error `0x800f0906`. This requires manual in-shop repair using a Windows ISO as an offline source (`/Source` flag) — beyond WINBARS' automated scope.
- **Mode 0**: Windows Health Check is never activated in Zero-Footprint mode. Mode 0's zero-host-action contract is absolute.
