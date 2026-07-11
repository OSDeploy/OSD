function Get-SystemFirmwareDevice {
    <#
    .SYNOPSIS
    Returns the system firmware device

    .DESCRIPTION
    Retrieves the system firmware device by querying Win32_PnpEntity for the System Firmware class GUID.

    .EXAMPLE
    Get-SystemFirmwareDevice
    Returns the system firmware device information

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help
    2026-07-11 - Improved CIM filtering and error handling
    #>
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    [CmdletBinding()]
    param ()

    $SystemFirmwareClassGuid = '{f2e7dd72-6468-4e36-b6f1-6488f42c1b52}'
    $Filter = "ClassGuid = '$SystemFirmwareClassGuid' AND Caption LIKE '%System%'"

    try {
        Get-CimInstance -ClassName Win32_PnpEntity -Filter $Filter -ErrorAction Stop
    }
    catch {
        Write-Verbose "Failed to query Win32_PnpEntity. $_"
        $null
    }
}
function Get-SystemFirmwareResource {
    <#
    .SYNOPSIS
    Returns the GUID of the system firmware resource

    .DESCRIPTION
    Retrieves the system firmware device and extracts GUID values directly from
    its PNP Device ID for use with Microsoft Update Catalog queries.

    .EXAMPLE
    Get-SystemFirmwareResource
    Returns the firmware resource GUID

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help
    2026-07-11 - Removed dependency on Convert-PNPDeviceIDtoGuid and added local GUID extraction
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param ()

    $UefiFirmwareDevice = Get-SystemFirmwareDevice

    if (-not $UefiFirmwareDevice) {
        Write-Verbose 'Get-SystemFirmwareResource: No system firmware device found.'
        return
    }

    $GuidRegex = [System.Text.RegularExpressions.Regex]::new(
        '(?i)\{?[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\}?',
        [System.Text.RegularExpressions.RegexOptions]::Compiled
    )

    foreach ($Device in @($UefiFirmwareDevice)) {
        $Matches = $GuidRegex.Matches($Device.PNPDeviceID)

        if ($Matches.Count -eq 0) {
            Write-Verbose "Get-SystemFirmwareResource: No GUID found in PNPDeviceID '$($Device.PNPDeviceID)'."
            continue
        }

        foreach ($Match in $Matches) {
            $Match.Value
        }
    }
}

