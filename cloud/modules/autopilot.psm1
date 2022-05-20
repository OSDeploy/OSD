<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module can be loaded in all Windows phases except WinPE
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/autopilot.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/autopilot.psm1')
#>
#=================================================
#region Functions
function osdcloud-GetAutopilotEvents {
    [CmdletBinding()]
    param ()
    Get-WinEvent -MaxEvents 25 -LogName 'Microsoft-Windows-ModernDeployment-Diagnostics-Provider/AutoPilot' | Sort-Object TimeCreated | Select-Object TimeCreated, Id, Message | Format-Table
}
function osdcloud-ShowAutopilotProfile {
    [CmdletBinding()]
    param ()
    $Global:RegAutopilot = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot'

    #Oter Keys
    #Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\AutopilotPolicyCache'
    #Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot\EstablishedCorrelations'
    
    if ($Global:RegAutoPilot.CloudAssignedForcedEnrollment -eq 1) {
        Write-Host -ForegroundColor Cyan "This device has an Autopilot Profile"
        Write-Host -ForegroundColor DarkGray "  TenantDomain: $($Global:RegAutoPilot.CloudAssignedTenantDomain)"
        Write-Host -ForegroundColor DarkGray "  TenantId: $($Global:RegAutoPilot.TenantId)"
        Write-Host -ForegroundColor DarkGray "  CloudAssignedLanguage: $($Global:RegAutoPilot.CloudAssignedLanguage)"
        Write-Host -ForegroundColor DarkGray "  CloudAssignedMdmId: $($Global:RegAutoPilot.CloudAssignedMdmId)"
        Write-Host -ForegroundColor DarkGray "  CloudAssignedOobeConfig: $($Global:RegAutoPilot.CloudAssignedOobeConfig)"
        Write-Host -ForegroundColor DarkGray "  CloudAssignedRegion: $($Global:RegAutoPilot.CloudAssignedRegion)"
        Write-Host -ForegroundColor DarkGray "  CloudAssignedTelemetryLevel: $($Global:RegAutoPilot.CloudAssignedTelemetryLevel)"
        Write-Host -ForegroundColor DarkGray "  AutopilotServiceCorrelationId: $($Global:RegAutoPilot.AutopilotServiceCorrelationId)"
        Write-Host -ForegroundColor DarkGray "  IsAutoPilotDisabled: $($Global:RegAutoPilot.IsAutoPilotDisabled)"
        Write-Host -ForegroundColor DarkGray "  IsDevicePersonalized: $($Global:RegAutoPilot.IsDevicePersonalized)"
        Write-Host -ForegroundColor DarkGray "  IsForcedEnrollmentEnabled: $($Global:RegAutoPilot.IsForcedEnrollmentEnabled)"
        Write-Host -ForegroundColor DarkGray "  SetTelemetryLevel_Succeeded_With_Level: $($Global:RegAutoPilot.SetTelemetryLevel_Succeeded_With_Level)"
    }
    else {
        Write-Warning 'Could not find an Autopilot Profile on this device.  If this device is registered, restart the device while connected to the internet'
    }
}
New-Alias -Name 'osdcloud-ShowAutopilotInfo' -Value 'osdcloud-ShowAutopilotProfile' -Description 'OSDCloud' -Force
function osdcloud-TestAutopilotProfile {
    [CmdletBinding()]
    param ()
    $Global:RegAutopilot = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot'

    #Oter Keys
    #Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\AutopilotPolicyCache'
    #Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot\EstablishedCorrelations'
    
    if ($Global:RegAutoPilot.CloudAssignedForcedEnrollment -eq 1) {
        $true
    }
    else {
        $false
    }
}
#endregion
#=================================================