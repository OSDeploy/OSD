#Requires -RunAsAdministrator
<#
.DESCRIPTION
The features command of the winget tool displays a list of the experimental features available with your version of the Windows Package Manager.
Experimental features are only available in preview builds.
Instructions for obtaining a preview build can be found in the GitHub repository.

Each feature can be turned on individually by enabling the features through settings.

.LINK
https://learn.microsoft.com/en-us/windows/package-manager/winget/features

.NOTES
Usage
winget features
#>
[CmdletBinding()]
param()

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    winget features
}