<#
.SYNOPSIS
Selects Provisioning Packages

.DESCRIPTION
Selects Provisioning Packages

.PARAMETER All
Selects all Provisioning Packages in PPKG folder

.NOTES
General notes
#>
function Select-OSDCloudProvPackage {
    [CmdletBinding()]
    param (
        [switch]$All
    )
    $i = $null
    $FindOSDCloudFile = Find-OSDCloudFile -Name "*.ppkg" -Path '\OSDCloud\PPKG\' | Sort-Object FullName
    $FindOSDCloudFile = $FindOSDCloudFile | Where-Object { $_.FullName -notlike "C*" }

    if ($FindOSDCloudFile) {
        $ProvisioningPackages = foreach ($Item in $FindOSDCloudFile) {
            $i++
            
            $root = $Item.PSDrive.Root
            $SourceDevice = Get-CimInstance win32_Volume -Filter "Caption='$root\'" | Select-Object -ExpandProperty DeviceID # Get-Volume does not return device id for ramdrives
            #$Fullpath = Join-Path -Path $DeviceID (Split-Path $Item -NoQualifier)
    
            [PSCustomObject]@{
                Selection    = $i
                Name         = $Item.Name
                Fullname     = $Item.Fullname
                SourceDevice = $SourceDevice
            }            
        }

        if (!$All) {
            $ProvisioningPackages | Select-Object -Property Selection, Name, Fullname | Format-Table | Out-Host
            $SelectedItems = @()                    
            do {
                if ($SelectedItems) { Write-Host "Current selection : $($SelectedItems -join ",") " }
            
                $SelectReadHost = Read-Host -Prompt "Enter the Selection of the Provisioning Package to apply, press [A]ll or [D]one or [S]kip"
                if ($SelectReadHost -in $ProvisioningPackages.Selection -and $SelectReadHost -notin $SelectedItems) {
                    $SelectedItems += $SelectReadHost
                }
                elseif ($SelectReadHost -eq 'A') {
                    $SelectedItems = $ProvisioningPackages.Selection
                }
            }
            until (($SelectedItems.count -eq $ProvisioningPackages.count) -or
                $SelectReadHost -eq 'S' -or
                $SelectReadHost -eq 'D'
            )
        
            if ($SelectReadHost -eq 'S') {
                return $false
            }

            $ProvisioningPackages = $ProvisioningPackages | Where-Object { $_.Selection -in $SelectedItems }
        }
    
        Return $ProvisioningPackages
    }
}