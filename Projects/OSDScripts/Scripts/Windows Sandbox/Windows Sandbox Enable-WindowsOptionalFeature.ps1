#https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview

#Windows 10
#dism /online /Enable-Feature /FeatureName:"Containers-DisposableClientVM" -All

#Windows 11
$FeatureName = 'Containers-DisposableClientVM'
$WindowsOptionalFeature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName -ErrorAction SilentlyContinue
if ($WindowsOptionalFeature.State -eq 'Enabled') {
    Write-Host -ForegroundColor Green "[+] Windows Optional Feature $FeatureName is installed"
}
elseif ($WindowsOptionalFeature.State -eq 'Disabled') {
    Write-Host -ForegroundColor Yellow "[-] Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All -NoRestart"
    Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All -NoRestart
}
else {
    Write-Host -ForegroundColor Red "[!] $FeatureName is not compatible with this version of Windows"
}

#If you're using a virtual machine, run the following PowerShell command to enable nested virtualization:
#Set-VMProcessor -VMName <VMName> -ExposeVirtualizationExtensions $true