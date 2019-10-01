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
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet(
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
    #===================================================================================================
    #   Win32_ComputerSystem
    #===================================================================================================
    $Win32ComputerSystem = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property *)

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