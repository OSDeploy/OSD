#Requires -RunAsAdministrator

$UpdateWindows = $true
if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
    try {
        Install-Module PSWindowsUpdate -Force
    }
    catch {
        Write-Warning 'Unable to install PSWindowsUpdate PowerShell Module'
        $UpdateWindows = $false
    }
}

if ($UpdateWindows) {
    Write-Host -ForegroundColor DarkCyan 'Add-WUServiceManager -MicrosoftUpdate -Confirm:$false'
    Add-WUServiceManager -MicrosoftUpdate -Confirm:$false

    Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot'
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle 'Malicious','Preview'
}