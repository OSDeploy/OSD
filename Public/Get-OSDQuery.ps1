function Get-OSDQuery {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet(`
            'IsAdmin',`
            'IsDesktop',`
            'IsLaptop',`
            'IsWinPE'`
        )]
        [string]$Property
    )
    #======================================================================================
    #   Defaults
    #======================================================================================
    $Value = $false
    #======================================================================================
    #   Win32_SystemEnclosure
    #======================================================================================
    $ChassisTypes = (Get-CimInstance -ClassName Win32_SystemEnclosure).ChassisTypes

    $IsLaptop = $false
    if ($ChassisTypes -match 9 -or $ChassisTypes -match 10 -or $ChassisTypes -match 14) {$IsLaptop = $true}

    $IsDesktop = $false
    if ($IsLaptop -eq $false) {$IsDesktop = $true}
    #======================================================================================
    #   IsAdmin
    #======================================================================================
    if ($Property -eq 'IsAdmin') {
        $Value = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
        Return $Value
    }
    #======================================================================================
    #   IsDesktop
    #======================================================================================
    if ($Property -eq 'IsDesktop') {Return $IsDesktop}
    #======================================================================================
    #   IsLaptop
    #======================================================================================
    if ($Property -eq 'IsLaptop') {Return $IsLaptop}
    #======================================================================================
    #   IsWinPE
    #======================================================================================
    if ($Property -eq 'IsWinPE') {
        $Value = $env:SystemDrive -eq 'X:'
        Return $Value
    }
    #======================================================================================
    #	IsUEFI
    #======================================================================================
    if ($Property -eq 'IsUEFI') {
        if ($env:SystemDrive -eq 'X:') {
            $Value = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control).PEFirmwareType -eq 2
            $Global:IsUEFI = $PSDefaultParameterValues
            Return $Value
        } else {
            Write-Warning 'IsUEFI must be run in WinPE'
        }
    }
}