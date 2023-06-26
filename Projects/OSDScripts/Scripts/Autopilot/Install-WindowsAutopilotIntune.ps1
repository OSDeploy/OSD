#Requires -RunAsAdministrator

$InstalledModule = Import-Module WindowsAutopilotIntune -PassThru -ErrorAction Ignore
if (-not $InstalledModule) {
    Install-Module WindowsAutopilotIntune -Force -Scope CurrentUser -SkipPublisherCheck
}