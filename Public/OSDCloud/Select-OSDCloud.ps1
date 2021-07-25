<#
.SYNOPSIS
Selects Office Configuration Profiles

.DESCRIPTION
Selects Office Configuration Profiles

.LINK
https://osdcloud.osdeploy.com

.NOTES
#>
function Select-OSDCloudFile.wim {
    [CmdletBinding()]
    param ()

    $i = $null
    $Results = Find-OSDCloudFile -Name '*.wim' -Path '\OSDCloud\OS\'

    $Results = $Results | Sort-Object -Property Length -Unique | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}

    if ($Results) {
        $Results = foreach ($Item in $Results) {
            $i++

            $ObjectProperties = @{
                Selection   = $i
                Name        = $Item.Name
                Directory   = $Item.Directory
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }

        $Results | Select-Object -Property Selection, Name, Directory | Format-Table | Out-Host

        do {
            $SelectReadHost = Read-Host -Prompt "Select a Windows Image to apply by Selection [Number]"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Results.Selection))))
        
        if ($SelectReadHost -eq 'S') {
            Return $false
        }

        $Results = $Results | Where-Object {$_.Selection -eq $SelectReadHost}

        Return Get-Item (Join-Path $Results.Directory $Results.Name)
    }
}
function Select-OSDCloudImageIndex {
    [CmdletBinding()]
    param (
        [string]$ImagePath
    )

    $Results = Get-WindowsImage -ImagePath $ImagePath

    if (($Results | Measure-Object).Count -eq 1) {
        $SelectedItem = $GetDisk
        Return $Results.ImageIndex
    }

    if ($Results) {
        $Results | Select-Object -Property ImageIndex, ImageName | Format-Table | Out-Host

        do {
            $SelectReadHost = Read-Host -Prompt "Select an Image to apply by ImageIndex [Number]"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Results.ImageIndex))))
        
        if ($SelectReadHost -eq 'S') {
            Return $false
        }

        $Results = $Results | Where-Object {$_.ImageIndex -eq $SelectReadHost}

        Return $Results.ImageIndex
    }
}
<#
.SYNOPSIS
Selects Autopilot Profiles

.DESCRIPTION
Selects Autopilot Profiles

.LINK
https://osdcloud.osdeploy.com

.NOTES
21.3.12  Initial Release
#>
function Select-OSDCloudAutopilotFile {
    [CmdletBinding()]
    param ()

    $i = $null
    $FindOSDCloudFile = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
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
<#
.SYNOPSIS
Selects Office Configuration Profiles

.DESCRIPTION
Selects Office Configuration Profiles

.LINK
https://osdcloud.osdeploy.com

.NOTES
#>
function Select-OSDCloudODTFile {
    [CmdletBinding()]
    param ()

    $i = $null
    $ODTConfigFiles = Find-OSDCloudODTFile

    if ($ODTConfigFiles) {
        $ODTConfigFiles = foreach ($Item in $ODTConfigFiles) {
            $i++

            $ObjectProperties = @{
                Selection   = $i
                Name        = $Item.Name
                Directory   = $Item.Directory
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }

        $ODTConfigFiles | Select-Object -Property Selection, Name, Directory | Format-Table | Out-Host

        do {
            $SelectReadHost = Read-Host -Prompt "Enter the Selection of the Office Configuration to apply, or press S to Skip"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $ODTConfigFiles.Selection -or ($SelectReadHost -eq 'S')))))
        
        if ($SelectReadHost -eq 'S') {
            Return $false
        }
        $ODTConfigFiles = $ODTConfigFiles | Where-Object {$_.Selection -eq $SelectReadHost}

        Return Get-Item (Join-Path $ODTConfigFiles.Directory $ODTConfigFiles.Name)
    }
}