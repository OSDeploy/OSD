Clear-Host
#Install-Module -Name platyPS -Scope CurrentUser
#Import-Module platyPS
Import-Module OSD -Force
New-MarkdownHelp -Module OSD -OutputFolder $(Join-Path (Get-Module OSD).ModuleBase 'Docs') -Force
New-ExternalHelp $(Join-Path (Get-Module OSD).ModuleBase 'Docs') -OutputPath $(Join-Path (Get-Module OSD).ModuleBase 'en-US') -Force