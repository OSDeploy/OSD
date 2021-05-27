<#
.SYNOPSIS
Add Provisioning Packages to C:\ drive

.DESCRIPTION
Add Provisioning Packages to C:\ drive
Assign temporary drive letter to volume if needed

.PARAMETER All
Selects all Provisioning Packages in PPKG folder
#>
function Add-OSDCloudProvPackage {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [object[]]$OSDCloudProvPackages
    )
    process {
        foreach ($item in $OSDCloudProvPackages) {
            $PPKGPath = $item.Fullname
            $PPKGName = $item.name
            $PPKGSourceDevice = $item.SourceDevice
            
            # Check if volume is accessible for dism ( does not support volume paths )
            $SourceDriveLetter = Get-CimInstance Win32_Volume | Where-Object DeviceID -eq $PPKGSourceDevice | Select-Object -ExpandProperty Caption
            if (!$SourceDriveLetter) {
                # temporarily reassign drive letter if needed ( after Expand OS for example )
                $tempAssign = $true
                $freeDriveLetter = Get-ChildItem function:[d-z]: -Name | Where-Object{ !(test-path $_) } | Get-Random
                $SourceDriveLetter = Set-Volume -UniqueId $PPKGSourceDevice -DriveLetter $freeDriveLetter
            }
            
            $newPPKGPath = Join-Path $SourceDriveLetter (Split-Path -Path $PPKGPath -NoQualifier)
            Write-Host -ForegroundColor DarkGray "Applying $PPKGName to Drive C: " -NoNewline
        
            $command = "DISM.exe /Image=c:\ /Add-ProvisioningPackage /PackagePath:`"$newPPKGPath`""
            $result = $command | Invoke-Expression
            if ($tempAssign) {
                Get-Volume -UniqueId $PPKGSourceDevice | Get-Partition | Remove-PartitionAccessPath -AccessPath "$freeDriveLetter\"            
            }
            if ($LASTEXITCODE -eq 0) {
                Write-Host -ForegroundColor Green "OK"
            }
            else {
                Write-Host -ForegroundColor Red "FAIL"
                throw "There was en error when applying $PPKGName offline. Error was $result"
            }
        }
    }
}