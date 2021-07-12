function Convert-PNPDeviceIDtoGuid {
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PNPDeviceID
    )

    #$GuidPattern = '{[-0-9A-F]+?}'
    #($DeviceID | Select-String -Pattern $GuidPattern -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value)

    $GuidPattern = '\{?(([0-9a-f]){8}-([0-9a-f]){4}-([0-9a-f]){4}-([0-9a-f]){4}-([0-9a-f]){12})\}?'
    ($PNPDeviceID | Select-String -Pattern $GuidPattern -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value)
}
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

    Block-PSModuleNotInstalled -ModuleName MSCatalog

    Get-MSCatalogUpdate -Search (Get-SystemFirmwareResource) -SortBy LastUpdated -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore
}
function Save-SystemFirmwareUpdate {
    [CmdLetBinding()]
    param (
        [String] $DestinationDirectory = "$env:TEMP\SystemFirmwareUpdate"
    )
    #=======================================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=======================================================================
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -ErrorAction Ignore
    }
    #=======================================================================
    #	Block
    #=======================================================================
    #Block-PSModuleNotInstalled -ModuleName MSCatalog
    #=======================================================================
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
    #=======================================================================
}
function Save-MsUp {
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

        [string]$DestinationDirectory = "$env:TEMP\MSCUpdate",

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
    #	Block
    #=======================================================================
    Block-PSModuleNotInstalled -ModuleName MSCatalog
    #=======================================================================
    #	Details
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "OperatingSystem: $OS"
    Write-Host -ForegroundColor DarkGray "Architecture: $Arch"
    Write-Host -ForegroundColor DarkGray "Category: $Category"
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
        Write-Host -ForegroundColor DarkGray "Build: $Build"
        $SearchString = "$SearchString $Build $Arch"
    }
    elseif ($OS -eq 'Windows Server') {
        Write-Host -ForegroundColor DarkGray "Build: $Build"
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
            $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -match "Cumulative Update for Windows 10 Version $Build"}
        }
        if ($Category -eq 'SSU') {
            $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -match "Servicing Stack Update for Windows 10 Version $Build"}
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
        Write-Host -ForegroundColor DarkGray "Include Preview Updates: True"
    }
    else {
        Write-Host -ForegroundColor DarkGray "Include Preview Updates: False"
        $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'Preview'}
    }
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
    
<#     if ($CatalogUpdate) {
        explorer.exe $DestinationDirectory
    } #>
    #=======================================================================
}