function Install-SystemFirmwareUpdate {
    <#
    .SYNOPSIS
    Downloads and installs the system firmware update

    .DESCRIPTION
    Downloads the latest system firmware update from Microsoft Update Catalog and installs it on the running system. Requires admin rights and PowerShell 5.1.

    .PARAMETER DestinationDirectory
    Directory where the firmware update will be downloaded. Default is C:\Drivers\SystemFirmwareUpdate

    .EXAMPLE
    Install-SystemFirmwareUpdate
    Downloads and installs the latest firmware update

    .EXAMPLE
    Install-SystemFirmwareUpdate -DestinationDirectory 'D:\Updates'
    Downloads firmware update to D:\Updates and installs it

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help
    #>
    [CmdLetBinding()]
    param (
        [String] $DestinationDirectory = "C:\Drivers\SystemFirmwareUpdate"
    )
    #=================================================
    #	Blocks
    #=================================================
    Block-StandardUser

    if ($PSVersionTable.PSVersion.Major -ne 5) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PowerShell 5.1 is required to run this function"
        return
    }
    #=================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -SkipPublisherCheck -ErrorAction Ignore
    }
    #=================================================
    if (Test-Path 'C:\Windows' -PathType Container) {
        if (Test-MicrosoftUpdateCatalog) {
            if (Get-Module -ListAvailable -Name MSCatalog -ErrorAction Ignore) {
                $SystemFirmwareUpdate = Get-SystemFirmwareUpdate

                if ($SystemFirmwareUpdate.Guid) {
                    Write-Host -ForegroundColor DarkGray "$($SystemFirmwareUpdate.Title) version $($SystemFirmwareUpdate.Version)"
                    Write-Host -ForegroundColor DarkGray "Version $($SystemFirmwareUpdate.Version) Size: $($SystemFirmwareUpdate.Size)"
                    Write-Host -ForegroundColor DarkGray "Last Updated $($SystemFirmwareUpdate.LastUpdated)"
                    Write-Host -ForegroundColor DarkGray "UpdateID: $($SystemFirmwareUpdate.Guid)"
                    Write-Host -ForegroundColor DarkGray ""
                }

                if ($SystemFirmwareUpdate) {
                    $SystemFirmwareUpdateFile = Save-UpdateCatalog -Guid $SystemFirmwareUpdate.Guid -DestinationDirectory $DestinationDirectory
                    if ($SystemFirmwareUpdateFile) {
                        expand.exe "$($SystemFirmwareUpdateFile.FullName)" -F:* "$DestinationDirectory" | Out-Null
                        Remove-Item $SystemFirmwareUpdateFile.FullName | Out-Null
                        if ($env:SystemDrive -eq 'X:') {
                            Add-WindowsDriver -Path 'C:\' -Driver "$DestinationDirectory"
                        }
                        else {
                            if (Test-Path "$DestinationDirectory" -PathType Container) {
                                Get-ChildItem "$DestinationDirectory" -Recurse -Filter "*.inf" | ForEach-Object { PNPUtil.exe /Add-Driver $_.FullName /install }
                            }
                        }
                    }
                    else {
                        Write-Host -ForegroundColor DarkGray "Install-SystemFirmwareUpdate: Could not find a UEFI Firmware update for this HardwareID"
                    }
                }
                else {
                    Write-Host -ForegroundColor DarkGray "Install-SystemFirmwareUpdate: Could not find a UEFI Firmware HardwareID"
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "Install-SystemFirmwareUpdate: Could not install required PowerShell Module MSCatalog"
            }
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-SystemFirmwareUpdate: Could not reach https://www.catalog.update.microsoft.com/"
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "Install-SystemFirmwareUpdate: Could not locate C:\Windows"
        if ($env:SystemDrive -eq 'X:') {
            Write-Host -ForegroundColor DarkGray "Make sure that Bitlocker encrypted drives are unlocked and suspended first"
        }
    }
    #=================================================
}
function Save-SystemFirmwareUpdate {
    [CmdLetBinding()]
    param (
        [String]$DestinationDirectory = "$env:TEMP\SystemFirmwareUpdate"
    )
    #=================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -SkipPublisherCheck -Force -ErrorAction Ignore
    }
    #=================================================
    if (Test-MicrosoftUpdateCatalog) {
        if (Get-Module -ListAvailable -Name MSCatalog -ErrorAction Ignore) {
            $SystemFirmwareUpdate = Get-SystemFirmwareUpdate

            if ($SystemFirmwareUpdate.Guid) {
                Write-Host -ForegroundColor DarkGray "$($SystemFirmwareUpdate.Title) version $($SystemFirmwareUpdate.Version)"
                Write-Host -ForegroundColor DarkGray "Version $($SystemFirmwareUpdate.Version) Size: $($SystemFirmwareUpdate.Size)"
                Write-Host -ForegroundColor DarkGray "Last Updated $($SystemFirmwareUpdate.LastUpdated)"
                Write-Host -ForegroundColor DarkGray "UpdateID: $($SystemFirmwareUpdate.Guid)"
                Write-Host -ForegroundColor DarkGray ""
            }

            if ($SystemFirmwareUpdate) {
                $SystemFirmwareUpdateFile = Save-UpdateCatalog -Guid $SystemFirmwareUpdate.Guid -DestinationDirectory $DestinationDirectory
                if ($SystemFirmwareUpdateFile) {
                    expand.exe "$($SystemFirmwareUpdateFile.FullName)" -F:* "$DestinationDirectory"
                    Remove-Item $SystemFirmwareUpdateFile.FullName | Out-Null
                    if ($env:SystemDrive -eq 'X:') {
                        #Write-Host -ForegroundColor DarkGray "You can install the firmware by running the following command"
                        #Write-Host -ForegroundColor DarkGray "Add-WindowsDriver -Path C:\ -Driver $DestinationDirectory"
                    }
                    else {
                        #Write-Host -ForegroundColor DarkGray "Make sure Bitlocker is suspended first before installing the Firmware Driver"
                        if (Test-Path "$DestinationDirectory\firmware.inf") {
                            #Write-Host -ForegroundColor DarkGray "Right click on $DestinationDirectory\firmware.inf and Install"
                        }
                    }
                }
                else {
                    Write-Host -ForegroundColor DarkGray "Save-SystemFirmwareUpdate: Could not find a UEFI Firmware update for this HardwareID"
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "Save-SystemFirmwareUpdate: Could not find a UEFI Firmware HardwareID"
            }
        }
        else {
            Write-Host -ForegroundColor DarkGray "Save-SystemFirmwareUpdate: Could not install required PowerShell Module MSCatalog"
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "Save-SystemFirmwareUpdate: Could not reach https://www.catalog.update.microsoft.com/"
    }
    #=================================================
}
