function Select-WinPEDrivers {
    <#
    .SYNOPSIS
        Select WinPEDrivers in the OSDCache at $env:ProgramData\OSDCache.

    .DESCRIPTION
        Select WinPEDrivers in the OSDCache at $env:ProgramData\OSDCache.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        # Filters the drivers by architecture (amd64, arm64)
        [ValidateSet('amd64', 'arm64')]
        [System.String[]]
        $Architecture,

        [Parameter(Mandatory = $false)]
        # Filters the drivers by boot image (ADK, WinPE, WinRE) by excluding Wireless drivers for ADK and WinPE
        [ValidateSet('ADK','WinPE','WinRE')]
        [System.String]
        $BootImage
    )
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))] $($MyInvocation.MyCommand)"
    #=================================================
    #region Get the WinPEDrivers Paths
    $DriverPathAMD64 = Join-Path -Path $(Get-OSDCachePath) -ChildPath 'WinPEDrivers-amd64'
    $DriverPathARM64 = Join-Path -Path $(Get-OSDCachePath) -ChildPath 'WinPEDrivers-arm64'
    #endregion
    #=================================================
    #region Get the WinPEDrivers
    if ($Architecture -eq 'amd64') {
        $WinPEDrivers = @()
        $WinPEDrivers = Get-ChildItem -Path $DriverPathAMD64 -Directory -ErrorAction Ignore
    }
    elseif ($Architecture -eq 'arm64') {
        $WinPEDrivers = @()
        $WinPEDrivers = Get-ChildItem -Path $DriverPathARM64 -Directory -ErrorAction Ignore
    }
    else {
        $WinPEDrivers = @()
        $WinPEDrivers = Get-ChildItem -Path ($DriverPathAMD64,$DriverPathARM64) -Directory -ErrorAction Ignore
    }
    #endregion
    #=================================================
    #region Filter the WinPEDrivers
    if (($BootImage -eq 'ADK') -or ($BootImage -eq 'WinPE')) {
        $WinPEDrivers = $WinPEDrivers | Where-Object { $_.Name -notmatch 'Wireless' }
    }


    $WinPEDrivers = $WinPEDrivers | Select-Object Name, FullName | Out-GridView -Title 'Select WinPE Drivers and press OK (Cancel to skip)' -PassThru
    #endregion
    #=================================================
    return $WinPEDrivers
    #=================================================
}