function Save-MsUpCatDriver {
    [CmdletBinding(DefaultParameterSetName = 'ByPNPClass')]
    param (
        [System.String]$DestinationDirectory,

        [Parameter(ParameterSetName = 'ByHardwareID')]
        [System.String[]]$HardwareID,

        [Parameter(ParameterSetName = 'ByPNPClass')]
        [ValidateSet('DiskDrive','Display','Net','SCSIAdapter','SecurityDevices','USB')]
        [System.String]$PNPClass
    )
    #=================================================
    if (!($DestinationDirectory)) {
        Write-Warning 'Set the DestinationDirectory parameter to download the Drivers'
    }
    #=================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
<#     if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -ErrorAction Ignore
    } #>
    #=================================================
    #$HardwareIDPattern = 'VEN_([0-9a-f]){4}&DEV_([0-9a-f]){4}&SUBSYS_([0-9a-f]){8}'
    $HardwareIDPattern = 'v[ei][dn]_([0-9a-f]){4}&[pd][ie][dv]_([0-9a-f]){4}'
    $SurfaceIDPattern = 'mshw0[0-1]([0-9]){2}'

    if (Test-MicrosoftUpdateCatalog) {
        #=================================================
        #	ByPNPClass
        #=================================================
        if ($PSCmdlet.ParameterSetName -eq 'ByPNPClass') {
            $Params = @{
                ClassName = 'Win32_PnpEntity' 
                Property = 'Name','Description','DeviceID','HardwareID','ClassGuid','Manufacturer','PNPClass'
            }
            $Devices = Get-CimInstance @Params

            if ($Devices) {
                if ($PNPClass -match 'Display') {
                    $Devices = $Devices | Where-Object {($_.Name -match 'Video') -or ($_.PNPClass -match 'Display')}
                }
                elseif ($PNPClass -match 'Net') {
                    $Devices = $Devices | Where-Object {($_.Name -match 'Network') -or ($_.PNPClass -match 'Net')}
                }
                elseif ($PNPClass) {
                    $Devices = $Devices | Where-Object {$_.PNPClass -match $PNPClass}
                }
                else {
                    #All Devices
                }
            }

            if ($Devices) {
                if ($PNPClass) {
                    Write-Host -ForegroundColor DarkGray "Devices were found for PNPClass $PNPClass"
                }
                
                foreach ($Item in $Devices) {
                    $FindHardwareID = $null
    
                    #See if DeviceID matches the pattern
                    Write-Host -ForegroundColor DarkGray "DeviceID: $($Item.DeviceID)"
                    $FindHardwareID = $Item.DeviceID | Select-String -Pattern $HardwareIDPattern -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value

                    if (-not ($FindHardwareID)) {
                        if ($Item.HardwareID) {
                            Write-Host -ForegroundColor DarkGray "HardwareID: $($Item.HardwareID[0])"
                            $FindHardwareID = $Item.HardwareID[0] | Select-String -Pattern $HardwareIDPattern -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
                        }
                    }

                    if ($FindHardwareID) {
                        Write-Host -ForegroundColor Gray "Searching: $FindHardwareID"
                        $SearchString = "$FindHardwareID".Replace('&',"`%26")
    
                        $WindowsUpdateDriver = Get-MsUpCat -Search "22H2+$PNPClass+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                        
                        if (-not ($WindowsUpdateDriver)) {
                            $WindowsUpdateDriver = Get-MsUpCat -Search "21H2+$PNPClass+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                        }
                        if (-not ($WindowsUpdateDriver)) {
                            $WindowsUpdateDriver = Get-MsUpCat -Search "Vibranium+$PNPClass+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                        }
                        if (-not ($WindowsUpdateDriver)) {
                            $WindowsUpdateDriver = Get-MsUpCat -Search "1903+$PNPClass+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                        }
                        if (-not ($WindowsUpdateDriver)) {
                            $WindowsUpdateDriver = Get-MsUpCat -Search "1809+$PNPClass+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                        }
                        if (-not ($WindowsUpdateDriver)) {
                            $WindowsUpdateDriver = Get-MsUpCat -Search "$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                        }
    
                        if ($WindowsUpdateDriver.Guid) {
                            if ($Item.Name -and $Item.PNPClass) {
                                Write-Host -ForegroundColor Cyan "$($Item.PNPClass) $($Item.Name)"
                            }
                            elseif ($Item.Name) {
                                Write-Host -ForegroundColor Cyan "$($Item.Name)"
                            }
                            else {
                                Write-Host -ForegroundColor Cyan $Item.DeviceID
                            }
                            Write-Host -ForegroundColor DarkGray "HardwareID: $FindHardwareID"
                            Write-Host -ForegroundColor DarkGray "SearchString: $SearchString"
        
                            Write-Host -ForegroundColor DarkGray "$($WindowsUpdateDriver.Title) version $($WindowsUpdateDriver.Version)"
                            Write-Host -ForegroundColor DarkGray "Version $($WindowsUpdateDriver.Version) Size: $($WindowsUpdateDriver.Size)"
                            Write-Host -ForegroundColor DarkGray "Last Updated $($WindowsUpdateDriver.LastUpdated)"
                            Write-Host -ForegroundColor DarkGray "UpdateID: $($WindowsUpdateDriver.Guid)"
        
                            if ($DestinationDirectory) {
                                $DestinationPath = Join-Path $DestinationDirectory $WindowsUpdateDriver.Guid
    
                                if (Test-Path $DestinationPath) {
                                    Write-Host -ForegroundColor DarkGray "Driver already expanded at $DestinationPath"
                                }
                                else {
                                    Write-Host -ForegroundColor DarkGray "Downloading and expanding to $DestinationPath"
                                    $WindowsUpdateDriverFile = Save-UpdateCatalog -Guid $WindowsUpdateDriver.Guid -DestinationDirectory $DestinationPath
                                    if ($WindowsUpdateDriverFile) {
                                        expand.exe "$($WindowsUpdateDriverFile.FullName)" -F:* "$DestinationPath" | Out-Null
                                        Remove-Item $WindowsUpdateDriverFile.FullName | Out-Null
                                    }
                                    else {
                                        Write-Warning "Save-MsUpCatDriver: Could not find a Driver for this HardwareID"
                                    }
                                }
                            }
                        }
                        else {
                            Write-Host -ForegroundColor Gray "No Results: $($Item.Name) $FindHardwareID"
                            #Write-Host -ForegroundColor DarkGray "HardwareID: $FindHardwareID"
                            #Write-Host -ForegroundColor DarkGray "SearchString: $SearchString"
                            #Write-Warning "Save-MsUpCatDriver: Could not find a Windows Update GUID"
                        }
                    }
                    else {
                        #Write-Host -ForegroundColor Gray "No Results: $FindHardwareID"
                    }
                }
            }
        }
        #=================================================
        #	ByHardwareID
        #=================================================
        if ($PSCmdlet.ParameterSetName -eq 'ByHardwareID') {
            foreach ($Item in $HardwareID) {
                Write-Verbose $Item

                $WindowsUpdateDriver = $null

                #See if DeviceID matches the pattern
                $FindHardwareID = $Item | Select-String -Pattern $HardwareIDPattern | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value

                if (-not ($FindHardwareID)) {
                    $FindHardwareID = $Item | Select-String -Pattern $SurfaceIDPattern | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
                }
    
                if ($FindHardwareID) {
                    $SearchString = "$FindHardwareID".Replace('&',"`%26")

                    $WindowsUpdateDriver = Get-MsUpCat -Search "22H2+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore

                    if (-not ($WindowsUpdateDriver)) {
                        $WindowsUpdateDriver = Get-MsUpCat -Search "21H2+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                    }
                    if (-not ($WindowsUpdateDriver)) {
                        $WindowsUpdateDriver = Get-MsUpCat -Search "Vibranium+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                    }
                    if (-not ($WindowsUpdateDriver)) {
                        $WindowsUpdateDriver = Get-MsUpCat -Search "1903+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                    }
                    if (-not ($WindowsUpdateDriver)) {
                        $WindowsUpdateDriver = Get-MsUpCat -Search "1809+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                    }

                    if ($WindowsUpdateDriver.Guid) {
                        Write-Host -ForegroundColor Cyan "$Item $($WindowsUpdateDriver.Title)"
                        Write-Host -ForegroundColor DarkGray "UpdateID: $($WindowsUpdateDriver.Guid)"
                        Write-Host -ForegroundColor DarkGray "Size: $($WindowsUpdateDriver.Size) Last Updated $($WindowsUpdateDriver.LastUpdated)"

                        #Write-Host -ForegroundColor DarkGray "HardwareID: $FindHardwareID"
                        #Write-Host -ForegroundColor DarkGray "SearchString: $SearchString"
    
                        #Write-Host -ForegroundColor DarkGray "$($WindowsUpdateDriver.Title) version $($WindowsUpdateDriver.Version)"
                        #Write-Host -ForegroundColor DarkGray "Version $($WindowsUpdateDriver.Version) Size: $($WindowsUpdateDriver.Size)"
                        #Write-Host -ForegroundColor DarkGray "Last Updated $($WindowsUpdateDriver.LastUpdated)"
    
                        if ($DestinationDirectory) {
                            $DestinationPath = Join-Path $DestinationDirectory $WindowsUpdateDriver.Guid

                            if (Test-Path $DestinationPath) {
                                Write-Host -ForegroundColor DarkGray "Driver already expanded at $DestinationPath"
                            }
                            else {
                                Write-Host -ForegroundColor DarkGray "Downloading and expanding to $DestinationPath"
                                $WindowsUpdateDriverFile = Save-UpdateCatalog -Guid $WindowsUpdateDriver.Guid -DestinationDirectory $DestinationPath
                                if ($WindowsUpdateDriverFile) {
                                    expand.exe "$($WindowsUpdateDriverFile.FullName)" -F:* "$DestinationPath" | Out-Null
                                    Remove-Item $WindowsUpdateDriverFile.FullName | Out-Null
                                }
                                else {
                                    Write-Warning "Save-MsUpCatDriver: Could not find a Driver for this HardwareID"
                                }
                            }
                        }
                    }
                    else {
                        Write-Host -ForegroundColor Gray "No Results: $FindHardwareID"
                    }
                }
                else {
                    Write-Host -ForegroundColor Gray "No Results: $FindHardwareID"
                }
            }
        }
    }
}