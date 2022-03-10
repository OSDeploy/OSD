<#
.SYNOPSIS
Selects Office Configuration Profiles

.DESCRIPTION
Selects Office Configuration Profiles

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Select-OSDCloudFileWim {
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