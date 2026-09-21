# WINBARS BitLocker Master Key & Enterprise Certificate Architecture
## Universal Data Recovery Agent (DRA), Asymmetric Escrow & Co-Custody Guide

---

## 1. Overview & Problem Statement

### The Silent Encryption Trap
On modern Windows 10 and 11 computers (especially laptops, tablets, and OEM desktops), Windows automatically and silently enables **BitLocker Device Encryption** as soon as a user signs in with a Microsoft Account or connects to an Entra/Azure domain.

When hardware anomalies occur—such as:
- A TPM firmware glitch or motherboard replacement
- A BIOS/UEFI update or CMOS battery failure
- An SSD swap, controller failure, or boot order change
- Windows crash loop triggering automated recovery

Windows reboots into the dreaded **blue BitLocker Recovery screen**, demanding a 48-digit numerical recovery key.

### The Business & Bench Nightmare
If:
- The customer does not remember their Microsoft account login credentials
- An ex-employee left the company without documenting their recovery password
- The computer was set up with a local account or OEM temp profile
- The Microsoft Account was locked, disabled, or flagged for 2FA

**The encrypted data is mathematically unrecoverable.** 

WINBARS solves this permanently with a **100% native Universal Master Key Subsystem** that requires **zero resident software**, works across all Windows editions (Home, Pro, Enterprise, Education), and supports **dual co-custody**.

---

## 2. Asymmetric Cryptography: Zero Risk to Client Privacy

WINBARS uses industry-standard asymmetric RSA cryptography (`New-SelfSignedCertificate -Type DocumentEncryptionCert` / `DataRecoveryAgent`):

```
                       ┌────────────────────────────────────────────────────────┐
                       │               RSA-2048 / 4096 KEYPAIR                  │
                       └───────────────────────────┬────────────────────────────┘
                                                   │
                   ┌───────────────────────────────┴───────────────────────────────┐
                   ▼                                                               ▼
     ┌───────────────────────────┐                                   ┌───────────────────────────┐
     │   PUBLIC CERTIFICATE      │                                   │    PRIVATE MASTER KEY     │
     │         (*.cer)           │                                   │          (*.pfx)          │
     ├───────────────────────────┤                                   ├───────────────────────────┤
     │ • CAN ONLY ENCRYPT / BIND │                                   │ • CAN DECRYPT & UNLOCK    │
     │ • CAN NEVER DECRYPT       │                                   │ • SECURED WITH PASSPHRASE │
     │ • SAFE ON CLIENT COMPUTERS│                                   │ • NEVER LEAVES SHOP/OWNER │
     │ • SAFE ON PUBLIC WEBSITES │                                   │ • NEVER PUT ON GITHUB     │
     └───────────────────────────┘                                   └───────────────────────────┘
```

### Can you generate a `.cer` without having the `.pfx` first?
**No.** In asymmetric cryptography, key generation mathematically derives the private factors ($p, q, d$) and the public parameters ($N, e$) at the same instant. Once generated and exported, however:
- The `.pfx` is moved to secure offline cold storage (fireproof safe, encrypted USB, hardware token).
- The `.cer` is detached and distributed freely.

---

## 3. Dual-Custody Roles: Shop Master vs. Company Master

WINBARS supports enrolling **two independent master certificates** on the exact same computer simultaneously:

| Feature | Shop Master Key (`ShopMasterKey.cer`) | Enterprise / Company Key (`CompanyMasterKey.cer`) |
| :--- | :--- | :--- |
| **Primary Holder** | Support Shop / MSP Technician Bench | Business Owner, Managing Director, or Internal IT |
| **Use Case** | Bench repairs, warranty service, managed support | Fleet management, employee turnover, company data sovereignty |
| **Independence** | Can unlock any client machine serviced by shop | Can unlock any company machine without depending on external shop |
| **Co-Custody** | **Co-Active**: If an emergency occurs, EITHER party can unlock the computer independently. |

### Pre-Flight Co-Custody Toggle (`[M]`)
During interactive deployment, WINBARS detects all available certificates and allows technicians to cycle co-custody with a single keystroke:
- **`[Both Active]`**: Enrolls both Shop Master DRA and Company Enterprise DRA.
- **`[Company Only]`**: Enrolls exclusively the client company's master key (100% client autonomy).
- **`[Shop Only]`**: Enrolls exclusively the shop's recovery certificate.
- **`[Disabled]`**: Skips master certificate enrollment completely (relies only on local/backup key archival).

---

## 4. Universal Windows Edition Support

Different Windows editions handle BitLocker differently. WINBARS adapts automatically without requiring third-party tools:

### Windows Pro, Enterprise & Education (Native DRA)
On Windows Pro and Enterprise, WINBARS enrolls the public certificate(s) directly into Windows BitLocker as official **Data Recovery Agents (DRA)** using native Windows APIs:
```cmd
manage-bde.exe -protectors -add C: -Certificate -CertPath "ShopMasterKey.cer"
```
- The volume encryption key is hardware-bound to the certificate.
- The machine can be unlocked from WinPE, WinRE, or live Windows using the authorized `.pfx`.

### Windows Home (Device Encryption / Asymmetric Escrow)
Windows Home natively encrypts drives via *BitLocker Device Encryption* but lacks the native Enterprise DRA protector API. 

WINBARS overcomes this limitation by automatically:
1. Extracting the active 48-digit numerical recovery key via WMI/CIM.
2. Encrypting the recovery key into an asymmetric RSA cipher container using the public certificate.
3. Storing the encrypted ciphertext in:
   - Host PC: `C:\SystemRecovery\ShopEscrow.bin` and/or `CompanyEscrow.bin` (restricted to SYSTEM/Admin).
   - Technician USB: `<USB>:\ShopVault\<COMPUTERNAME>_ShopBitLocker.enc`
