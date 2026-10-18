# WINBARS Demo Kit

Safe, local-only demos for showing customers (or colleagues) what WINBARS **Mode 4 – Total Protection** does.
Nothing here downloads or installs anything. This folder is **not** part of the release ZIP or `dist/`.

| Demo | What it simulates | How it triggers WINBARS |
|---|---|---|
| **ScamBuster** | Fake full-screen "VIRUS DETECTED – call Microsoft" browser lockup | `scambuster-lockup.html` goes full screen with a scam-phrase window title |
| **RAT Interceptor** | A scammer getting a remote-access tool running | A renamed copy of `cmd.exe` called `ratdemo.exe` (dedicated demo token) |
| **PUP Shield** | Bundled junkware / fake "driver updater" installer | A renamed copy of `cmd.exe` called `pupdemo.exe` (intercepted in real time in Mode 4 or via `-ScanPupNow`) |

## Before any demo (Mode 4)
1. WINBARS is deployed in Mode 4 and the **Floppy Tray Sentry is running** (system-tray floppy icon).
2. Run PowerShell from this folder. Check readiness with:
   ```powershell
   .\Run-Demo.ps1 -Demo Status
   ```
3. Close anything you care about (the ScamBuster "reclaim" button closes all browsers).

## Quick start
```powershell
.\Run-Demo.ps1                 # interactive menu
.\Run-Demo.ps1 -Demo ScamBuster
.\Run-Demo.ps1 -Demo RAT       # launches harmless ratdemo.exe placeholder
.\Run-Demo.ps1 -Demo PUP       # launches harmless pupdemo.exe placeholder
.\Run-Demo.ps1 -Demo Cleanup
```
Or open `index.html` for a presenter page with the same steps.

## 1. ScamBuster (real-time)
* **Trigger:** the foreground browser fills the whole primary screen **and** its title contains a scam phrase
  (`security alert`, `virus`, `microsoft support`, …). The tray checks about every **2.5 seconds**.
* **Run:** `.\Run-Demo.ps1 -Demo ScamBuster`, then click **Start the demo** on the page.
* **Expected:** browser audio is muted and the rescue dialog appears
  (*"THE SCREEN SHOWING BEHIND THIS PROMPT IS A SCAM"*).
  **Cancel / Keep Open** continues the demo; **RECLAIM MY COMPUTER** shows the clean-up (closes all browsers).
* **Exit the simulation:** `Esc`, the **End demo** button, or it auto-ends after 3 minutes.
* The optional siren is quiet and only plays if you tick the box, so you can show the audio being muted.

## 2. RAT Interceptor (real-time)
* **Trigger:** a running process whose name matches a known remote-access tool (including the dedicated `ratdemo`
  demo signature) and that is **not** on `SentryAndNotifications.AllowedRemoteTools`. Same ~2.5 second check.
* **Run:** `.\Run-Demo.ps1 -Demo RAT` (default name `ratdemo`). Using `ratdemo.exe` avoids touching or
  allow-listing any real remote-access tool (`AnyDesk`, `TeamViewer`, etc.) on the machine.
* **Expected:** the remote-access warning appears within a few seconds. The script reports whether the
  placeholder was closed while it watched, then cleans up.

## 3. PUP Shield (real-time in Mode 4 + sweep)
* **Trigger:** in Mode 4, the Floppy Tray Sentry checks running processes every ~2.5 seconds against `pup_rules.json`
  (including `pupdemo`), and WINBARS also sweeps at logon, after MSI installs, or via `WINBARS.exe -ScanPupNow`.
* **Run:** `.\Run-Demo.ps1 -Demo PUP` – starts `pupdemo.exe` and watches for the Mode 4 Tray Sentry to intercept it
  in real time (falling back to `WINBARS.exe -ScanPupNow` if the tray is not running).
* **Expected:** the PUP warning dialog names the program and offers to cancel the install.

## Good to know
* Both `ratdemo.exe` and `pupdemo.exe` are copies of Windows' own `cmd.exe` in `%TEMP%\WINBARS_Demo` using dedicated
  synthetic names so they never conflict with real remote tools or trigger AV heuristics for commercial RAT filenames.
* `-Demo Cleanup` stops the placeholders and removes the temp folder at any time.
