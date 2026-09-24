# BitLocker AES-256 Disaster Vault & 1-Click WinPE Recovery

## 1. The Real-World BitLocker Crisis

Modern Windows 10 & 11 PCs (OEM installations from Dell, HP, Lenovo, Microsoft Surface) now enable **BitLocker Device Encryption by default** out of the factory.

### Why Disaster Strikes:
1. **The Silent Trap**: Non-technical customers have zero idea their internal SSD is encrypted.
2. **Missing 48-Digit Key**: The 48-digit numerical recovery key was never printed or backed up to a USB drive.
3. **The 2FA Catch-22**: When a BIOS update, firmware flash, or hardware repair trips the TPM, the machine halts at a blue BitLocker recovery prompt. The customer cannot access their Microsoft Account to retrieve the key because their 2-factor authentication code is sent to an email account accessible only on that locked computer!

---

## 1.1 TPM Hardware PINs vs. External Drive Passwords (BitLocker To Go)

A common point of confusion is why BitLocker on external drives requires complex passwords instead of simple 4-to-6 digit numeric PINs:

* **Internal OS Drives (`C:\`) & TPM Anti-Hammering**:
  Internal drives rely on the computer's motherboard **TPM (Trusted Platform Module)** chip. A short numeric PIN is secure on the host PC because the hardware TPM enforces **rate limiting and lockout counter penalties** (preventing brute-force guessing attacks).
* **External Removable USB Drives (BitLocker To Go)**:
  External drives have **no onboard TPM**. If an external drive accepted a short numeric PIN, an attacker could attach it to another machine and brute-force all possible PIN combinations in seconds. Therefore, Windows mandates an **alphanumeric Password / Passphrase** (with complexity rules) or Smart Cards.
* **Seamless Host PC Auto-Unlock (`AutoUnlockKey Protector`)**:
  To avoid having to type long passwords every day, BitLocker allows **Auto-Unlock on authorized host PCs**. When enabled, the drive master key is stored in the host PC's registry, encrypted by the host TPM and user logon session. The drive unlocks instantly when plugged into the host PC, while remaining password-protected if plugged into an unfamiliar machine.
* **The 48-Digit Recovery Key Failsafe**:
  If the user forgets their password or needs to unlock the drive in WinPE/WinRE, the 48-digit numerical recovery key backed up by WINBARS serves as the ultimate master recovery bypass.

---

## 1.2 Blocking Silent Automatic Encryption Traps (`PreventDeviceEncryption`)

Starting in Windows 11 (24H2) and on modern hardware supporting Modern Standby / HSTI, Windows automatically activates **Device Encryption** silently in the background when linking a Microsoft account or completing major setup updates.
* **The Risk**: This encryption happens without any confirmation prompts, warning dialogs, or visible display of the 48-digit numerical recovery key. If a firmware update trips the TPM before the user prints a key, they are permanently locked out.
* **The Native Prevention**: WINBARS configures native Windows registry policy:
  `HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker` -> `PreventDeviceEncryption = 1` (DWORD).
  This policy prevents Windows from silently encrypting the system drive in the background, while still allowing the user or administrator to manually enable BitLocker intentionally whenever desired.
* **Scope & Controls**:
  * **Modes 1, 2, 3, and 4**: Enabled by default during deployment.
  * **Modes 0 and N**: Excluded (strict 0-modification host compliance).
  * **Interactive Pre-Flight**: Toggleable via `[E]` key in `Invoke-ProfilePreFlightMenu`.
  * **CLI Automation**: Toggleable via `WINBARS.exe -BlockSilentBitLocker` and `WINBARS.exe -AllowSilentBitLocker`.
  * **Console Menu**: Toggleable in Setup Menu -> `[9] Protection Shields` -> `[4] Block Silent BitLocker Device Encr.`
  * **Clean Uninstallation**: Reverted automatically upon `Uninstall.bat` or `WINBARS.exe -ResetSuite`.

---

## 2. The WINBARS Solution: Encrypted Vault & 1-Click WinPE Unlock

WINBARS automates key archival at rest while providing an effortless unlock mechanism during a disaster:

### A. AES-256 Vault Architecture (BitLocker_Vault.enc)
* **Automated Archival**: On every scheduled backup pass, WINBARS queries active BitLocker volume protectors via manage-bde -protectors -get C:.
* **Zero Plaintext on Disk**: While a human-readable text key (BitLocker_Recovery_Keys.txt) is saved to the physical USB vault, an encrypted container (BitLocker_Vault.enc) is also constructed.
* **Cryptographic Hardening**:
  * Key Derivation: PBKDF2 (100,000 iterations of SHA-256 with 128-bit salt).
  * Encryption: AES-256-CBC cipher stream.
  * Integrity Authentication: HMAC-SHA256 payload verification.

---

## 3. The 1-Click WinPE Recovery Workflow

When a customer's computer is locked at the blue BitLocker recovery screen, boot from standard Windows installation media or WINBARS WinRE rescue drive:

`	ext
========================================================================
   WINBARS BitLocker Disaster Recovery & Auto-Unlock Wizard             
========================================================================
 [!] Locked BitLocker volume detected on drive C:
 [!] Encrypted recovery vault found on USB: D:\WINBARS_Backup\BitLocker_Keys\BitLocker_Vault.enc

 Enter your Windows account password or PIN to unlock: [ ********** ]

 [*] Decrypting 48-digit recovery key in RAM... SUCCESS!

 Choose your recovery unlock action:
  [1] 1-Click Instant Unlock & Suspend for 1 Reboot (Recommended)
      -> Unlocks drive C: and allows Windows to boot straight to desktop
  [2] Instant Unlock Volume (Active Session Only)
  [3] Display 48-Digit Numerical Recovery Key on Screen
  [0] Cancel
`

### Key Technical Commands Used:
* **Temporary Suspension for 1 Clean Reboot**:
  `cmd
  manage-bde -unlock C: -RecoveryPassword <48-digit-key>
  manage-bde -protectors -disable C: -RebootCount 1
  `
  *This permits the machine to reboot normally directly into Windows without prompting the user for 48 digits, allowing Windows to automatically re-seal the TPM cleanly upon logon.*

---

## 4. Printable Emergency Recovery Card (BitLocker_Emergency_Card.html)

WINBARS automatically generates a printable, high-contrast HTML disaster card saved to:
D:\WINBARS_Backup\BitLocker_Keys\BitLocker_Emergency_Card.html

* Styled with CSS `@media print` rules for physical printing.
* Displays segmented, large-format 48-digit recovery passwords for all system drives.
* Includes emergency phone support instructions and technician contact information.

---

## 5. Universal Master Key Architecture: Shop Master & Enterprise Business Master (Co-Custody)

For repair benches, managed service providers (MSPs), corporate IT departments, and small businesses, WINBARS includes a **100% native Universal BitLocker Master Key engine** supporting single or dual co-custody key enrollment:

### A. The Challenge with Unaware Clients & Fleet Management
Modern Windows 10/11 PCs silently activate BitLocker Device Encryption by default. Everyday users and small businesses are completely unaware of BitLocker until a TPM glitch, BIOS flash, or motherboard replacement stops boot with a blue recovery prompt. If the user cannot access their Microsoft account, or an ex-employee left without providing the 48-digit key, data is mathematically lost.

### B. Dual-Custody Roles (Shop vs. Company)
BitLocker natively supports **multiple Data Recovery Agent (DRA) certificate protectors on the same volume**. WINBARS leverages this to offer two distinct master roles:
1. **Shop Partner Key (`ShopMasterKey.cer`)**: Kept by the external IT provider/shop. Useful for bench repairs and ongoing managed service.
2. **Company / Business Master Key (`CompanyMasterKey.cer`)**: Created for and held exclusively by the **business owner or internal IT director**. The business retains 100% independent ownership and can unlock any PC across their fleet without being dependent on an outside vendor.
3. **Co-Custody (`[Both Active]`)**: Both the company owner and the IT provider can independently unlock the computer in a disaster. If the business ever transitions away from an IT partner, the shop protector can be cleanly unenrolled without affecting the company's master key.

### C. Zero-Branding Requirement (Universal & Independent)
**Using Master Keys does NOT require custom branding.** A 100% vanilla or Mode 0/1 setup can utilize Company or Shop Master Keys through multiple convenient discovery channels:
* **Standalone Files**: Drop `ShopMasterKey.cer`, `CompanyMasterKey.cer`, or any `*.cer` into `certs/`, `branding/`, `config/`, `tools/`, or the USB root.
* **General Configuration (`config/config.json`)**:
  ```json
  "SecurityShields": {
      "CompanyMasterKey": "certs/AcmeMedical_Public_DRA.cer",
      "MasterCertificateBase64": "MIIChzCCAW+gAwIBAgIQ..."
  }
  ```
* **Embedded Base64 in JSON**: The entire public `.cer` can be embedded directly into `config.json` or a brand JSON as a Base64 string. WINBARS decodes and materializes the certificate automatically on the fly—enabling seamless, single-file zero-extra-asset remote deployments!

### D. Asymmetric Cryptography (Zero Risk to Client Security)
WINBARS uses asymmetric public/private cryptography (`New-SelfSignedCertificate -Type DocumentEncryptionCert`):
1. **Private Master Keys (`*_Master_Private.pfx`)**:
   - Password-protected and retained strictly inside physical safes / secure lockboxes.
   - **NEVER uploaded to web servers and NEVER committed to GitHub.**
2. **Public Certificates (`*.cer`)**:
   - Can only encrypt or act as a DRA, never decrypt. Completely safe on client PCs and public web servers.
   - During deployment, WINBARS automatically discovers all available public certificates and binds them.

### E. Universal Dual-Engine Support
* **Windows Pro & Enterprise**: Binds the public certificate(s) directly to the volume as official native Data Recovery Agents (`manage-bde -protectors -add C: -Certificate ...`).
* **Windows Home (Device Encryption)**: Asymmetrically encrypts the volume's 48-digit recovery key using the RSA public certificate(s) and stores it in:
  - Local disk: `C:\SystemRecovery\ShopEscrow.bin` and/or `C:\SystemRecovery\CompanyEscrow.bin`
  - Technician USB: `<TechDrive>:\ShopVault\<Machine>_<Role>_BitLocker.enc`

### F. Future-Proofing: Drives Encrypted After Deployment
* **What if the drive is not BitLocker-encrypted on the bench?** If WINBARS is deployed on an unencrypted drive, the public certificate(s) are staged locally (`C:\SystemRecovery\`).
* **AutoHeal Sentry (Modes 1–4)**: On every system boot and scheduled maintenance pass, AutoHeal checks if `C:` was recently encrypted. If BitLocker is detected and the master keys have not yet been bound, AutoHeal automatically attaches the protectors in the background—requiring zero customer or shop intervention!

### G. 1-Click Bench Batch Wizards
* `tools/Generate-MasterKey.bat`: Consolidated 1-click wizard to generate Shop Master Key, Business Client Key, or Custom Master Keypair (also prints Base64 string for JSON embedding).
* `tools/Unlock-BitLocker-With-MasterKey.bat`: Consolidated 1-click unlock tool for technicians running in WinPE, WinRE, or live Windows. Auto-detects any Shop or Business `.pfx` key and unlocks `C:\` instantly.
* `tools/Verify-MasterKey-Password.bat`: Safely tests and verifies unlock passwords against any `.pfx` file without touching system drives.