#Requires -RunAsAdministrator
<#
.DESCRIPTION
The info command of the winget tool displays metadata about the system, including version numbers, system architecture, log location, links to legal agreements, and Group Policy state.

When submitting an issue to the winget repository on GitHub, this information is helpful for troubleshooting.
It may also explain why the winget client behaves differently than expected in the case of Group Policy configuration.

.LINK
https://learn.microsoft.com/en-us/windows/package-manager/winget/info

.NOTES
Usage
winget --info
#>
[CmdletBinding()]
param()

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    winget --info
}