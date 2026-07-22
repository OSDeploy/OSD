# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [26.7.10.1] - 2026-07-10

### Added

- **OSD Core function surface expansion** — Added new core functions for deployment and catalog workflows, including `Get-OSDCoreOperatingSystems`, `Initialize-OSDCoreDevice`, `Invoke-OSDCoreDownloadFile`, `Get-OSDCoreCacheContent`, `Get-OSDCoreCacheDrive`, `Get-OSDCoreCachePathUSB`, `Test-OSDCoreCacheUSB`, `Get-OSDCoreDeploymentDisk`, `Get-OSDCoreLicense`, and driver pack catalog helpers (`Get-OSDCoreDriverPackCatalogDell`, `Get-OSDCoreDriverPackCatalogHP`, `Get-OSDCoreDriverPackCatalogLenovo`, `Get-OSDCoreDriverPackCatalogPanasonic`, `Get-OSDCoreDriverPackCatalogSurface`, `Get-OSDCoreDriverPacks`).
- **New OSDCloud workflow functions** — Added `Get-OSDCloudDefaultOS`, `Invoke-RecastOSDCloud`, `Invoke-RecastOSDCloudCLI`, `Start-RecastOSDCloudCLI`, `Start-RecastOSDCloudGUI`, and `Update-RecastOSDCloudUSBCache` to support default OS resolution, CLI/GUI deployment UX, and USB cache maintenance workflows.
- **New OSDCloud deployment steps** — Added step functions for preinstall logs, hooks, disk validation and partitioning, USB drive letter removal and restore, ODT and Autopilot JSON validation, Windows ESD copy/download/save, driver pack cache/online validation, driver pack offline/online save, Office staging, module save, OS information export, BCD boot configuration, WinPE and WinRE driver handling, telemetry, final logging, and workflow cleanup.
- **Source validation helpers** — Added `Test-OSDCoreDriverPackObjectUrl`, `Test-OSDCoreOperatingSystemObjectUrl`, and hardened `Test-WebConnection` behavior for live TCP validation and cache-bypassed HTTP HEAD checks.
- **OOBE, firmware, and utility functions** — Added OOBE deployment helpers, Microsoft Update COM object retrieval functions, GitHub raw content helpers, Azure Key Vault secret conversion, PSCloudScript retrieval, video resolution lookup, Bootmgr timeout configuration, Dell BIOS helpers, Windows Update manifest retrieval, and additional Windows settings, registry, cache path, module path, module version, and VM setting helpers.
- **Driver pack and OEM artifacts** — Added core driver pack catalog files for Dell, HP, Lenovo, Surface, Panasonic, generic mappings under `core/driverpacks`, and OEM driver/BIOS catalog support scripts.
- **Repository authoring guidance** — Added `.github/copilot-instructions.md` with standardized comment-based help authoring requirements.

### Changed

- **Recast OSDCloud workflow refresh** — Reworked the Recast OSDCloud launch flow with timestamped output, deployment timing, telemetry handling, final log export, WinPE post-action cleanup, improved Windows edition and image metadata handling, and updated CLI/GUI parameter support.
- **OSDCloud step state model** — Updated deployment steps to use clearer global state flags for cached operating system objects, cached driver pack objects, and online source tests.
- **Cache and media handling** — Improved OSDCloud cache discovery, USB cache detection, Windows ESD copy/save behavior, hash validation, retry logging, and offline/online operating system and driver pack source selection.
- **Device and keyboard detection** — Expanded `Initialize-OSDCoreDevice` with USB disk and partition information plus improved keyboard and language-code detection.
- **Comment-based help standardization** — Updated and standardized help metadata, examples, notes, parameter descriptions, and link casing across a broad set of public scripts, docs, Azure functions, OSDCloud setup, VM, TS, IPU, system firmware, HPIA, Microsoft Update, and module utility functions.
- **Author metadata normalization** — Updated author references in help documentation to align with Recast Software attribution standards.
- **Logging and diagnostics** — Standardized log date formatting from `G` to `s`, added command names to verbose/error messages, normalized logging colors, clarified administrative rights errors, and improved firmware, BitLocker, module resource, assembly loading, and catalog parsing diagnostics.
- **Docs folder normalization** — Updated documentation links and generated docs to use the lowercase `docs` path consistently.
- **Cloud and launch script refresh** — Updated `cloud/functions.ps1`, cloud subdomain scripts, OSDCloud workspace behavior, OSDCloud GUI project files, and launch scripts to align with new function exports and workflow changes.
- **Dependency and export maintenance** — Updated dependencies and refreshed `OSD.psd1` exports for the new and reorganized function surface, including Recast, OSD Core cache, source validation, and USB cache commands.

