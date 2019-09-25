function Get-OSDProperty {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet(`
        'BootDevice',`
        'BuildNumber',`
        'Caption',`
        'ChassisSKUNumber',`
        'ComputerName',`
        'InstallDate',`
        'Locale',`
        'Make',`
        'Manufacturer',`
        'Model',`
        'OSArchitecture',`
        'OperatingSystemSKU',`
        'ProductType',`
        'SystemDevice',`
        'SystemDirectory',`
        'SystemDrive',`
        'SystemFamily',`
        'SystemSKUNumber',`
        'Version',`
        'WindowsBuild',`
        'WindowsDirectory',`
        'WindowsReleaseId',`
        'WindowsUbr'`
        )][string]$Property
    )
    #===================================================================================================
    #   Win32_ComputerSystem
    #===================================================================================================
    $Win32ComputerSystem = Get-OSDWMI -Property ComputerSystem

    if ($Property -eq 'ChassisSKUNumber') {$Win32ComputerSystem.ChassisSKUNumber}
    if ($Property -eq 'ComputerName') {$Win32ComputerSystem.ComputerName}
    if ($Property -eq 'Make') {$Win32ComputerSystem.Manufacturer}
    if ($Property -eq 'Manufacturer') {$Win32ComputerSystem.Manufacturer}
    if ($Property -eq 'Model') {$Win32ComputerSystem.Model}
    if ($Property -eq 'SystemFamily') {$Win32ComputerSystem.SystemFamily}
    if ($Property -eq 'SystemSKUNumber') {$Win32ComputerSystem.SystemSKUNumber}
    #===================================================================================================
    #   Win32_OperatingSystem
    #===================================================================================================
    $Win32OperatingSystem = Get-OSDWMI -Property OperatingSystem

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
        Write-Verbose "Get-OSDWindowsUbr: What is the Windows UBR?"
        Write-Verbose "(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').UBR"
    
        $Value = (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion').UBR
        Return $Value
    }
}