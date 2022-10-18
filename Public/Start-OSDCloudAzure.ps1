function Start-OSDCloudAzure {
    <#
    .SYNOPSIS
    Installs the OSDCloudAzure Module and starts OS Deployment from Azure Storage

    .DESCRIPTION
    Installs the OSDCloudAzure Module and starts OS Deployment from Azure Storage

    .EXAMPLE
    Start-OSDCloudAzure

    .EXAMPLE
    Start-OSDCloudAzure -Force

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        #Resets everything to initial settings
        $Force
    )
    if ($env:SystemDrive -eq 'X:') {
        $PSModuleName = 'OSDCloudAzure'

        if (-not (Get-Module -ListAvailable -Name $PSModuleName)) {
            $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
            $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore
        
            if ($InstalledModule) {
                if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
                    Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                    Update-Module -Name $PSModuleName -Scope AllUsers -Force -ErrorAction Stop
                    Import-Module $PSModuleName -Force
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Install-Module $PSModuleName -Scope AllUsers -SkipPublisherCheck -Force -ErrorAction Stop
            }
        }
        Import-Module $PSModuleName -Force

        if ($Force) {
            $Force = $false
            $Global:AzOSDCloudBlobImage = $null
        }
        Initialize-OSDCloudAzure
    }
    else {
        Write-Warning "OSDCloudAzure must be run from WinPE"
    }
}