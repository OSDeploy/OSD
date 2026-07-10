function Get-SystemFirmwareDevice {
    <#
    .SYNOPSIS
    Returns the system firmware device

    .DESCRIPTION
    Retrieves the system firmware device from WMI using Win32_PnpEntity with the System Firmware class GUID.

    .EXAMPLE
    Get-SystemFirmwareDevice
    Returns the system firmware device information

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdLetBinding()]
    param ()

    Get-CimInstance -ClassName Win32_PnpEntity | Where-Object ClassGuid -eq '{f2e7dd72-6468-4e36-b6f1-6488f42c1b52}' | Where-Object Caption -match 'System'
}
function Get-SystemFirmwareResource {
    <#
    .SYNOPSIS
    Returns the GUID of the system firmware resource

    .DESCRIPTION
    Retrieves the system firmware device and converts its PNP Device ID to a GUID for use with Microsoft Update Catalog queries.

    .EXAMPLE
    Get-SystemFirmwareResource
    Returns the firmware resource GUID

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdLetBinding()]
    param ()

    $UefiFirmwareDevice = Get-SystemFirmwareDevice

    if ($UefiFirmwareDevice) {
        Convert-PNPDeviceIDtoGuid -PNPDeviceID $UefiFirmwareDevice.PNPDeviceID
    }
}
function Get-SystemFirmwareUpdate {
    <#
    .SYNOPSIS
    Retrieves the latest system firmware update from Microsoft Update Catalog

    .DESCRIPTION
    Searches Microsoft Update Catalog for the latest system firmware update available for the current computer's firmware device. Requires PowerShell 5.1 and MSCatalog module.

    .EXAMPLE
    Get-SystemFirmwareUpdate
    Returns the latest available firmware update

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdLetBinding()]
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if ($PSVersionTable.PSVersion.Major -ne 5) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PowerShell 5.1 is required to run this function"
        return
    }
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -SkipPublisherCheck -ErrorAction Ignore
    }
    #=================================================
    #	Make sure the Module was installed
    #=================================================
    if (Get-Module -ListAvailable -Name MSCatalog) {
        if (Test-MicrosoftUpdateCatalog) {
            Try {
                Get-MSCatalogUpdate -Search (Get-SystemFirmwareResource) -SortBy LastUpdated -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1
            }
            Catch {
                #Do nothing
            }
        }
        else {
            Write-Host -ForegroundColor DarkGray "Get-SystemFirmwareUpdate: Could not reach https://www.catalog.update.microsoft.com/"
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "Get-SystemFirmwareUpdate: Could not install required PowerShell Module MSCatalog"
    }
    #=================================================
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

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
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
