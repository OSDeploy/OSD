<#
.SYNOPSIS
Evaluates an OSD Property and returns a Boolean value ($true or $false)

.DESCRIPTION
Evaluates an OSD Property and returns a Boolean value ($true or $false)

.LINK
https://osd.osdeploy.com/module/functions/get-osdbool

.NOTES
19.10.1     David Segura @SeguraOSD
#>
function Get-OSDBool {
    [CmdletBinding()]
    Param (
        #Property is returned as a Boolean value ($true or $false)
        #IsAdmin
        #IsClientOS
        #IsDesktop
        #IsLaptop
        #IsOnBattery
        #IsSFF
        #IsServer
        #IsServerCoreOS
        #IsServerOS
        #IsTablet
        #IsUEFI
        #IsVM
        #IsWinPE
        #IsInWinSE
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet(
            'IsAdmin',
            'IsClientOS',
            'IsDesktop',
            'IsLaptop',
            'IsOnBattery',
            'IsSFF',
            'IsServer',
            'IsServerCoreOS',
            'IsServerOS',
            'IsTablet',
            'IsUEFI',
            'IsVM',
            'IsWinPE',
            'IsInWinSE'
        )]
        [string]$Property
    )
    #======================================================================================================
    #   Get Values
    #======================================================================================================
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    $IsWinPE = $env:SystemDrive -eq 'X:'
    $IsInWinSE = (($env:SystemDrive -eq 'X:') -and (Test-Path 'X:\Setup.exe'))

    $IsClientOS = $false
    $IsServerOS = $false
    $IsServerCoreOS = $false

    $Win32ComputerSystem = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property *)


    if ($IsWinPE -eq $false) {
        if ($Win32ComputerSystem.Roles -match 'Server_NT' -or $Win32ComputerSystem.Roles -match 'LanmanNT') {
            $IsClientOS = $false
            $IsServerOS = $true
        } else {
            $IsClientOS = $true
            $IsServerOS = $false
        }

        if (!(Test-Path "$env:windir\explorer.exe")) {
            $IsClientOS = $false
            $IsServerOS = $false
            $IsServerCoreOS = $true
        }
    }
    #======================================================================================================
    #   IsUEFI
    #======================================================================================================
    if ($IsWinPE) {
        $IsUEFI = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control).PEFirmwareType -eq 2
    } else {
        if ($null -eq (Get-ItemProperty HKLM:\System\CurrentControlSet\Control\SecureBoot\State -ErrorAction SilentlyContinue)) {
            $IsUEFI = $false
        } else {
            $IsUEFI = $true
        }
    }
    #======================================================================================================
    #   Return Values
    #======================================================================================================
    if ($Property -eq 'IsAdmin') {Return $IsAdmin}
    if ($Property -eq 'IsWinPE') {Return $IsWinPE}
    if ($Property -eq 'IsInWinSE') {Return $IsInWinSE}
    if ($Property -eq 'IsClientOS') {Return $IsClientOS}
    if ($Property -eq 'IsServerOS') {Return $IsServerOS}
    if ($Property -eq 'IsServerCoreOS') {Return $IsServerCoreOS}
    if ($Property -eq 'IsUEFI') {Return $IsUEFI}

    if ($Property -eq 'IsOnBattery') {
        $IsOnBattery = ((Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue).BatteryStatus -eq 1)
        Return $IsOnBattery
    }
    if ($Property -eq 'IsVM') {
        $ComputerModel = ((Get-CimInstance -ClassName Win32_ComputerSystem).Model)
        $IsVM = ($ComputerModel -match 'Virtual') -or ($ComputerModel-match 'VMware')
        Return $IsVM
    }
    #======================================================================================================
    #   Win32_SystemEnclosure
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #   Credit Johan Schrewelius    https://gallery.technet.microsoft.com/PowerShell-script-that-a8a7bdd8
    #======================================================================================================
    $IsDesktop = $false
    $IsLaptop = $false
    $IsServer = $false
    $IsSFF = $false
    $IsTablet = $false
    Get-CimInstance -ClassName Win32_SystemEnclosure | ForEach-Object {
        $AssetTag = $_.SMBIOSAssetTag.Trim()
        if ($_.ChassisTypes[0] -in "8", "9", "10", "11", "12", "14", "18", "21") { $IsLaptop = $true }
        if ($_.ChassisTypes[0] -in "3", "4", "5", "6", "7", "15", "16") { $IsDesktop = $true }
        if ($_.ChassisTypes[0] -in "23") { $IsServer = $true }
        if ($_.ChassisTypes[0] -in "34", "35", "36") { $IsSFF = $true }
        if ($_.ChassisTypes[0] -in "13", "31", "32", "30") { $IsTablet = $true } 
    }
    if ($Property -eq 'AssetTag') {Return $AssetTag}
    if ($Property -eq 'IsDesktop') {Return $IsDesktop}
    if ($Property -eq 'IsLaptop') {Return $IsLaptop}
    if ($Property -eq 'IsServer') {Return $IsServer}
    if ($Property -eq 'IsSFF') {Return $IsSFF}
    if ($Property -eq 'IsTablet') {Return $IsTablet}
}