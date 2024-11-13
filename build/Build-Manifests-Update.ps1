#Requires -RunAsAdministrator

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

# OSD Module Path
$OSDModulePath = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase

# Get WSUSXML Updates
$Manifests = Get-WindowsUpdateManifests

$Manifests = $Manifests | `
Select-Object -Property * | `
Sort-Object -Property Title -Unique | `
Sort-Object LastModified -Descending #| Out-GridView -PassThru -Title "All OSDUpdates"

$Manifests | Select-Object -Property LastModified, Id, Title | `
    Sort-Object @{Expression = { $_.LastModified }; Ascending = $false }, Id, Title | `
Out-File $OSDModulePath\UPDATES.md