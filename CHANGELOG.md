# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [26.4.23.1] - 2026-04-23

### Changed

- **`Public/OSDCloudTS/Get-HPTPMDetermine.ps1`** — Enhanced all HP TPM management functions with comprehensive comment-based help (synopsis, description, parameters, examples, outputs, notes) and improved error handling:
  - `Install-ModuleHPCMSL` — Installs/updates HPCMSL 1.8.5 from the PowerShell Gallery; added full documentation.
  - `Test-HPTPMFromOSDCloudUSB` — Tests for HP TPM firmware softpaq files (SP87753/SP94937) on an OSDCloud USB drive; added parameter and output documentation.
  - `Get-HPTPMDetermine` — Queries WMI to identify required Infineon TPM firmware update package; added full documentation.
  - `Invoke-HPTPMDownload` — Downloads and extracts the required HP TPM softpaq via HPCMSL; added `WorkingFolder` parameter documentation.
  - `Invoke-HPTPMDowngrade` — Downloads SP94937 and downgrades an Infineon TPM from 2.0 to 1.2; added full documentation.
  - `Invoke-HPTPMEXEDownload` — Downloads the required HP TPM firmware EXE to `C:\OSDCloud\HP\TPM`, with OSDCloud USB fallback; added full documentation.
  - `Invoke-HPTPMEXEInstall` — Extracts and installs the staged HP TPM firmware via TPMConfig64.exe; added parameter and exit-code documentation.
- **`OSD.psd1`** — Bumped module version to `26.4.23.1`; updated generated-on date to `4/23/2026`.
