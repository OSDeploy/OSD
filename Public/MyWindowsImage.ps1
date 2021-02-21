<#
.SYNOPSIS
Dismounts a Windows image from the directory it is mapped to.

.DESCRIPTION
The Dismount-WindowsImage cmdlet either saves or discards the changes to a Windows image and then dismounts the image.

.PARAMETER Path
Specifies the full path to the root directory of the offline Windows image that you will service.

.PARAMETER Discard
Discards the changes to a Windows image.

.PARAMETER Save
Saves the changes to a Windows image.

.LINK
https://osd.osdeploy.com/module/functions/dism/dismount-mywindowsimage

.INPUTS
System.String[]

.INPUTS
Microsoft.Dism.Commands.ImageObject

.INPUTS
Microsoft.Dism.Commands.MountedImageInfoObject

.INPUTS
Microsoft.Dism.Commands.ImageInfoObject

.OUTPUTS
Microsoft.Dism.Commands.BaseDismObject

.NOTES
19.11.21    Initial Release
21.2.9      Renamed from Dismount-WindowsImageOSD
#>
function Dismount-MyWindowsImage {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'DismountDiscard')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Path,

        [Parameter(ParameterSetName = 'DismountDiscard', Mandatory = $true)]
        [switch]$Discard,

        [Parameter(ParameterSetName = 'DismountSave', Mandatory = $true)]
        [switch]$Save
    )

    begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #===================================================================================================
        #   Get-WindowsImage Mounted
        #===================================================================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
        #===================================================================================================
    }
    process {
        foreach ($Input in $Path) {
            #===================================================================================================
            #   Path
            #===================================================================================================
            $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
            Write-Verbose "Path: $MountPath"
            #===================================================================================================
            #   Validate Mount Path
            #===================================================================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Dismount-MyWindowsImage: Unable to locate Mounted WindowsImage at $Input"
                Break
            }
            #===================================================================================================
            #   Dismount-WindowsImage
            #===================================================================================================
            if ($Discard.IsPresent) {
                if ($PSCmdlet.ShouldProcess($Input, "Dismount-MyWindowsImage -Discard")) {
                    Dismount-WindowsImage -Path $Input -Discard | Out-Null
                }
            }
            if ($Save.IsPresent) {
                if ($PSCmdlet.ShouldProcess($Input, "Dismount-MyWindowsImage -Save")) {
                    Dismount-WindowsImage -Path $Input -Save | Out-Null
                }
            }
        }
    }
    end {}
}
<#
.SYNOPSIS
Edits a mounted Windows Image

.DESCRIPTION
Edits a mounted Windows Image

