#Requires -RunAsAdministrator

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

# OSD Module Path
$OSDModulePath = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase

# Get WSUSXML Updates
$WSUSXMLUpdates = @()
$AllUpdateCatalogs = Get-ChildItem -Path "$OSDModulePath\Catalogs\WSUSXML\*" -Include '*.json' -Recurse

foreach ($UpdateCatalog in $AllUpdateCatalogs) {
    $WSUSXMLUpdates += Get-Content $UpdateCatalog.FullName | ConvertFrom-Json
}

$WSUSXMLUpdates = $WSUSXMLUpdates | `
Select-Object -Property * | `
Sort-Object -Property Title -Unique | `
Sort-Object CreationDate -Descending #| Out-GridView -PassThru -Title "All OSDUpdates"

$WSUSXMLUpdates | Select-Object -Property CreationDate, KBNumber, Title | `
Sort-Object @{Expression = {$_.CreationDate}; Ascending = $false}, KBNumber, Title | `
Out-File $OSDModulePath\UPDATES.md