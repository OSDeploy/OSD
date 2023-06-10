<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module is designed for OOBE
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/eq-oobe-startup.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/eq-oobe-startup.psm1')
#>
#=================================================
#region Functions
function osdcloud-StartOOBE {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        #Install Autopilot Support
        $Autopilot,

        [System.Management.Automation.SwitchParameter]
        #Show Windows Settings Display
        $Display,

        [System.Management.Automation.SwitchParameter]
        #Show Windows Settings Display
        $Language,

        [System.Management.Automation.SwitchParameter]
        #Show Windows Settings Display
        $DateTime,

        [System.Management.Automation.SwitchParameter]
        #Install Azure support
        $Azure,

        [System.Management.Automation.SwitchParameter]
        #Install Azure KeyVault support
        $KeyVault
    )
    if ($Display) {
        osdcloud-SetWindowsDisplay
    }
    if ($Language) {
        osdcloud-SetWindowsLanguage
    }
    if ($DateTime) {
        osdcloud-SetWindowsDateTime
    }
    osdcloud-SetExecutionPolicy
    osdcloud-SetPowerShellProfile
    osdcloud-InstallPackageManagement
    osdcloud-TrustPSGallery
    osdcloud-InstallModulePester
    osdcloud-InstallModulePSReadLine
    osdcloud-InstallPowerShellModule -Name OSD
    osdcloud-InstallWinGet

    #Add Azure KeuVault Support
    if ($Azure) {
        osdcloud-InstallPowerShellModule -Name 'Az.Accounts'
        osdcloud-InstallPowerShellModule -Name 'Az.KeyVault'
    }

    #Add Azure KeuVault Support
    if ($KeyVault) {
        osdcloud-InstallPowerShellModule -Name 'Az.Accounts'
        osdcloud-InstallPowerShellModule -Name 'Az.KeyVault'
    }

    #Get Autopilot information from the device
    $TestAutopilotProfile = osdcloud-TestAutopilotProfile

    #If the device has an Autopilot Profile, show the information
    if ($TestAutopilotProfile -eq $true) {
        osdcloud-ShowAutopilotProfile
        $Autopilot = $false
    }
    
    #Install the required Autopilot Modules
    if ($Autopilot) {
        if ($TestAutopilotProfile -eq $false) {
            osdcloud-InstallModuleAutopilot
            osdcloud-InstallPowerShellModule -Name 'AzureAD'
            osdcloud-InstallScriptAutopilot
        }
    }
}
New-Alias -Name 'Start-OOBE' -Value 'osdcloud-StartOOBE' -Description 'OSDCloud' -Force
#endregion
#=================================================