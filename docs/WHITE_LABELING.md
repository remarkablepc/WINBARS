# White-Labeling & The Lifetime Shop Branding Token

## 1. Overview & Business Model

WINBARS is distributed as a **100% free standalone executable (`WINBARS.exe`)** for individual computer users, home labs, and basic technician use.

For independent computer repair shops, Managed Service Providers (MSPs), and IT consultants, WINBARS offers an optional **$100 One-Time Lifetime Shop Branding Token**. This token configures the suite as an in-house, white-labeled client defense asset carrying your shop's business name, phone hotline, website, and direct remote support integration across unlimited customer machines.

---

## 2. Commercial IT & MSP Architecture: Fixed Cost vs. Recurring Subscriptions

| Operational Requirement | Traditional Enterprise Backup / RMM | WINBARS with Lifetime Shop Token |
| :--- | :--- | :--- |
| **Pricing Model** | $50–$100+ per machine, **every single year** | **$100 one-time flat fee**, lifetime ownership |
| **Endpoint Limits** | Strict per-seat metering (10, 50, 100 seats) | **Unlimited client PCs** |
| **White-Label Cost** | Enterprise tiers starting at $5,000–$10,000/yr | Included with token |
| **Direct Contact** | Generic vendor brand; client forgets who serviced the PC | Client sees **your shop name** and **hotline** directly |
| **Connectivity** | Requires continuous cloud dashboard connection | **100% offline**, air-gapped, zero cloud dependencies |
| **Scam Defense** | Blind to signed remote tools (AnyDesk, TeamViewer) | **Active Remote Tool Interceptor** blocks unauthorized access |

### Direct Support Verification & Anti-Fraud Protection:
When a customer picks up their repaired PC, they take home a protected system. Months later, when they encounter a scare, need a file restored, or want to back up their data:
* They open the **Protection Center** (`Ctrl + Win + W` or desktop shortcut).
* The header prominently displays: `Protected by [Your Business Name] • Managed Safeguards`.
* A single click dials your shop's hotline or opens your helpdesk website.
* Clicking **Remote Support** displays a branded verification dialog showing your shop's verified contact information and anti-fraud warning before launching Microsoft Quick Assist—stopping clients from searching Google and calling scam call centers.

---

## 3. Cryptographic Offline Architecture (`branding.json`)

To prevent tampering, unauthorized key spoofing, or grey-market resale, WINBARS protects white-label metadata using **asymmetric ECDSA-SHA256 signatures and AES-256 encryption**:

```text
       [ Shop Info: Name, Phone, URL, Notice ]
                         │
                         ▼  (Cryptographic Master Signer)
                [ branding.json ]  <-- Contains Signature + Encrypted Payload
                         │
                         ▼  WINBARS.exe (Target PC)
               [ 100% Offline Local Audit ]
                         ├── Valid Signature  --> Displays Shop Branding & Hotline
                         └── Missing/Invalid  --> Falls Back to Generic Unbranded Suite
```

* **Zero Cloud Dependence**: The cryptographic public key is embedded within `WINBARS.exe`. Validation takes 5 milliseconds using Windows native Cryptography API: Next Generation (CNG).
* **Zero Telemetry / Phone-Home**: WINBARS never contacts a licensing server or verifies activations over the internet. It works in completely air-gapped, offline, and secure enterprise environments.

---

## 4. How to Obtain and Deploy Your Shop Branding

