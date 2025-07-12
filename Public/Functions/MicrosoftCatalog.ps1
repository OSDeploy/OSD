function Get-MsUpCat {
    <#
        .SYNOPSIS
        Query catalog.update.micrsosoft.com for available updates.

        .DESCRIPTION
        This function uses MSCatalogLTS module to search for updates from Microsoft Update Catalog.

        .PARAMETER Search
        Specify a string to search for.

        .PARAMETER Architecture
        Specify the architecture to filter results.

        .EXAMPLE
        Get-MsUpCat -Search "Cumulative for Windows Server, version 1903"

        .EXAMPLE
        Get-MsUpCat -Search "Cumulative for Windows Server, version 1903" -Architecture x64
    #>
    
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Search,

        [Parameter(Mandatory = $false)]
        [ValidateSet("all", "x64", "x86", "arm64")]
        [string] $Architecture = "all"
    )

    try {
        # Install and import MSCatalogLTS if not available
        if (!(Get-Module -ListAvailable -Name MSCatalogLTS)) {
            Install-Module MSCatalogLTS -Force -SkipPublisherCheck
        }
        
        if (Get-Module -ListAvailable -Name MSCatalogLTS -ErrorAction Ignore) {
            Import-Module MSCatalogLTS -Force
            Get-MSCatalogUpdate -Search $Search -Architecture $Architecture
        } else {
            Write-Warning "Could not install required PowerShell Module MSCatalogLTS"
        }
    } catch {
        throw $_
    }
}

function Get-MsUpCatUpdate {
    [CmdLetBinding()]
    param (
        [ValidateSet('Windows 11','Windows 10','Windows Server','Windows Server 2016','Windows Server 2019','Windows Server 2022')]
        [Alias('OperatingSystem')]
        [string]$OS = 'Windows 11',

        [ValidateSet('x64','x86')]
        [Alias('Architecture')]
        [string]$Arch = 'x64',

        [ValidateSet('24H2','23H2','22H2','21H2','21H1','20H2',2004,1909,1903,1809,1803,1709,1703,1607,1511,1507)]
        [string]$Build = '22H2',

        [ValidateSet('LCU','SSU','DotNetCU')]
        [string]$Category = 'LCU',

        [System.Management.Automation.SwitchParameter]$Insider,

        [System.Management.Automation.SwitchParameter]$ListAvailable
    )
    #=================================================
    #	MSCatalogLTS PowerShell Module
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if (!(Get-Module -ListAvailable -Name MSCatalogLTS)) {
        Install-Module MSCatalogLTS -Force -SkipPublisherCheck
    }
    #=================================================
    #	Make sure the Module was installed first
    #=================================================
    if (Test-MicrosoftUpdateCatalog) {
        if (Get-Module -ListAvailable -Name MSCatalogLTS -ErrorAction Ignore) {
            Import-Module MSCatalogLTS -Force
            #=================================================
            #	Details
            #=================================================
            Write-Verbose -Verbose "OperatingSystem: $OS"
            Write-Verbose -Verbose "Architecture: $Arch"
            Write-Verbose -Verbose "Category: $Category"
            #=================================================
            #	Build
            #=================================================
            if ($OS -eq 'Windows 10') {
                Write-Verbose -Verbose "Build: $Build"
                $SearchString = "$OS $Build $Arch"
            }
            elseif ($OS -eq 'Windows Server') {
                Write-Verbose -Verbose "Build: $Build"
                $SearchString = "$OS $Build $Arch"
            }
            else {
                $SearchString = "$OS $Arch"
            }
            #=================================================
            #	Category
            #=================================================
            if ($Category -eq 'SSU') {
                $SearchString = "$SearchString Servicing Stack Update"
            }
            if ($Category -eq 'LCU') {
                $SearchString = "$SearchString Cumulative Update"
            }
            if ($Category -eq 'DotNetCU') {
                $SearchString = "$SearchString Framework"
            }
            Write-Verbose -Verbose "SearchString: $SearchString"
            #=================================================
            #	Go
            #=================================================
            $CatalogUpdate = Get-MSCatalogUpdate -Search $SearchString -Architecture $Arch |`
            Sort-Object LastUpdated -Descending |`
            Select-Object LastUpdated,Classification,Title,Size,Products,Guid
            #=================================================
            #	Exclude
            #=================================================
            $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'arm64'}
            #=================================================
            #	OperatingSystem
            #=================================================
            if ($OS -eq 'Windows 10') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -match 'Windows 10'}
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Products -notmatch 'Windows Server'}
            }
            if ($OS -eq 'Windows Server') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Products -eq 'Windows Server, version 1903 and later'}
            }
            if ($OS -eq 'Windows Server 2016') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Products -eq 'Windows Server 2016'}
            }
            if ($OS -eq 'Windows Server 2019') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Products -eq 'Windows Server 2019'}
            }
            #=================================================
            #	Category
            #=================================================
            if ($Category -eq 'SSU') {
                #Do nothing
            }
            if ($Category -eq 'LCU') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch '.NET'}
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'Dynamic Cumulative Update'}
            }
            if ($Category -eq 'DotNetCU') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -match "Framework"}
            }
            if ($Insider) {
                Write-Verbose -Verbose "Insider and Preview Updates: True"
            }
            else {
                Write-Verbose -Verbose "Insider and Preview Updates: False"
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'Preview'}
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Products -notmatch 'Insider'}
            }
            #=================================================
            #	ListAvailable
            #=================================================
            if ($ListAvailable) {
                #Do Nothing
            }
            else {
                $CatalogUpdate = $CatalogUpdate | Select-Object -First 1
            }
            #=================================================
            Write-Output $CatalogUpdate
            #=================================================
        }
        else {
            Write-Warning "Save-MsUpCatUpdate: Could not install required PowerShell Module MSCatalogLTS"
        }
    }
    else {
        Write-Warning "Save-MsUpCatUpdate: Could not reach https://www.catalog.update.microsoft.com/"
    }
    #=================================================
}

