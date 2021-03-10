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
    $GetMyDellBios = Get-MyDellBios | Sort-Object ReleaseDate -Descending | Select-Object -First 1

    $SourceUrl = $GetMyDellBios.Url
    $DestinationFile = $GetMyDellBios.FileName
    $OutFile = Join-Path $env:TEMP $DestinationFile

    if (-NOT (Test-Path $OutFile)) {
        Write-Verbose "Downloading using BITS $SourceUrl" -Verbose
        Save-OSDDownload -BitsTransfer -SourceUrl $SourceUrl -DownloadFolder $env:TEMP -ErrorAction SilentlyContinue | Out-Null
    }
    if (-NOT (Test-Path $OutFile)) {
        Write-Verbose "BITS didn't work ..."
        Write-Verbose "Downloading using WebClient $SourceUrl" -Verbose
        Save-OSDDownload -SourceUrl $SourceUrl -DownloadFolder $env:TEMP -ErrorAction SilentlyContinue | Out-Null
    }

    if (-NOT (Test-Path $OutFile)) {Write-Warning "Unable to download $SourceUrl"; Break}

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
                Break
            }
        } else {
            Write-Verbose "BitLocker was not enabled" -Verbose
        }
    } else {
        Write-Verbose "Downloading Flash64W using WebClient https://downloads.dell.com/FOLDER04165397M/1/Flash64W.zip" -Verbose
        Save-OSDDownload -SourceUrl 'https://downloads.dell.com/FOLDER04165397M/1/Flash64W.zip' -DownloadFolder $env:TEMP -ErrorAction SilentlyContinue | Out-Null
        if (Test-Path "$env:TEMP\Flash64W.zip") {
            Expand-Archive -Path "$env:TEMP\Flash64W.zip" -DestinationPath $env:TEMP -Force
        }
    }

    $BiosLog = Join-Path $env:TEMP 'Update-MyDellBios.log'
    
    $Arguments = "/l=`"$BiosLog`""
    if ($Reboot) {
        $Arguments = $Arguments + " /r /s"
    } elseif ($Silent) {
        $Arguments = $Arguments + " /s"
    }

    Write-Verbose "Starting BIOS Update" -Verbose 
    if (($env:SystemDrive -eq 'X:') -and ($env:PROCESSOR_ARCHITECTURE -match '64')) {
        if (-NOT (Test-Path "$env:TEMP\Flash64W.EXE")) {
            Write-Warning "Unable to locate $env:TEMP\Flash64W.exe"
            Break
        } else {
            Start-Process -FilePath "$env:TEMP\Flash64W.exe" -ArgumentList "/b=$DestinationFile $Arguments" -Wait
        }
    } else {

        Write-Verbose "$OutFile $Arguments" -Verbose
        Start-Process -FilePath $OutFile -ArgumentList $Arguments -Wait
    }
}