4. The key **cannot be decrypted** without the private `.pfx` passphrase in the shop safe.

---

## 5. How to Generate Master Keys

WINBARS includes turnkey batch wizards located in the `tools/` directory:

### 1. Generating a Shop Master Keypair
1. Run `tools/Generate-ShopMasterKey.bat` as Administrator on the shop bench PC.
2. Enter your shop or company name (e.g., `MacPCMarket` or `RemarkablePC`).
3. Enter a strong private key passphrase.
4. Output files:
   - `ShopMasterKey_Private.pfx` $\rightarrow$ **Store immediately in your shop's password vault or safe.**
   - `ShopMasterKey.cer` $\rightarrow$ Copy to your technician USB drives or host on your IRM web server.

### 2. Generating an Enterprise Company Master Keypair
1. Run `tools/Generate-BusinessMasterKey.bat` as Administrator on the client's corporate PC.
2. Enter the business name (e.g., `AcmeMedical_DRA`).
3. Enter the business owner's private passphrase.
4. Output files:
   - `CompanyMasterKey_Private.pfx` $\rightarrow$ Handed directly to the business owner on an encrypted flash drive.
   - `CompanyMasterKey.cer` $\rightarrow$ Placed on the deployment USB or embedded in the company's `config.json`.
   - **Base64 String**: The wizard automatically prints the Base64-encoded certificate string to the console for easy copy-pasting into JSON files!

---

## 6. How WINBARS Discovers Master Certificates

WINBARS supports zero-touch automatic certificate discovery through four separate channels:

### Method A: Standalone Files on USB / Deployment Media
Drop any of the following into `certs/`, `branding/`, `config/`, `tools/`, or the USB root:
- `ShopMasterKey.cer`
- `CompanyMasterKey.cer`
- `*.cer` (any X.509 certificate with Document Encryption or DRA KeyUsage)

### Method B: Global Configuration (`config/config.json`)
```json
{
  "SecurityShields": {
    "CompanyMasterKey": "certs/AcmeCorp_Public.cer",
    "MasterCertificateBase64": "MIIChzCCAW+gAwIBAgIQ..."
  }
}
```

### Method C: Embedded Base64 in Brand Profiles (`branding/*.json`)
For 1-click remote deployment (e.g., via IRM web links), you can embed the raw `.cer` as a Base64 string directly into your brand JSON:
```json
{
  "Brand": {
    "CompanyName": "MacPC Market",
    "MasterCertificateBase64": "MIIChzCCAW+gAwIBAgIQ..."
  }
}
```
WINBARS automatically decodes the Base64 string in memory and stages it for BitLocker enrollment—requiring **zero secondary file downloads**.

### Method D: Web-Hosted IRM Deployment
When launching WINBARS via PowerShell IRM (e.g., `irm macpc.remarkablepc.com | iex`):
- The public `ShopMasterKey.cer` is hosted alongside `install.ps1`.
- The installer downloads `ShopMasterKey.cer` directly to the staging folder before executing setup.

---

## 7. Emergency Unlocking Procedure (Disaster Recovery)

If a machine is locked with a blue BitLocker recovery screen:

### Unlocking Windows Pro / Enterprise with Shop PFX:
1. Boot the computer into **Windows Recovery Environment (WinRE)** or connect a **WINBARS Rescue USB**.
2. Open Command Prompt (`Shift + F10`).
3. Plug in the secure technician flash drive containing `ShopMasterKey_Private.pfx`.
4. Run:
   ```cmd
   tools\Unlock-BitLocker-With-ShopKey.bat
   ```
5. Enter the private PFX passphrase when prompted.
6. The script imports the private DRA into the WinRE session, issues `manage-bde.exe -unlock C: -Certificate`, and unlocks the drive immediately!

### Decrypting Windows Home Asymmetric Escrow:
1. Copy `C:\SystemRecovery\ShopEscrow.bin` (or from `<USB>:\ShopVault\`) to the technician bench.
2. In PowerShell with the shop PFX imported:
   ```powershell
   $pfx = Get-PfxCertificate -FilePath "ShopMasterKey_Private.pfx"
   $cipher = [System.IO.File]::ReadAllBytes("ShopEscrow.bin")
   $keyText = [System.Text.Encoding]::UTF8.GetString($pfx.PrivateKey.Decrypt($cipher, [System.Security.Cryptography.RSAEncryptionPadding]::Pkcs1))
   Write-Host "Discovered 48-Digit Recovery Key: $keyText"
   ```
3. Type the 48-digit key into the blue recovery screen to unlock Windows.

---

## 8. Client Sovereignty & Zero Vendor Lock-In

### Can a client disable or remove the master key?
**Yes, easily.** WINBARS strictly upholds zero vendor lock-in:
1. **Pre-Flight Keystroke**: Press `[M]` during deployment to switch to `[Company Only]` or `[Disabled]`.
2. **Deleting the Certificate**: Simply deleting `ShopMasterKey.cer` from the USB or clearing `"MasterCertificateBase64"` from `config.json` prevents enrollment on future passes.
3. **Removing Existing DRA Protector from Live PC**:
   Open an elevated Command Prompt and run:
   ```cmd
   manage-bde.exe -protectors -get C:
   manage-bde.exe -protectors -delete C: -id {PROTECTOR-GUID}
   ```
4. **Permanent Prevention**: Once the DRA protector is removed from the volume, the shop **cannot re-enable it remotely** without physical bench access and the client's explicit consent.
