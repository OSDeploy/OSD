<#
.SYNOPSIS
Removes Appx Packages and Appx Provisioned Packages for All Users

.Description
Removes Appx Packages and Appx Provisioned Packages for All Users

.LINK
https://osd.osdeploy.com/module/functions/appx/remove-appxonline

.NOTES
19.12.20 David Segura @SeguraOSD
#>
function Remove-AppxOnline {
    [CmdletBinding()]
    Param (
        #Appx Packages selected in GridView will be removed from the Windows Image
        [switch]$GridRemoveAppx,

        #Appx Provisioned Packages selected in GridView will be removed from the Windows Image
        [switch]$GridRemoveAppxPP,

        #Appx Packages matching the string will be removed
        [string[]]$Name
    )

    Begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning 'Remove-AppxOnline: This function requires ELEVATED Admin Rights'
            Break
        }
    }
    Process {
        #===================================================================================================
        #   Get Registry Information
        #===================================================================================================
        $GetRegCurrentVersion = Get-RegCurrentVersion
        #===================================================================================================
        #   Require OSMajorVersion 10
        #===================================================================================================
        if ($GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
            Write-Warning "Remove-AppxOnline: OS MajorVersion 10 is required"
            Break
        }
        #===================================================================================================
        #   AppxPackage
        #===================================================================================================
        if (Get-Command Get-AppxPackage) {
            if ($GridRemoveAppx.IsPresent) {
                Get-AppxPackage | Select-Object * | Where-Object {$_.NonRemovable -ne $true} | Out-GridView -PassThru -Title "Select Appx Packages to Remove from Online Windows Image" | ForEach-Object {
                    Write-Verbose "$($_.Name): Removing Appx Package $($_.PackageFullName)" -Verbose
                    Remove-AppPackage -AllUsers -Package $_.PackageFullName -Verbose
                }
            }
        }
        #===================================================================================================
        #   AppxProvisionedPackage
        #===================================================================================================
        if (Get-Command Get-AppxProvisionedPackage) {
            if ($GridRemoveAppxPP.IsPresent) {
                Get-AppxProvisionedPackage -Online | Select-Object DisplayName, PackageName | Out-GridView -PassThru -Title "Select Appx Provisioned Packages to Remove from Online Windows Image" | ForEach-Object {
                    Write-Verbose "$($_.DisplayName): Removing Appx Provisioned Package $($_.PackageName)" -Verbose
                    Remove-AppProvisionedPackage -Online -AllUsers -PackageName $_.PackageName
                }
            }
        }
        #===================================================================================================
        #   RemoveAppx
        #===================================================================================================
        foreach ($Item in $Name) {
            if (Get-Command Get-AppxPackage) {
                if ((Get-Command Get-AppxPackage).Parameters.ContainsKey('AllUsers')) {
                    Get-AppxPackage -AllUsers | Select-Object * | Where-Object {$_.NonRemovable -ne $true} | Where-Object {$_.Name -Match $Item} | ForEach-Object {
                        if ((Get-Command Remove-AppxPackage).Parameters.ContainsKey('AllUsers')) {
                            Write-Verbose "$($_.Name): Remove AllUsers Appx Package $($_.PackageFullName)" -Verbose
                            Try {Remove-AppxPackage -AllUsers -Package $_.PackageFullName | Out-Null}
                            Catch {Write-Warning "$($_.Name): Remove AllUsers Appx Package $($_.PackageFullName) did not complete successfully"}
                        } else {
                            Write-Verbose "$($_.Name): Remove Appx Package $($_.PackageFullName)" -Verbose
                            Try {Remove-AppxPackage -Package $_.PackageFullName | Out-Null}
                            Catch {Write-Warning "$($_.Name): Remove Appx Package $($_.PackageFullName) did not complete successfully"}
                        }
                    }
                } else {
                    Get-AppxPackage | Select-Object * | Where-Object {$_.NonRemovable -ne $true} | Where-Object {$_.Name -Match $Item} | ForEach-Object {
                        if ((Get-Command Remove-AppxPackage).Parameters.ContainsKey('AllUsers')) {
                            Write-Verbose "$($_.Name): Remove AllUsers Appx Package $($_.PackageFullName)" -Verbose
                            Try {Remove-AppxPackage -AllUsers -Package $_.PackageFullName | Out-Null}
                            Catch {Write-Warning "$($_.Name): Remove AllUsers Appx Package $($_.PackageFullName) did not complete successfully"}
                        } else {
                            Write-Verbose "$($_.Name): Remove Appx Package $($_.PackageFullName)" -Verbose
                            Try {Remove-AppxPackage -Package $_.PackageFullName | Out-Null}
                            Catch {Write-Warning "$($_.Name): Remove Appx Package $($_.PackageFullName) did not complete successfully"}
                        }
                    }
                }
            }
            if (Get-Command Get-AppxProvisionedPackage) {
                Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {
                    if ((Get-Command Remove-AppxProvisionedPackage).Parameters.ContainsKey('AllUsers')) {
                        Write-Verbose "$($_.DisplayName): Remove AllUsers Appx Provisioned Package $($_.PackageName)" -Verbose
                        Try {Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $_.PackageName | Out-Null}
                        Catch {Write-Warning "$($_.DisplayName): Remove AllUsers Appx Provisioned Package $($_.PackageName) did not complete successfully"}
                    } else {
                        Write-Verbose "$($_.DisplayName): Remove Appx Provisioned Package $($_.PackageName)" -Verbose
                        Try {Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName | Out-Null}
                        Catch {Write-Warning "$($_.DisplayName): Remove Appx Provisioned Package $($_.PackageName) did not complete successfully"}
                    }
                }
            }
        }
    }
    End {}
}