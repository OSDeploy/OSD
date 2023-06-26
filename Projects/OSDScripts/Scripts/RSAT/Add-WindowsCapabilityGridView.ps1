#Requires -Modules @{ ModuleName="OSD"; ModuleVersion="23.5.26.1" }
#Requires -PSEdition Desktop
#Requires -RunAsAdministrator

$Result = Get-MyWindowsCapability -Category Rsat -State NotPresent -Detail
$Result | `
Out-GridView -PassThru -Title 'Select one or more Windows RSAT Capabilities to install' | `
Add-WindowsCapability -Online -ErrorAction Ignore