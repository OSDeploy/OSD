function Test-AutopilotProfile {
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

Test-AutopilotProfile