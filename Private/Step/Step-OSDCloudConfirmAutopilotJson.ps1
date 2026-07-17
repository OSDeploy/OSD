function Step-OSDCloudConfirmAutopilotJson {
    <#
    .SYNOPSIS
    Verifies and loads Autopilot JSON configuration for OSDCloud deployments.

    .DESCRIPTION
    Evaluates available Autopilot configuration inputs in priority order: existing object,
    URL source, and discovered local JSON files. If no profile is selected or discovered,
    deployment continues without AutopilotConfigurationFile.json.

    .EXAMPLE
    Step-OSDCloudConfirmAutopilotJson
    Resolves Autopilot JSON from configured sources and logs the effective outcome.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial help block created
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] $($MyInvocation.MyCommand.Name) is skipped when not running in WinPE (X:)"
        return
    }
    #=================================================
    if ($Global:OSDCloud.SkipAutopilot -ne $true) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Validate Autopilot Configuration"

        if ($Global:OSDCloud.AutopilotJsonObject) {
            Write-DarkGrayHost 'Importing AutopilotJsonObject'
        }
        elseif ($Global:OSDCloud.AutopilotJsonUrl) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Importing Autopilot Configuration $($Global:OSDCloud.AutopilotJsonUrl)"
            if (Test-WebConnection -Uri $Global:OSDCloud.AutopilotJsonUrl) {
                $Global:OSDCloud.AutopilotJsonObject = (Invoke-WebRequest -Uri $Global:OSDCloud.AutopilotJsonUrl).Content | ConvertFrom-Json
            }
        }
        else {
            $autopilotSearchName = '*.json'
            if ($Global:OSDCloud.AutopilotJsonItem) {
                $autopilotSearchName = $Global:OSDCloud.AutopilotJsonItem.Name
            }
            elseif ($Global:OSDCloud.AutopilotJsonName) {
                $autopilotSearchName = $Global:OSDCloud.AutopilotJsonName
            }

            $Global:OSDCloud.AutopilotJsonChildItem = @(
                Find-OSDCloudFile -Name $autopilotSearchName -Path '\OSDCloud\Autopilot\Profiles\'
                Find-OSDCloudFile -Name $autopilotSearchName -Path '\OSDCloud\Config\AutopilotJSON\'
            ) | Sort-Object FullName | Where-Object {$_.FullName -notlike 'C*'}

            if ($Global:OSDCloud.AutopilotJsonChildItem) {
                if ($Global:OSDCloud.AutopilotJsonItem -or $Global:OSDCloud.AutopilotJsonName) {
                    $Global:OSDCloud.AutopilotJsonItem = $Global:OSDCloud.AutopilotJsonChildItem | Select-Object -First 1
                }
                elseif ($Global:OSDCloud.ZTI -eq $true) {
                    $Global:OSDCloud.AutopilotJsonItem = $Global:OSDCloud.AutopilotJsonChildItem | Select-Object -First 1
                }
                else {
                    $Global:OSDCloud.AutopilotJsonItem = Select-OSDCloudAutopilotJsonItem
                }

                if ($Global:OSDCloud.AutopilotJsonItem) {
                    $Global:OSDCloud.AutopilotJsonObject = Get-Content $Global:OSDCloud.AutopilotJsonItem.FullName | ConvertFrom-Json
                }
            }
        }

        if ($Global:OSDCloud.AutopilotJsonObject) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCloud will apply the following Autopilot Configuration as AutopilotConfigurationFile.json"
            $Global:OSDCloud.AutopilotJsonObject | Format-List | Out-Host
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] AutopilotConfigurationFile.json will not be configured for this deployment"
        }
    }
    #=================================================
}
