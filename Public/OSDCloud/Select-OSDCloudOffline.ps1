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

    $Results = $Results | Sort-Object -Property Length -Unique | Sort-Object FullName

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