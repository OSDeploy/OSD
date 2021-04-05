Import-Module -Name OSD -Force
Get-CatalogDellDriverPack | Export-Clixml -Path $PSScriptRoot\CatalogDellDriverPack.xml