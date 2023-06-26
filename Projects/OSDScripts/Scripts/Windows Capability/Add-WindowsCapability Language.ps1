#Requires -Modules @{ ModuleName="OSD"; ModuleVersion="23.5.26.1" }
#Requires -PSEdition Desktop
#Requires -RunAsAdministrator

Get-MyWindowsCapability -Category Language -State NotPresent -Detail | `
Out-GridView -PassThru -Title 'Select one or more Windows Language Capabilities to install' | `
Add-WindowsCapability -Online -Verbose