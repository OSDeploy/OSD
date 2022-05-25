<#
.SYNOPSIS
Creates an ADK CopyPE Working Directory

.DESCRIPTION
Creates an ADK CopyPE Working Directory

.LINK
https://osd.osdeploy.com/module/functions/adk

.NOTES
21.5.27.2   Resolved issue with paths
21.3.15.2   Renamed to make it easier to understand what it does
21.3.10     Initial Release
#>
function New-AdkCopyPE {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('amd64','x86')]
        [string]$WinPEArch = 'amd64'
    )

    #=================================================
    #   Require Admin Rights
    #=================================================
    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
        Break
    }
    #=================================================
    #   Get Adk Paths
    #=================================================
    $AdkPaths = Get-AdkPaths -Arch $WinPEArch
    #=================================================
    $Destination = $Path

    $AdkWimSourcePath = $AdkPaths.WimSourcePath
    $AdkPathOscdimg = $AdkPaths.PathOscdimg
    $AdkPathWinPEMedia = $AdkPaths.PathWinPEMedia

    $DestinationMedia = Join-Path $Destination 'media'
    if (-NOT (Test-Path $DestinationMedia)) {
        New-Item -Path $DestinationMedia -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $DestinationMount = Join-Path $Destination 'mount'
    if (-NOT (Test-Path $DestinationMount)) {
        New-Item -Path $DestinationMount -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $DestinationFirmwareFiles = Join-Path $Destination 'fwfiles'
    if (-NOT (Test-Path $DestinationFirmwareFiles)) {
        New-Item -Path $DestinationFirmwareFiles -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $DestinationSources = Join-Path $DestinationMedia 'sources'
    if (-NOT (Test-Path $DestinationSources)) {
        New-Item -Path $DestinationSources -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    xcopy /herky "$AdkPathWinPEMedia" "$DestinationMedia\"

    Copy-Item "$AdkWimSourcePath" "$DestinationSources\boot.wim"
    Copy-Item "$AdkPathOscdimg\efisys.bin" "$DestinationFirmwareFiles"
    Copy-Item "$AdkPathOscdimg\etfsboot.com" "$DestinationFirmwareFiles"
    #=================================================
}