### Step 1: Obtain Your Lifetime Token
1. Acquire the **$100 Lifetime Shop Branding Token** through the [official RemarkablePC checkout portal](https://www.paypal.com/ncp/payment/EKH76RTYHH24S).
2. Provide your shop details:
   * **Company Name**: (e.g. `Emerald Coast Computer Repair`)
   * **Support Hotline**: (e.g. `(850) 555-0199`)
   * **Website URL**: (e.g. `https://emeraldrepair.com`)
   * **Custom Emergency Notice**: (e.g. `Questions or blue screen? Call Emerald Coast Repair at (850) 555-0199 immediately.`)
3. You will receive your signed, production-ready `branding.json` file.

### Step 2: Portable Deployment via USB
1. Copy `branding.json` onto your technician USB drive in the same folder as `WINBARS.exe` and `Run-WINBARS.bat`.
2. Insert the USB into the client workstation and double-click `Run-WINBARS.bat`.
3. Select **Option 2 (`Launch Technician Interactive Console & Setup Wizard`)**:
   * The launcher detects `branding.json` and prompts:
     `Apply shop branding? (Y/n) [Default: Y]:`
   * If you wish to deploy a vanilla, unbranded setup on this specific machine, enter `N`.
   * If you choose to provision the suite to `C:\Tools\WINBARS`, the branding file is automatically copied with the suite.

### Step 3: Command-Line Unattended Deployment
For automated deployment scripts or deployment via your existing RMM agent:

```cmd
REM Deploy Branded Managed Suite (Tray sentry + desktop shortcuts):
WINBARS.exe -Install -Branded

REM Deploy Branded Zero-Footprint (Task scheduler with branded recovery cards):
WINBARS.exe -SetProfile ZeroFootprint -Branded

REM Deploy Vanilla / Unbranded (Force ignores branding.json):
WINBARS.exe -Install -Vanilla
```

### Step 4: Web Deployment via Private/Public Web Server (One-Liner Install)
You can deploy your white-labeled WINBARS suite over the web via a single PowerShell command:

```powershell
irm https://backup.yourshop.com | iex
```

#### Smart User-Agent Routing (`.htaccess`)
Your web server can serve both interactive web users and automated PowerShell scripts from the exact same root URL:
- **Browsers (Chrome, Edge, Safari)**: Served `index.php` or `index.html` (professional white-labeled landing/info page), or redirected to your main company website.
- **PowerShell / `curl` / `Invoke-RestMethod`**: Automatically rewritten to serve `install.ps1` as `text/plain`.

```apache
# Apache .htaccess Smart User-Agent Routing
AddType text/plain .ps1
DirectoryIndex index.php index.html install.ps1

<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /

    # 1. Automated CLI Runners -> Serve install.ps1
    RewriteCond %{HTTP_USER_AGENT} (PowerShell|WindowsPowerShell|curl|Wget|WinGet) [NC]
    RewriteCond %{DOCUMENT_ROOT}/install.ps1 -f
    RewriteRule ^$ install.ps1 [L]

    # 2. (Optional) Redirect Web Browsers to Main Website
    # RewriteCond %{HTTP_USER_AGENT} !(PowerShell|WindowsPowerShell|curl|Wget|WinGet) [NC]
    # RewriteRule ^$ https://yourshop.com/ [R=302,L]
</IfModule>
```

#### Folder Structure & Aliasing
On your private web server, place your brand JSONs and certificates in simple folders. The package automatically resolves aliases:
- **Branding Directory**: `brands/`, `brand/`, or `branding/` (e.g. `brands/my_shop.json`)
- **Certificates Directory**: `certs/`, `cert/`, or `certificates/` (e.g. `certs/ShopMasterKey.cer` — public `.cer` key only; never upload private `.pfx` keys!)

#### Zero-Footprint Staging in %TEMP%
When clients execute the web installer, the staging ZIP archive and extraction process live entirely within `%TEMP%`. If Mode 0 (`ZeroFootprint`) is deployed, the staging files are purged upon task execution, preserving complete forensic sterility on the client host.

---

## 5. Branded User Experience Across the Suite

When branded, the client encounters your business identity across all customer touchpoints:

1. **Protection Center Live Dashboard**:
   * Top Header: `Protected by [Your Business Name] • Managed Safeguards, System Recovery & Security`.
   * Support Pill: Displays your shop's hotline with 1-click calling.
   * Helpdesk Button: Directly opens your company website.
2. **Floppy System Tray Menu (Profile 4)**:
   * Top Branding Item: `🛡 Managed by [Your Business Name]`.
   * Direct Menu Item: `📞 Call Support: [Your Phone]`.
3. **Emergency ScamBuster & Remote Tool Warnings**:
   * In addition to stopping full-screen browser traps, the warning screen advises:
     *"If someone claiming to be technical support asked you to install this, STOP! Call [Your Business Name] at [Your Phone] before proceeding."*
4. **Printable BitLocker Emergency Card**:
   * The generated offline `BitLocker_Emergency_Card.html` features your shop header and emergency assistance instructions.
