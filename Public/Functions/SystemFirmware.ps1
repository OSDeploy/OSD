function Get-SystemFirmwareDevice {
    [CmdLetBinding()]
    param ()

    Get-CimInstance -ClassName Win32_PnpEntity | Where-Object ClassGuid -eq '{f2e7dd72-6468-4e36-b6f1-6488f42c1b52}' | Where-Object Caption -match 'System'
}
function Get-SystemFirmwareResource {
    [CmdLetBinding()]
    param ()

    $UefiFirmwareDevice = Get-SystemFirmwareDevice

    if ($UefiFirmwareDevice) {
        Convert-PNPDeviceIDtoGuid -PNPDeviceID $UefiFirmwareDevice.PNPDeviceID
    }
}
function Get-SystemFirmwareUpdate {
    #=================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if ($PSVersionTable.PSVersion.Major -ne 5) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] PowerShell 5.1 is required to run this function"
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
            Write-Warning "Get-SystemFirmwareUpdate: Could not reach https://www.catalog.update.microsoft.com/"
        }
    }
    else {
        Write-Warning "Get-SystemFirmwareUpdate: Could not install required PowerShell Module MSCatalog"
    }
    #=================================================
}
function Install-SystemFirmwareUpdate {
    [CmdLetBinding()]
    param (
        [String] $DestinationDirectory = "C:\Drivers\SystemFirmwareUpdate"
    )
    #=================================================
    #	Blocks
    #=================================================
    Block-StandardUser
    
    if ($PSVersionTable.PSVersion.Major -ne 5) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] PowerShell 5.1 is required to run this function"
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
                        Write-Warning "Install-SystemFirmwareUpdate: Could not find a UEFI Firmware update for this HardwareID"
                    }
                }
                else {
                    Write-Warning "Install-SystemFirmwareUpdate: Could not find a UEFI Firmware HardwareID"
                }
            }
            else {
                Write-Warning "Install-SystemFirmwareUpdate: Could not install required PowerShell Module MSCatalog"
            }
        }
        else {
            Write-Warning "Install-SystemFirmwareUpdate: Could not reach https://www.catalog.update.microsoft.com/"
        }
    }
    else {
        Write-Warning "Install-SystemFirmwareUpdate: Could not locate C:\Windows"
        if ($env:SystemDrive -eq 'X:') {
            Write-Warning "Make sure that Bitlocker encrypted drives are unlocked and suspended first"
        }
    }
    #=================================================
}
function Save-SystemFirmwareUpdate {
    [CmdLetBinding()]
    param (
        [String] $DestinationDirectory = "$env:TEMP\SystemFirmwareUpdate"
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
                    Write-Warning "Save-SystemFirmwareUpdate: Could not find a UEFI Firmware update for this HardwareID"
                }
            }
            else {
                Write-Warning "Save-SystemFirmwareUpdate: Could not find a UEFI Firmware HardwareID"
            }
        }
        else {
            Write-Warning "Save-SystemFirmwareUpdate: Could not install required PowerShell Module MSCatalog"
        }
    }
    else {
        Write-Warning "Save-SystemFirmwareUpdate: Could not reach https://www.catalog.update.microsoft.com/"
    }
    #=================================================
}
