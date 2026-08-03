function Get-MyDellBios {
    <#
    .SYNOPSIS
    Returns the latest compatible Dell BIOS update for the current system.

    .DESCRIPTION
    Detects the current Dell system SKU, filters the cached Dell BIOS catalog for
    compatible entries, and returns the newest matching BIOS update object. This
    function only returns data when it is run on Dell hardware.

    .EXAMPLE
    Get-MyDellBios
    Returns the newest compatible Dell BIOS update object for the current Dell device.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2021-03-04 - Initial release
    2021-03-05 - Resolved issue with multiple objects
    2021-03-11 - Pulled data from local catalog due to Dell site availability issues
    2026-07-22 - Updated comment-based help
    #>
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
    #   Get-DellSystemCatalog
    #=================================================
    #$GetMyDellBios = Get-DellSystemCatalog -Component BIOS -Compatible | Sort-Object ReleaseDate -Descending | Select-Object -First 1
    $GetMyDellBIOS = Get-DellBiosCatalog | Sort-Object ReleaseDate -Descending
    $GetMyDellBIOS | Add-Member -MemberType NoteProperty -Name 'Flash64W' -Value 'https://github.com/OSDeploy/Archive-OSDCloud/raw/main/BIOS/Flash64W_Ver3.3.8.cab'
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
    <#
    .SYNOPSIS
    Downloads the latest compatible Dell BIOS update to a local folder.

    .DESCRIPTION
    Resolves the current system's compatible Dell BIOS update and downloads the
    BIOS package to the specified folder when it is not already present. This
    function only operates on Dell hardware and returns the existing or newly
    downloaded BIOS file when successful.

    .PARAMETER DownloadPath
    Specifies the directory where the Dell BIOS update should be stored. The
    default location is the current user's temporary folder.

    .EXAMPLE
    Save-MyDellBios
    Downloads the compatible Dell BIOS update to the default temporary folder.

    .EXAMPLE
    Save-MyDellBios -DownloadPath 'C:\OSDCloud\Firmware'
    Downloads the compatible Dell BIOS update to C:\OSDCloud\Firmware.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-22 - Initial help block created
    #>
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
function Update-MyDellBios {
    <#
    .SYNOPSIS
    Downloads and launches a compatible BIOS update for the current Dell system.

    .DESCRIPTION
    Downloads the latest compatible Dell BIOS update, optionally prepares the
    Flash64W utility for WinPE x64 scenarios, suspends BitLocker on the operating
    system volume when needed, and launches the BIOS update installer. The BIOS
    installer log is written to $env:TEMP\Update-MyDellBios.log. Administrative
    rights are required.

    .PARAMETER DownloadPath
    Specifies the directory used to cache the BIOS update and supporting files.
    The default location is the current user's temporary folder.

    .PARAMETER Force
    Forces the update workflow even when the installed BIOS version comparison
    would not normally trigger an update.

    .PARAMETER Reboot
    Adds reboot arguments to the BIOS installer so the system reboots after the
    silent update completes.

    .PARAMETER Silent
    Runs the BIOS installer silently without automatically rebooting the system.

    .EXAMPLE
    Update-MyDellBios
    Downloads and launches the compatible Dell BIOS update with the default
    interactive installer behavior.

    .EXAMPLE
    Update-MyDellBios -Silent
    Runs the compatible Dell BIOS update silently and does not add a reboot.

    .EXAMPLE
    Update-MyDellBios -Silent -Reboot
    Runs the compatible Dell BIOS update silently and requests a reboot when the
    installer completes.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2021-03-04 - Initial release
    2021-03-05 - Resolved issue with multiple objects
    2021-03-09 - Started adding logic for WinPE
    2026-07-22 - Updated comment-based help
    #>
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
    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
        return
    }
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
    <#
    .SYNOPSIS
    Downloads and extracts the Dell Flash64W BIOS utility.

    .DESCRIPTION
    Downloads the Flash64W support package referenced by the current compatible
    Dell BIOS update and extracts Flash64W.exe to the specified folder. This is
    primarily used to support BIOS flashing from WinPE x64 environments on Dell
    hardware.

    .PARAMETER DownloadPath
    Specifies the directory where the Flash64W package should be downloaded and
    extracted. The default location is the current user's temporary folder.

    .EXAMPLE
    Save-MyDellBiosFlash64W
    Downloads and extracts Flash64W.exe to the default temporary folder.

    .EXAMPLE
    Save-MyDellBiosFlash64W -DownloadPath 'C:\OSDCloud\Firmware'
    Downloads and extracts Flash64W.exe to C:\OSDCloud\Firmware.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-22 - Initial help block created
    #>
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
    <#
    .SYNOPSIS
    Tests connectivity to the current compatible Dell BIOS download URL.

    .DESCRIPTION
    Resolves the current compatible Dell BIOS update and validates whether the
    BIOS download URL is reachable by using Test-WebConnection. Returns $false
    when a compatible BIOS update cannot be determined.

    .EXAMPLE
    Test-MyDellBiosWebConnection
    Returns True when the compatible Dell BIOS download URL is reachable.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-22 - Initial help block created
    #>
    [CmdletBinding()]
    param ()

    $GetMyDellBios = Get-MyDellBios
    if ($GetMyDellBios) {
        Test-WebConnection -Uri $GetMyDellBios.Url
    } else {
        Return $false
    }
}