.LINK
https://osd.osdeploy.com/module/functions/dism/edit-mywindowsimage

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
        [switch]$Online,

        #Appx Packages selected in GridView will be removed from the Windows Image
        [Parameter(ParameterSetName = 'Online')]
        [switch]$GridRemoveAppx,

        #Appx Provisioned Packages selected in GridView will be removed from the Windows Image
        [switch]$GridRemoveAppxPP,

        #Appx Packages matching the string will be removed
        [Parameter(ParameterSetName = 'Online')]
        [string[]]$RemoveAppx,

        #Appx Provisioned Packages matching the string will be removed
        [string[]]$RemoveAppxPP
    )

    begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #===================================================================================================
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Online') {
            #===================================================================================================
            #   Get Registry Information
            #===================================================================================================
            $GetRegCurrentVersion = Get-RegCurrentVersion
            #===================================================================================================
            #   Require OSMajorVersion 10
            #===================================================================================================
            if ($GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
                Write-Warning "Edit-MyWindowsImage: OS MajorVersion 10 is required"
                Break
            }
            #===================================================================================================
            #   GridRemoveAppx
            #===================================================================================================
            if ($GridRemoveAppx.IsPresent) {
                Get-AppxPackage | Select-Object * | Where-Object {$_.NonRemovable -ne $true} | Out-GridView -PassThru -Title "Select Appx Packages to Remove from Online Windows Image" | ForEach-Object {
                    Remove-AppPackage -AllUsers -Package $_.PackageFullName -Verbose
                }
            }
            #===================================================================================================
            #   GridRemoveAppxPP
            #===================================================================================================
            if ($GridRemoveAppxPP.IsPresent) {
                Get-AppxProvisionedPackage -Online | Select-Object DisplayName, PackageName | Out-GridView -PassThru -Title "Select Appx Provisioned Packages to Remove from Online Windows Image" | Remove-AppProvisionedPackage -Online -AllUsers
            }
            #===================================================================================================
            #   RemoveAppx
            #===================================================================================================
            if ($RemoveAppx) {
                foreach ($Item in $RemoveAppx) {
                    Get-AppxPackage | Where-Object {$_.Name -Match $Item} | ForEach-Object {
                        Write-Verbose "$($_.Name): Removing Appx Package $($_.PackageFullName)" -Verbose
                        Try {Remove-AppxPackage -AllUsers -Package $_.PackageFullName | Out-Null}
                        Catch {Write-Warning "$($_.Name): Removing Appx Package $($_.PackageFullName) did not complete successfully"}
                    } 
                }
            }
            #===================================================================================================
            #   RemoveAppxPP
            #===================================================================================================
            if ($RemoveAppxPP) {
                foreach ($Item in $RemoveAppxPP) {
                    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {
                        Write-Verbose "$($_.DisplayName): Removing Appx Provisioned Package $($_.PackageName)" -Verbose
                        Try {Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $_.PackageName | Out-Null}
                        Catch {Write-Warning "$($_.DisplayName): Removing Appx Provisioned Package $($_.PackageName) did not complete successfully"}
                    } 
                }
            }
            #===================================================================================================
            #   Continue for PassThru
            #===================================================================================================
            Continue

        }
        if ($PSCmdlet.ParameterSetName -eq 'Offline') {
            #===================================================================================================
            #   Get-WindowsImage Mounted
            #===================================================================================================
            if ($null -eq $Path) {
                $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
            }
            foreach ($Input in $Path) {
                #===================================================================================================
                #   Path
                #===================================================================================================
                $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
                Write-Verbose "Path: $MountPath" -Verbose
                #===================================================================================================
                #   Validate Mount Path
                #===================================================================================================
                if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                    Write-Warning "Edit-MyWindowsImage: Unable to locate Mounted WindowsImage at $Input"
                    Break
                }
                #===================================================================================================
                #   Get Registry Information
                #===================================================================================================
                $GetRegCurrentVersion = Get-RegCurrentVersion -Path $Input
                #===================================================================================================
                #   Require OSMajorVersion 10
                #===================================================================================================
                if ($GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
                    Write-Warning "Edit-MyWindowsImage: OS MajorVersion 10 is required"
                    Break
                }
                #===================================================================================================
                #   GridRemoveAppxPP
                #===================================================================================================
                if ($GridRemoveAppxPP.IsPresent) {
                    $CurrentLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Edit-MyWindowsImage.log"
                    Get-AppxProvisionedPackage -Path $Input | Select-Object DisplayName, PackageName | Out-GridView -PassThru -Title "Select Appx Provisioned Packages to Remove from $Input" | Remove-AppProvisionedPackage -Path $Input -LogPath $CurrentLog
                }
                #===================================================================================================
                #   RemoveAppxPP
                #===================================================================================================
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
                #===================================================================================================
                #   Cleanup
                #===================================================================================================
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

                #===================================================================================================
                #   Return for PassThru
                #===================================================================================================
                Return Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
            }
        }
    }
    end {}
}
<#
.SYNOPSIS
Mounts a WIM file

.DESCRIPTION
Mounts a WIM file automatically selecting the Path and the Index

.LINK
https://osd.osdeploy.com/module/functions/dism/mount-mywindowsimage

.NOTES
19.11.21 David Segura @SeguraOSD
#>
function Mount-MyWindowsImage {
    [CmdletBinding()]
    param (
        #Specifies the location of the WIM or VHD file containing the Windows image you want to mount.
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$ImagePath,

        #Index of the WIM to Mount
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [UInt32]$Index = 1,

        #Mount the WIM as Read Only
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]$ReadOnly,

        #Opens the Path in Windows Explorer
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]$Explorer
    )

    begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #===================================================================================================
    }
    process {
        foreach ($Input in $ImagePath) {
            #===================================================================================================
            #   ImagePath
            #===================================================================================================
            Write-Verbose "ImagePath: $Input"
            Write-Verbose "Index: $Index"
            #===================================================================================================
            #   Validate File
            #===================================================================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Unable to locate WindowsImage at $Input"
                Break
            }
            #===================================================================================================
            #   Get-Item
            #===================================================================================================
            $WindowsImageOSD = Get-Item $Input
            if ($WindowsImageOSD.Extension -ne '.wim') {
                Write-Warning "WindowsImage does not have a .wim extension"
                Break
            }
            if ($WindowsImageOSD.IsReadOnly -eq $true) {
                Write-Warning "WindowsImage is Read Only"
                Break
            }
            #===================================================================================================
            #   Set Mount Path
            #===================================================================================================
            $OSDMountPath = $env:Temp + '\OSD' + (Get-Random)
            if (! (Test-Path $OSDMountPath)) {
                New-Item $OSDMountPath -ItemType Directory -Force | Out-Null
            }
            $Path = (Get-Item $OSDMountPath).FullName
            #===================================================================================================
            #   Mount-WindowsImage
            #===================================================================================================
            if ($ReadOnly.IsPresent) {
                Mount-WindowsImage -Path $Path -ImagePath $Input -Index $Index -ReadOnly | Out-Null
            } else {
                Mount-WindowsImage -Path $Path -ImagePath $Input -Index $Index | Out-Null
            }
            #===================================================================================================
            #   Explorer
            #===================================================================================================
            if ($Explorer.IsPresent) {explorer $Path}
            #===================================================================================================
            #   Return for PassThru
            #===================================================================================================
            Return Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $Path}

        }
    }
    end {}
}
<#
.SYNOPSIS
Updates a mounted WIM

.DESCRIPTION
Updates a mounted WIM files.  Requires OSDSUS Catalog

