<#
.SYNOPSIS
Searches for AutoPilot Jsons and allows you to select one

.DESCRIPTION
Searches for AutoPilot Jsons and allows you to select one

.LINK
https://osd.osdeploy.com/module/functions/autopilotjson

.NOTES
21.3.12  Initial Release
#>
function Select-OSDCloudOfflineAutoPilotProfiles {
    [CmdletBinding()]
    param ()

    $GetOSDCloudOfflineAutoPilotProfiles = Get-OSDCloudOfflineAutoPilotProfiles

    if ($GetOSDCloudOfflineAutoPilotProfiles) {
        $AutoPilotProfiles = foreach ($Item in $GetOSDCloudOfflineAutoPilotProfiles) {
            $i++
            $JsonConfiguration = Get-Content -Path $Item.FullName | ConvertFrom-Json

            $ObjectProperties = @{
                Selection           = $i
                Name                = $Item.Name
                FullName            = $Item.FullName
                Profile             = $JsonConfiguration.Comment_File
                Tenant              = $JsonConfiguration.CloudAssignedTenantDomain
                ZtdCorrelationId    = $JsonConfiguration.ZtdCorrelationId
                FullContent         = $JsonConfiguration
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }

        $AutoPilotProfiles | Select-Object -Property Selection, Tenant, Profile, FullName | Format-Table | Out-Host

        do {
            $SelectReadHost = Read-Host -Prompt "Enter the Selection of the AutoPilot Profile to apply, or press S to Skip"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $AutoPilotProfiles.Selection -or ($SelectReadHost -eq 'S')))))
        
        if ($SelectReadHost -eq 'S') {
            Return $false
        }
        $AutoPilotProfiles = $AutoPilotProfiles | Where-Object {$_.Selection -eq $SelectReadHost}

        Return $AutoPilotProfiles.FullContent
        

<#         do {
            $AutoPilotJson = Read-Host -Prompt "Type the Number to select an AutoPilot Profile to apply (AutoPilotConfigurationFile.json), or S to Skip"
        }
        until (
            ((($AutoPilotJson -ge 0) -and ($AutoPilotJson -in $AutoPilotJsons.Number)) -or ($AutoPilotJson -eq 'S')) 
        )
        if ($AutoPilotJson -ne 'S') {
           $AutoPilotConfiguration = $AutoPilotJsons | Where-Object {$_.Number -eq $AutoPilotJson}
           $AutoPilotConfiguration = $AutoPilotConfiguration | Select-Object -Property * -ExcludeProperty Number
        }
        Return $AutoPilotProfiles #>
    }
}