### Removed

- **Deprecated private operating system retrieval functions** — Removed `Private/operatingsystem/Get-CoreOperatingSystems.ps1` and legacy private `Get-OSDCoreOperatingSystems` implementation after migration to the public core function layout.
- **Deprecated and relocated Recast entry points** — Removed old top-level `Public/Invoke-RecastOSDCloud.ps1` and `Public/Invoke-RecastOSDCloudCLI.ps1` after moving the Recast command implementations under `Public/recast`.
- **Deprecated conversion and Intel driver pack scripts** — Removed deprecated ESD conversion wrappers, obsolete Intel Ethernet driver pack scripts, and older OSDCloud IPU support scripts superseded by the newer Windows Update manifest and conversion flows.

---

## [26.7.6.1] - 2026-07-06

### Changed

- **`Invoke-OSDCloud` analytics instrumentation** (`OSD/Public/OSDCloud.ps1`) — Added deployment analytics event handling in the launch validation flow, including hashed device UUID generation for privacy-safe correlation and expanded event property collection for deployment telemetry.
- **`OSD.psd1`** — Bumped module version to `26.7.6.1` and updated generated-on date to `2026-07-06`.

---

## [26.6.25.1] - 2026-06-25

### Added

- **Operating system catalog retrieval functions** — Added `Get-MCTOperatingSystems` and `Get-MCTOperatingSystemsOSD` to improve catalog data retrieval workflows used by OSDCloud.

### Changed

- **Operating system retrieval refactor** — Renamed and reorganized internal retrieval functions (`Get-CoreOperatingSystems`, `Get-OSDCoreOperatingSystems`) and updated `Get-OSDCloudOperatingSystems` to use the newer flow while removing deprecated function paths.
- **`OSD.psd1`** — Updated exports for operating system retrieval function changes and bumped module version to `26.6.25.1`; updated generated-on date to `6/25/2026`.
- **Power and index function documentation** — Enhanced comment-based help for:
  - `Get-PowerSettingSleepAfter`
  - `Get-PowerSettingTurnMonitorOffAfter`
  - `Get-OSDCloudOperatingSystemsIndexMap`
  - `Get-OSDCloudOperatingSystemsIndexes`
- **Driver pack and cache content** — Added Panasonic driver pack catalog coverage and refreshed associated operating system catalog/cache artifacts.

### Removed

- **Legacy v2 driver pack docs and scripts** — Removed outdated `Get-OSDCatalogDriverPack` and `Get-OSDCatalogDriverPacks` documentation and v2 public functions.
- **Archived operating system cache artifacts** — Removed stale `cache/archive-operatingsystems/operatingsystems.json` and `cache/archive-operatingsystems/operatingsystems.xml`.

---

## [26.6.23.1] - 2026-06-23

### Changed

- **Windows 11 25H2 operating system catalogs** — Updated the published 25H2 media catalog to build `26200.8653` for release consumption.
- **`OSD.json`** — Refreshed Windows 11 25H2 release selections (x64 and ARM64) used by OSDCloud workflows.
- **`OSD.psd1`** — Bumped module version to `26.6.23.1`; updated generated-on date to `6/23/2026`.

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

---

## [25.2.26] - 2025-02-26

