function Get-MsUpCatUpdate {
    [CmdLetBinding()]
    param (
        [ValidateSet('Windows 11','Windows 10','Windows Server','Windows Server 2016','Windows Server 2019')]
        [Alias('OperatingSystem')]
        [string]$OS = 'Windows 10',

        [ValidateSet('x64','x86')]
        [Alias('Architecture')]
        [string]$Arch = 'x64',

        [ValidateSet('21H2','21H1','20H2',2004,1909,1903,1809,1803,1709,1703,1607,1511,1507)]
        [string]$Build = '21H1',

        [ValidateSet('LCU','SSU','DotNetCU')]
        [string]$Category = 'LCU',

        [ValidateSet('Preview')]
        [string[]]$Include,

        [string]$DestinationDirectory = "$env:TEMP\MsUpCat",

        [switch]$Latest
    )
    #=======================================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=======================================================================
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force
    }
    #=======================================================================
    #	Make sure the Module was installed first
    #=======================================================================
    if (Test-WebConnectionMsUpCat) {
        if (Get-Module -ListAvailable -Name MSCatalog -ErrorAction Ignore) {
            #=======================================================================
            #	Details
            #=======================================================================
            Write-Verbose -Verbose "OperatingSystem: $OS"
            Write-Verbose -Verbose "Architecture: $Arch"
            Write-Verbose -Verbose "Category: $Category"
            #=======================================================================
            #	Category
            #=======================================================================
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
            #=======================================================================
            #	Go
            #=======================================================================
            $CatalogUpdate = Get-MSCatalogUpdate -Search $SearchString -SortBy "Title" -AllPages -Descending |`
            Sort-Object LastUpdated -Descending |`
            Select-Object LastUpdated,Classification,Title,Size,Products,Guid
            #=======================================================================
            #	Exclude
            #=======================================================================
            $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'arm64'}
            $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'Dynamic'}
            #=======================================================================
            #	OperatingSystem
            #=======================================================================
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
            #=======================================================================
            #	Category
            #=======================================================================
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
            #=======================================================================
            #	Latest
            #=======================================================================
            if ($Latest.IsPresent) {
                $CatalogUpdate = $CatalogUpdate | Select-Object -First 1
            }
            #=======================================================================
            Write-Output $CatalogUpdate
            #=======================================================================
        }
        else {
            Write-Warning "Save-MsUpCatUpdate: Could not install required PowerShell Module MSCatalog"
        }
    }
    else {
        Write-Warning "Save-MsUpCatUpdate: Could not reach https://www.catalog.update.microsoft.com/"
    }
    #=======================================================================
}
function Save-MsUpCatUpdate {
    [CmdLetBinding()]
    param (
        [ValidateSet('Windows 10','Windows Server','Windows Server 2016','Windows Server 2019')]
        [Alias('OperatingSystem')]
        [string]$OS = 'Windows 10',

        [ValidateSet('x64','x86')]
        [Alias('Architecture')]
        [string]$Arch = 'x64',

        [ValidateSet('21H1','20H2',2004,1909,1903,1809,1803,1709,1703,1607,1511,1507)]
        [string]$Build = '21H1',

        [ValidateSet('LCU','SSU','DotNetCU')]
        [string]$Category = 'LCU',

        [ValidateSet('Preview')]
        [string[]]$Include,

        [string]$DestinationDirectory = "$env:TEMP\MsUpCat",

        [switch]$Latest
    )
    #=======================================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=======================================================================
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force
    }
    #=======================================================================
    #	Make sure the Module was installed first
    #=======================================================================
    if (Test-WebConnectionMsUpCat) {
        if (Get-Module -ListAvailable -Name MSCatalog -ErrorAction Ignore) {
            #=======================================================================
            #	Details
            #=======================================================================
            Write-Verbose -Verbose "OperatingSystem: $OS"
            Write-Verbose -Verbose "Architecture: $Arch"
            Write-Verbose -Verbose "Category: $Category"
            #=======================================================================
            #	Category
            #=======================================================================
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
            #=======================================================================
            #	Go
            #=======================================================================
            $CatalogUpdate = Get-MSCatalogUpdate -Search $SearchString -SortBy "Title" -AllPages -Descending |`
            Sort-Object LastUpdated -Descending |`
            Select-Object LastUpdated,Classification,Title,Size,Products,Guid
            #=======================================================================
            #	Exclude
            #=======================================================================
            $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'arm64'}
            $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'Dynamic'}
            #=======================================================================
            #	OperatingSystem
            #=======================================================================
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
            #=======================================================================
            #	Category
            #=======================================================================
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
            #=======================================================================
            #	Select
            #=======================================================================
            if ($Latest.IsPresent) {
                $CatalogUpdate = $CatalogUpdate | Select-Object -First 1
            }
            else {
                $CatalogUpdate = $CatalogUpdate | Out-GridView -Title 'Select a Microsoft Update to download' -PassThru
            }
            #=======================================================================
            #	Download
            #=======================================================================
            foreach ($Update in $CatalogUpdate) {
                Save-UpdateCatalog -Guid $Update.Guid -DestinationDirectory $DestinationDirectory
            }
            #=======================================================================
        }
        else {
            Write-Warning "Save-MsUpCatUpdate: Could not install required PowerShell Module MSCatalog"
        }
    }
    else {
        Write-Warning "Save-MsUpCatUpdate: Could not reach https://www.catalog.update.microsoft.com/"
    }
    #=======================================================================
}