#Requires -RunAsAdministrator
<#
.DESCRIPTION
The help command of the winget tool displays help for all the supported commands and sub commands
In addition, you can pass the --help argument to any other command to get details about all additional command options.

.LINK
https://learn.microsoft.com/en-us/windows/package-manager/winget/help

.NOTES
Usage
Display help for all commands: winget --help or winget -?
View options for a command: winget <command> --help or winget <command> -?
#>
[CmdletBinding()]
param()

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    winget --help
}