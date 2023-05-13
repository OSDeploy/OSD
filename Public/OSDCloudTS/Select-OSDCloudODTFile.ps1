<#
.SYNOPSIS
Selects Office Configuration Profiles

.DESCRIPTION
Selects Office Configuration Profiles

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
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