<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    Version 22.5.23.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpestartup.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpestartup.psm1')
#>
#=================================================
$Manufacturer = (Get-CimInstance -Class:Win32_ComputerSystem).Manufacturer
$Model = (Get-CimInstance -Class:Win32_ComputerSystem).Model
if ($Manufacturer -match "HP" -or $Manufacturer -match "Hewlett-Packard"){
    $Manufacturer = "HP"
    $EnterpriseModels = @("ProBook","ProDesk","EliteBook","EliteDesk","ZBook")
    foreach ($EnterpriseModel in $EnterpriseModels){
        if ($model -match $EnterpriseModel){
            $HPEnterprise = $true
            }
        }
    }
if ($Manufacturer -match "Dell"){$Manufacturer = "Dell"}

#region Functions
function AzOSD {
    [CmdletBinding()]
    param ()
    Connect-AzOSDCloud
    Get-AzOSDCloudBlobImage
    Start-AzOSDCloud
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
        #osdcloud-WinpeInstallNuget
        osdcloud-InstallPackageManagement
        osdcloud-WinpeInstallPowerShellGet
        osdcloud-TrustPSGallery
        if ($OSDCloud) {
            osdcloud-WinpeInstallCurl
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
        if ($HPEnterprise) {
            osdcloud-InstallModuleHPCMSL
        }
    }
    else {
        Write-Warning 'Function is not supported in this Windows Phase'
    }
}
New-Alias -Name 'Start-WinPE' -Value 'osdcloud-StartWinPE' -Description 'OSDCloud' -Force
#endregion
#=================================================
