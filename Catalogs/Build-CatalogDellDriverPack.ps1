Import-Module -Name OSD -Force
Get-DellDriverPackCatalog | Export-Clixml -Path $PSScriptRoot\DellDriverPackCatalog.xml