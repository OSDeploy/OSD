cls
#Install-Module -Name platyPS -Scope CurrentUser
#Import-Module platyPS
Import-Module OSD -Force
New-MarkdownHelp -Module OSD -OutputFolder $(Join-Path (Get-Module OSD).ModuleBase 'docs')
New-ExternalHelp $(Join-Path (Get-Module OSD).ModuleBase 'docs') -OutputPath $(Join-Path (Get-Module OSD).ModuleBase 'en-US') -Force