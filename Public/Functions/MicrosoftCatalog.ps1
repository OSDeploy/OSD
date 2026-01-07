function Get-MsUpCat {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    #[OutputType([MSCatalogUpdate[]])]
    #[OutputType([MsUpCat[]])]
    param (
        #region Parameters
        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates by architecture")]
        [ValidateSet("All", "x64", "x86", "arm64")]
        [string] $Architecture = "All",
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Sort in descending order")]
        [switch] $Descending,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Exclude .NET Framework updates")]
        [switch] $ExcludeFramework,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates from this date")]
        [DateTime] $FromDate,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Format for the results")]
        [ValidateSet("Default", "CSV", "JSON", "XML")]
        [string] $Format = "Default",
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Only show .NET Framework updates")]
        [switch] $GetFramework,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Search through all available pages")]
        [switch] $AllPages,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Include dynamic updates")]
        [switch] $IncludeDynamic,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Include file names in the results")]
        [switch] $IncludeFileNames,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Include preview updates")]
        [switch] $IncludePreview,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates from the last N days")]
        [int] $LastDays,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates with maximum size")]
        [double] $MaxSize,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates with minimum size")]
        [double] $MinSize,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'OS',
            HelpMessage = "Operating System to search updates for")]
        [ValidateSet("Windows 11", "Windows 10", "Windows Server")]
        [string] $OperatingSystem,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Select specific properties to display")]
        [string[]] $Properties,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Search',
            Position = 0,
            HelpMessage = "Search query for Microsoft Update Catalog")]
        [string] $Search,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Unit for size filtering (MB or GB)")]
        [ValidateSet("MB", "GB")]
        [string] $SizeUnit = "MB",
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Sort results by specified field")]
        [ValidateSet("Date", "Size", "Title", "Classification", "Product")]
        [string] $SortBy = "Date",
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Use strict search with exact phrase matching")]
        [switch] $Strict,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates until this date")]
        [DateTime] $ToDate,
        
        [Parameter(Mandatory = $false,
            HelpMessage = "Filter by update type")]
        [ValidateSet(
            "Security Updates", 
            "Updates", 
            "Critical Updates", 
            "Feature Packs", 
            "Service Packs", 
            "Tools", 
            "Update Rollups",
            "Cumulative Updates",
            "Security Quality Updates",
            "Driver Updates"
        )]
        [string[]] $UpdateType,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'OS',
            HelpMessage = "OS Version/Release (e.g., 22H2, 21H2, 23H2)")]
        [string] $Version
        #endregion Parameters
    )

    begin {
        #region Initialization
        # Ensure MSCatalogUpdate class is available
        if (-not ('MsUpCat' -as [type])) {
            $classPath = Join-Path $PSScriptRoot '..\Classes\MsUpCat.Class.ps1'
            if (Test-Path $classPath) {
                . $classPath
            }
            else {
                throw "MsUpCat class file not found at: $classPath"
            }
        }

        $ProgressPreference = "SilentlyContinue"
        $Updates = @()
        $MaxResults = 1000
        #endregion Initialization

        #region Query Building
        # Build search query based on parameters
        $searchQuery = if ($PSCmdlet.ParameterSetName -eq 'OS') {
            switch ($OperatingSystem) {
                "Windows 10" {
                    if ($Version) {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Windows 10 Version $Version"
                        }
                        else {
                            "Windows 10 Version $Version"
                        }
                    }
                    else {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Windows 10"
                        }
                        else {
                            "Windows 10"
                        }
                    }
                }
                "Windows 11" {
                    if ($Version) {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Windows 11 Version $Version"
                        }
                        else {
                            "Windows 11 Version $Version"
                        }
                    }
                    else {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Windows 11"
                        }
                        else {
                            "Windows 11"
                        }
                    }
                }
                "Windows Server" {
                    if ($Version) {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Microsoft Server Operating System, Version $Version"
                        }
                        else {
                            "Microsoft Server Operating System, Version $Version"
                        }
                    }
                    else {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Microsoft Server Operating System"
                        }
                        else {
                            "Microsoft Server Operating System"
                        }
                    }
                }
                default {
                    if ($Version) {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for $OperatingSystem $Version"
                        }
                        else {
                            "$OperatingSystem $Version"
                        }
                    }
                    else {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for $OperatingSystem"
                        }
                        else {
                            "$OperatingSystem"
                        }
                    }
                }
            }
        }
        else {
            $Search
        }

        Write-Verbose "Search query: $searchQuery"
        #endregion Query Building
    }

    process {
        try {
            #region Search Preparation
            # Prepare search query
            $EncodedSearch = switch ($true) {
                $Strict { [uri]::EscapeDataString('"' + $searchQuery + '"') }
                $GetFramework { [uri]::EscapeDataString("*$searchQuery*") }
                default { [uri]::EscapeDataString($searchQuery) }
            }
    
            # Initialize catalog request
            $Uri = "https://www.catalog.update.microsoft.com/Search.aspx?q=$EncodedSearch"
            $Res = Invoke-CatalogRequest -Uri $Uri
            
            $Rows = $Res.Rows
            #endregion Search Preparation

            #region Pagination
            # Handle pagination
            if ($AllPages) {
                $PageCount = 0
                while ($Res.NextPage -and $PageCount -lt 39) {
                    # Microsoft Catalog limit is 40 pages
                    $PageCount++
                    $PageUri = "$Uri&p=$PageCount"
                    $Res = Invoke-CatalogRequest -Uri $PageUri
                    $Rows += $Res.Rows
                }
            } 
            #endregion Pagination

            #region Base Filtering
            # Apply base filters with improved logic
            $Rows = $Rows.Where({
                    $title = $_.SelectNodes("td")[1].InnerText.Trim()
                    $classification = $_.SelectNodes("td")[3].InnerText.Trim()
                    $include = $true
            
                
                    # Basic exclusion filters
                    if (-not $IncludeDynamic -and $title -like "*Dynamic*") { $include = $false }
                    if (-not $IncludePreview -and $title -like "*Preview*") { $include = $false }

                    # Framework filtering: handle GetFramework and ExcludeFramework parameters
                    if ($GetFramework) {
                        # If GetFramework is specified, only keep Framework updates
                        if (-not ($title -like "*Framework*")) { $include = $false }
                    }
                    elseif ($ExcludeFramework) {
                        # If ExcludeFramework is specified, exclude Framework updates
                        if ($title -like "*Framework*") { $include = $false }
                    }

                    # OS and Version specific filtering
                    if ($PSCmdlet.ParameterSetName -eq 'OS') {
                        if ($OperatingSystem -eq "Windows Server") {
                            # For Server, look for "Microsoft server" or similar patterns
                            if (-not ($title -like "*Microsoft*Server*" -or $title -like "*Server Operating System*")) { $include = $false }
                        }
                        else {
                            # For other OS types, use the standard pattern
                            if (-not ($title -like "*$OperatingSystem*")) { $include = $false }
                        }
                        if ($Version -and -not ($title -like "*$Version*")) { $include = $false }
                    }

                    # Update type filtering
                    if ($UpdateType) {
                        $hasMatchingType = $false
                        foreach ($type in $UpdateType) {
                            switch ($type) {
                                "Security Updates" {
                                    # In the Classification column
                                    if ($classification -eq "Security Updates") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Cumulative Updates" {
                                    # In the title, look for "Cumulative Update"
                                    if ($title -like "*Cumulative Update*") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Critical Updates" {
                                    # In the Classification column
                                    if ($classification -eq "Critical Updates") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Updates" {
                                    # In the Classification column
                                    if ($classification -eq "Updates") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Feature Packs" {
                                    # In the Classification column
                                    if ($classification -eq "Feature Packs") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Service Packs" {
                                    # In the Classification column
                                    if ($classification -eq "Service Packs") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Tools" {
                                    # In the Classification column
                                    if ($classification -eq "Tools") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Update Rollups" {
                                    # In the Classification column
                                    if ($classification -eq "Update Rollups") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Security Quality Updates" {
                                    # Combines security and quality
                                    if (($classification -eq "Security Updates") -and 
                                        ($title -like "*Quality Update*")) {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Driver Updates" {
                                    # For drivers
                                    if ($title -like "*Driver*") {
                                        $hasMatchingType = $true
                                    }
                                }
                                default {
                                    if ($title -like "*$type*") {
                                        $hasMatchingType = $true
                                    }
                                }
                            }
                            if ($hasMatchingType) { break }
                        }
                        if (-not $hasMatchingType) { $include = $false }
                    }
                
                    $include
                })
            #endregion Base Filtering

            #region Architecture Filtering
            # Apply architecture filter with improved logic
            if ($Architecture -ne "all") {
                $Rows = $Rows.Where({
                        $title = $_.SelectNodes("td")[1].InnerText.Trim()
                        switch ($Architecture) {
                            "x64" { $title -match "x64|64.?bit|64.?based" -and -not ($title -match "x86|32.?bit|arm64") }
                            "x86" { $title -match "x86|32.?bit|32.?based" -and -not ($title -match "64.?bit|arm64") }
                            "arm64" { $title -match "arm64|ARM.?based" }
                        }
                    })
            }
            #endregion Architecture Filtering

            #region Create Update Objects
            # Create MSCatalogUpdate objects with improved error handling
            $Updates = $Rows.Where({ $_.Id -ne "headerRow" }).ForEach({
                    try {
                        [MsUpCat]::new($_, $IncludeFileNames)
                    }
                    catch {
                        Write-Warning "Failed to process update: $($_.Exception.Message)"
                        $null
                    }
                }) | Where-Object { $null -ne $_ }
            #endregion Create Update Objects

            #region Apply Filters
            # Apply date filters
            if ($FromDate) { $Updates = $Updates.Where({ $_.LastUpdated -ge $FromDate }) }
            if ($ToDate) { $Updates = $Updates.Where({ $_.LastUpdated -le $ToDate }) }
            if ($LastDays) {
                $CutoffDate = (Get-Date).AddDays(-$LastDays)
                $Updates = $Updates.Where({ $_.LastUpdated -ge $CutoffDate })
            }

            # Apply size filters
            if ($MinSize -or $MaxSize) {
                $Multiplier = if ($SizeUnit -eq "GB") { 1024 } else { 1 }
                $Updates = $Updates.Where({
                        $size = [double]($_.Size -replace ' MB$', '')
                        $meetsMin = -not $MinSize -or $size -ge ($MinSize * $Multiplier)
                        $meetsMax = -not $MaxSize -or $size -le ($MaxSize * $Multiplier)
                        $meetsMin -and $meetsMax
                    })
            }
            #endregion Apply Filters

            #region Sorting and Output
            # Apply sorting
            $Updates = switch ($SortBy) {
                "Date" { $Updates | Sort-Object LastUpdated -Descending:$Descending }
                "Size" { $Updates | Sort-Object { [double]($_.Size -replace ' MB$', '') } -Descending:$Descending }
                "Title" { $Updates | Sort-Object Title -Descending:$Descending }
                "Classification" { $Updates | Sort-Object Classification -Descending:$Descending }
                "Product" { $Updates | Sort-Object Products -Descending:$Descending }
                default { $Updates }
            }

            # Display result summary but Silent if $Update variable or piped is used Fixes#23
            $IsUpdate = ($MyInvocation.Line -match '^\s*\$update\s*=')
            $IsPiped = ($PSCmdlet.MyInvocation.PipelineLength -gt 1)

            if (-not $IsUpdate -and -not $IsPiped) {
                Write-Host "`nSearch completed for: $searchQuery"
                Write-Host "Found $($Updates.Count) updates"
            }

            if ($Updates.Count -ge $MaxResults) {
                Write-Warning "Result limit of $MaxResults reached. Please refine your search criteria."
            }

            # Format and return results
            switch ($Format) {
                "Default" { 
                    if ($Properties) { $Updates | Select-Object $Properties }
                    else { $Updates }
                }
                "CSV" { 
                    if ($Properties) { $Updates | Select-Object $Properties | ConvertTo-Csv -NoTypeInformation }
                    else { $Updates | ConvertTo-Csv -NoTypeInformation }
                }
                "JSON" { 
                    if ($Properties) { $Updates | Select-Object $Properties | ConvertTo-Json }
                    else { $Updates | ConvertTo-Json }
                }
                "XML" { 
                    if ($Properties) { $Updates | Select-Object $Properties | ConvertTo-Xml -As String }
                    else { $Updates | ConvertTo-Xml -As String }
                }
            }
            #endregion Sorting and Output
        }
        catch {
            Write-Warning "Error processing search request: $($_.Exception.Message)"
        }
    }

    end {
        $ProgressPreference = "Continue"
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

        [ValidateSet('22H2','21H2','21H1','20H2',2004,1909,1903,1809,1803,1709,1703,1607,1511,1507)]
        [string]$Build = '22H2',

        [ValidateSet('LCU','SSU','DotNetCU')]
        [string]$Category = 'LCU',

        [System.Management.Automation.SwitchParameter]$Insider,

        [System.Management.Automation.SwitchParameter]$ListAvailable
    )
    #=================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -SkipPublisherCheck
    }
    #=================================================
    #	Make sure the Module was installed first
    #=================================================
    if (Test-MicrosoftUpdateCatalog) {
        if (Get-Module -ListAvailable -Name MSCatalog -ErrorAction Ignore) {
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
            $CatalogUpdate = Get-MSCatalogUpdate -Search $SearchString -SortBy "Title" -AllPages -Descending |`
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
            Write-Host -ForegroundColor DarkGray "Save-MsUpCatUpdate: Could not install required PowerShell Module MSCatalog"
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "Save-MsUpCatUpdate: Could not reach https://www.catalog.update.microsoft.com/"
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
        Write-Host -ForegroundColor DarkGray 'Set the DestinationDirectory parameter to download the Drivers'
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
                                            Write-Host -ForegroundColor DarkGray "Save-MsUpCatDriver: Could not find a Driver for this HardwareID"
                                        }
                                    }
                                }
                            }
                            else {
                                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No Results: $($Item.Name) $FindHardwareID"
                                #Write-Host -ForegroundColor DarkGray "HardwareID: $FindHardwareID"
                                #Write-Host -ForegroundColor DarkGray "SearchString: $SearchString"
                                #Write-Host -ForegroundColor DarkGray "Save-MsUpCatDriver: Could not find a Windows Update GUID"
                            }
                        }
                        catch{
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Unable to get Driver for Hardware component"
                        }   
                    }
                    else {
                        Write-Verbose "DeviceID: $($Item.DeviceID)"
                        #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No Results: $FindHardwareID"
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
                                    Write-Host -ForegroundColor DarkGray "Save-MsUpCatDriver: Could not find a Driver for this HardwareID"
                                }
                            }
                        }
                    }
                    else {
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No Results: $FindHardwareID"
                    }
                }
                else {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No Results: $FindHardwareID"
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
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Transfering $([Math]::Round($MsUpCatDriverCacheSizeGB,2)) GB of MS Update Drivers to $Destination"
                        Invoke-Exe robocopy $Source $Destination *.* /s /ndl /nfl /njh /njs
                    }
                    else {
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Not enough Free Space on OSDCloudUSB to sync drivers"
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Requires $([Math]::Round(($MsUpCatDriverCacheSizeGB + 5),2)) GB, but only $($OSDCloudUSB.SizeRemainingGB) GB available"
                    }
                }
            }
            else {
                # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDCloudUSB not detected to sync drivers back to, skipping sync"
            }
        }
    }
}
function Save-MsUpCatUpdate {
    [CmdLetBinding()]
    param (
        [ValidateSet('Windows 10','Windows Server','Windows Server 2016','Windows Server 2019')]
        [Alias('OperatingSystem')]
        [string]$OS = 'Windows 11',

        [ValidateSet('x64','x86')]
        [Alias('Architecture')]
        [string]$Arch = 'x64',

        [ValidateSet('22H2','21H2','21H1','20H2',2004,1909,1903,1809,1803,1709,1703,1607,1511,1507)]
        [string]$Build = '22H2',

        [ValidateSet('LCU','SSU','DotNetCU')]
        [string]$Category = 'LCU',

        [ValidateSet('Preview')]
        [string[]]$Include,

        [string]$DestinationDirectory = "$env:TEMP\MsUpCat",

        [System.Management.Automation.SwitchParameter]$Latest
    )
    #=================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -SkipPublisherCheck
    }
    #=================================================
    #	Make sure the Module was installed first
    #=================================================
    if (Test-MicrosoftUpdateCatalog) {
        if (Get-Module -ListAvailable -Name MSCatalog -ErrorAction Ignore) {
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
            $CatalogUpdate = Get-MSCatalogUpdate -Search $SearchString -SortBy "Title" -AllPages -Descending |`
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
                Save-UpdateCatalog -Guid $Update.Guid -DestinationDirectory $DestinationDirectory
            }
            #=================================================
        }
        else {
            Write-Host -ForegroundColor DarkGray "Save-MsUpCatUpdate: Could not install required PowerShell Module MSCatalog"
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "Save-MsUpCatUpdate: Could not reach https://www.catalog.update.microsoft.com/"
    }
    #=================================================
}
