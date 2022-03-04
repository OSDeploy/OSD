<#
.SYNOPSIS
Edits a mounted Windows Image

.DESCRIPTION
Edits a mounted Windows Image

.LINK
https://osd.osdeploy.com/module/functions/mywindowsimage

.NOTES
19.11.22 David Segura @SeguraOSD
#>
function Edit-MyWindowsImage {
    [CmdletBinding(DefaultParameterSetName = 'Offline')]
    param (
        #Specifies the full path to the root directory of the offline Windows image that you will service.
        #If the directory named Windows is not a subdirectory of the root directory, -WindowsDirectory must be specified.
        [Parameter(ParameterSetName = 'Offline', ValueFromPipelineByPropertyName)]
        [string[]]$Path,

        #Dism Actions
        #Analyze cannot be used for PassThru
        [Parameter(ParameterSetName = 'Offline')]
        [ValidateSet('Analyze','Cleanup','CleanupResetBase')]
        [string]$CleanupImage,

        #Specifies that the action is to be taken on the operating system that is currently running on the local computer.
        [Parameter(ParameterSetName = 'Online', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]$Online,

        #Appx Packages selected in GridView will be removed from the Windows Image
        [Parameter(ParameterSetName = 'Online')]
        [System.Management.Automation.SwitchParameter]$GridRemoveAppx,

        #Appx Provisioned Packages selected in GridView will be removed from the Windows Image
        [System.Management.Automation.SwitchParameter]$GridRemoveAppxPP,

        #Appx Packages matching the string will be removed
        [Parameter(ParameterSetName = 'Online')]
        [string[]]$RemoveAppx,

        #Appx Provisioned Packages matching the string will be removed
        [string[]]$RemoveAppxPP,

        [System.Management.Automation.SwitchParameter]$DismountSave
    )

    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #=================================================
        #   Get Registry Information
        #=================================================
        $GetRegCurrentVersion = Get-RegCurrentVersion
        #=================================================
        #   Require OSMajorVersion 10
        #=================================================
        if ($GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
            Write-Warning "$($MyInvocation.MyCommand) requires OS MajorVersion 10"
            Break
        }
        #=================================================
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Online') {
            #=================================================
            #   Get Registry Information
            #=================================================
            $GetRegCurrentVersion = Get-RegCurrentVersion
            #=================================================
            #   Require OSMajorVersion 10
            #=================================================
            if ($GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
                Write-Warning "Edit-MyWindowsImage: OS MajorVersion 10 is required"
                Break
            }
            #=================================================
            #   GridRemoveAppx
            #=================================================
            if ($GridRemoveAppx.IsPresent) {
                Get-AppxPackage | Select-Object * | Where-Object {$_.NonRemovable -ne $true} | Out-GridView -PassThru -Title "Select Appx Packages to Remove from Online Windows Image" | ForEach-Object {
                    Remove-AppPackage -AllUsers -Package $_.PackageFullName -Verbose
                }
            }
            #=================================================
            #   GridRemoveAppxPP
            #=================================================
            if ($GridRemoveAppxPP.IsPresent) {
                Get-AppxProvisionedPackage -Online | Select-Object DisplayName, PackageName | Out-GridView -PassThru -Title "Select Appx Provisioned Packages to Remove from Online Windows Image" | Remove-AppProvisionedPackage -Online -AllUsers
            }
            #=================================================
            #   RemoveAppx
            #=================================================
            if ($RemoveAppx) {
                foreach ($Item in $RemoveAppx) {
                    Get-AppxPackage | Where-Object {$_.Name -Match $Item} | ForEach-Object {
                        Write-Verbose "$($_.Name): Removing Appx Package $($_.PackageFullName)" -Verbose
                        Try {Remove-AppxPackage -AllUsers -Package $_.PackageFullName | Out-Null}
                        Catch {Write-Warning "$($_.Name): Removing Appx Package $($_.PackageFullName) did not complete successfully"}
                    } 
                }
            }
            #=================================================
            #   RemoveAppxPP
            #=================================================
            if ($RemoveAppxPP) {
                foreach ($Item in $RemoveAppxPP) {
                    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {
                        Write-Verbose "$($_.DisplayName): Removing Appx Provisioned Package $($_.PackageName)" -Verbose
                        Try {Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $_.PackageName | Out-Null}
                        Catch {Write-Warning "$($_.DisplayName): Removing Appx Provisioned Package $($_.PackageName) did not complete successfully"}
                    } 
                }
            }
            #=================================================
            #   Continue for PassThru
            #=================================================
            Continue

        }
        if ($PSCmdlet.ParameterSetName -eq 'Offline') {
            #=================================================
            #   Get-WindowsImage Mounted
            #=================================================
            if ($null -eq $Path) {
                $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
            }

            foreach ($Input in $Path) {
                Write-Verbose "Edit-MyWindowsImage $Input"
                #=================================================
                #   Get-Item
                #=================================================
                if (Get-Item $Input -ErrorAction SilentlyContinue) {
                    $GetItemInput = Get-Item -Path $Input
                } else {
                    Write-Warning "Unable to locate WindowsImage at $Input"
                    Continue
                }
                #=================================================
                #   Mount-MyWindowsImage
                #=================================================
                try {
                    $MountMyWindowsImage = Mount-MyWindowsImage -ImagePath $Input -Index $Index
                }
                catch {
                    Write-Warning "Could not mount this WIM for some reason"
                    Continue
                }

                if ($null -eq $MountMyWindowsImage) {
                    Write-Warning "Could not mount this WIM for some reason"
                    Continue
                }
                #=================================================
                #   Make sure WinPE is Major Version 10
                #=================================================
                Write-Verbose "Verifying WinPE 10"
                $GetRegCurrentVersion = Get-RegCurrentVersion -Path $MountMyWindowsImage.Path
    
                if ($GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
                    Write-Warning "$($MyInvocation.MyCommand) can only service WinPE with MajorVersion 10"
                    
                    $MountMyWindowsImage | Dismount-MyWindowsImage -Discard
                    Continue
                }
                #=================================================
                #   GridRemoveAppxPP
                #=================================================
                if ($GridRemoveAppxPP.IsPresent) {
                    $CurrentLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Edit-MyWindowsImage.log"
                    Get-AppxProvisionedPackage -Path $Input | Select-Object DisplayName, PackageName | Out-GridView -PassThru -Title "Select Appx Provisioned Packages to Remove from $Input" | Remove-AppProvisionedPackage -Path $Input -LogPath $CurrentLog
                }
                #=================================================
                #   RemoveAppxPP
                #=================================================
                if ($RemoveAppxPP) {
                    foreach ($Item in $RemoveAppxPP) {
                        Write-Verbose "RemoveAppxPP: $Item"
                        Get-AppxProvisionedPackage -Path $Input | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {
                            $DismLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Edit-MyWindowsImage.log"
                            Write-Verbose "$($_.DisplayName): Removing Appx Provisioned Package $($_.PackageName)" -Verbose
                            Remove-AppxProvisionedPackage -Path $_.Path -PackageName $_.PackageName -LogPath $DismLog | Out-Null
                        } 
                    }
                }
                #=================================================
                #   Cleanup
                #=================================================
                if ($CleanupImage -eq 'Analyze') {
                    $DismLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Cleanup-Image-Analyze-Dism.log"
                    $ConsoleLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Cleanup-Image-Analyze-Console.log"
                    Write-Verbose "DISM /Image:$Input /Cleanup-Image /AnalyzeComponentStore" -Verbose
                    Write-Warning "Console Output is being redirected to $ConsoleLog"
                    DISM /Image:"$Input" /Cleanup-Image /AnalyzeComponentStore /LogPath:"$DismLog" *> $ConsoleLog
                }
                if ($CleanupImage -eq 'Cleanup') {
                    $DismLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Cleanup-Image-Cleanup-Dism.log"
                    $ConsoleLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Cleanup-Image-Cleanup-Console.log"
                    Write-Verbose "DISM /Image:$Input /Cleanup-Image /StartComponentCleanup" -Verbose
                    Write-Warning "This process will take between 1 - 200 minutes to complete, depending on the number of Updates"
                    Write-Warning "Console Output is being redirected to $ConsoleLog"
                    DISM /Image:"$Input" /Cleanup-Image /StartComponentCleanup /LogPath:"$DismLog" *> $ConsoleLog
                }
                if ($CleanupImage -eq 'CleanupResetBase') {
                    $DismLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Cleanup-Image-CleanupResetBase-Dism.log"
                    $ConsoleLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Cleanup-Image-CleanupResetBase-Console.log"
                    Write-Verbose "DISM /Image:$Input /Cleanup-Image /StartComponentCleanup /ResetBase" -Verbose
                    Write-Warning "This process will take between 1 - 200 minutes to complete, depending on the number of Updates"
                    Write-Warning "Console Output is being redirected to $ConsoleLog"
                    DISM /Image:"$Input" /Cleanup-Image /StartComponentCleanup /ResetBase /LogPath:"$DismLog" *> $ConsoleLog

                }
                #=================================================
                #   Dismount-MyWindowsImage
                #=================================================
                if ($DismountSave) {
                    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
                } else {
                    $MountMyWindowsImage
                }
                #=================================================
            }
        }
    }
    end {}
}