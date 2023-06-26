#Requires -RunAsAdministrator
<#
.DESCRIPTION
The import command of the winget tool imports a JSON file of apps to install.
The import command combined with the export command allows you to batch install applications on your PC.
The import command is often used to share your developer environment or build up your PC image with your favorite apps.

.LINK
https://learn.microsoft.com/en-us/windows/package-manager/winget/import

.NOTES
Usage
winget import [-i] <import-file> [<options>]

Arguments
-i,--import-file            JSON file describing the packages to install.

Options
--ignore-unavailable        Suppresses errors if the app requested is unavailable.
--ignore-versions           Ignores versions specified in the JSON file and installs the latest available version.
--accept-package-agreements Used to accept the license agreement, and avoid the prompt.
--accept-source-agreements  Used to accept the source license agreement, and avoid the prompt.
--verbose-logs	            Used to override the logging setting and create a verbose log.
#>
[CmdletBinding()]
param()

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    winget import --import-file $env:TEMP\wingetimport.json
}