#Requires -RunAsAdministrator
<#
.DESCRIPTION
The hash command of the winget tool generates the SHA256 hash for an installer.
This command is used if you need to create a manifest file for submitting software to the Microsoft Community Package Manifest Repository on GitHub.
In addition, the hash command also supports generating a SHA256 certificate hash for MSIX files.

.LINK
https://learn.microsoft.com/en-us/windows/package-manager/winget/hash

.NOTES
Usage
winget hash [--file] \<file> [\<options>]

Arguments
-f,--file       The path to the file to be hashed.
-m,--msix       Specifies that the hash command will also create the SHA-256 SignatureSha256 for use with MSIX installers.
--verbose-logs  Used to override the logging setting and create a verbose log.
-?, --help      Gets additional help on this command.
#>
[CmdletBinding()]
param()

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    winget hash $env:windir\notepad.exe
}