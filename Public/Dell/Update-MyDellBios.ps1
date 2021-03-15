<#
.SYNOPSIS
Downloads and installed a compatible BIOS Update for your Dell system

.DESCRIPTION
Downloads and installed a compatible BIOS Update for your Dell system
BitLocker friendly, but you need Admin Rights
Logs to $env:TEMP\Update-MyDellBios.log

.EXAMPLE
Update-MyDellBios
Downloads and launches the Dell BIOS Update.  Does not automatically install the BIOS Update

.EXAMPLE
Update-MyDellBios -Silent
Yes, this will update your BIOS silently, and NOT reboot when its done

.EXAMPLE
Update-MyDellBios -Silent -Reboot
Yes, this will update your BIOS silently, AND reboot when its done

.LINK
https://osd.osdeploy.com/module/functions/dell/update-mydellbios

.NOTES
21.3.9  Started adding logic for WinPE
21.3.5  Resolved issue with multiple objects
21.3.4  Initial Release
#>
function Update-MyDellBios {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Alias ('DownloadFolder','Path')]
        [string]$DownloadPath = $env:TEMP,

        [switch]$Silent,
        [switch]$Reboot
    )
    #===================================================================================================
    #   Require Admin Rights
    #===================================================================================================
    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
        Break
    }
    #===================================================================================================
    #   Require Dell Computer
    #===================================================================================================
    if ((Get-MyComputerManufacturer -Brief) -ne 'Dell') {
        Write-Warning "Dell computer is required for this function"
        Return $null
    }
    #===================================================================================================
    #   Current System Information
    #===================================================================================================
    $SystemSKU = $((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()
    #===================================================================================================
    #   Compare
    #===================================================================================================
    $GetMyDellBios = Get-MyDellBios | Sort-Object ReleaseDate -Descending | Select-Object -First 1

    if ($GetMyDellBios.DellVersion -eq $BIOSVersion) {
        Write-Warning "BIOS version is already at latest"
        #Continue
    }
    #===================================================================================================
    #   Download
    #===================================================================================================
    $SaveMyDellBios = Save-MyDellBios -DownloadPath $DownloadPath
    if (-NOT ($SaveMyDellBios)) {Return $null}
    if (-NOT (Test-Path $SaveMyDellBios.FullName)) {Return $null}

    if (($env:SystemDrive -eq 'X:') -and ($env:PROCESSOR_ARCHITECTURE -match '64')) {
        $SaveMyDellBiosFlash64W = Save-MyDellBiosFlash64W -DownloadPath $DownloadPath
        if (-NOT ($SaveMyDellBiosFlash64W)) {Return $null}
        if (-NOT (Test-Path $SaveMyDellBiosFlash64W.FullName)) {Return $null}
    }
    $SaveMyDellBiosFlash64W = Save-MyDellBiosFlash64W -DownloadPath $DownloadPath
    #===================================================================================================
    #   BitLocker
    #===================================================================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Verbose "Checking for BitLocker" -Verbose
        #http://www.dptechjournal.net/2017/01/powershell-script-to-deploy-dell.html
        #https://github.com/dptechjournal/Dell-Firmware-Updates/blob/master/Install_Dell_Bios_upgrade.ps1
        $GetBitLockerVolume = Get-BitLockerVolume | Where-Object { $_.ProtectionStatus -eq "On" -and $_.VolumeType -eq "OperatingSystem" }
        if ($GetBitLockerVolume) {
            Write-Verbose "Suspending BitLocker for 1 Reboot"
            Suspend-BitLocker -Mountpoint $GetBitLockerVolume -RebootCount 1
            if (Get-BitLockerVolume -MountPoint $GetBitLockerVolume | Where-Object ProtectionStatus -eq "On") {
                Write-Warning "Couldn't suspend Bitlocker"
                Return $null
            }
        } else {
            Write-Verbose "BitLocker was not enabled" -Verbose
        }
    }
    #===================================================================================================
    #   Arguments
    #===================================================================================================
    $BiosLog = Join-Path $env:TEMP 'Update-MyDellBios.log'

    $Arguments = "/l=`"$BiosLog`""
    if ($Reboot) {
        $Arguments = $Arguments + " /r /s"
    } elseif ($Silent) {
        $Arguments = $Arguments + " /s"
    }
    #===================================================================================================
    #   Execution
    #===================================================================================================
    if (($env:SystemDrive -eq 'X:') -and ($env:PROCESSOR_ARCHITECTURE -match '64')) {
        $Arguments = "/b=`"$($SaveMyDellBios.FullName)`" " + $Arguments
        Write-Verbose "Start-Process -WorkingDirectory `"$($SaveMyDellBios.Directory)`" -FilePath `"$($SaveMyDellBiosFlash64W.FullName)`" -ArgumentList $Arguments -Wait" -Verbose
        Start-Process -WorkingDirectory "$($SaveMyDellBios.Directory)" -FilePath "$($SaveMyDellBiosFlash64W.FullName)" -ArgumentList $Arguments -Wait -ErrorAction Inquire
    }
    else {
        Write-Verbose "Start-Process -FilePath `"$($SaveMyDellBios.FullName)`" -ArgumentList $Arguments -Wait" -Verbose
        Start-Process -FilePath "$($SaveMyDellBios.FullName)" -ArgumentList $Arguments -Wait -ErrorAction Inquire
    }
}