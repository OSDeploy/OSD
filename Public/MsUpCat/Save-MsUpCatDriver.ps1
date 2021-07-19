function Save-MsUpCatDriver {
    [CmdLetBinding()]
    param (
        [string]$DestinationDirectory,
        [ValidateSet('Display','Net','USB')]
        [string]$PNPClass
    )
    if (!($DestinationDirectory)) {
        Write-Warning 'Set the DestinationDirectory parameter to download the Drivers'
    }
    #=======================================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=======================================================================
<#     if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -ErrorAction Ignore
    } #>
    #=======================================================================
    #$DeviceIDPattern = 'VEN_([0-9a-f]){4}&DEV_([0-9a-f]){4}&SUBSYS_([0-9a-f]){8}'
    $DeviceIDPattern = 'v[ei][dn]_([0-9a-f]){4}&[pd][ie][dv]_([0-9a-f]){4}'

    if (Test-WebConnectionMsUpCat) {
        #if (Get-Module -ListAvailable -Name MSCatalog -ErrorAction Ignore) {
        
        $Params = @{
            ClassName = 'Win32_PnpEntity' 
            Property = 'Name','Description','DeviceID','HardwareID','ClassGuid','Manufacturer','PNPClass'
        }
        $Devices = Get-CimInstance @Params
        
        if ($PNPClass -match 'Display') {
            $Devices = $Devices | Where-Object {($_.Name -match 'Video') -or ($_.PNPClass -match 'Display')}
        }
        if ($PNPClass -match 'Net') {
            $Devices = $Devices | Where-Object {($_.Name -match 'Network') -or ($_.PNPClass -match 'Net')}
        }

        foreach ($Item in $Devices) {
            $NardwareID = $null

            #See if DeviceID matches the pattern
            $HardwareID = $Item.DeviceID | Select-String -Pattern $DeviceIDPattern -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value

            if (($null -eq $HardwareID) -and ($Item.HardwareID)) {
                $HardwareID = $Item.HardwareID[0] | Select-String -Pattern $DeviceIDPattern -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
            }

            if ($HardwareID) {
                $SearchString = "$HardwareID".Replace('&',"`%26")
                $WindowsUpdateDriver = Get-MsUpCat -Search "1903+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
    
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
                    Write-Host -ForegroundColor DarkGray "HardwareID: $HardwareID"
                    Write-Host -ForegroundColor DarkGray "SearchString: $SearchString"

                    Write-Host -ForegroundColor DarkGray "$($WindowsUpdateDriver.Title) version $($WindowsUpdateDriver.Version)"
                    Write-Host -ForegroundColor DarkGray "Version $($WindowsUpdateDriver.Version) Size: $($WindowsUpdateDriver.Size)"
                    Write-Host -ForegroundColor DarkGray "Last Updated $($WindowsUpdateDriver.LastUpdated)"
                    Write-Host -ForegroundColor DarkGray "UpdateID: $($WindowsUpdateDriver.Guid)"

                    if ($DestinationDirectory) {
                        if ($Item.PNPClass) {
                            $DestinationPath = Join-Path $DestinationDirectory (Join-Path $Item.PNPClass $WindowsUpdateDriver.Guid)
                        }
                        else {
                            $DestinationPath = Join-Path $DestinationDirectory $WindowsUpdateDriver.Guid
                        }
                        Write-Host -ForegroundColor DarkGray "DestinationPath: $DestinationPath"
                        $WindowsUpdateDriverFile = Save-UpdateCatalog -Guid $WindowsUpdateDriver.Guid -DestinationDirectory $DestinationPath
                        if ($WindowsUpdateDriverFile) {
                            expand.exe "$($WindowsUpdateDriverFile.FullName)" -F:* "$DestinationPath" | Out-Null
                            Remove-Item $WindowsUpdateDriverFile.FullName | Out-Null
                        }
                        else {
                            Write-Warning "Save-MsUpCatDriver: Could not find a Driver for this DeviceID"
                        }
                    }
                }
                else {
                    Write-Host -ForegroundColor Gray "No Results: $($Item.Name) $HardwareID"
                    #Write-Host -ForegroundColor DarkGray "HardwareID: $HardwareID"
                    #Write-Host -ForegroundColor DarkGray "SearchString: $SearchString"
                    #Write-Warning "Save-MsUpCatDriver: Could not find a Windows Update GUID"
                }
            }
            else {
                #Write-Warning "Save-MsUpCatDriver: Could not build a DeviceID Match"
            }
        }
        #}
        #else {
            #Write-Warning "Save-MsUpCatDriver: Could not install required PowerShell Module MSCatalog"
        #}
    }
    #else {
        #Write-Warning "Save-MsUpCatDriver: Could not reach https://www.catalog.update.microsoft.com/"
    #}
    #=======================================================================
}