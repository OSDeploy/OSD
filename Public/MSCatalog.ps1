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
        Install-Module MSCatalog -Force
    }
    #=======================================================================
    #	Block
    #=======================================================================
    Block-PSModuleNotInstalled -ModuleName MSCatalog
    #=======================================================================
    #	Get-SystemFirmwareUpdate

<#     Write-Host -ForegroundColor DarkGray "UEFI Firmware PNPDeviceID: $($SystemFirmwareUpdate.PNPDeviceID)"

    $PNPDeviceGuid = Convert-PNPDeviceIDtoGuid -PNPDeviceID $SystemFirmwareUpdate.PNPDeviceID
    Write-Host -ForegroundColor DarkGray "UEFI Firmware Guid: $PNPDeviceGuid"

    $CatalogUpdate = Get-MSCatalogUpdate -Search $PNPDeviceGuid -SortBy LastUpdated -Descending |`
    Select-Object LastUpdated,Title,Version,Size,Guid -First 1 -ErrorAction Ignore #>
    #=======================================================================
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
                Write-Host -ForegroundColor DarkGray "You can install the firmware by running the following command"
                Write-Host -ForegroundColor DarkGray "Add-WindowsDriver -Path C:\ -Driver $DestinationDirectory"
            }
            else {
                Write-Host -ForegroundColor DarkGray "Make sure Bitlocker is suspended first before installing the Firmware Driver"
                if (Test-Path "$DestinationDirectory\firmware.inf") {
                    Write-Host -ForegroundColor DarkGray "Right click on $DestinationDirectory\firmware.inf and Install"
                }
            }
        }
        else {
            Write-Warning "Could not find a UEFI Firmware update for this HardwareID"
        }
    }
    else {
        Write-Warning "Could not find a UEFI Firmware HardwareID"
    }
}
function Save-OSDUpdateBetaTest {
    [CmdLetBinding()]
    param (
        [ValidateSet('x64','x86')]
        [string]$Architecture = 'x64',

        #Filter by UpdateBuild Property
        [ValidateSet(1507,1511,1607,1703,1709,1803,1809,1903,1909,2004,'20H2','21H1')]
        [string]$Build = '21H1',

        #Filter by UpdateGroup Property
        [ValidateSet('Cumulative Update')]
        [string]$UpdateGroup = 'Cumulative Update',

        #Filter by UpdateOS Property
        [ValidateSet('Windows 10')]
        [string]$OperatingSystem = 'Windows 10',

        [ValidateSet('Preview')]
        [string[]]$Include,

        [String] $DestinationDirectory = "$env:TEMP\CatalogUpdate"
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
    Write-Host -ForegroundColor DarkGray "OperatingSystem: $OperatingSystem"
    Write-Host -ForegroundColor DarkGray "Architecture: $Architecture"
    Write-Host -ForegroundColor DarkGray "Build: $Build"
    Write-Host -ForegroundColor DarkGray "UpdateGroup: $UpdateGroup"
    #=======================================================================
    #	Go
    #=======================================================================
    $CatalogUpdate = Get-MSCatalogUpdate -Search "$OperatingSystem $Architecture $Build $UpdateGroup" -SortBy "Title" -AllPages -Descending |`
    Where-Object Title -NotMatch 'Dynamic' |`
    Where-Object Title -NotMatch '.NET' |`
    Sort-Object LastUpdated -Descending |`
    Select-Object LastUpdated,Classification,Title,Size,Guid

    if ($Include -notcontains 'Preview') {
        $CatalogUpdate = $CatalogUpdate | Where-Object {$_.Title -notmatch 'Preview'}
    }

    $CatalogUpdate = $CatalogUpdate | Out-GridView -Title 'Select a Microsoft Update to download' -PassThru

    foreach ($Update in $CatalogUpdate) {
        Save-UpdateCatalog -Guid $Update.Guid -DestinationDirectory $DestinationDirectory
    }
    
    if ($CatalogUpdate) {
        explorer.exe $DestinationDirectory
    }
}