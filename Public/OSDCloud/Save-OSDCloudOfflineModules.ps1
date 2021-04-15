function Save-OSDCloudOfflineModules {
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
        Save-Module -Name WindowsAutopilotIntune -Path "$PowerShellSavePath\Modules" -Force
        Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellSavePath\Scripts" -Force
    }
    else {
        Write-Verbose -Verbose "Copy-PSModuleToFolder -Name OSD to $PowerShellSavePath\Modules"
        Copy-PSModuleToFolder -Name OSD -Destination "$PowerShellSavePath\Modules"
        Copy-PSModuleToFolder -Name PackageManagement -Destination "$PowerShellSavePath\Modules"
        Copy-PSModuleToFolder -Name PowerShellGet -Destination "$PowerShellSavePath\Modules"
        Copy-PSModuleToFolder -Name WindowsAutopilotIntune -Destination "$PowerShellSavePath\Modules"
    
        $OSDCloudOfflinePath = Find-OSDCloudOfflinePath
    
        foreach ($Item in $OSDCloudOfflinePath) {
            if (Test-Path "$($Item.FullName)\PowerShell\Required") {
                Write-Host -ForegroundColor Cyan "Applying PowerShell Modules and Scripts in $($Item.FullName)\PowerShell\Required"
                robocopy "$($Item.FullName)\PowerShell\Required" "$PowerShellSavePath" *.* /e /ndl /njh /njs
            }
        }
    }
}