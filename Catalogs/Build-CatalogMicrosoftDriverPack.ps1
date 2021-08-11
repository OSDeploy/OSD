Import-Module -Name OSD -Force
Get-CatalogMicrosoftDriverPack | ConvertTo-Json | Out-File $PSScriptRoot\CatalogMicrosoftDriverPack.json -Encoding ascii -Width 2000 -Force