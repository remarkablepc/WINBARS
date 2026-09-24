# Proactive Scam Sentry, Remote Access Interceptor & Global Hotkeys

## 1. The Real-World Epidemic: Call-Center Lockup Scams

Every week, repair shops and technicians encounter everyday computer users and seniors in tears after falling for social-engineering traps:
1. **Full-Screen Browser Lockups**: A malicious JavaScript popup traps the cursor in fullscreen mode (F11), displays fake FBI / Microsoft warning logos, and plays loud looping speech sirens demanding the user call a 1-800 number.
2. **Crash Tab Reload Traps**: When a panicked user force-kills the browser via Task Manager, reopening the browser triggers *"Restore tabs after unexpected shutdown"*, immediately reloading the exact same scam popup!
3. **Remote Access Hijacking**: The phone scammer instructs the victim to download remote access software (ScreenConnect, UltraViewer, AnyDesk, TeamViewer), takes over the screen, and drains bank accounts or ransoms the PC.
4. **Web Push Notification Floods**: Fake McAfee/Norton Expired bottom-right notification popups bombard the screen every few minutes even when the browser appears closed.

---

## 2. The 3-Layered WINBARS Defense

WINBARS provides active defense against these predatory social engineering traps:

```
+-------------------------------------------------------------------------+
| Layer 1: Universal Emergency Hotkey (Ctrl+Win+B)                        |
|   -> 1-Press Instant Browser Scram, Audio Mute & Reload Trap Purge       |
+-------------------------------------------------------------------------+
                                    |
+-------------------------------------------------------------------------+
| Layer 2: Proactive Fullscreen Browser Scam Sentry                       |
|   -> Dual Engine: Process Catalog + Win32 Window Class Heuristics       |
|   -> Automatically Mutes Blaring Audio & Defuses Reload Loop Traps      |
+-------------------------------------------------------------------------+
                                    |
+-------------------------------------------------------------------------+
| Layer 3: Remote Access Interceptor & Smart Whitelist                    |
|   -> Monitors 25+ remote access and RMM binaries (ScreenConnect, etc.)  |
|   -> 4-Way Action Modal: Disconnect, Allow, Whitelist, Snooze 2 Hours    |
+-------------------------------------------------------------------------+
```

> 🛡️ **Deployment Tier Integration (Modes 2, 3, 4)**:
> - **Modes 2 & 3 (Silent Guardian)**: Layers 1, 2, and 3 run **continuously in the background** to automatically mute audio sirens and block unauthorized remote access sessions without displaying taskbar tray clutter or office pop-ups.
> - **Mode 4 (Visual Sentry)**: Adds the interactive topmost prompt modal (`[STOP] Disconnect & Block`), full-screen overlay dialog, live Protection Center GUI, and the signature Floppy Tray Sentry.
> - **Modes 0, N, and 1**: Omit Scam Buster entirely to uphold a strict zero-resident-binary footprint policy.

---

## 3. Engine-Level Heuristics & Exotic Browser Matrix

Scam Buster operates at both the **executable level** and the **underlying engine level** to ensure complete protection across mainstream, exotic, and adware-bundled browsers:

### Supported Process Matrix (25+ Browsers):
* **Mainstream Engines**: Google Chrome, Microsoft Edge, Mozilla Firefox, Brave, Opera, Opera GX, Vivaldi.
* **Gecko / Firefox Forks**: Floorp (`floorp.exe`), Waterfox (`waterfox.exe`), LibreWolf (`librewolf.exe`), Zen Browser (`zen.exe`), Pale Moon (`palemoon.exe`), Mullvad Browser (`mullvadbrowser.exe`), Tor Browser (`torbrowser.exe`).
* **Chromium Forks & Adware Browsers**: Wave Browser (`wavebox.exe`, `waveserver.exe`, `wave.exe`, `wavebrowser.exe`), Arc (`arc.exe`), Thorium (`thorium.exe`), Chromium (`chromium.exe`), Yandex (`browser.exe`), DuckDuckGo (`duckduckgo.exe`), Sidekick (`sidekick.exe`), Epic Privacy Browser (`epic.exe`), Maxthon (`maxthon.exe`), CentBrowser (`centbrowser.exe`), Superbird (`superbird.exe`).

### Win32 Window Class Engine Detection:
Even if a scam operates in an unlisted or custom-named browser, WINBARS inspects the top-level foreground window class via Win32 API:
* **Chromium Engine**: `Chrome_WidgetWin_1` (detects 100% of Chromium-based browsers).
* **Gecko / Mozilla Engine**: `MozillaWindowClass` (detects 100% of Firefox-based forks).
* **Legacy Trident**: `IEFrame` / `Internet Explorer_Server`.

---

## 4. Engine-Wide Generic Profile & Notification Cleanser

When **Scam Buster** is triggered (via `Ctrl+Win+B` or `WINBARS.exe -ScamBuster`):

