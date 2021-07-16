function Save-WindowsUpdateDriver {
    [CmdLetBinding()]
    param (
        [string]$DestinationDirectory = 'C:\Drivers',
        [string]$DeviceID,
        [string]$PNPClass = 'System'
    )
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
    $DeviceIDPattern = 'VEN_([0-9a-f]){4}&DEV_([0-9a-f]){4}'

    if (Test-MicrosoftCatalogWebConnection) {
        #if (Get-Module -ListAvailable -Name MSCatalog -ErrorAction Ignore) {

        $WindowsUpdateDeviceID = $DeviceID | Select-String -Pattern $DeviceIDPattern -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
            
        if ($WindowsUpdateDeviceID) {
            Write-Host -ForegroundColor DarkGray "WindowsUpdateDeviceID: $WindowsUpdateDeviceID"

            $SearchString = "$WindowsUpdateDeviceID".Replace('&',"`%26")
            Write-Host -ForegroundColor DarkGray "SearchString: $SearchString"

            $WindowsUpdateDriver = Get-OSDCatalogUpdate -Search "1903+$SearchString" -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore

            if ($WindowsUpdateDriver.Guid) {
                Write-Host -ForegroundColor DarkGray "$($WindowsUpdateDriver.Title) version $($WindowsUpdateDriver.Version)"
                Write-Host -ForegroundColor DarkGray "Version $($WindowsUpdateDriver.Version) Size: $($WindowsUpdateDriver.Size)"
                Write-Host -ForegroundColor DarkGray "Last Updated $($WindowsUpdateDriver.LastUpdated)"
                Write-Host -ForegroundColor DarkGray "UpdateID: $($WindowsUpdateDriver.Guid)"

                $DestinationPath = Join-Path $DestinationDirectory (Join-Path $PNPClass $WindowsUpdateDriver.Guid)
                Write-Host -ForegroundColor DarkGray "DestinationPath: $DestinationPath"

                $WindowsUpdateDriverFile = Save-UpdateCatalog -Guid $WindowsUpdateDriver.Guid -DestinationDirectory $DestinationPath
                if ($WindowsUpdateDriverFile) {
                    expand.exe "$($WindowsUpdateDriverFile.FullName)" -F:* "$DestinationPath" | Out-Null
                    Remove-Item $WindowsUpdateDriverFile.FullName | Out-Null
                }
                else {
                    Write-Warning "Save-WindowsUpdateDriver: Could not find a Driver for this DeviceID"
                }
            }
            else {
                #Write-Warning "Save-WindowsUpdateDriver: Could not find a Windows Update GUID"
            }
        }
        else {
            #Write-Warning "Save-WindowsUpdateDriver: Could not build a DeviceID Match"
        }
        #}
        #else {
            #Write-Warning "Save-WindowsUpdateDriver: Could not install required PowerShell Module MSCatalog"
        #}
    }
    else {
        Write-Warning "Save-WindowsUpdateDriver: Could not reach https://www.catalog.update.microsoft.com/"
    }
    #=======================================================================
}