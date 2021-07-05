Import-Module -Name OSD -Force
Get-CatalogLenovoDriverPack -Verbose | Export-Clixml -Path $PSScriptRoot\CatalogLenovoDriverPack.xml