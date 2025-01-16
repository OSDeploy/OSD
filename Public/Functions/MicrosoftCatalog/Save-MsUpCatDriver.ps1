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
    else {
        if (!(Test-Path $DestinationDirectory)){
            New-Item -Path $DestinationDirectory -ItemType Directory -Force | Out-Null
        }
    }
    #Grab OSDCloud USB Flash Drive Info
    $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Select-Object -First 1
    if ($OSDCloudUSB){
        $MSUpCatDriversOSDCloudUSBPath =  "$($OSDCloudUSB.DriveLetter):\OSDCloud\MsUpCatDrivers"
    }
    #=================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
<#     if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -SkipPublisherCheck -ErrorAction Ignore
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
                        try {
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
                                    #If OSDCloud USB Attached, Check for Driver in Cache and Copy ro Local Cache
                                    if ($OSDCloudUSB){
                                        $USBCachePath = Join-Path $MSUpCatDriversOSDCloudUSBPath $WindowsUpdateDriver.Guid
                                        if (Test-Path $USBCachePath){
                                            Write-Host -ForegroundColor DarkGray "Driver already expanded at $USBCachePath, copying to $DestinationPath"
                                            Copy-Item -Path $USBCachePath -Destination $DestinationPath -Recurse -Force
                                        }
                                    }
                                    #Check if Driver is already Local Cache 
                                    if (Test-Path $DestinationPath) {
                                        Write-Host -ForegroundColor DarkGray "Driver already expanded at $DestinationPath"
                                    }
                                    #Download if not already found in Local Cache
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
                        catch{
                            Write-Host -ForegroundColor Gray "Unable to get Driver for Hardware component"
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
                Write-Verbose "Save-MsUpCatDriver: ByHardwareID"
                Write-Verbose $Item

                $WindowsUpdateDriver = $null

                #See if DeviceID matches the pattern
                $FindHardwareID = $Item | Select-String -Pattern $HardwareIDPattern | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value

                if (-not ($FindHardwareID)) {
                    $FindHardwareID = $Item | Select-String -Pattern $SurfaceIDPattern | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
                }
    
                if ($FindHardwareID) {
                    $SearchString = "$FindHardwareID".Replace('&', "`%26")

                    try {
                        Write-Verbose "Save-MsUpCatDriver Search: 23H2 $SearchString"
                        $WindowsUpdateDriver = Get-MsUpCat -Search "23H2+$SearchString" -Descending | Select-Object LastUpdated, Title, Version, Size, Guid -First 1 -ErrorAction Ignore
                    }
                    catch {
                        <#Do this if a terminating exception happens#>
                    }
                    if (-not ($WindowsUpdateDriver)) {
                        try {
                            Write-Verbose "Save-MsUpCatDriver Search: 22H2 $SearchString"
                            $WindowsUpdateDriver = Get-MsUpCat -Search "22H2+$SearchString" -Descending | Select-Object LastUpdated, Title, Version, Size, Guid -First 1 -ErrorAction Ignore
                        }
                        catch {
                            <#Do this if a terminating exception happens#>
                        }
                    }
                    if (-not ($WindowsUpdateDriver)) {
                        try {
                            Write-Verbose "Save-MsUpCatDriver Search: 21H2+$SearchString"
                            $WindowsUpdateDriver = Get-MsUpCat -Search "21H2+$SearchString" -Descending | Select-Object LastUpdated, Title, Version, Size, Guid -First 1 -ErrorAction Ignore
                        }
                        catch {
                            <#Do this if a terminating exception happens#>
                        }
                    }
                    if (-not ($WindowsUpdateDriver)) {
                        try {
                            Write-Verbose "Save-MsUpCatDriver Search: Vibranium+$SearchString"
                            $WindowsUpdateDriver = Get-MsUpCat -Search "Vibranium+$SearchString" -Descending | Select-Object LastUpdated, Title, Version, Size, Guid -First 1 -ErrorAction Ignore
                        }
                        catch {
                            <#Do this if a terminating exception happens#>
                        }
                    }
                    if (-not ($WindowsUpdateDriver)) {
                        try {
                            Write-Verbose "Save-MsUpCatDriver Search: 1903+$SearchString"
                            $WindowsUpdateDriver = Get-MsUpCat -Search "1903+$SearchString" -Descending | Select-Object LastUpdated, Title, Version, Size, Guid -First 1 -ErrorAction Ignore
                        }
                        catch {
                            <#Do this if a terminating exception happens#>
                        }
                    }
                    if (-not ($WindowsUpdateDriver)) {
                        try {
                            Write-Verbose "Save-MsUpCatDriver Search: 1809+$SearchString"
                            $WindowsUpdateDriver = Get-MsUpCat -Search "1809+$SearchString" -Descending | Select-Object LastUpdated, Title, Version, Size, Guid -First 1 -ErrorAction Ignore
                        }
                        catch {
                            <#Do this if a terminating exception happens#>
                        }
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
                            #If OSDCloud USB Attached, Check for Driver in Cache and Copy ro Local Cache
                            if ($OSDCloudUSB){
                                $USBCachePath = Join-Path $MSUpCatDriversOSDCloudUSBPath $WindowsUpdateDriver.Guid
                                if (Test-Path $USBCachePath){
                                    Write-Host -ForegroundColor DarkGray "Driver already expanded at $USBCachePath, copying to $DestinationPath"
                                    Copy-Item -Path $USBCachePath -Destination $DestinationPath -Recurse -Force
                                }
                            }
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
        #=================================================
        #	Sync Back to OSDCloudUSB
        #=================================================
        if ($Global:OSDCloud.SyncMSUpCatDriverUSB -eq $true){
            if ($OSDCloudUSB){
                #Get Size of Cached Drivers in Local Drive Cache
                if (Test-Path $DestinationDirectory){
                    $MsUpCatDriverCacheSizeGB = (Get-ChildItem $DestinationDirectory -Recurse | Measure-Object -Property Length -Sum).Sum /1GB
                    #Get Free Space on OSDCloud USB Drive (with buffer)
                    $OSDCloudUSBFree = ($OSDCloudUSB.SizeRemainingGB - 5) #Free Space with 5GB Buffer
                    #If enough Free Space, cache files on Flash Drive
                    if ($MsUpCatDriverCacheSizeGB -lt $OSDCloudUSBFree){
                        $Source      = $DestinationDirectory #Yes this can seem confusing, remember Destination is where the Drivers were downloaded orginially
                        $Destination = $MSUpCatDriversOSDCloudUSBPath #OSDCloud Flash Drive cache folder

                        Write-Host -ForegroundColor Cyan "Syncing MS Update Catalog Drivers to OSDCloud USB Cache"
                        Write-Host -ForegroundColor Gray "Transfering $([Math]::Round($MsUpCatDriverCacheSizeGB,2)) GB of MS Update Drivers to $Destination"
                        Invoke-Exe robocopy $Source $Destination *.* /s /ndl /nfl /njh /njs
                    }
                    else {
                        Write-Host -ForegroundColor Gray "Not enough Free Space on OSDCloudUSB to sync drivers"
                        Write-Host -ForegroundColor Gray "Requires $([Math]::Round(($MsUpCatDriverCacheSizeGB + 5),2)) GB, but only $($OSDCloudUSB.SizeRemainingGB) GB available"
                    }
                }
            }
            else {
                Write-Host -ForegroundColor Gray "OSDCloudUSB not detected to sync drivers back to, skipping sync"
            }
        }
    }
}