$WindowsCapability = Get-WindowsCapability -Online -Name "*NetFX*" -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
if ($WindowsCapability) {
    Write-Host -ForegroundColor Cyan "Add-WindowsCapability NetFX"
    foreach ($Capability in $WindowsCapability) {
        Write-Host -ForegroundColor DarkGray $Capability.DisplayName
        $Capability | Add-WindowsCapability -Online | Out-Null
    }
}