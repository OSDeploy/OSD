Clear-Host
Import-Module platyPS
Import-Module OSD -Force
New-MarkdownHelp -Module OSD -OutputFolder $(Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase 'Docs') -Force

$OSDDocsPath = $(Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase 'Docs')
$OSDDocsOutoutPath = $(Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase 'en-US')
New-ExternalHelp -Path $OSDDocsPath -OutputPath $OSDDocsOutoutPath -Force -Verbose