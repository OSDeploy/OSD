<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    Version 22.9.13.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_eq_winpe_startup.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_eq_winpe_startup.psm1')
#>

#region Functions  
function AzOSD {
    [CmdletBinding()]
    param ()
    Connect-OSDCloudAzure
    Get-OSDCloudAzureResources
    Start-OSDCloudAzure
}
function osdcloud-StartWinPE {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Azure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $KeyVault,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $OSDCloud
    )
    if ($env:SystemDrive -eq 'X:') {
        osdcloud-SetExecutionPolicy
        osdcloud-WinpeSetEnvironmentVariables
        osdcloud-SetPowerShellProfile
        #osdcloud-InstallNuget
        osdcloud-InstallPackageManagement
        osdcloud-WinpeInstallPowerShellGet
        osdcloud-TrustPSGallery
        if ($OSDCloud) {
            osdcloud-WinpeInstallCurl
            osdcloud-InstallModulePSReadLine
            osdcloud-InstallModuleOSD
            if (-not (Get-Command 'curl.exe' -ErrorAction SilentlyContinue)) {
                Write-Warning 'curl.exe is missing from WinPE. This is required for OSDCloud to function'
                Start-Sleep -Seconds 5
                Break
            }
        }
        if ($Azure) {
            $KeyVault = $false
            osdcloud-InstallModuleAzureAD
            osdcloud-InstallModuleAzAccounts
            osdcloud-InstallModuleAzKeyVault
            osdcloud-InstallModuleAzResources
            osdcloud-InstallModuleAzStorage
            osdcloud-InstallModuleMSGraphDeviceManagement
        }
        if ($KeyVault) {
            osdcloud-InstallModuleAzAccounts
            osdcloud-InstallModuleAzKeyVault
        }
        if ($Manufacturer -eq "HP") {
            $HPEnterprise = Test-HPIASupport
            if ($HPEnterprise -eq $true) {
                osdcloud-InstallModuleHPCMSL
            }
        }
    }
    else {
        Write-Warning 'Function is not supported in this Windows Phase'
    }
}
New-Alias -Name 'Start-WinPE' -Value 'osdcloud-StartWinPE' -Description 'OSDCloud' -Force
#endregion