function Invoke-MSCatalogParseDate {
    param (
        [String] $DateString
    )

    $Array = $DateString.Split("/")
    Get-Date -Year $Array[2] -Month $Array[0] -Day $Array[1]
}

function Save-MsUpCatDriver {
    [CmdLetBinding(DefaultParameterSetName = 'ByPNPClass')]
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
    #	MSCatalogLTS PowerShell Module
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if (!(Get-Module -ListAvailable -Name MSCatalogLTS)) {
        Install-Module MSCatalogLTS -Force -SkipPublisherCheck -ErrorAction Ignore
    }
    #=================================================
    #$HardwareIDPattern = 'VEN_([0-9a-f]){4}&DEV_([0-9a-f]){4}&SUBSYS_([0-9a-f]){8}'
    $HardwareIDPattern = 'v[ei][dn]_([0-9a-f]){4}&[pd][ie][dv]_([0-9a-f]){4}'
    $SurfaceIDPattern = 'mshw0[0-1]([0-9]){2}'

    if (Test-MicrosoftUpdateCatalog) {
        if (Get-Module -ListAvailable -Name MSCatalogLTS -ErrorAction Ignore) {
            Import-Module MSCatalogLTS -Force
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
                        Write-Verbose "Devices were found for PNPClass $PNPClass"
                    }
                    
                    foreach ($Item in $Devices) {
                        $FindHardwareID = $null
        
                        #See if DeviceID matches the pattern
                        # Write-Host -ForegroundColor DarkGray "DeviceID: $($Item.DeviceID)"
                        $FindHardwareID = $Item.DeviceID | Select-String -Pattern $HardwareIDPattern -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value

                        if (-not ($FindHardwareID)) {
                            if ($Item.HardwareID) {
                                Write-Verbose "HardwareID: $($Item.HardwareID[0])"
                                $FindHardwareID = $Item.HardwareID[0] | Select-String -Pattern $HardwareIDPattern -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
                            }
                        }

                        if ($FindHardwareID) {
                            # Write-Verbose "Searching: $FindHardwareID"
                            $SearchString = "$FindHardwareID".Replace('&',"`%26")
                            try {
                                # Try multiple Windows versions for driver search
                                $WindowsUpdateDriver = $null
                                
                                # Try Windows 11 24H2 first
                                $WindowsUpdateDriver = Get-MSCatalogUpdate -Search "24H2+$PNPClass+$SearchString" -Architecture x64 | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                                
                                if (-not ($WindowsUpdateDriver)) {
                                    $WindowsUpdateDriver = Get-MSCatalogUpdate -Search "23H2+$PNPClass+$SearchString" -Architecture x64 | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                                }
                                if (-not ($WindowsUpdateDriver)) {
                                    $WindowsUpdateDriver = Get-MSCatalogUpdate -Search "22H2+$PNPClass+$SearchString" -Architecture x64 | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                                }
                                if (-not ($WindowsUpdateDriver)) {
                                    $WindowsUpdateDriver = Get-MSCatalogUpdate -Search "21H2+$PNPClass+$SearchString" -Architecture x64 | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                                }
                                if (-not ($WindowsUpdateDriver)) {
                                    $WindowsUpdateDriver = Get-MSCatalogUpdate -Search "Vibranium+$PNPClass+$SearchString" -Architecture x64 | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                                }
                                if (-not ($WindowsUpdateDriver)) {
                                    $WindowsUpdateDriver = Get-MSCatalogUpdate -Search "1903+$PNPClass+$SearchString" -Architecture x64 | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                                }
                                if (-not ($WindowsUpdateDriver)) {
                                    $WindowsUpdateDriver = Get-MSCatalogUpdate -Search "1809+$PNPClass+$SearchString" -Architecture x64 | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
                                }
                                if (-not ($WindowsUpdateDriver)) {
                                    $WindowsUpdateDriver = Get-MSCatalogUpdate -Search "$SearchString" -Architecture x64 | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
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
                                            try {
                                                # Создаем временную папку для скачивания
                                                $TempDownloadPath = Join-Path $env:TEMP "MSCatalogDownload"
                                                if (!(Test-Path $TempDownloadPath)) {
                                                    New-Item -Path $TempDownloadPath -ItemType Directory -Force | Out-Null
                                                }
                                                
                                                # Скачиваем файл
                                                $WindowsUpdateDriverFile = Save-MSCatalogUpdate -Guid $WindowsUpdateDriver.Guid -Destination $TempDownloadPath
                                                Write-Verbose "Download result: $WindowsUpdateDriverFile"
                                                
                                                if ($WindowsUpdateDriverFile -and $WindowsUpdateDriverFile -ne "") {
                                                    # Проверяем результат скачивания
                                                    if ($WindowsUpdateDriverFile -and $WindowsUpdateDriverFile -ne "") {
                                                        Write-Verbose "Download successful, file: $WindowsUpdateDriverFile"
                                                        
                                                        # Проверяем, что файл существует
                                                        if (Test-Path $WindowsUpdateDriverFile) {
                                                            Write-Verbose "File exists, expanding to $DestinationPath"
                                                            expand.exe "$WindowsUpdateDriverFile" -F:* "$DestinationPath" | Out-Null
                                                            Remove-Item $WindowsUpdateDriverFile -Force
                                                            Write-Host -ForegroundColor Green "Driver successfully downloaded and expanded to $DestinationPath"
                                                        }
                                                        else {
                                                            Write-Warning "Downloaded file not found at: $WindowsUpdateDriverFile"
                                                        }
                                                    }
                                                    else {
                                                        Write-Warning "Save-MSCatalogUpdate returned empty result"
                                                        
                                                        # Альтернативный способ - ищем файл в временной папке
                                                        Write-Verbose "Trying alternative method - searching for MSU file in $TempDownloadPath"
                                                        $MsuFile = Get-ChildItem -Path $TempDownloadPath -Filter "*.msu" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                                                        
                                                        if ($MsuFile) {
                                                            Write-Verbose "Found MSU file: $($MsuFile.FullName)"
                                                            expand.exe "$($MsuFile.FullName)" -F:* "$DestinationPath" | Out-Null
                                                            Remove-Item $MsuFile.FullName -Force
                                                            Write-Host -ForegroundColor Green "Driver successfully downloaded and expanded to $DestinationPath (alternative method)"
                                                        }
                                                        else {
                                                            Write-Warning "Save-MsUpCatDriver: Could not download driver file using any method"
                                                        }
                                                    }
                                                }
                                                else {
                                                    Write-Warning "Save-MsUpCatDriver: Could not download driver file"
                                                }
                                            }
                                            catch {
                                                Write-Warning "Save-MsUpCatDriver: Error downloading driver - $($_.Exception.Message)"
                                                Write-Verbose "Exception details: $($_.Exception.ToString())"
                                            }
                                        }
                                    }
                                }
                                else {
                                    Write-Host -ForegroundColor Gray "No Results: $($Item.Name) $FindHardwareID"
                                }
                            }
                            catch{
                                Write-Host -ForegroundColor Gray "Unable to get Driver for Hardware component"
                            }   
                        }
                        else {
                            Write-Verbose "DeviceID: $($Item.DeviceID)"
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
                            # Try multiple Windows versions for driver search
                            Write-Verbose "Save-MsUpCatDriver Search: 24H2 $SearchString"
                            $SearchResults = Get-MSCatalogUpdate -Search "24H2 $SearchString" -ErrorAction Ignore
                            Write-Verbose "Search Results Count: $($SearchResults.Count)"
                            if ($SearchResults -and $SearchResults.Count -gt 0) {
                                $WindowsUpdateDriver = $SearchResults | Select-Object LastUpdated, Title, Version, Size, Guid -First 1
                                Write-Verbose "Found driver: $($WindowsUpdateDriver.Title)"
                            }
                        }
                        catch {
                            Write-Verbose "Error searching for 24H2: $($_.Exception.Message)"
                        }
                        
                        if (-not ($WindowsUpdateDriver)) {
                            try {
                                Write-Verbose "Save-MsUpCatDriver Search: 23H2 $SearchString"
                                $SearchResults = Get-MSCatalogUpdate -Search "23H2 $SearchString" -ErrorAction Ignore
                                Write-Verbose "Search Results Count: $($SearchResults.Count)"
                                if ($SearchResults -and $SearchResults.Count -gt 0) {
                                    $WindowsUpdateDriver = $SearchResults | Select-Object LastUpdated, Title, Version, Size, Guid -First 1
                                    Write-Verbose "Found driver: $($WindowsUpdateDriver.Title)"
                                }
                            }
                            catch {
                                Write-Verbose "Error searching for 23H2: $($_.Exception.Message)"
                            }
                        }
                        
                        if (-not ($WindowsUpdateDriver)) {
                            try {
                                Write-Verbose "Save-MsUpCatDriver Search: 22H2 $SearchString"
                                $SearchResults = Get-MSCatalogUpdate -Search "22H2 $SearchString" -ErrorAction Ignore
                                Write-Verbose "Search Results Count: $($SearchResults.Count)"
                                if ($SearchResults -and $SearchResults.Count -gt 0) {
                                    $WindowsUpdateDriver = $SearchResults | Select-Object LastUpdated, Title, Version, Size, Guid -First 1
                                    Write-Verbose "Found driver: $($WindowsUpdateDriver.Title)"
                                }
                            }
                            catch {
                                Write-Verbose "Error searching for 22H2: $($_.Exception.Message)"
                            }
                        }
                        
                        if (-not ($WindowsUpdateDriver)) {
                            try {
                                Write-Verbose "Save-MsUpCatDriver Search: 21H2 $SearchString"
                                $SearchResults = Get-MSCatalogUpdate -Search "21H2 $SearchString" -ErrorAction Ignore
                                Write-Verbose "Search Results Count: $($SearchResults.Count)"
                                if ($SearchResults -and $SearchResults.Count -gt 0) {
                                    $WindowsUpdateDriver = $SearchResults | Select-Object LastUpdated, Title, Version, Size, Guid -First 1
                                    Write-Verbose "Found driver: $($WindowsUpdateDriver.Title)"
                                }
                            }
                            catch {
                                Write-Verbose "Error searching for 21H2: $($_.Exception.Message)"
                            }
                        }
                        
                        if (-not ($WindowsUpdateDriver)) {
                            try {
                                Write-Verbose "Save-MsUpCatDriver Search: Vibranium $SearchString"
                                $SearchResults = Get-MSCatalogUpdate -Search "Vibranium $SearchString" -ErrorAction Ignore
                                Write-Verbose "Search Results Count: $($SearchResults.Count)"
                                if ($SearchResults -and $SearchResults.Count -gt 0) {
                                    $WindowsUpdateDriver = $SearchResults | Select-Object LastUpdated, Title, Version, Size, Guid -First 1
                                    Write-Verbose "Found driver: $($WindowsUpdateDriver.Title)"
                                }
                            }
                            catch {
                                Write-Verbose "Error searching for Vibranium: $($_.Exception.Message)"
                            }
                        }
                        
                        if (-not ($WindowsUpdateDriver)) {
                            try {
                                Write-Verbose "Save-MsUpCatDriver Search: 1903 $SearchString"
                                $SearchResults = Get-MSCatalogUpdate -Search "1903 $SearchString" -ErrorAction Ignore
                                Write-Verbose "Search Results Count: $($SearchResults.Count)"
                                if ($SearchResults -and $SearchResults.Count -gt 0) {
                                    $WindowsUpdateDriver = $SearchResults | Select-Object LastUpdated, Title, Version, Size, Guid -First 1
                                    Write-Verbose "Found driver: $($WindowsUpdateDriver.Title)"
                                }
                            }
                            catch {
                                Write-Verbose "Error searching for 1903: $($_.Exception.Message)"
                            }
                        }
                        
                        if (-not ($WindowsUpdateDriver)) {
                            try {
                                Write-Verbose "Save-MsUpCatDriver Search: 1809 $SearchString"
                                $SearchResults = Get-MSCatalogUpdate -Search "1809 $SearchString" -ErrorAction Ignore
                                Write-Verbose "Search Results Count: $($SearchResults.Count)"
                                if ($SearchResults -and $SearchResults.Count -gt 0) {
                                    $WindowsUpdateDriver = $SearchResults | Select-Object LastUpdated, Title, Version, Size, Guid -First 1
                                    Write-Verbose "Found driver: $($WindowsUpdateDriver.Title)"
                                }
                            }
                            catch {
                                Write-Verbose "Error searching for 1809: $($_.Exception.Message)"
                            }
                        }
                        
                        if (-not ($WindowsUpdateDriver)) {
                            try {
                                Write-Verbose "Save-MsUpCatDriver Search: $SearchString"
                                $SearchResults = Get-MSCatalogUpdate -Search "$SearchString" -ErrorAction Ignore
                                Write-Verbose "Search Results Count: $($SearchResults.Count)"
                                if ($SearchResults -and $SearchResults.Count -gt 0) {
                                    $WindowsUpdateDriver = $SearchResults | Select-Object LastUpdated, Title, Version, Size, Guid -First 1
                                    Write-Verbose "Found driver: $($WindowsUpdateDriver.Title)"
                                }
                            }
                            catch {
                                Write-Verbose "Error searching for generic: $($_.Exception.Message)"
                            }
                        }

                        if ($WindowsUpdateDriver -and $WindowsUpdateDriver.Guid) {
                            Write-Host -ForegroundColor Cyan "$Item $($WindowsUpdateDriver.Title)"
                            Write-Host -ForegroundColor DarkGray "UpdateID: $($WindowsUpdateDriver.Guid)"
                            Write-Host -ForegroundColor DarkGray "Size: $($WindowsUpdateDriver.Size) Last Updated $($WindowsUpdateDriver.LastUpdated)"

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
                                    try {
                                        # Создаем папку назначения
                                        if (!(Test-Path $DestinationPath)) {
                                            New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null
                                        }
                                        
                                        # Создаем временную папку для скачивания
                                        $TempDownloadPath = Join-Path $env:TEMP "MSCatalogDownload"
                                        if (!(Test-Path $TempDownloadPath)) {
                                            New-Item -Path $TempDownloadPath -ItemType Directory -Force | Out-Null
                                        }
                                        
                                        # Скачиваем файл с указанием папки назначения
                                        Write-Verbose "Attempting to download GUID: $($WindowsUpdateDriver.Guid) to $TempDownloadPath"
                                        $null = Save-MSCatalogUpdate -Guid $WindowsUpdateDriver.Guid -Destination $TempDownloadPath
                                        Write-Verbose "Download completed"
                                        
                                        # Ищем скачанный файл в временной папке
                                        Write-Verbose "Searching for downloaded MSU file in $TempDownloadPath"
                                        $MsuFile = Get-ChildItem -Path $TempDownloadPath -Filter "*.msu" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                                        
                                        if ($MsuFile) {
                                            Write-Verbose "Found MSU file: $($MsuFile.FullName)"
                                            
                                            # Проверяем, что файл существует
                                            if (Test-Path $MsuFile.FullName) {
                                                Write-Verbose "File exists, expanding to $DestinationPath"
                                                expand.exe "$($MsuFile.FullName)" -F:* "$DestinationPath" | Out-Null
                                                Remove-Item $MsuFile.FullName -Force
                                                Write-Host -ForegroundColor Green "Driver successfully downloaded and expanded to $DestinationPath"
                                            }
                                            else {
                                                Write-Warning "Downloaded file not found at: $($MsuFile.FullName)"
                                            }
                                        }
                                        else {
                                            Write-Warning "Save-MsUpCatDriver: Could not find downloaded MSU file in $TempDownloadPath"
                                            
                                            # Альтернативный способ - ищем в корне TEMP
                                            Write-Verbose "Trying alternative method - searching for MSU file in $env:TEMP"
                                            $MsuFile = Get-ChildItem -Path $env:TEMP -Filter "*.msu" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                                            
                                            if ($MsuFile) {
                                                Write-Verbose "Found MSU file in TEMP: $($MsuFile.FullName)"
                                                expand.exe "$($MsuFile.FullName)" -F:* "$DestinationPath" | Out-Null
                                                Remove-Item $MsuFile.FullName -Force
                                                Write-Host -ForegroundColor Green "Driver successfully downloaded and expanded to $DestinationPath (alternative method)"
                                            }
                                            else {
                                                Write-Warning "Save-MsUpCatDriver: Could not download driver file using any method"
                                            }
                                        }
                                    }
                                    catch {
                                        Write-Warning "Save-MsUpCatDriver: Error downloading driver - $($_.Exception.Message)"
                                        Write-Verbose "Exception details: $($_.Exception.ToString())"
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
        else {
            Write-Warning "Save-MsUpCatDriver: Could not install required PowerShell Module MSCatalogLTS"
        }
    }
}

function Save-MsUpCatUpdate {
    [CmdLetBinding()]
    param (
        [ValidateSet('Windows 11','Windows 10','Windows Server','Windows Server 2016','Windows Server 2019')]
        [Alias('OperatingSystem')]
        [string]$OS = 'Windows 11',

        [ValidateSet('x64','x86')]
        [Alias('Architecture')]
        [string]$Arch = 'x64',

        [ValidateSet('24H2','23H2','22H2','21H2','21H1','20H2',2004,1909,1903,1809,1803,1709,1703,1607,1511,1507)]
        [string]$Build = '22H2',

        [ValidateSet('LCU','SSU','DotNetCU')]
        [string]$Category = 'LCU',

        [ValidateSet('Preview')]
        [string[]]$Include,

        [string]$DestinationDirectory = "$env:TEMP\MsUpCat",

        [System.Management.Automation.SwitchParameter]$Latest
    )
    #=================================================
    #	MSCatalogLTS PowerShell Module
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if (!(Get-Module -ListAvailable -Name MSCatalogLTS)) {
        Install-Module MSCatalogLTS -Force -SkipPublisherCheck
    }
    #=================================================
    #	Make sure the Module was installed first
    #=================================================
    if (Test-MicrosoftUpdateCatalog) {
        if (Get-Module -ListAvailable -Name MSCatalogLTS -ErrorAction Ignore) {
            Import-Module MSCatalogLTS -Force
            #=================================================
            #	Details
            #=================================================
            Write-Verbose -Verbose "OperatingSystem: $OS"
            Write-Verbose -Verbose "Architecture: $Arch"
            Write-Verbose -Verbose "Category: $Category"
            #=================================================
            #	Category
            #=================================================
            if ($Category -eq 'LCU') {
                $SearchString = "Cumulative Update $OS"
            }
            if ($Category -eq 'SSU') {
                $SearchString = "Servicing Stack Update $OS"
            }
            if ($Category -eq 'DotNetCU') {
                $SearchString = "Framework $OS"
            }
            if ($OS -eq 'Windows 10') {
                Write-Verbose -Verbose "Build: $Build"
                $SearchString = "$SearchString $Build $Arch"
            }
            elseif ($OS -eq 'Windows Server') {
                Write-Verbose -Verbose "Build: $Build"
                $SearchString = "$SearchString $Build $Arch"
            }
            else {
                $SearchString = "$SearchString $Arch"
            }
            #=================================================
            #	Go
            #=================================================
            $CatalogUpdate = Get-MSCatalogUpdate -Search $SearchString -Architecture $Arch |`
            Sort-Object LastUpdated -Descending |`
            Select-Object LastUpdated,Classification,Title,Size,Products,Guid
            #=================================================
            #	Exclude
            #=================================================
            $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'arm64'}
            $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'Dynamic'}
            #=================================================
            #	OperatingSystem
            #=================================================
            if ($OS -eq 'Windows 10') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -match 'Windows 10'}
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Products -notmatch 'Windows Server'}
                if ($Category -eq 'LCU') {
                    #$CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -match "Cumulative Update for Windows 10 Version $Build"}
                }
                if ($Category -eq 'SSU') {
                    #$CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -match "Servicing Stack Update for Windows 10 Version $Build"}
                }
            }
            if ($OS -eq 'Windows Server') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Products -eq 'Windows Server, version 1903 and later'}
            }
            if ($OS -eq 'Windows Server 2016') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Products -eq 'Windows Server 2016'}
            }
            if ($OS -eq 'Windows Server 2019') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Products -eq 'Windows Server 2019'}
            }
            #=================================================
            #	Category
            #=================================================
            if ($Category -eq 'LCU') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch '.NET'}
            }
            if ($Category -eq 'DotNetCU') {
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -match "Framework"}
            }
            if ($Include -contains 'Preview') {
                Write-Verbose -Verbose "Include Preview Updates: True"
            }
            else {
                Write-Verbose -Verbose "Include Preview Updates: False"
                $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'Preview'}
            }
            $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Products -notmatch 'Insider'}
            #=================================================
            #	Select
            #=================================================
            if ($Latest.IsPresent) {
                $CatalogUpdate = $CatalogUpdate | Select-Object -First 1
            }
            else {
                $CatalogUpdate = $CatalogUpdate | Out-GridView -Title 'Select a Microsoft Update to download' -PassThru
            }
            #=================================================
            #	Download
            #=================================================
            foreach ($Update in $CatalogUpdate) {
                Save-MSCatalogUpdate -Guid $Update.Guid
            }
            #=================================================
        }
        else {
            Write-Warning "Save-MsUpCatUpdate: Could not install required PowerShell Module MSCatalogLTS"
        }
    }
    else {
        Write-Warning "Save-MsUpCatUpdate: Could not reach https://www.catalog.update.microsoft.com/"
    }
    #=================================================
}
