# OSD PowerShell Module

## Release Notes Start Date: 24.01.02

Note from Gary Blok (@gwblok) 

I know that OSDCloud has been around awhile, and has a ton of changes over the past couple years.  I'm starting this now so I can better keep track of changes I create, and other contributors.

Note, the changes I make won't go into effect until the next module release date, so if you see changes here, and the date is newer then the module date, then they haven't taken effect.

If you really want to know what is going on, I suggest looking back over the merges and monitoring.  This is how I typically do it, as we have several contributors, and we typically don't communicate our changes to each other.  I have the repo synced in VSCode, and I look over the Source control Graph, which provides the notes with the commits, which generally gives me a good idea of the changes, and if I want to know more, I drill into look a the code changes. If you are serious in knowing all changes, I recommend you do something similar.

## Changes

### 25.2.26 (Not yet in Module)
 - Invoke-OSDCloudIPU - added SkipFinalize - Issue 247


### 25.2.25 (Filling in the Blanks)
 - Several updates have been released since my last note, sorry, just don't have much time... you get it.
 - ARM support was removed from creating a template, this will be reworked and readded at a future date
 - TPM Update Fixes [Note 24H2 breaks a lot of things in specialize that just work as expected on 23H2, no ETA or plans to fix from our side]
 - Invoke-OSDCloudIPU has added a few parameters that can be passed to the Windows Setup Engine.
 - I noticed some driver URLS have been updated
 - I noticed changes for the ADK features
 - Some WiFi Changes & Fixes
 - SetupComplete Functions modified to look in additional locations for custom setup complete files to run.


### 24.11.15 (Released to Gallary)
 - Several minor changes over the past month, including a bug fix - see issues closed over the past month
 - Completely revamped the index lookup in the DEV GUI - Modified to use a generic Index Map for all Build Versions.  This will greatly simplify the method no longer requiring me to build a new Index Map for each build.
  - As part of this, built a new Index Map JSON/XML files in the Catalog folders. Will eventually go back and cleanup the no longer used Index files 
  - Still considering just dropping the Index Field in the GUI, and have it dynamically figured out in the main OSDCLOUD function script

### 24.11.14 (Released to Gallary)
 - Updated the 24H2 Catalog file with the latest release to public available from MS on 24.10.04

### 24.10.1 (Released to Gallary)
 - Updates for Windows 11 24H2 x64 and ARM64
  - Updated Catalog JSON & XML files
  - Updated to OSD.json file to add options for 24H2
  - Still to do is create the index JSON file, this takes a long to to build, hopefully done by sometime tomorrow
    - This is to support Start-OSDCloudGUIDev (which is dynamic), which is also required for ARM64, I think?
  - Single test with Start-OSDCloudGUI with Win 11 24H2 was successful

### 24.7.8 (Released to Gallary)
 - Created Function: Add-7Zip2BootImage
   - Will be used in New-OSDCloudTemplate & Edit-OSDCloudWinPE to add 7zip into your boot images.

### 24.7.3 (Released to Gallary)
- Added several HP Functions into OSD Module that mirror HP CMSL but work in WinPE
 - Get-HPDriverPackLatest - Will find the latest driver pack for a platform, with options for download or just URL
 - Get-HPOSSUpport - Lists the supported Windows OS's supported by a platform
 - Get-HPSoftpaqListLatest - Finds latest supported OS for Platform and provides list of softpaqs
 - Get-HPSoftpaqItems - Provides list of Softpaqs for a Platform based on user input
- Adding ability for OSDCloud to reach directly to HP's catalog realtime, find latest driver pack, download.
 - New Variable: HPCMSLDriverPackLatest tell OSDCloud to use this new feature. (not available in GUI, maybe never will be?)
