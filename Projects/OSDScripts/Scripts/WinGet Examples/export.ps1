#Requires -RunAsAdministrator
<#
.DESCRIPTION
The export command of the winget tool exports a JSON file of apps to a specified file.
The export command uses JSON as the format. You can find the schema for the JSON file used by winget in the Windows Package Manager Client repo on GitHub.
The export combined with the import command allows you to batch install applications on your PC.
The export command is often used to create a file that you can share with other developers, or for use when restoring your build environment.

.LINK
https://learn.microsoft.com/en-us/windows/package-manager/winget/export

.NOTES
Usage
winget export [-o] <output> [<options>]

Arguments
-o,--output	Path to the JSON file to be created

Options
-s, --source                Specifies a source to export files from. Use this option when you only want files from a specific source.
--include-versions          Includes the version of the app currently installed. Use this option if you want a specific version. By default, unless specified, import will use latest.
--accept-source-agreements  Used to accept the source license agreement, and avoid the prompt.
--verbose-logs              Used to override the logging setting and create a verbose log.
#>
[CmdletBinding()]
param()

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    # Export the list of installed apps to a JSON file
    winget export --output $env:TEMP\wingetexport.json

    if (Test-Path "$env:TEMP\wingetexport.json") {
        notepad.exe "$env:TEMP\wingetexport.json"
    }

    # Export the list of installed apps to a JSON file and include the version of the app currently installed
    winget export --output $env:TEMP\wingetexportver.json --include-versions
    
    if (Test-Path "$env:TEMP\wingetexportver.json") {
        notepad.exe "$env:TEMP\wingetexportver.json"
    }

    # Export the list of installed apps to a JSON file and include the version of the app currently installed and accept the source license agreement
    winget export --output $env:TEMP\wingetexportveragree.json --include-versions --accept-source-agreements --verbose-logs
    
    if (Test-Path "$env:TEMP\wingetexportveragree.json") {
        notepad.exe "$env:TEMP\wingetexportveragree.json"
    }
}