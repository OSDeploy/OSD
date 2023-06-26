https://learn.microsoft.com/en-us/windows/package-manager/configuration/
Using a WinGet Configuration file, you can consolidate manual machine setup and project onboarding to a single command that is reliable and repeatable.
To achieve this, WinGet utilizes:
    A YAML-formatted WinGet Configuration file that lists all of the software versions, packages, tools, dependencies, and settings required to set up the desired state of the development environment on your Windows machine.
    PowerShell Desired State Configuration (DSC) to automate the configuration of your Windows operating system.
    The Windows Package Manager winget configure command to initiate the configuration process.

https://learn.microsoft.com/en-us/windows/package-manager/winget/configure
The configure command of the winget tool uses a WinGet Configuration file to begin setting up your Windows machine to a desired development environment state.
WinGet Configuration is currently in preview.
To use a WinGet Configuration file with the winget configure command, you must first enable the experimental configuration feature.

https://learn.microsoft.com/en-us/windows/package-manager/configuration/#enable-the-winget-configuration-experimental-configuration-preview-feature
Enable the WinGet Configuration experimental configuration preview feature
In order to use a WinGet Configuration file with the winget configure command:
    Confirm you're running the Preview version of WinGet.
    Enter the command: winget features to display a list of available experimental features.
    Enter the command: winget settings to open the WinGet Settings file in your default text editor. The WinGet Settings file uses a JSON format.

In your WinGet Settings JSON file, enter:

"experimentalFeatures": {
       "configuration": true
   }

Features may be managed by your workplace group policy, potentially blocking your ability to use experimental features.
You can use the winget --info command to view any policies in effect on your system.

https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget-preview-version-developers-only
WinGet is included in the Windows App Installer. To try the latest Windows Package Manager features, you can install a preview build one of the following ways:

Download the latest winget preview version.
Read the Release notes for winget preview to learn about any new features.
Installing this package will give you the preview version of the WinGet client, but it will not enable automatic updates of new preview versions from the Microsoft Store.
https://aka.ms/getwingetpreview