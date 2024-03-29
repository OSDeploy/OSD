# OSDCloud FAQ

I'm just starting this page, expect more in the future.  I've just started to write an outline, and haven't filled in much of the content yet.  If you have other Questions you would like anwsers to, let me know and I'll see if I can add things here.

## Troubleshooting

### Common things to try when troubleshooting
- Confirm you're on the latest ADK
  - https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install
- Confirm you're on the latest OSD Module
- Create New Clean OSDCloud Process

```PowerShell
#Setup WorkSpace Location
Import-Module -name OSD -force
$OSDCloudWorkspace = "C:\OSDCloudWinPE"
[void][System.IO.Directory]::CreateDirectory($OSDCloudWorkspace)

#New Template (After you've updated ADK to lastest Version)
New-OSDCloudTemplate -Name "OSDCloudWinPE"

#New WorkSpace
New-OSDCloudWorkspace -WorkspacePath $OSDCloudWorkspace
New-OSDCloudWorkSpaceSetupCompleteTemplate #Creates Sample SetupComplete templates in Workspace

#Added HPCMSL into WinPE
Edit-OSDCloudWinPE -PSModuleInstall HPCMSL

#Create Cloud USB
New-OSDCloudUSB
```


### Creating a Issue after you've done troubleshooting
- Please provide:
  - All Logs in C:\OSDCloud\Logs (Which will provide us with:)
    - Machine Make / Model / Product
    - OSD Module Version
    - WinPE Version
    - 
  - How you're running OSDCloud (Start-OSDCloud / Start-OSDCloudGUI /etc)
    - Provide full command line argument, or script if using script to trigger OSDCloud
  - What steps you've taken in troubleshooting

## Customizations
### How do I use a custom Setup Complete script?

### How do I have OSDCloud inject extracted driver packs from OSDCloudUSB?

### How do I run OSDCloud via command line automated?
 - Wrapper Script
 - Command Line

