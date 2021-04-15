Import-Module -Name OSD -Force
Get-CatalogLenovoDriverPack | Export-Clixml -Path $PSScriptRoot\CatalogLenovoDriverPack.xml