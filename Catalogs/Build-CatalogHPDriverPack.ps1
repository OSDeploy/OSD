Import-Module -Name OSD -Force
Get-HPDriverPackCatalog | Export-Clixml -Path $PSScriptRoot\HPDriverPackCatalog.xml