- `Invoke-OSDCloudIPU` — added `SkipFinalize` parameter ([Issue 247](https://github.com/OSDeploy/OSD/issues/247))

---

## [25.2.25] - 2025-02-25

- Several updates released since previous note
- ARM support removed from template creation — will be reworked and re-added at a future date
- TPM Update fixes (note: Windows 11 24H2 breaks several specialize behaviors that work on 23H2; no ETA for fix)
- `Invoke-OSDCloudIPU` — added additional parameters passed to the Windows Setup Engine
- Driver URL updates
- ADK feature changes
- WiFi changes and fixes
- `SetupComplete` functions modified to look in additional locations for custom SetupComplete files

---

## [24.11.15] - 2024-11-15

- Several minor changes and a bug fix — see closed issues for this period
- Completely revamped index lookup in the DEV GUI — now uses a generic Index Map for all build versions, eliminating the need to build a new Index Map per release
  - Built new Index Map JSON/XML files in the Catalog folders; older Index files to be cleaned up later
  - Considering dropping the Index Field in the GUI and dynamically resolving it in the main OSDCloud function script

---

## [24.11.14] - 2024-11-14

- Updated the Windows 11 24H2 catalog file with the latest public MS release (2024-10-04)

---

## [24.10.1] - 2024-10-01

- Windows 11 24H2 x64 and ARM64 support
  - Updated Catalog JSON & XML files
  - Updated `OSD.json` to add 24H2 options
  - Index JSON file for `Start-OSDCloudGUIDev` / ARM64 pending completion
  - Single test of `Start-OSDCloudGUI` with Windows 11 24H2 successful

---

## [24.7.8] - 2024-07-08

- Added function `Add-7Zip2BootImage`
  - Used by `New-OSDCloudTemplate` & `Edit-OSDCloudWinPE` to add 7-Zip into boot images

---

## [24.7.3] - 2024-07-03

- Added HP functions that mirror HP CMSL but work in WinPE:
  - `Get-HPDriverPackLatest` — finds the latest driver pack for a platform, with download or URL options
  - `Get-HPOSSupport` — lists supported Windows OSes for a platform
  - `Get-HPSoftpaqListLatest` — finds latest supported OS for a platform and provides softpaq list
  - `Get-HPSoftpaqItems` — provides softpaq list for a platform based on user input
- OSDCloud can now reach HP's catalog in real time to find and download the latest driver pack
  - New variable: `HPCMSLDriverPackLatest` (not available in GUI)
- Added 7-Zip (`7za.exe`) support for extracting HP Softpaqs in WinPE for offline DISM
  - Requires `-Add7Zip` with `New-OSDCloudTemplate`
  - `Edit-OSDCloudWinPE` support planned for a future release

---

## [24.3.27] - 2024-03-27

*Implemented in OSD Module 24.3.27.1*

- Quick fix for [Issue 132](https://github.com/OSDeploy/OSD/issues/132)
- Minor updates to DEV for ARM64 testing

---

## [24.3.22] - 2024-03-22

*Implemented in OSD Module 24.3.27.1*

- Small change to `Invoke-CatalogRequest` ([Issue 127](https://github.com/OSDeploy/OSD/issues/127))

---

## [24.3.20] - 2024-03-20

*Implemented in OSD Module 24.3.27.1*

- Added Debug Mode checkbox to `Start-OSDCloudGUIDev` drop-down menu
  - When `debugmode = $true` (via GUI or variable), creates additional logs in `C:\Windows\Temp\OSDCloud\Logs`:
    - DiskPart logs (before & after format step)
    - OSDCloudDebug logs: OSDCloud variables, Windows 11 readiness, TPM information, `MyComputerInfo`

---

## [24.3.19] - 2024-03-19

*Implemented in OSD Module 24.3.20.1*

- Bug fixes:
  - [Issue 126](https://github.com/OSDeploy/OSD/issues/126) — Unable to add HP drivers into WinPE: updated URL in function; added verbose logging
  - [Issue 125](https://github.com/OSDeploy/OSD/issues/125) — HP BIOS failing to update using CMSL: BIOS update moved to a separate job so failures no longer block OSDCloud

---

## [24.3.12] - 2024-03-12

*Implemented in OSD Module 24.3.20.1*

- `Start-OSDCloudGUIDev` — OS Edition and Index numbers now pulled dynamically based on OS Name, Language, and Activation selection ([Issue 117](https://github.com/OSDeploy/OSD/issues/117))
- `DISMFromOSDCloudUSB` — now searches mapped network drives in addition to USB volumes
  - Supports network drives following the OSDCloud USB folder structure as a driver cache

---

## [24.3.6] - 2024-03-06

*Implemented in OSD Module 24.3.10.1*

- Promoted HP and SetupComplete enhancements from `Start-OSDCloudGUIDev` to `Start-OSDCloudGUI`
- Fix for downloading content from MS Update Catalog ([Issue 122](https://github.com/OSDeploy/OSD/issues/122))

---

## [24.2.15] - 2024-02-15

*Implemented in OSD Module 24.2.20.1*

- `Set-TimeZoneFromIP` — completely reworked due to previous API no longer being free ([Issue 110](https://github.com/OSDeploy/OSD/issues/110), thanks @JHBDO)
- Added function `New-OSDCloudWorkSpaceSetupCompleteTemplate` ([Issue 107](https://github.com/OSDeploy/OSD/issues/107))
  - Creates SetupComplete files on the WorkSpace drive (`%WorkSpace%\Config\Scripts\SetupComplete`)
  - Files are automatically copied to OSDCloud USB on update and applied during SetupComplete

---

## [24.2.7] - 2024-02-07

*Implemented in OSD Module 24.2.13.1*

- Fixed `Start-OSDCloudGUI` called via command line with preset variables (thanks @PatrickThomasD2)
- Started basic ARM64 code support — no production plans in near term
  - Initial work to create ARM64 WinPE via OSDCloudTemplate functions

---

## [24.1.22] - 2024-01-22

*Implemented in OSD Module 24.2.4.1*

- Added function `New-OSDCloudUSBSetupCompleteTemplate`
  - Creates SetupComplete files on OSDCloud USB (`\OSDCloud\Config\Scripts\SetupComplete`)
- Updated `Start-OSDCloudGUIDev`:
  - HP Tools: HPIA (Drivers/Firmware/Software/All during SetupComplete), TPM update (Specialize), BIOS update (WinPE)
  - SetupComplete commands: Windows Updates, Windows Defender Updates, Apply Key from UEFI, Setup Complete Shutdown

---

## [24.1.17] - 2024-01-17

*Implemented in OSD Module 24.2.4.1*

- Fixed issue in `Save-FeatureUpdate` ([Issue 106](https://github.com/OSDeploy/OSD/issues/106))
- `Get-IntelWirelessDriverPack` — modified to better handle Intel's changing catalog URLs (thanks christiandekker, [Issue 101](https://github.com/OSDeploy/OSD/issues/101))
- `Start-OSDCloudGUI` — added support to show ESD and SWM files in the OS drop-down list ([Issue 99](https://github.com/OSDeploy/OSD/issues/99), [Issue 85](https://github.com/OSDeploy/OSD/issues/85))

---

## [24.1.9] - 2024-01-09

*Implemented in OSD Module 24.1.11.1*

- Integrated `Test-DISMFromOSDCloudUSB` & `Start-DISMFromOSDCloudUSB` into the main OSDCloud process
  - Detects pre-expanded driver packs on OSDCloud USB and DISMs them into the offline OS:
    - `OSDCloudUSB\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$PackageID`
    - `OSDCloudUSB\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$ComputerProduct`
  - Benefits: saves download time, reduces storage usage on device, all drivers present at first reboot
- DISM log copied from `X:\Windows\Logs\DISM\dism.log` to `C:\Windows\Temp\OSDCloud\Logs\WinPE-DISM.log`

---

## [24.1.3] - 2024-01-03

*Implemented in OSD Module 24.1.11.1*

- Added support for Split WIMs (`.swm`) ([Issue 99](https://github.com/OSDeploy/OSD/issues/99))
  - Tested with MS Surface Book 2 MS Recovery Media
  - Place `.swm` files in `OSDCloudUSB\OSDCloud\OS\%RecoveryImageName%`
  - Use `Start-OSDCloud -FindImageFile` or `Start-OSDCloudGUIDev`

---

## [24.1.2] - 2024-01-02

*Implemented in OSD Module 24.1.3.1*

- `Get-IntelWirelessDriverPack` — switched to Intel's Driver & Support Assistant catalog after previous method was blocked ([Issue 101](https://github.com/OSDeploy/OSD/issues/101))
- Updated `IntelWirelessDriverPack.json` — removed support for older OSes and 32-bit
- Added support for custom ESD files on USB in `OSDCloud\OS` folder ([Issue 85](https://github.com/OSDeploy/OSD/issues/85))
  - Available via `Start-OSDCloudGUIDev` or variables: `$Global:MyOSDCloud.ImageFileItem`, `.ImageFileName`, `.ImageFileFullName`
- MS Update Catalog driver process — checks `OSDCloudUSB\OSDCloud\MsUpCatDrivers` and copies locally when in WinPE
  - Optional USB sync back enabled via `SyncMSUpCatDriverUSB = $true` (default: `$false`)
- SetupComplete enhancements:
  - OSDCloud looks for `OSDCloudUSB\OSDCloud\Config\Scripts\SetupComplete\SetupComplete.cmd` and runs it after its own SetupComplete
  - Added shutdown-at-end-of-SetupComplete via `ShutdownSetupComplete = $true` ([Issue 96](https://github.com/OSDeploy/OSD/issues/96))
- HP Enterprise device support:
  - BIOS update (WinPE phase): `$Global:MyOSDCloud.HPBIOSUpdate`
  - TPM update (Specialize phase): `$Global:MyOSDCloud.HPTPMUpdate`
  - HPIA (SetupComplete phase): `$Global:MyOSDCloud.HPIAALL`, `$Global:MyOSDCloud.HPIADrivers`
  - Run `Get-Command -Module "OSD" | Where-Object {$_.Name -match "-HP"}` for full function list

---

## [23.12.1] - 2023-12-01

- Moved ESD file references in catalog from WSUS data to Microsoft Creation Tool catalogs
- Process: [Build-OSDCloudOperatingSystemsv3.ps1](https://github.com/OSDeploy/OSD/blob/master/build/Build-OSDCloudOperatingSystemsv3.ps1)
