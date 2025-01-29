function Get-WinPEDrivers {
    [CmdletBinding()]
    param (
        [ValidateSet('ADK','WinPE','WinRE')]
        [System.String]
        $BootImage,

        [ValidateSet('amd64','arm64')]
        [System.String[]]
        $Architecture,

        [System.Management.Automation.SwitchParameter]
        $GridView
    )
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))] $($MyInvocation.MyCommand)"
    #=================================================
    #region Get Paths
    $DriverPathAMD64 = Join-Path -Path $(Get-OSDCachePath) -ChildPath 'WinPEDrivers-amd64'
    $DriverPathARM64 = Join-Path -Path $(Get-OSDCachePath) -ChildPath 'WinPEDrivers-arm64'
    #=================================================
    #region DriverPaths

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

    if (($BootImage -eq 'ADK') -or ($BootImage -eq 'WinPE')) {
        $WinPEDrivers = $WinPEDrivers | Where-Object { $_.Name -notmatch 'Wireless' }
    }

    if ($GridView) {
        $WinPEDrivers = $WinPEDrivers | Select-Object Name, FullName | Out-GridView -Title 'Select WinPE Drivers and press OK (Cancel to skip)' -PassThru
    }

    return $WinPEDrivers
}