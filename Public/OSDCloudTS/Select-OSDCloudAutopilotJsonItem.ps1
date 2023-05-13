<#
.SYNOPSIS
Selects Autopilot Profiles

.DESCRIPTION
Selects Autopilot Profiles

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Select-OSDCloudAutopilotJsonItem {
    [CmdletBinding()]
    param ()

    $i = $null
    $FindOSDCloudFile = @()
    [array]$FindOSDCloudFile = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
    [array]$FindOSDCloudFile += Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\AutopilotJSON\' | Sort-Object FullName


    $FindOSDCloudFile = $FindOSDCloudFile | Where-Object {$_.FullName -notlike "C*"}


    if ($FindOSDCloudFile) {
        $AutopilotProfiles = foreach ($Item in $FindOSDCloudFile) {
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

        $AutopilotProfiles | Select-Object -Property Selection, Profile, FullName | Format-Table | Out-Host

        #if ($Global:OSDCloudZTI -eq $true) {
        #    $AutopilotProfiles = $AutopilotProfiles | Where-Object {$_.Selection -eq 1}
        #}
        #else {
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection of the Autopilot Profile to apply, or press S to Skip"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $AutopilotProfiles.Selection -or ($SelectReadHost -eq 'S')))))
            
            if ($SelectReadHost -eq 'S') {
                Return $false
            }
            $AutopilotProfiles = $AutopilotProfiles | Where-Object {$_.Selection -eq $SelectReadHost}
        #}

        Return Get-Item $AutopilotProfiles.FullName
    }
}