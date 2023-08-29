#Requires -RunAsAdministrator

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

# PlatyPS Module
$modules = Get-Module -Name platyPS -ListAvailable
if ($modules.Count -eq 0) {
    Install-Module -Name PlatyPS -Force -ErrorAction Stop
}
else {
    Import-Module platyPS -Force -ErrorAction Stop
}

# OSD Module Path
$OSDModulePath = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase

# Markdown Help
$OSDDocsPath = $(Join-Path $OSDModulePath 'Docs')
New-MarkdownHelp -Module OSD -OutputFolder $OSDDocsPath -Force

# External Help
$OSDDocsOutoutPath = $(Join-Path $OSDModulePath 'en-US')
New-ExternalHelp -Path $OSDDocsPath -OutputPath $OSDDocsOutoutPath -Force