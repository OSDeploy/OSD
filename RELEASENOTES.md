# OSD PowerShell Module

## Release Notes Start Date: 24.01.02

Note from Gary Blok (@gwblok) 

I know that OSDCloud has been around awhile, and has a ton of changes over the past couple years.  I'm starting this now so I can better keep track of changes I create, and other contributors.

Note, the changes I make won't go into effect until the next module release date, so if you see changes here, and the date is newer then the module date, then they haven't taken effect.

## Changes

23.12.01
- Moved ESD file references in catalog form using WSUS data to using Microsoft Creation Tool catalogs
- Catalog File: https://github.com/OSDeploy/OSD/blob/master/Catalogs/CloudOperatingSystems.json
- Process to create Catalog File: https://github.com/OSDeploy/OSD/blob/master/build/Build-OSDCloudOperatingSystemsv3.ps1


24.01.02 
- Modified Intel Wireless Function [Get-IntelWirelessDriverPack] to use Intel's Driver and Support Assistant Catalog after previous method has been blocked by Intel, To resolve [Issue 101](https://github.com/OSDeploy/OSD/issues/101)
- Modified IntelWirelessDriverPack.json catalog with updated drivers, removed support for older OSes and 32bit
- Added support for custom ESD files on flash drive in OSDCloud\OS folder per Request [Issue 85](https://github.com/OSDeploy/OSD/issues/85)
  - They will show up in Start-OSDCloudGUIDev or use Variables
  - $Global:MyOSDCloud.ImageFileItem
  - $Global:MyOSDCloud.ImageFileName
  - $Global:MyOSDCloud.ImageFileFullName
  - See an example here: https://github.com/gwblok/garytown/blob/master/Dev/CloudScripts/SettingOSDCloudVarsSample.ps1
- Modifications to MS Catalog Driver Update Process
  - When using MS Updates for Drivers while in WinPE, it will check the OSDCloudUSB drive in \OSDCloud\MsUpCatDrivers and copy those local if needed.
  - You can enable the MS Update Catalog drivers to sync from C back to the USB Drive by setting a variable
    - SyncMSUpCatDriverUSB = [bool]$true
    - Note that default behavior as of now is disabled [$false] 
- SetupComplete Phase
  - OSDCloud by default creates SetupComplete.cmd & SetupComplete.ps1 to run addtional tasks during SetupComplete
  - OSDCloud will look for OSDCloudUSB\OSDCloud\Config\Scripts\SetupComplete\SetupComplete.cmd.  If found, the contents of that entire folder are copied to C:\OSDCloud\Scripts\SetupComplete and OSDCloud will trigger your custom SetupComplete.cmd file at the end of it's own SetupComplete processes
  - Ability to Shutdown Computer at the end of SetupComplete Phase by setting variable
    - ShutdownSetupComplete = [bool]$true 
- ### HP Enterprise Class device specific updates
  - These Updates happen in various phases
  - Update BIOS by setting Variable - WinPE Phase
    -  $Global:MyOSDCloud.HPBIOSUpdate
  - Update TPM by setting Variable - Specialize Phase
    - $Global:MyOSDCloud.HPTPMUpdate
  - Use HPIA by setting Variable - SetupComplete Phase
    - $Global:MyOSDCloud.HPIAALL | Runs HPIA in "All" mode (Software, Accesories, BIOS, Drivers, Firmware)
    - $Global:MyOSDCloud.HPIADrivers | Runs HPIA in "Drivers" mode (Drivers Only)
  - Created & Updated serveral HP Specific functions to support these options
    - For complete list of Functions run: Get-Command -Module "OSD" | Where-Object {$_.Name -match "-HP"}