.LINK
https://osd.osdeploy.com/module/functions/dism/update-mywindowsimage

.NOTES
19.11.19 David Segura @SeguraOSD
#>
function Update-MyWindowsImage {
    [CmdletBinding()]
    param (
        #Specifies the full path to the root directory of the offline Windows image that you will service.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Path,

        #Check or Install the specified Update Group
        #Check = Validate installed Updates
        #All = Install all required Updates
        #AdobeSU = Adobe Security Update
        #DotNet = DotNet Update
        #DotNetCU = DotNet Cumulative Update
        #LCU = Latest Cumulative Update
        #SSU = Servicing Stack Update
        [ValidateSet('Check','All','AdobeSU','DotNet','DotNetCU','LCU','SSU')]
        [string]$Update = 'Check',

        #Download the file using BITS-Transfer
        #Interactive Login required
        [switch]$BitsTransfer,

        #Updates are only installed if they are needed.  Force parameter will install the update even if it is already installed
        [switch]$Force
    )

    begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #===================================================================================================
        #   Require OSDSUS Module
        #===================================================================================================
        if (-not (Get-Module -ListAvailable -Name OSDSUS)) {
            Write-Warning "$($MyInvocation.MyCommand) requires PowerShell Module OSDSUS"
            Break
        }
        #===================================================================================================
        #   Get-WindowsImage Mounted
        #===================================================================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
    }
    process {
        foreach ($Input in $Path) {
            #===================================================================================================
            #   Path
            #===================================================================================================
            $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
            Write-Verbose "Path: $MountPath" -Verbose
            #===================================================================================================
            #   Validate Mount Path
            #===================================================================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Update-MyWindowsImage: Unable to locate Mounted WindowsImage at $Input"
                Break
            }
            #===================================================================================================
            #   Get Registry Information
            #===================================================================================================
            $global:GetRegCurrentVersion = Get-RegCurrentVersion -Path $Input
            #===================================================================================================
            #   Require OSMajorVersion 10
            #===================================================================================================
            if ($global:GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
                Write-Warning "Update-MyWindowsImage: OS MajorVersion 10 is required"
                Break
            }
            #===================================================================================================
            #   Get-OSDSUS and Filter Results
            #===================================================================================================
            $global:GetOSDSUS = Get-OSDSUS -Catalog OSDBuilder | Sort-Object UpdateGroup -Descending
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateBuild -eq $global:GetRegCurrentVersion.ReleaseId}
            
            if ($global:GetRegCurrentVersion.BuildLabEx -match 'amd64') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateArch -eq 'x64'}
            } else {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateArch -eq 'x86'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'WindowsPE') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateOS -eq 'Windows 10'}
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -notmatch 'DotNet'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Core') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Client') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateOS -notmatch 'Server'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Server') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateOS -match 'Server'}
            }

            #Don't install Optional Updates
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -ne ''}

            if ($Update -ne 'Check' -and $Update -ne 'All') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -match $Update}
            }
            #===================================================================================================
            #   Get-SessionsXml
            #===================================================================================================
            $global:GetSessionsXml = Get-SessionsXml -Path "$Input" | Where-Object {$_.targetState -eq 'Installed'} | Sort-Object id
            #===================================================================================================
            #   Apply Update
            #===================================================================================================
            foreach ($item in $global:GetOSDSUS) {
                if (! ($Force.IsPresent)) {
                    if ($global:GetSessionsXml | Where-Object {$_.KBNumber -match "$($item.FileKBNumber)"}) {
                        Write-Verbose "Installed: $($item.Title) $($item.FileName)" -Verbose
                        Continue
                    } else {
                        Write-Warning "Not Installed: $($item.Title) $($item.FileName)"
                    }
                }

                if ($Update -eq 'Check') {Continue}
                

                if ($BitsTransfer.IsPresent) {
                    $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -BitsTransfer -Verbose
                } else {
                    $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -Verbose
                }
                $CurrentLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Update-MyWindowsImage.log"

                if (! (Test-Path "$env:TEMP\OSD")) {New-Item -Path "$env:TEMP\OSD" -Force | Out-Null}

                if (Test-Path $UpdateFile.FullName) {
                    #Write-Verbose "Add-WindowsPackage -PackagePath $($UpdateFile.FullName) -Path $Input" -Verbose
                    Try {
                        Write-Verbose "Add-WindowsPackage -Path $Input -PackagePath $($UpdateFile.FullName)" -Verbose
                        Add-WindowsPackage -Path $Input -PackagePath $UpdateFile.FullName -LogPath $CurrentLog | Out-Null
                    }
                    Catch {
                        if ($_.Exception.Message -match '0x800f081e') {
                        Write-Verbose "Update-MyWindowsImage: 0x800f081e The package is not applicable to this image" -Verbose}
                        Write-Verbose $CurrentLog -Verbose
                    }
                } else {
                    Write-Warning "Unable to download $($UpdateFile.FullName)"
                }
            }
            #===================================================================================================
            #   Return for PassThru
            #===================================================================================================
            Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
        }
    }
    end {}
}