- Adding 7zip (7za.exe) features to extract HP Softpaqs while in WinPE to DISM in while offline
  - Requires you use the new -Add7Zip when using New-OSDCloudTemplate function
  - Will add functionality into Edit-OSDCloudWinPE eventually, for now, just download the extra.7z 7zip download, grab the 3 files in the x64 folder and add them to your system32 folder on the boot wim.
  - Issue open with 7zip GitHub to see if possible to add on the fly in WinPE: [Issue 24](https://github.com/ip7z/7zip/issues/24)
  
### Other
- Several small updates to resolve issues, sorry I forgot to add info here, feel free to look at commits if you're really interested

### 24.3.27 (implemented in OSD Module 24.3.27.1)
- Quick fix for [Issue 132](https://github.com/OSDeploy/OSD/issues/132)
- Minor updates to DEV for ARM64 testing

### 24.3.22 (implemented in OSD Module 24.3.27.1)
- Small change to Invoke-CatalogRequest [Issue 127](https://github.com/OSDeploy/OSD/issues/127)

### 24.3.20 (implemented in OSD Module 24.3.27.1)
- Added changes for easier debugging
 - Added checkbox in Start-OSDCloudGUIDev drop down menu to enable Debug Mode
  - when debugmode = $true (Via GUI or setting variable in script)
    - Creates addtional logs in c:\OSDCloud\Logs
      - DiskPart Logs (Before & After Format Step)
      - OSDCloudDebug
        - OSDCloud Variables
        - Windows 11 Readiness
        - TPM Information
        - MyComputerInfo
- If you open issues for OSDCloud, I'll be asking for those logs.


### 24.3.19 (implemented in OSD Module 24.3.20.1)
- Bug Fixes
  - [Issue 126](https://github.com/OSDeploy/OSD/issues/126) - Unable to add HP drivers into the WinPE
    - Updated URL in Function to address it not downloading WinPE driver pack
    - Added addtional Verbose Logging to help track the issue faster in the future if vendor modifies URL
  - [Issue 125](https://github.com/OSDeploy/OSD/issues/125) - HP BIOS failing to Update using CMSL
    - I've been unable to reproduce the issue, but I've modified the BIOS update to be a seperate JOB, so if the update fails, it shoudn't break OSDCloud's process.

### 24.3.12 (implemented in OSD Module 24.3.20.1)
- Start-OSDCloudGUIDev Updates
  - Dynamically pulling the OS Edition and Index Numbers based on the OS Name, Language and Activation chosen in the GUI.
    - This is to improve experience on other language esd files [Issue 117](https://github.com/OSDeploy/OSD/issues/117)
- Updated DISMFromOSDCloudUSB function to now search mapped network drives too
  - If you have a network drive that follows the OSDCloud USB Drive folder structure, it will use that as a cache similar to the flash drive
    - F:\OSDCloud\DriverPacks\DISM\HP\859C
    - F:\OSDCloud\OS\
    - etc
  
### 24.3.6 (implemented in OSD Module 24.3.10.1)
- Promoted code from Start-OSDCloudGUIDev to Start-OSDCloudGUI
  - This will add the HP enhancements as well as the SetupComplete enchancements into the Menus of the GUI
  - See updates from 24.1.22 for more details.
- Fix for downloading content from MS Update Catalog [Issue 122](https://github.com/OSDeploy/OSD/issues/122)

### 24.2.15 (implemented in OSD Module 24.2.20.1)
- Modifications to Function Set-TimeZoneFromIP - Due to prevous method using an API that is no longer free, had to completely change process.  Doing best to make it work for everyone when I can only test 1 timezone. 
  - Bug fix thanks to @JHBDO [Issue 110](https://github.com/OSDeploy/OSD/issues/110)
- Added Function: New-OSDCloudWorkSpaceSetupCompleteTemplate [Issue 107](https://github.com/OSDeploy/OSD/issues/107)
  - This creates the Setup Complete files for you on your WorkSpace drive (%WorkSpace%\Config\Scripts\SetupComplete)
  - You can then modify the SetupComplete.ps1 file to match your needs, or leave alone and look at the logs later to see how it worked.
  - These will get automatically copied to your OSDCloud USB when you update your OSDCLoud USB drive, and be automatically applied during Setup Complete during OSD.

### 24.2.7 (implemented in OSD Module 24.2.13.1)
- Fixes for when you call OSDCloudGUI via command line with preset variables.  This was not a use case I had tested for and had totally missed implementing all of the ground work for the recent functions added to OSDCloudGUIDev to work in this manner.
  - Thanks @PatrickThomasD2 for bringing this to my attention.
- Started basic code updates to support ARM64.  No plans to go "production" for a very long time.
  - Attempting to create the code requirements to have it create ARM64 WinPE with the OSDCloudTemplate functions

### 24.1.22 (implemented in OSD Module 24.2.4.1)
- Added Function: New-OSDCloudUSBSetupCompleteTemplate
  - This creates the Setup Complete files for you on your OSDCloudUSB drive (\OSDCloud\Config\Scripts\SetupComplete)
  - You can then modify the SetupComplete.ps1 file to match your needs, or leave alone and look at the logs later to see how it worked.
- Updated Start-OSDCloudGUIDev
  - Include the HP Tools
    - Using HPIA to Update Drivers, Firmware, Software, or All (During SetupComplete)
    - Update TPM (During Specialize)
    - Update BIOS (During WinPE)
  - Include SetupComplete commands
    - Windows Updates (No Drivers)
    - Windows Update (Drivers Only)
    - Windows Defender Updates
    - Apply Key from UEFI
      - This will attempt to lookup the Windows Code in UEFI and Apply to Windows
    - Setup Complete Shutdown
      - This will Shutdown the computer at the end of Setup Complete, leaving it at the OOBE the next time the device is turned on
  - Please Note, all of these are already available today via variables you can call before triggering OSDCloud.  This is just adding to the GUI Dev front end for testing, then eventually be promoted into the production front end (Start-OSDCloudGUI)

### 24.1.17 (implemented in OSD Module 24.2.4.1)
- Fixed issue in Save-FeatureUpdate function [Issue 106](https://github.com/OSDeploy/OSD/issues/106)
- Continue to deal with Intel's changing catalogs for WiFi drivers
  - Modifications to Get-IntelWirelessDriverPack to GUESS the correct URL
    - Thanks christiandekker for some ideas and code [Issue 101](https://github.com/OSDeploy/OSD/issues/101)
- Update to OSDCloudGUI (Start-OSDCLoudGUI)
  - Added support to show ESD files & SWM files in the drop down list to choose from [Issue 99](https://github.com/OSDeploy/OSD/issues/99) [Issue 85](https://github.com/OSDeploy/OSD/issues/85) 
  - promoted from DEV.  Was orginally in the 24.1.11.1 release (Start-OSDCLOUDGUIDev)

### 24.1.9 (implemented in OSD Module 24.1.11.1)
- Integrated Test-DISMFromOSDCloudUSB & Start-DISMFromOSDCloudUSB into the main OSDCloud Process
  - This will look at the OSDCloudUSB and if it detects the driverpack already expanded, proceeds to DISM the drivers into the Offline OS
    - OSDCloudUSB\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$PackageID
    - EX E:\OSDCloud\DriverPacks\DISM\HP\SP149133
    - OSDCloudUSB\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$ComputerProduct
    - EX E:\OSDCloud\DriverPacks\DISM\HP\8870
  - This allows you to pre-download driver packs and extract to those locations before running OSDCloud providing a few benifits
    - Saves time downloading driver pack over internet
    - Saves storage on device, as drivers are not copied over to C:\
    - Drivers are DISM in offline, so all drivers are present when the device reboots, reducing risk of missing storage / network
    - Allows you to choose specific drivers by placing in the "ComputerProduct" folder for specific models of PCs
- Dism log is copied from X:\Windows\Logs\DISM\dism.log to C:\OSDCloud\Logs\WinPE-DISM.log at the end of OSDCloud WinPE stage

### 24.1.3 (implemented in OSD Module 24.1.11.1)
- Added support for Split WIMS (.swm). [Issue 99](https://github.com/OSDeploy/OSD/issues/99)  
- Tested with MS Surface Book 2 MS Recovery Media
  - Download the Recovery Image, extract the swm files to OSDCloudUSB\OSDCloud\OS\%RecoveryImageName%
  - Example 
    - D:\OSDCloud\OS\SurfaceBook2_BMR_15_11.8.2\install.swm
    - D:\OSDCloud\OS\SurfaceBook2_BMR_15_11.8.2\install2.swm
    - D:\OSDCloud\OS\SurfaceBook2_BMR_15_11.8.2\install3.swm
  - use Start-OSDCloud -FindImageFile or Start-OSDCloudGUIDev

### 24.1.2 (implemented in OSD Module 24.1.3.1)
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
  - OSDCloud by default creates SetupComplete.cmd & SetupComplete.ps1 to run addtional tasks during SetupComplete in C:\Windows\Setup\scripts
  - OSDCloud will look for OSDCloudUSB\OSDCloud\Config\Scripts\SetupComplete\SetupComplete.cmd.  If found, the contents of that entire folder are copied to C:\OSDCloud\Scripts\SetupComplete and OSDCloud will trigger your custom SetupComplete.cmd file at the end of it's own SetupComplete processes
  - Ability to Shutdown Computer at the end of SetupComplete Phase by setting variable [Issue 96](https://github.com/OSDeploy/OSD/issues/96)
    - ShutdownSetupComplete = [bool]$true 
- #### HP Enterprise Class device specific updates
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

### 23.12.1
- Moved ESD file references in catalog form using WSUS data to using Microsoft Creation Tool catalogs
- Catalog File: https://github.com/OSDeploy/OSD/blob/master/Catalogs/CloudOperatingSystems.json
- Process to create Catalog File: https://github.com/OSDeploy/OSD/blob/master/build/Build-OSDCloudOperatingSystemsv3.ps1