1. **Instant Audio Mute**: Immediately invokes Windows CoreAudio / winmm API to silence blaring panic sirens.
2. **Process Scram**: Terminates all running browser processes and popup loops across the entire browser matrix.
3. **Generic Session Trap Purge**:
   * **Chromium Engines**: Crawls `%LOCALAPPDATA%` and `%APPDATA%` for all `User Data` directories, deleting `Sessions`, `Current Session`, `Current Tabs`, `Last Session`, and `Last Tabs` across `Default` and numbered user profiles (`Profile 1`, `Profile 2`, etc.).
   * **Gecko / Firefox Engines**: Crawls `%APPDATA%` across all Mozilla, Floorp, Waterfox, LibreWolf, and Zen profile directories, removing `sessionstore*` crash restore state.
4. **Surgical Push Notification Defuser**:
   * Inspects `Preferences` files across all browser profiles for registered Web Push notification endpoints.
   * Purges subscriptions matching known malicious scam TLDs (`.top`, `.xyz`, `.click`, `.club`, `.buzz`, `.info`, `.icu`, `.cam`, `.work`, `.site`, `.online`, `.download`, `.cfd`, `.rest`, `.monster`, `.tk`, `.ml`, `.ga`, `.cf`, `.gq`).
   * **100% Safe for Legitimate Services**: Standard notifications for Gmail, Outlook, Facebook, YouTube, and Microsoft Teams remain completely untouched. Bookmarks, saved passwords, and browsing history are never modified.

---

## 5. Remote Access Interceptor & Servicing Modes

WINBARS continuously monitors active process trees for tools commonly exploited in phone scams:

| Remote Tool | Executable Name | Threat Context & Scammer Usage Pattern |
| :--- | :--- | :--- |
| **ScreenConnect / ConnectWise** | `ScreenConnect.ClientService.exe` | #1 most common tool deployed via malicious redirect sites. |
| **AnyDesk** | `AnyDesk.exe` | Lightweight portable remote desktop abused for bank transfers. |
| **UltraViewer** | `UltraViewer_Desktop.exe` | Frequently used by overseas call centers to bypass basic AV. |
| **TeamViewer** | `TeamViewer.exe`, `TeamViewer_Service.exe` | Standard commercial remote software abused in tech support scams. |
| **RustDesk** | `rustdesk.exe` | Open-source remote access tool increasingly abused by scammers. |
| **DWService / DWAgent** | `dwagent.exe` | Web-based background agent enabling persistent backdoor access. |
| **Splashtop** | `SplashtopStreamer.exe`, `SplashtopRemote.exe` | Commercial remote control agent installed during support sessions. |
| **RemotePC** | `RemotePCDesktop.exe`, `RemotePCService.exe` | Cloud remote utility deployed under guise of diagnostic tools. |
| **UltraVNC / TightVNC** | `winvnc.exe`, `tvnserver.exe` | Unencrypted VNC server instances opened for remote hijacking. |
| **Supremo** | `Supremo.exe`, `SupremoService.exe` | Portable remote access binary requiring zero installation. |
| **LogMeIn / GoToAssist** | `LMIGuardian.exe`, `g2a_comm.exe` | Enterprise remote tools used by unauthorized third-party callers. |
| **Zoho Assist** | `ZohoAssist.exe`, `ZohoURSService.exe` | On-demand support tool abused for screen manipulation. |
| **Atera / NinjaOne** | `AteraAgent.exe`, `NinjaRMMAgent.exe` | RMM agent installers tricked into executing on residential PCs. |

### 4-Way Security Warning Dialog Actions:
When an unapproved remote tool launches, WINBARS raises a topmost warning dialog:
1. **🛑 Disconnect & Block (Recommended)**: Immediately terminates the rogue remote access process tree.
2. **Allow Once**: Temporarily allows the remote tool for the current Windows session without altering config.
3. **Always Allow (Whitelist)**: Permanently adds the executable to `AllowedRemoteTools` in `config.json`.
4. **⏰ Snooze 2 Hrs (Tech Working)**: Suppresses all remote tool alerts for 2 hours, ideal when a technician is actively repairing or configuring the machine.

---

## 6. Universal Global Hotkeys & Smart Conflict Engine

Even when running in completely silent or headless modes:

* **Ctrl + Win + W $\rightarrow$ Live Protection Center Dashboard**:
  * **Automatic Conflict Fallback**: If another app holds `Ctrl+Win+W`, WINBARS automatically cycles through fallback candidates:  
    $$\text{Ctrl+Win+W} \longrightarrow \text{Ctrl+Win+P} \longrightarrow \text{Ctrl+Alt+W} \longrightarrow \text{Ctrl+Alt+B} \longrightarrow \text{Ctrl+Alt+P} \longrightarrow \text{Ctrl+Alt+D} \longrightarrow \text{F11}$$
* **Ctrl + Win + B $\rightarrow$ Emergency Scam Buster & Audio Scram (Paired with Quick Assist `Ctrl+Win+Q`)**:
  * **Automatic Conflict Fallback**:  
    $$\text{Ctrl+Win+B} \longrightarrow \text{Ctrl+Win+K} \longrightarrow \text{Ctrl+Alt+B} \longrightarrow \text{Ctrl+Alt+K} \longrightarrow \text{Ctrl+Alt+X} \longrightarrow \text{Ctrl+Alt+Q} \longrightarrow \text{F12}$$
* **Customizable via `config.json`**:
  ```json
  "GlobalShortcuts": {
      "ProtectionCenterHotkey": "Ctrl+Win+W",
      "ScamBusterHotkey": "Ctrl+Win+B"
  }
  ```
