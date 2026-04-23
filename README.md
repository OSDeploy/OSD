# OSD PowerShell Module

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/OSD)](https://www.powershellgallery.com/packages/OSD)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/OSD)](https://www.powershellgallery.com/packages/OSD)
[![License](https://img.shields.io/github/license/OSDeploy/OSD)](LICENSE)

A PowerShell module for Windows deployment, built around **OSDCloud** — a modern, internet-based OS deployment framework that runs entirely from WinPE.

- **Author:** David Segura
- **Project site:** https://osd.osdeploy.com
- **GitHub:** https://github.com/OSDeploy/OSD
- **PowerShell Gallery:** https://www.powershellgallery.com/packages/OSD

---

## Requirements

| Requirement | Value |
|---|---|
| PowerShell | 5.1 or later |
| Edition | Desktop (Windows PowerShell) |
| OS | Windows |

---

## Installation

### Install from PowerShell Gallery

```powershell
Install-Module -Name OSD -Force
```

### Update to the latest version

```powershell
Update-Module -Name OSD -Force
```

### Import into the current session

```powershell
Import-Module -Name OSD -Force
```

### Check the installed version

```powershell
Get-Module -Name OSD -ListAvailable | Select-Object Name, Version
```

---

## Quick Start: OSDCloud

OSDCloud deploys Windows directly from the internet (or a USB cache) via WinPE. The typical workflow is:

### 1. Create a WinPE template

```powershell
New-OSDCloudTemplate -Name "OSDCloudWinPE"
```

### 2. Create a workspace and USB drive

```powershell
$OSDCloudWorkspace = "C:\OSDCloudWinPE"
New-OSDCloudWorkspace -WorkspacePath $OSDCloudWorkspace
New-OSDCloudUSB
```

### 3. Optionally customize WinPE

```powershell
# Add a PowerShell module into WinPE (e.g., HPCMSL for HP devices)
Edit-OSDCloudWinPE -PSModuleInstall HPCMSL

# Add 7-Zip support for extracting HP softpaqs in WinPE
Edit-OSDCloudWinPE -Add7Zip
```

### 4. Boot and deploy

Boot from the OSDCloud USB drive. From WinPE, launch the deployment:

```powershell
# GUI (recommended for interactive deployments)
Start-OSDCloudGUI

# Command line
Start-OSDCloud -OSName "Windows 11 24H2 x64" -OSEdition Pro
```

---

## Key Features & Function Groups

### OSDCloud Deployment

| Function | Description |
|---|---|
| `Start-OSDCloud` | Core deployment engine — downloads and installs Windows from the internet |
| `Start-OSDCloudGUI` | Interactive GUI for selecting OS, language, and edition |
| `Start-OSDCloudGUIDev` | Developer/testing GUI with additional HP, SetupComplete, and debug options |
| `Start-OSDCloudCLI` | Non-interactive command-line deployment |
| `Invoke-OSDCloud` | Invokes OSDCloud after variables are set |
| `Invoke-OSDCloudIPU` | In-Place Upgrade using OSDCloud |

### Template & Workspace Management

| Function | Description |
|---|---|
| `New-OSDCloudTemplate` | Creates a new WinPE template using the installed Windows ADK |
| `New-OSDCloudWorkspace` | Creates a new OSDCloud workspace from a template |
| `Edit-OSDCloudWinPE` | Customizes the WinPE boot image (modules, drivers, 7-Zip, etc.) |
| `New-OSDCloudUSB` | Creates a bootable OSDCloud USB drive |
| `Update-OSDCloudUSB` | Updates an existing OSDCloud USB drive |
| `Get-OSDCloudTemplate` | Returns the current OSDCloud template |
| `Set-OSDCloudTemplate` | Sets the active OSDCloud template |

### Driver Packs

| Function | Description |
|---|---|
| `Get-MyDriverPack` | Detects and returns the appropriate driver pack for the current device |
| `Save-MyDriverPack` | Downloads the driver pack for the current device |
| `Get-HPDriverPackLatest` | Gets the latest HP driver pack for a given platform |
| `Get-DellDriverPackCatalog` | Returns the Dell driver pack catalog |
| `Get-LenovoDriverPackCatalog` | Returns the Lenovo driver pack catalog |
| `Get-SurfaceDriverPackCatalog` | Returns the Surface driver pack catalog |
| `Get-OSDCatalogDriverPack` | Returns driver pack catalog entries across all vendors |

### HP Device Management

| Function | Description |
|---|---|
| `Get-HPTPMDetermine` | Detects the required HP TPM firmware update package (SP87753 / SP94937) |
| `Invoke-HPTPMEXEDownload` | Downloads the required HP TPM firmware to `C:\OSDCloud\HP\TPM` |
| `Invoke-HPTPMEXEInstall` | Extracts and installs the staged HP TPM firmware via TPMConfig64.exe |
| `Invoke-HPTPMDowngrade` | Downgrades an Infineon TPM from firmware 2.0 to 1.2 |
| `Install-HPIA` | Installs HP Image Assistant |
| `Invoke-HPIA` | Runs HP Image Assistant to update drivers, firmware, BIOS, and software |
| `Install-ModuleHPCMSL` | Installs the HP Client Management Script Library (HPCMSL) |
| `Get-HPSoftpaqListLatest` | Returns the latest HP softpaq list for a platform |

### Windows Image Servicing

| Function | Description |
|---|---|
| `Edit-MyWindowsImage` | Mounts and services a Windows image offline |
| `Mount-MyWindowsImage` | Mounts a WIM/FFU for offline servicing |
| `Dismount-MyWindowsImage` | Dismounts a mounted Windows image |
| `Copy-PSModuleToWindowsImage` | Injects a PowerShell module into an offline Windows image |
| `Add-WindowsPackageSSU` | Adds a Servicing Stack Update to a Windows image |
| `Update-MyWindowsImage` | Applies cumulative updates to a mounted Windows image |

### Disk & Volume Management

| Function | Description |
|---|---|
| `Get-LocalDisk` | Returns local fixed disks |
| `Clear-LocalDisk` | Clears all partitions from a local disk |
| `Get-USBDisk` | Returns connected USB disks |
| `Clear-USBDisk` | Clears all partitions from a USB disk |
| `New-OSDisk` | Creates a new OSD-formatted disk layout |
| `Backup-DiskToFFU` | Captures a disk to a Full Flash Update (FFU) image |
| `Invoke-SelectLocalDisk` | Interactive disk selection UI |

### Microsoft Update Catalog

| Function | Description |
|---|---|
| `Get-MsUpCat` | Queries the Microsoft Update Catalog |
| `Get-MsUpCatUpdate` | Returns update metadata from the MS Update Catalog |
| `Save-MsUpCatDriver` | Downloads a driver update from the MS Update Catalog |
| `Save-MsUpCatUpdate` | Downloads an update package from the MS Update Catalog |

### OOBE & SetupComplete

| Function | Description |
|---|---|
| `Invoke-oobeUpdateWindows` | Runs Windows Update during OOBE |
| `Invoke-oobeUpdateDrivers` | Runs driver updates during OOBE |
| `Invoke-oobeAddNetFX3` | Adds .NET Framework 3.5 during OOBE |
| `Invoke-oobeAddRSAT` | Adds RSAT tools during OOBE |
| `New-OSDCloudUSBSetupCompleteTemplate` | Creates SetupComplete script templates on OSDCloud USB |
| `New-OSDCloudWorkSpaceSetupCompleteTemplate` | Creates SetupComplete script templates in the workspace |

### WinRE & WiFi

| Function | Description |
|---|---|
| `Connect-WinREWiFi` | Connects to WiFi from WinRE/WinPE |
| `Connect-WinREWiFiByXMLProfile` | Connects to WiFi using an XML profile from WinRE/WinPE |
| `Get-WinREWiFi` | Returns available WiFi networks from WinRE |
| `Set-WinREWiFi` | Configures WiFi in WinRE |

### Azure

| Function | Description |
|---|---|
| `Connect-OSDCloudAzure` | Authenticates to Azure for OSDCloud |
| `Get-AzOSDCloud` | Returns Azure OSDCloud resources |
| `Get-CloudSecret` | Retrieves a secret from Azure Key Vault |
| `Set-CloudSecret` | Saves a secret to Azure Key Vault |

---

## Useful Commands

```powershell
# List all exported functions
Get-Command -Module OSD

# List all HP-related functions
Get-Command -Module OSD | Where-Object { $_.Name -match '-HP' }

# List all OSDCloud-related functions
Get-Command -Module OSD | Where-Object { $_.Name -match 'OSDCloud' }

# Get help for a specific function
Get-Help Start-OSDCloud -Full
Get-Help New-OSDCloudTemplate -Examples
```

---

## Links

- [Documentation](https://osd.osdeploy.com)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/OSD)
- [GitHub Repository](https://github.com/OSDeploy/OSD)
- [Changelog](CHANGELOG.md)
- [FAQ](FAQ.md)
- [License](LICENSE)
