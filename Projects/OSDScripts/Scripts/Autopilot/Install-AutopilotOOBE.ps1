#Requires -RunAsAdministrator

$InstalledModule = Import-Module AutopilotOOBE -PassThru -ErrorAction Ignore
if (-not $InstalledModule) {
    Install-Module AutopilotOOBE -Force -Scope CurrentUser -SkipPublisherCheck
}