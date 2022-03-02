<#
.SYNOPSIS
Removes Appx Packages and Appx Provisioned Packages for All Users

.DESCRIPTION
Removes Appx Packages and Appx Provisioned Packages for All Users

.LINK
https://osd.osdeploy.com/module/functions/appx/remove-appxonline

.NOTES
19.12.20 David Segura @SeguraOSD
#>
function Remove-AppxOnline {
    [CmdletBinding()]
    param (
        #Appx Packages selected in GridView will be removed from the Windows Image
        [System.Management.Automation.SwitchParameter]$GridRemoveAppx,

        #Appx Provisioned Packages selected in GridView will be removed from the Windows Image
        [System.Management.Automation.SwitchParameter]$GridRemoveAppxPP,

        #Appx Packages matching the string will be removed
        [string[]]$Name
    )

    begin {
        #=================================================
        #   Blocks
        #=================================================
        Block-StandardUser
        Block-WindowsVersionNe10
        #=================================================
    }
    process {
        #=================================================
        #   AppxPackage
        #=================================================
        if (Get-Command Get-AppxPackage) {
            if ($GridRemoveAppx.IsPresent) {
                Get-AppxPackage | Select-Object * | Where-Object {$_.NonRemovable -ne $true} | Out-GridView -PassThru -Title "Select Appx Packages to Remove from Online Windows Image" | ForEach-Object {
                    Write-Verbose "$($_.Name): Removing Appx Package $($_.PackageFullName)" -Verbose
                    Remove-AppPackage -AllUsers -Package $_.PackageFullName -Verbose
                }
            }
        }
        #=================================================
        #   AppxProvisionedPackage
        #=================================================
        if (Get-Command Get-AppxProvisionedPackage) {
            if ($GridRemoveAppxPP.IsPresent) {
                Get-AppxProvisionedPackage -Online | Select-Object DisplayName, PackageName | Out-GridView -PassThru -Title "Select Appx Provisioned Packages to Remove from Online Windows Image" | ForEach-Object {
                    Write-Verbose "$($_.DisplayName): Removing Appx Provisioned Package $($_.PackageName)" -Verbose
                    Remove-AppProvisionedPackage -Online -AllUsers -PackageName $_.PackageName
                }
            }
        }
        #=================================================
        #   RemoveAppx
        #=================================================
        foreach ($Item in $Name) {
            if (Get-Command Get-AppxPackage) {
                if ((Get-Command Get-AppxPackage).Parameters.ContainsKey('AllUsers')) {
                    Get-AppxPackage -AllUsers | Select-Object * | Where-Object {$_.NonRemovable -ne $true} | Where-Object {$_.Name -Match $Item} | ForEach-Object {
                        
                        Write-Host -ForegroundColor DarkCyan $_.Name
                        if ((Get-Command Remove-AppxPackage).Parameters.ContainsKey('AllUsers')) {
                            Try {Remove-AppxPackage -AllUsers -Package $_.PackageFullName | Out-Null}
                            Catch {
                                #Write-Warning "AllUsers Appx Package $($_.PackageFullName) did not remove successfully"
                        }
                        }
                        else {
                            Try {Remove-AppxPackage -Package $_.PackageFullName | Out-Null}
                            Catch {
                                #Write-Warning "Appx Package $($_.PackageFullName) did not remove successfully"
                        }
                        }
                    }
                } else {
                    Get-AppxPackage | Select-Object * | Where-Object {$_.NonRemovable -ne $true} | Where-Object {$_.Name -Match $Item} | ForEach-Object {
                        
                        Write-Host -ForegroundColor DarkCyan $_.Name
                        if ((Get-Command Remove-AppxPackage).Parameters.ContainsKey('AllUsers')) {
                            Try {Remove-AppxPackage -AllUsers -Package $_.PackageFullName | Out-Null}
                            Catch {
                                #Write-Warning "AllUsers Appx Package $($_.PackageFullName) did not remove successfully"
                        }
                        }
                        else {
                            Try {Remove-AppxPackage -Package $_.PackageFullName | Out-Null}
                            Catch {
                                #Write-Warning "Appx Package $($_.PackageFullName) did not remove successfully"
                            }
                        }
                    }
                }
            }
            if (Get-Command Get-AppxProvisionedPackage) {
                Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {

                    Write-Host -ForegroundColor DarkCyan $_.Name
                    if ((Get-Command Remove-AppxProvisionedPackage).Parameters.ContainsKey('AllUsers')) {
                        Try {Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $_.PackageName | Out-Null}
                        Catch {
                            #Write-Warning "AllUsers Appx Provisioned Package $($_.PackageName) did not remove successfully"
                    }
                    }
                    else {
                        Try {Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName | Out-Null}
                        Catch {
                            #Write-Warning "Appx Provisioned Package $($_.PackageName) did not remove successfully"
                    }
                    }
                }
            }
        }
    }
    end {}
}