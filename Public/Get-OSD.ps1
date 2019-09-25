function Get-OSD {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet(`
        'IsAdmin',`
        'IsDesktop',`
        'IsLaptop',`
        'IsWinPE'
        )][string]$Property
    )
    #===================================================================================================
    #
    #===================================================================================================
    $Value = $false
    $ChassisTypes = (Get-CimInstance -ClassName Win32_SystemEnclosure).ChassisTypes

    $IsLaptop = $false
    if ($ChassisTypes -match 9 -or $ChassisTypes -match 10 -or $ChassisTypes -match 14) {$IsLaptop = $true}

    $IsDesktop = $false
    if ($IsLaptop -eq $false) {$IsDesktop = $true}


    if ($Property -eq 'IsAdmin') {
        Write-Verbose "IsAdmin: Do I have Admin Rights?"
        Write-Verbose "([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')"
    
        $Value = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
        Return $Value
    }

    if ($Property -eq 'IsDesktop') {Return $IsDesktop}
    if ($Property -eq 'IsLaptop') {Return $IsLaptop}

    if ($Property -eq 'IsWinPE') {
        Write-Verbose "Get-OSDIsWinPE: Am I running in WinPE?"
        Write-Verbose '$env:SystemDrive -eq "X:"'

        $Value = $env:SystemDrive -eq 'X:'
        Return $Value
    }
}