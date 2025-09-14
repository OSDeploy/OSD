function Get-MsUpCat {
    <#
        .SYNOPSIS
        Query catalog.update.micrsosoft.com for available updates.

        .DESCRIPTION
        Given that there is currently no public API available for the catalog.update.micrsosoft.com site, this
        command makes HTTP requests to the site and parses the returned HTML for the required data.

        .PARAMETER Search
        Specify a string to search for.

        .PARAMETER SortBy
        Specify a field to sort the results by. The default sort is by LastUpdated and in descending order.

        .PARAMETER Descending
        Switch the sort order to descending.

        .PARAMETER Strict
        Force a Search paramater with multiple words to be treated as a single string.

        .PARAMETER IncludeFileNames
        Include the filenames for the files as they would be downloaded from catalog.update.micrsosoft.com.
        This option will cause an extra web request for each update included in the results. It is best to only
        use this option with a very narrow search term.

        .PARAMETER AllPages
        By default the Get-MSCatalogUpdate command returns the first page of results from catalog.update.micrsosoft.com, which is
        limited to 25 updates. If you specify this switch the command will instead return all pages of search results.
        This can result in a significant increase in the number of HTTP requests to the catalog.update.micrsosoft.com endpoint.

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903"

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -SortBy "Title" -Descending

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -Strict

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -IncludeFileNames

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -AllPages
    #>
    
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Search,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Title", "Products", "Classification", "LastUpdated", "Size")]
        [string] $SortBy,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Descending,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Strict,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $IncludeFileNames,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $AllPages
    )

    try {
        $ProgPref = $ProgressPreference
        $ProgressPreference = "SilentlyContinue"

        $Uri = "https://www.catalog.update.microsoft.com/Search.aspx?q=$Search"
        $Res = Invoke-CatalogRequest -Uri $Uri

        if ($PSBoundParameters.ContainsKey("SortBy")) {
            $SortParams = @{
                Uri = $Uri
                SortBy = $SortBy
                Descending = $Descending
                EventArgument = $Res.EventArgument
                EventValidation = $Res.EventValidation
                ViewState = $Res.ViewState
                ViewStateGenerator = $Res.ViewStateGenerator
            }
            $Res = Sort-CatalogResults @SortParams
        } else {
            # Default sort is by LastUpdated and in descending order.
            $SortParams = @{
                Uri = $Uri
                SortBy = "LastUpdated"
                Descending = $true
                EventArgument = $Res.EventArgument
                EventValidation = $Res.EventValidation
                ViewState = $Res.ViewState
                ViewStateGenerator = $Res.ViewStateGenerator
            }
            $Res = Sort-CatalogResults @SortParams
        }

        $Rows = $Res.Rows

        if ($Strict -and -not $AllPages) {
            $StrictRows = $Rows.Where({
                $_.SelectNodes("td")[1].innerText.Trim() -like "*$Search*"
            })
            # If $NextPage is $null then there are more pages to collect. It is arse backwards but trust me.
            while (($StrictRows.Count -lt 25) -and ($Res.NextPage -eq "")) {
                $NextParams = @{
                    Uri = $Uri
                    EventArgument = $Res.EventArgument
                    EventTarget = 'ctl00$catalogBody$nextPageLinkText'
                    EventValidation = $Res.EventValidation
                    ViewState = $Res.ViewState
                    ViewStateGenerator = $Res.ViewStateGenerator
                    Method = "Post"
                }
                $Res = Invoke-CatalogRequest @NextParams
                $StrictRows += $Res.Rows.Where({
                    $_.SelectNodes("td")[1].innerText.Trim() -like "*$Search*"
                })
            }
            $Rows = $StrictRows[0..24]
        } elseif ($AllPages) {
            # If $NextPage is $null then there are more pages to collect. It is arse backwards but trust me.
            while ($Res.NextPage -eq "") {
                $NextParams = @{
                    Uri = $Uri
                    EventArgument = $Res.EventArgument
                    EventTarget = 'ctl00$catalogBody$nextPageLinkText'
                    EventValidation = $Res.EventValidation
                    ViewState = $Res.ViewState
                    ViewStateGenerator = $Res.ViewStateGenerator
                    Method = "Post"
                }
                $Res = Invoke-CatalogRequest @NextParams
                $Rows += $Res.Rows
            }
            if ($Strict) {
                $Rows = $Rows.Where({
                    $_.SelectNodes("td")[1].innerText.Trim() -like "*$Search*"
                })
            }
        }
        
        if ($Rows.Count -gt 0) {
            foreach ($Row in $Rows) {
                if ($Row.Id -ne "headerRow") {
                    [MsUpCat]::new($Row, $IncludeFileNames)
                }
            }
        } else {
            Write-Host -ForegroundColor DarkGray "No updates found matching the search term."
        }
        $ProgressPreference = $ProgPref
    } catch {
        $ProgressPreference = $ProgPref
        if ($_.Exception.Message -like "We did not find*") {
            #Write-Host -ForegroundColor DarkGray $_.Exception.Message
        } else {
            throw $_
        }
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
