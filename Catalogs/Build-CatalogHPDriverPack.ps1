Import-Module -Name OSD -Force
Get-CatalogHPDriverPack | Export-Clixml -Path $PSScriptRoot\CatalogHPDriverPack.xml