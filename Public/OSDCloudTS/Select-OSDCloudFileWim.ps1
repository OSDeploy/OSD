<#
.SYNOPSIS
Selects Office Configuration Profiles

.DESCRIPTION
Selects Office Configuration Profiles

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs
#>
function Select-OSDCloudFileWim {
    [CmdletBinding()]
    param (
        [switch]$ZTI
    )

    $i = $null
    $Results = @()
    $Results += Find-OSDCloudFile -Name '*.wim' -Path '\OSDCloud\OS\' | Where-Object {$_.FullName -notmatch 'C:'}
    $Results += Find-OSDCloudFile -Name '*.esd' -Path '\OSDCloud\OS\' | Where-Object {$_.FullName -notmatch 'C:'}
    $Results += Find-OSDCloudFile -Name '*install.swm' -Path '\OSDCloud\OS\' | Where-Object {$_.FullName -notmatch 'C:'}

    $Results = $Results | Sort-Object -Property Length -Unique | Sort-Object FullName | Where-Object {$_.Length -gt 2GB}

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

        if ($ZTI) {
            if (($Results | Measure-Object).Count -eq 1) {
                Return Get-Item (Join-Path $Results.Directory $Results.Name)
            }
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] -ZTI requires exactly one Windows Image candidate under \OSDCloud\OS\, found $(($Results | Measure-Object).Count). Remove the extras or run without -ZTI to select interactively."
        }

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
