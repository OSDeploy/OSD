<#
.SYNOPSIS
Returns the value of an OSD Property

.DESCRIPTION
Returns the value of an OSD Property

.EXAMPLE
OSDProperty Model
Returns Computer Model using (Get-CimInstance -ClassName Win32_ComputerSystem).Model 
Option 1: OSDProperty Model
Option 2: Get-OSDProperty Model
Option 3: Get-OSDProperty -Property Model

.EXAMPLE
OSDProperty SystemDrive
Returns Computer System Drive using (Get-CimInstance -ClassName Win32_OperatingSystem).SystemDrive 
Option 1: OSDProperty SystemDrive
Option 2: Get-OSDProperty SystemDrive
Option 3: Get-OSDProperty -Property SystemDrive

.LINK
https://osd.osdeploy.com/module/functions/get-osdproperty

.NOTES
19.10.1     David Segura @SeguraOSD
19.9.29.1   Ben Whitmore @byteben
19.9.29     David Segura @SeguraOSD
#>
function Get-OSDProperty {
    [CmdletBinding()]
    Param (
        #Return Boolean ($true or $false)
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
        #
        #Return Value
        #BootDevice
        #BuildNumber
        #Caption
        #ChassisSKUNumber
        #Name
        #InstallDate
        #Locale
        #Make
        #Manufacturer
        #Model
        #OSArchitecture
        #OperatingSystemSKU
        #ProductType
        #SystemDevice
        #SystemDirectory
        #SystemDrive
        #SystemFamily
        #SystemSKUNumber
        #Version
        #WindowsBuild
        #WindowsDirectory
        #WindowsReleaseId
        #WindowsUbr
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
        'IsInWinSE',
        'BootDevice',
        'BuildNumber',
        'Caption',
        'ChassisSKUNumber',
        'Name',
        'InstallDate',
        'Locale',
        'Make',
        'Manufacturer',
        'Model',
        'OSArchitecture',
        'OperatingSystemSKU',
        'ProductType',
        'SystemDevice',
        'SystemDirectory',
        'SystemDrive',
        'SystemFamily',
        'SystemSKUNumber',
        'Version',
        'WindowsBuild',
        'WindowsDirectory',
        'WindowsReleaseId',
        'WindowsUbr'
        )]
        [string]$Property
    )
    #======================================================================================================
    #   Basic
    #======================================================================================================
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    if ($Property -eq 'IsAdmin') {Return $IsAdmin}
    
    $IsWinPE = $env:SystemDrive -eq 'X:'
    if ($Property -eq 'IsWinPE') {Return $IsWinPE}

    $IsInWinSE = (($env:SystemDrive -eq 'X:') -and (Test-Path 'X:\Setup.exe'))
    if ($Property -eq 'IsInWinSE') {Return $IsInWinSE}
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
    if ($Property -eq 'IsUEFI') {Return $IsUEFI}
    #======================================================================================================
    #   IsOnBattery
    #======================================================================================================
    if ($Property -eq 'IsOnBattery') {
        $IsOnBattery = ((Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue).BatteryStatus -eq 1)
        Return $IsOnBattery
    }
    #======================================================================================================
    #   Boolean Operating System
    #======================================================================================================
    $Win32ComputerSystem = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property *)
    $IsClientOS = $false
    $IsServerOS = $false
    $IsServerCoreOS = $false

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
    if ($Property -eq 'IsClientOS') {Return $IsClientOS}
    if ($Property -eq 'IsServerOS') {Return $IsServerOS}
    if ($Property -eq 'IsServerCoreOS') {Return $IsServerCoreOS}
    #======================================================================================================
    #   Return Values
    #======================================================================================================
    if ($Property -eq 'IsVM') {
        $ComputerModel = (($Win32ComputerSystem).Model)
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
    #===================================================================================================
    #   Win32_ComputerSystem
    #===================================================================================================
    if ($Property -eq 'ChassisSKUNumber') {$Win32ComputerSystem.ChassisSKUNumber}
    if ($Property -eq 'Name') {$Win32ComputerSystem.Name}
    if ($Property -eq 'Make') {$Win32ComputerSystem.Manufacturer}
    if ($Property -eq 'Manufacturer') {$Win32ComputerSystem.Manufacturer}
    if ($Property -eq 'Model') {$Win32ComputerSystem.Model}
    if ($Property -eq 'SystemFamily') {$Win32ComputerSystem.SystemFamily}
    if ($Property -eq 'SystemSKUNumber') {$Win32ComputerSystem.SystemSKUNumber}
    #===================================================================================================
    #   Win32_OperatingSystem
    #===================================================================================================
    $Win32OperatingSystem = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property *)

    if ($Property -eq 'BootDevice') {$Win32OperatingSystem.BootDevice}
    if ($Property -eq 'BuildNumber') {$Win32OperatingSystem.BuildNumber}
    if ($Property -eq 'Caption') {$Win32OperatingSystem.Caption}
    if ($Property -eq 'InstallDate') {$Win32OperatingSystem.InstallDate}
    if ($Property -eq 'Locale') {$Win32OperatingSystem.Locale}
    if ($Property -eq 'OSArchitecture') {$Win32OperatingSystem.OSArchitecture}
    if ($Property -eq 'OperatingSystemSKU') {$Win32OperatingSystem.OperatingSystemSKU}
    if ($Property -eq 'ProductType') {$Win32OperatingSystem.ProductType}
    if ($Property -eq 'SystemDevice') {$Win32OperatingSystem.SystemDevice}
    if ($Property -eq 'SystemDirectory') {$Win32OperatingSystem.SystemDirectory}
    if ($Property -eq 'SystemDrive') {$Win32OperatingSystem.SystemDrive}
    if ($Property -eq 'Version') {$Win32OperatingSystem.Version}
    if ($Property -eq 'WindowsDirectory') {$Win32OperatingSystem.WindowsDirectory}


    if ($Property -eq 'WindowsBuild') {
        Write-Verbose "WindowsBuild: What is the Windows Build?"
        Write-Verbose 'System.Environment]::OSVersion.Version.Build'
    
        $Value = [System.Environment]::OSVersion.Version.Build
        #$Value = $Win32OperatingSystem.BuildNumber
        Return $Value
    }

    if ($Property -eq 'WindowsReleaseId') {
        Write-Verbose "WindowsReleaseId: What is the Windows Release ID?"
        Write-Verbose "(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId"
    
        $Value = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId
        Return $Value
    }

    if ($Property -eq 'WindowsUbr') {
        Write-Verbose "WindowsUbr: What is the Windows UBR?"
        Write-Verbose "(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').UBR"
    
        $Value = (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion').UBR
        Return $Value
    }
}