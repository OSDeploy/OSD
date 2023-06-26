#=============================================================
# Dell Management Agent Service (300)
# If the Service is running, it will need to be stopped
#=============================================================
$serviceName = 'DellMgmtAgent'
$getService = Get-Service $serviceName -ErrorAction Ignore

if ($getService) {
    Write-Log "$serviceName service is present"
    Write-Host "$serviceName service is present"

    if ($getService.Status -eq 'Running') {
        Write-Log "$serviceName service is running and will be stopped"
        Write-Host "$serviceName service is running and will be stopped"
        $DellService | Stop-Service -Force -ErrorAction Ignore
    }
}
else {
    Write-Log "$serviceName service is not present"
    Write-Host "$serviceName service is not present"
}
#=============================================================
# BitLocker (300)
# If BitLocker is protecting C: it will need to be suspended
#=============================================================
$BitLockerVolume = Get-BitLockerVolume -MountPoint 'C:' -ErrorAction SilentlyContinue

if ($BitLockerVolume.ProtectionStatus -eq 'On') {
    Write-Log "BitLocker encryption is enabled, suspending BitLocker"
    Write-Host "BitLocker encryption is enabled, suspending BitLocker"
    try {
        Suspend-BitLocker -MountPoint "C:" -RebootCount 3 -ErrorAction Stop
    }
    catch {
        Write-Log $_.Exception.Message
        Write-Host $_.Exception.Message
        $ErrorMessage = $_.Exception.Message
        $ExitCode = 3431
        Add-RegistryCode -ExitCode $ExitCode -ErrorMessage $ErrorMessage
        Add-RegistryHistory
    }
}
else {
    Write-Log "Bitlocker encryption is not enabled."
    Write-Host "Bitlocker encryption is not enabled."
}
#=============================================================