function Save-OSDCloud.offlineos.modules {
    [CmdletBinding()]
    param ()

    $PowerShellSavePath = 'C:\Program Files\WindowsPowerShell'

    if (-NOT (Test-Path "$PowerShellSavePath\Configuration")) {
        New-Item -Path "$PowerShellSavePath\Configuration" -ItemType Directory -Force | Out-Null
    }
    if (-NOT (Test-Path "$PowerShellSavePath\Modules")) {
        New-Item -Path "$PowerShellSavePath\Modules" -ItemType Directory -Force | Out-Null
    }
    if (-NOT (Test-Path "$PowerShellSavePath\Scripts")) {
        New-Item -Path "$PowerShellSavePath\Scripts" -ItemType Directory -Force | Out-Null
    }
    
    if (Test-WebConnection -Uri "https://www.powershellgallery.com") {
        Copy-PSModuleToFolder -Name OSD -Destination "$PowerShellSavePath\Modules"
        Save-Module -Name OSD -Path "$PowerShellSavePath\Modules" -Force
        Save-Module -Name PackageManagement -Path "$PowerShellSavePath\Modules" -Force
        Save-Module -Name PowerShellGet -Path "$PowerShellSavePath\Modules" -Force
        Save-Module -Name WindowsAutoPilotIntune -Path "$PowerShellSavePath\Modules" -Force
        Save-Script -Name Get-WindowsAutoPilotInfo -Path "$PowerShellSavePath\Scripts" -Force
    }
    else {
        Write-Verbose -Verbose "Copy-PSModuleToFolder -Name OSD to $PowerShellSavePath\Modules"
        Copy-PSModuleToFolder -Name OSD -Destination "$PowerShellSavePath\Modules"
        Copy-PSModuleToFolder -Name PackageManagement -Destination "$PowerShellSavePath\Modules"
        Copy-PSModuleToFolder -Name PowerShellGet -Destination "$PowerShellSavePath\Modules"
        Copy-PSModuleToFolder -Name WindowsAutoPilotIntune -Destination "$PowerShellSavePath\Modules"
    
        $OSDCloudOfflinePath = Get-OSDCloud.offline.path
    
        foreach ($Item in $OSDCloudOfflinePath) {
            if (Test-Path "$($Item.FullName)\PowerShell\Required") {
                Write-Host -ForegroundColor Cyan "Applying PowerShell Modules and Scripts in $($Item.FullName)\PowerShell\Required"
                robocopy "$($Item.FullName)\PowerShell\Required" "$PowerShellSavePath" *.* /e /ndl /njh /njs
            }
        }
    }
}