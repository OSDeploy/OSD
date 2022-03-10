<#
.SYNOPSIS
This will return the latest compatible BIOS Update for your system as a PowerShell Object

.DESCRIPTION
This will return the latest compatible BIOS Update for your system as a PowerShell Object
Shortcut for Get-OSDCatalogDellSystem -Component BIOS -Compatible

.LINK
https://osd.osdeploy.com/module/functions/dell/get-mydellbios

.NOTES
21.3.11 Pulling data from Local due to issues with the Dell site being down
21.3.5  Resolved issue with multiple objects
21.3.4  Initial Release
#>
function Get-MyDellBios {
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = 'SilentlyContinue'
    #=================================================
    #   Require Dell Computer
    #=================================================
    if ((Get-MyComputerManufacturer -Brief) -ne 'Dell') {
        Write-Warning "Dell computer is required for this function"
        Return $null
    }
    #=================================================
    #   Current System Information
    #=================================================
    $SystemSKU = $((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()
    #=================================================
    #   Get-OSDCatalogDellSystem
    #=================================================
    #$GetMyDellBios = Get-OSDCatalogDellSystem -Component BIOS -Compatible | Sort-Object ReleaseDate -Descending | Select-Object -First 1
    $GetMyDellBIOS = Get-CatalogDellBios | Sort-Object ReleaseDate -Descending
    $GetMyDellBIOS | Add-Member -MemberType NoteProperty -Name 'Flash64W' -Value 'https://github.com/OSDeploy/OSDCloud/raw/main/BIOS/Flash64W_Ver3.3.8.cab'
    #=================================================
    #   Filter Compatible
    #=================================================
    Write-Verbose "Filtering XML for items compatible with SystemSKU $SystemSKU"
    $GetMyDellBIOS = $GetMyDellBIOS | `
        Where-Object {$_.SupportedSystemID -contains $SystemSKU}
    #=================================================
    #   Pick and Sort
    #=================================================
    $GetMyDellBios = $GetMyDellBios | Sort-Object ReleaseDate -Descending | Select-Object -First 1
    #Write-Verbose "You are currently running Dell Bios version $BIOSVersion" -Verbose
    #=================================================
    #   Return
    #=================================================
    Return $GetMyDellBios
}
function Save-MyDellBios {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Alias ('DownloadFolder','Path')]
        [string]$DownloadPath = $env:TEMP
    )
    #Make sure Computer is a Dell
    if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
        
        #See if we can get the Dell BIOS
        $GetMyDellBios = Get-MyDellBios

        if ($GetMyDellBios) {

            #See if the BIOS has already been downloaded
            if (Test-Path "$DownloadPath\$($GetMyDellBios.FileName)") {
                Write-Verbose -Verbose "Bios Update File: $DownloadPath\$($GetMyDellBios.FileName)"
                Get-Item "$DownloadPath\$($GetMyDellBios.FileName)"
            }
            elseif (Test-MyDellBiosWebConnection) {
                #Download the BIOS Update
                #$SaveMyDellBios = Save-OSDDownload -SourceUrl $GetMyDellBios.Url -DownloadFolder "$DownloadPath"
                $SaveMyDellBios = Save-WebFile -SourceUrl $GetMyDellBios.Url -DestinationDirectory "$DownloadPath"
                Start-Sleep -Seconds 1

                #Make sure the BIOS Downloaded
                if (Test-Path "$($SaveMyDellBios.FullName)") {
                    Write-Verbose -Verbose "Bios Update Download: $($SaveMyDellBios.FullName)"
                    Get-Item "$($SaveMyDellBios.FullName)"
                }
                else {
                    Write-Warning "Could not download the Dell BIOS Update"
                }
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Bios"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable Bios update for this Computer Model"
        }
    }
}
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
        [System.Management.Automation.SwitchParameter]$Force,
        [System.Management.Automation.SwitchParameter]$Reboot,
        [System.Management.Automation.SwitchParameter]$Silent
    )
    #=================================================
    #   Block
    #=================================================
    Block-StandardUser
    #=================================================
    #   Require Dell Computer
    #=================================================
    if ((Get-MyComputerManufacturer -Brief) -ne 'Dell') {
        Write-Warning "Dell computer is required for this function"
        Return $null
    }
    #=================================================
    #   Current System Information
    #=================================================
    $SystemSKU = $((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()
    #=================================================
    #   Compare
    #=================================================
    $GetMyDellBios = Get-MyDellBios | Sort-Object ReleaseDate -Descending | Select-Object -First 1

    if ($GetMyDellBios.DellVersion -eq (Get-MyBiosVersion)) {
        Write-Warning "Update-MyDellBios: Current BIOS version $(Get-MyBiosVersion) is already the latest version"
        Start-Sleep -Seconds 5
    }
    if (($GetMyDellBios.DellVersion -lt (Get-MyBiosVersion)) -or ($Force.IsPresent) ) {
        #=================================================
        #   Download
        #=================================================
        $SaveMyDellBios = Save-MyDellBios -DownloadPath $DownloadPath
        if (-NOT ($SaveMyDellBios)) {Return $null}
        if (-NOT (Test-Path $SaveMyDellBios.FullName)) {Return $null}
    
        if (($env:SystemDrive -eq 'X:') -and ($env:PROCESSOR_ARCHITECTURE -match '64')) {
            $SaveMyDellBiosFlash64W = Save-MyDellBiosFlash64W -DownloadPath $DownloadPath
            if (-NOT ($SaveMyDellBiosFlash64W)) {Return $null}
            if (-NOT (Test-Path $SaveMyDellBiosFlash64W.FullName)) {Return $null}
        }
        $SaveMyDellBiosFlash64W = Save-MyDellBiosFlash64W -DownloadPath $DownloadPath
        #=================================================
        #   BitLocker
        #=================================================
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
        #=================================================
        #   Arguments
        #=================================================
        $BiosLog = Join-Path $env:TEMP 'Update-MyDellBios.log'
    
        $Arguments = "/l=`"$BiosLog`""
        if ($Reboot) {
            $Arguments = $Arguments + " /r /s"
        } elseif ($Silent) {
            $Arguments = $Arguments + " /s"
        }
        #=================================================
        #   Execution
        #=================================================
        if (($env:SystemDrive -eq 'X:') -and ($env:PROCESSOR_ARCHITECTURE -match '64')) {
            $Arguments = "/b=`"$($SaveMyDellBios.FullName)`" " + $Arguments
            Write-Verbose "Start-Process -WorkingDirectory `"$($SaveMyDellBios.Directory)`" -FilePath `"$($SaveMyDellBiosFlash64W.FullName)`" -ArgumentList $Arguments -Wait" -Verbose
            Start-Process -WorkingDirectory "$($SaveMyDellBios.Directory)" -FilePath "$($SaveMyDellBiosFlash64W.FullName)" -ArgumentList $Arguments -Wait -ErrorAction Inquire
        }
        else {
            Write-Verbose "Start-Process -FilePath `"$($SaveMyDellBios.FullName)`" -ArgumentList $Arguments -Wait" -Verbose
            Start-Process -FilePath "$($SaveMyDellBios.FullName)" -ArgumentList $Arguments -Wait -ErrorAction Inquire
        }
        #=================================================
    }
}
function Save-MyDellBiosFlash64W {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Alias ('DownloadFolder','Path')]
        [string]$DownloadPath = $env:TEMP
    )

    if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
        $GetMyDellBios = Get-MyDellBios
        if ($GetMyDellBios) {
            if (Test-WebConnection -Uri $GetMyDellBios.Flash64W) {
                #$SaveMyDellBiosFlash64W = Save-OSDDownload -SourceUrl $GetMyDellBios.Flash64W -DownloadFolder "$DownloadPath"
                $SaveMyDellBiosFlash64W = Save-WebFile -SourceUrl $GetMyDellBios.Flash64W -DestinationDirectory "$DownloadPath"
                Expand -R "$($SaveMyDellBiosFlash64W.FullName)" -F:* "$DownloadPath" | Out-Null
                if (Test-Path (Join-Path $DownloadPath 'Flash64W.exe')) {
                    Get-Item (Join-Path $DownloadPath 'Flash64W.exe')
                }
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Bios"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable Bios update for this Computer Model"
        }
    }
}
function Test-MyDellBiosWebConnection {
    [CmdletBinding()]
    param ()
    
    $GetMyDellBios = Get-MyDellBios
    if ($GetMyDellBios) {
        Test-WebConnection -Uri $GetMyDellBios.Url
    } else {
        Return $false
    }
}