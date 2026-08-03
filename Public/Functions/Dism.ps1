function Add-WindowsPackageSSU {
    <#
    .SYNOPSIS
    Adds a Servicing Stack Update package to Windows.

    .DESCRIPTION
    Extracts SSU cabinet files from a .cab or .msu package and applies them to an online or offline Windows image using Add-WindowsPackage.

    .PARAMETER PackagePath
    Full path to the source .cab or .msu package file.

    .PARAMETER Path
    Full path to the root directory of the offline mounted Windows image.

    .PARAMETER Online
    Applies the SSU to the currently running operating system.

    .PARAMETER LogPath
    Full path to the DISM log file used during package application.

    .EXAMPLE
    Add-WindowsPackageSSU -PackagePath C:\Updates\windows10.0-kbxxxx.msu -Path C:\Mount
    Extracts SSU content from the MSU and applies it to the mounted image at C:\Mount.

    .EXAMPLE
    Add-WindowsPackageSSU -PackagePath C:\Updates\ssu.cab -Online
    Applies SSU cab content to the running operating system.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Moved help block inside function and expanded sections
    #>
    [CmdletBinding(DefaultParameterSetName = 'Offline')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackagePath,

        [Parameter(ParameterSetName = 'Offline', Mandatory = $true)]
        [string]$Path,

        [Parameter(ParameterSetName = 'Online', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]$Online,

        [string]$LogPath = "$env:windir\Logs\Dism\dism.log"
    )
    #=================================================
    #   Blocks
    #=================================================
    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
        return
    }
    Block-WindowsVersionNe10
    #=================================================
    #   Test PackagePath
    #=================================================
    if (!(Test-Path "$PackagePath" -PathType Leaf)) {
        Write-Warning "Add-WindowsPackageLCU could not find $Path"; Continue
    }
    $PackagePathItem = Get-Item $PackagePath
    #=================================================
    #   SSU Temp Path
    #=================================================
    $SSUTemp = Join-Path $env:Temp 'SSU'

    #See if the path already exists and remove it
    if (Test-Path $SSUTemp) {
        Remove-Item -Path $SSUTemp -Recurse -Force -ErrorAction Ignore | Out-Null
    }

    #Create the SSU Temp Path
    New-Item -Path $SSUTemp -ItemType Directory -Force -ErrorAction Ignore | Out-Null

    #Bail if SSU Temp Path doesn't exist
    if (!(Test-Path $SSUTemp)) {
        Write-Warning "Add-WindowsPackageLCU could not create $SSUTemp"; Continue
    }
    #=================================================
    #   Expand MSU
    #=================================================
    if ($PackagePathItem.Extension -match '.msu') {
        & Expand.exe "$($PackagePathItem.FullName)" /f:Windows*.cab "$SSUTemp"
        Get-ChildItem -Path $SSUTemp *.cab | Where-Object {$_.Name -notmatch 'SSU'} | foreach {
            & Expand.exe $_.FullName /f:SSU*.cab "$SSUTemp"
        }
    }
    else {
        #Write-Host -ForegroundColor DarkGray "Expand SSU: $PackagePath"
        & Expand.exe "$($PackagePathItem.FullName)" /f:SSU*.cab "$SSUTemp"
    }
    #=================================================
    #   Apply SSU
    #=================================================
    if ($Online.IsPresent) {
        Get-ChildItem -Path $SSUTemp SSU*.cab | foreach {
            Write-Host -ForegroundColor DarkGray $_.FullName
            Add-WindowsPackage -PackagePath $_.FullName -Online -LogPath $LogPath -Verbose | Out-Null
        }
    }
    else {
        Get-ChildItem -Path $SSUTemp SSU*.cab | foreach {
            Write-Host -ForegroundColor DarkGray $_.FullName
            Add-WindowsPackage -PackagePath $_.FullName -Path $Path -LogPath $LogPath -Verbose | Out-Null
        }
    }
    #=================================================
}
function Copy-PSModuleToWindowsImage {
    <#
    .SYNOPSIS
    Copies PowerShell modules to a mounted Windows image

    .DESCRIPTION
    Copies specified PowerShell modules from the running operating system to a mounted Windows image for offline servicing.

    .PARAMETER Name
    Name of the PowerShell module(s) to copy. Wildcard patterns are supported. This parameter is mandatory.

    .PARAMETER ExecutionPolicy
    Sets the PowerShell Execution Policy in the Windows image. Valid values are Restricted, AllSigned, RemoteSigned, Unrestricted, Bypass, and Undefined.

    .PARAMETER Path
    Path to the mounted Windows image. If not specified, will use the currently mounted image.

    .EXAMPLE
    Copy-PSModuleToWindowsImage -Name 'OSD' -Path 'C:\Mount'
    Copies the OSD module to the mounted image at C:\\Mount

    .EXAMPLE
    Copy-PSModuleToWindowsImage -Name 'OSD','ActiveDirectory' -ExecutionPolicy Bypass -Path 'C:\Mount'
    Copies multiple modules and sets execution policy

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [SupportsWildcards()]
        [String[]]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Restricted','AllSigned','RemoteSigned','Unrestricted','Bypass','Undefined')]
        [string]$ExecutionPolicy,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$Path
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
        #   Get-WindowsImage Mounted
        #=================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
        #=================================================
    }
    process {
        foreach ($Input in $Path) {
            #=================================================
            #   Path
            #=================================================
            $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
            Write-Verbose "Path: $MountPath"
            #=================================================
            #   Validate Mount Path
            #=================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Unable to locate Mounted WindowsImage at $Input"
                Break
            }
            #=================================================
            #   Copy-PSoduleToFolder
            #=================================================
            Copy-PSModuleToFolder -Name $Name -Destination "$MountPath\Program Files\WindowsPowerShell\Modules" -RemoveOldVersions
            #=================================================
            #   Set-WindowsImageExecutionPolicy
            #=================================================
            if ($ExecutionPolicy) {
                Set-WindowsImageExecutionPolicy -ExecutionPolicy $ExecutionPolicy -Path $MountPath
            }
            #=================================================
            #   Return for PassThru
            #=================================================
            Return Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
            #=================================================
        }
    }
    end {}
}
function Dismount-MyWindowsImage {
<#
.SYNOPSIS
Dismounts MyWindowsImage and finalizes changes.

.DESCRIPTION
Commits or discards changes to MyWindowsImage and then unmounts the image.

.PARAMETER Path
Specifies the Path to use when running Dismount-MyWindowsImage.

.PARAMETER Discard
Specifies the Discard to use when running Dismount-MyWindowsImage.

.PARAMETER Save
Specifies the Save to use when running Dismount-MyWindowsImage.

.EXAMPLE
Dismount-MyWindowsImage -Path <value>
Demonstrates a common way to run Dismount-MyWindowsImage.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'DismountDiscard')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Path,

        [Parameter(ParameterSetName = 'DismountDiscard', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]$Discard,

        [Parameter(ParameterSetName = 'DismountSave', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]$Save
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
        #   Get-WindowsImage Mounted
        #=================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
        #=================================================
    }
    process {
        foreach ($Input in $Path) {
            #=================================================
            #   Path
            #=================================================
            $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
            Write-Verbose "Path: $MountPath"
            #=================================================
            #   Validate Mount Path
            #=================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Dismount-MyWindowsImage: Unable to locate Mounted WindowsImage at $Input"
                Break
            }
            #=================================================
            #   Dismount-WindowsImage
            #=================================================
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
function Edit-MyWindowsImage {
<#
.SYNOPSIS
Edits MyWindowsImage content.

.DESCRIPTION
Applies modifications to MyWindowsImage in the current servicing workflow.

.PARAMETER Path
Specifies the Path to use when running Edit-MyWindowsImage.

.PARAMETER CleanupImage
Specifies the CleanupImage to use when running Edit-MyWindowsImage.

.PARAMETER Online
Specifies the Online to use when running Edit-MyWindowsImage.

.PARAMETER GridRemoveAppx
Specifies the GridRemoveAppx to use when running Edit-MyWindowsImage.

.PARAMETER GridRemoveAppxPP
Specifies the GridRemoveAppxPP to use when running Edit-MyWindowsImage.

.PARAMETER RemoveAppx
Specifies the RemoveAppx to use when running Edit-MyWindowsImage.

.PARAMETER RemoveAppxPP
Specifies the RemoveAppxPP to use when running Edit-MyWindowsImage.

.PARAMETER DismountSave
Specifies the DismountSave to use when running Edit-MyWindowsImage.

.EXAMPLE
Edit-MyWindowsImage -Path <value>
Demonstrates a common way to run Edit-MyWindowsImage.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
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
function Get-MyWindowsCapability {
<#
.SYNOPSIS
Gets MyWindowsCapability information.

.DESCRIPTION
Returns MyWindowsCapability data for the current system or OSD session context.

.PARAMETER Path
Specifies the Path to use when running Get-MyWindowsCapability.

.PARAMETER State
Specifies the State to use when running Get-MyWindowsCapability.

.PARAMETER Category
Specifies the Category to use when running Get-MyWindowsCapability.

.PARAMETER Culture
Specifies the Culture to use when running Get-MyWindowsCapability.

.PARAMETER Like
Specifies the Like to use when running Get-MyWindowsCapability.

.PARAMETER Match
Specifies the Match to use when running Get-MyWindowsCapability.

.PARAMETER Detail
Specifies the Detail to use when running Get-MyWindowsCapability.

.PARAMETER DisableWSUS
Specifies the DisableWSUS to use when running Get-MyWindowsCapability.

.EXAMPLE
Get-MyWindowsCapability -Path <value>
Demonstrates a common way to run Get-MyWindowsCapability.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding(DefaultParameterSetName = 'Online')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Offline", ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [ValidateSet('Installed','NotPresent')]
        [string]$State,

        [ValidateSet('Language','Rsat','Other')]
        [string]$Category,

        [string[]]$Culture,

        [string[]]$Like,
        [string[]]$Match,

        [System.Management.Automation.SwitchParameter]$Detail,

        [Parameter(ParameterSetName = "Online")]
        [System.Management.Automation.SwitchParameter]$DisableWSUS
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
        #   Test Get-WindowsCapability
        #=================================================
        if (Get-Command -Name Get-WindowsCapability -ErrorAction SilentlyContinue) {
            Write-Verbose 'Verified command Get-WindowsCapability'
        } else {
            Write-Warning 'Get-MyWindowsCapability requires Get-WindowsCapability which is not present'
            Break
        }
        #=================================================
        #   Verify BuildNumber
        #=================================================
        $MinimumBuildNumber = 17763
        $CurrentBuildNumber = (Get-CimInstance -Class Win32_OperatingSystem).BuildNumber
        if ($MinimumBuildNumber -gt $CurrentBuildNumber) {
            Write-Warning "The current Windows BuildNumber is $CurrentBuildNumber"
            Write-Warning "Get-MyWindowsCapability requires Windows BuildNumber greater than $MinimumBuildNumber"
            Break
        }
        #=================================================
        #   UseWUServer
        #   Original code from Martin Bengtsson
        #   https://www.imab.dk/deploy-rsat-remote-server-administration-tools-for-windows-10-v2004-using-configmgr-and-powershell/
        #   https://github.com/imabdk/Powershell/blob/master/Install-RSATv1809v1903v1909v2004v20H2.ps1
        #=================================================
        $WUServer = (Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name WUServer -ErrorAction Ignore).WUServer
        $UseWUServer = (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ErrorAction Ignore).UseWuServer
        if ($PSCmdlet.ParameterSetName -eq 'Online') {

            if (($WUServer -ne $null) -and ($UseWUServer -eq 1) -and ($DisableWSUS -eq $false)) {
                Write-Warning "This computer is configured to receive updates from WSUS Server $WUServer"
                Write-Warning "Piping to Add-WindowsCapability may not function properly"
                Write-Warning "Local Source:    Get-MyWindowsCapability | Add-WindowsCapability -Source"
                Write-Warning "Windows Update:  Get-MyWindowsCapability -DisableWSUS | Add-WindowsCapability"
            }

            if (($DisableWSUS -eq $true) -and ($UseWUServer -eq 1)) {
                Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWuServer" -Value 0
                Restart-Service wuauserv
            }
        }
        #=================================================
        #   Get Module Path
        #=================================================
        $GetModuleBase = Get-OSDModulePath
        #=================================================
    }
    process {
        #=================================================
        #   Get-WindowsCapability
        #=================================================
        if ($PSCmdlet.ParameterSetName -eq 'Online') {
            $GetAllItems = Get-WindowsCapability -Online
        }
        if ($PSCmdlet.ParameterSetName -eq 'Offline') {
            $GetAllItems = Get-WindowsCapability -Path $Path
        }
        #=================================================
        #   Like
        #=================================================
        foreach ($Item in $Like) {
            $GetAllItems = $GetAllItems | Where-Object {$_.Name -like "$Item"}
        }
        #=================================================
        #   Match
        #=================================================
        foreach ($Item in $Match) {
            $GetAllItems = $GetAllItems | Where-Object {$_.Name -match "$Item"}
        }
        #=================================================
        #   State
        #=================================================
        if ($State) {$GetAllItems = $GetAllItems | Where-Object {$_.State -eq $State}}
        #=================================================
        #   Category
        #=================================================
        if ($Category -eq 'Other') {
            $GetAllItems = $GetAllItems | Where-Object {$_.Name -notmatch 'Language'}
            $GetAllItems = $GetAllItems | Where-Object {$_.Name -notmatch 'Rsat'}
        }
        if ($Category -eq 'Language') {
            $GetAllItems = $GetAllItems | Where-Object {$_.Name -match 'Language'}
        }
        if ($Category -eq 'Rsat') {
            $GetAllItems = $GetAllItems | Where-Object {$_.Name -match 'Rsat'}
        }
        #=================================================
        #   Culture
        #=================================================
        $FilteredItems = @()
        if ($Culture) {
            foreach ($Item in $Culture) {
                $FilteredItems += $GetAllItems | Where-Object {$_.Name -match $Item}
            }
        } else {
            $FilteredItems = $GetAllItems
        }
        #=================================================
        #   Dictionary
        #=================================================
        if (Test-Path "$GetModuleBase\Resources\Dictionary\Get-MyWindowsCapability.json") {
            $GetAllItemsDictionary = Get-Content "$GetModuleBase\Resources\Dictionary\Get-MyWindowsCapability.json" | ConvertFrom-Json
        }
        #=================================================
        #   Create Object
        #=================================================
        if ($Detail -eq $true) {
            $Results = foreach ($Item in $FilteredItems) {
                $ItemProductName   = ($Item.Name -split ',*~')[0]
                $ItemCulture    = ($Item.Name -split ',*~')[3]
                $ItemVersion    = ($Item.Name -split ',*~')[4]

                $ItemDetails = $null
                $ItemDetails = $GetAllItemsDictionary | `
                    Where-Object {($_.ProductName -eq $ItemProductName)} | `
                    Where-Object {($_.Culture -eq $ItemCulture)} | `
                    Select-Object -First 1

                if ($null -eq $ItemDetails) {
                    Write-Verbose "$($Item.Name) ... gathering details" -Verbose
                    if ($PSCmdlet.ParameterSetName -eq 'Online') {
                        $ItemDetails = Get-WindowsCapability -Name $Item.Name -Online
                    }
                    if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                        $ItemDetails = Get-WindowsCapability -Name $Item.Name -Path $Path
                    }
                }

                if ($PSCmdlet.ParameterSetName -eq 'Online') {
                    [PSCustomObject] @{
                        DisplayName     = $ItemDetails.DisplayName
                        Culture         = $ItemCulture
                        Version         = $ItemVersion
                        State           = $Item.State
                        Description     = $ItemDetails.Description
                        Name            = $Item.Name
                        Online          = $Item.Online
                        ProductName     = $ItemProductName
                    }
                }
                if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                    [PSCustomObject] @{
                        DisplayName     = $ItemDetails.DisplayName
                        Culture         = $ItemCulture
                        Version         = $ItemVersion
                        State           = $Item.State
                        Description     = $ItemDetails.Description
                        Name            = $Item.Name
                        Path            = $Item.Path
                        ProductName     = $ItemProductName
                    }
                }
            }
        } else {
            $Results = foreach ($Item in $FilteredItems) {
                $ItemProductName   = ($Item.Name -split ',*~')[0]
                $ItemCulture   = ($Item.Name -split ',*~')[3]
                $ItemVersion    = ($Item.Name -split ',*~')[4]

                if ($PSCmdlet.ParameterSetName -eq 'Online') {
                    [PSCustomObject] @{
                        ProductName     = $ItemProductName
                        Culture         = $ItemCulture
                        Version         = $ItemVersion
                        State           = $Item.State
                        Name            = $Item.Name
                        Online          = $Item.Online
                    }
                }
                if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                    [PSCustomObject] @{
                        ProductName     = $ItemProductName
                        Culture         = $ItemCulture
                        Version         = $ItemVersion
                        State           = $Item.State
                        Name            = $Item.Name
                        Path            = $Item.Path
                    }
                }
            }
        }
        #=================================================
        #   Rebuild Dictionary
        #=================================================
        $Results | `
        Sort-Object ProductName, Culture | `
        Select-Object Name, ProductName, Culture, DisplayName, Description | `
        ConvertTo-Json | `
        Out-File "$env:TEMP\Get-MyWindowsCapability.json" -Width 2000 -Force
        #=================================================
        #   Install / Return
        #=================================================
        if ($Install -eq $true) {
            foreach ($Item in $Results) {
                if ($_.State -eq 'Installed') {
                    Write-Verbose "$_.Name is already installed" -Verbose
                } else {
                    $Item | Add-WindowsCapability -Online
                }
            }
        } else {
            Return $Results
        }
        #=================================================
    }
    end {
        if (($DisableWSUS -eq $true) -and ($UseWUServer -eq 1)) {
            Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWuServer" -Value $UseWUServer
            Restart-Service wuauserv
        }
    }
}
function Get-MyWindowsPackage {
<#
.SYNOPSIS
Gets MyWindowsPackage information.

.DESCRIPTION
Returns MyWindowsPackage data for the current system or OSD session context.

.PARAMETER Path
Specifies the Path to use when running Get-MyWindowsPackage.

.PARAMETER PackageState
Specifies the PackageState to use when running Get-MyWindowsPackage.

.PARAMETER ReleaseType
Specifies the ReleaseType to use when running Get-MyWindowsPackage.

.PARAMETER Category
Specifies the Category to use when running Get-MyWindowsPackage.

.PARAMETER Culture
Specifies the Culture to use when running Get-MyWindowsPackage.

.PARAMETER Like
Specifies the Like to use when running Get-MyWindowsPackage.

.PARAMETER Match
Specifies the Match to use when running Get-MyWindowsPackage.

.PARAMETER Detail
Specifies the Detail to use when running Get-MyWindowsPackage.

.EXAMPLE
Get-MyWindowsPackage -Path <value>
Demonstrates a common way to run Get-MyWindowsPackage.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding(DefaultParameterSetName = 'Online')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Offline", ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [ValidateSet('Installed','Superseded')]
        [string]$PackageState,

        [ValidateSet('FeaturePack','Foundation','LanguagePack','OnDemandPack','SecurityUpdate','Update')]
        [string]$ReleaseType,

        [ValidateSet('FOD','Language','LanguagePack','Update','Other')]
        [string]$Category,

        [string[]]$Culture,

        [string[]]$Like,
        [string[]]$Match,

        [System.Management.Automation.SwitchParameter]$Detail
    )
    #=================================================
    #   Require Admin Rights
    #=================================================
    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
        Break
    }
    #=================================================
    #   Test Get-WindowsPackage
    #=================================================
    if (Get-Command -Name Get-WindowsPackage -ErrorAction SilentlyContinue) {
        Write-Verbose 'Verified command Get-WindowsPackage'
    } else {
        Write-Warning 'Get-MyWindowsPackage requires Get-WindowsPackage which is not present'
        Break
    }
    #=================================================
    #   Get Module Path
    #=================================================
    $GetModuleBase = Get-OSDModulePath
    #=================================================
    #   Get-WindowsPackage
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'Online') {
        $GetAllItems = Get-WindowsPackage -Online
    }
    if ($PSCmdlet.ParameterSetName -eq 'Offline') {
        $GetAllItems = Get-WindowsPackage -Path $Path
    }
    #=================================================
    #   Like
    #=================================================
    foreach ($Item in $Like) {
        $GetAllItems = $GetAllItems | Where-Object {$_.PackageName -like "$Item"}
    }
    #=================================================
    #   Match
    #=================================================
    foreach ($Item in $Match) {
        $GetAllItems = $GetAllItems | Where-Object {$_.PackageName -match "$Item"}
    }
    #=================================================
    #   PackageState
    #=================================================
    if ($PackageState) {$GetAllItems = $GetAllItems | Where-Object {$_.PackageState -eq $PackageState}}
    #=================================================
    #   ReleaseType
    #=================================================
    if ($ReleaseType) {$GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -eq $ReleaseType}}
    #=================================================
    #   Category
    #=================================================
    #Get-MyWindowsPackage -Category FOD
    if ($Category -eq 'FOD') {
        $GetAllItems = $GetAllItems | Where-Object {$_.PackageName -match 'FOD'}
    }
    #Get-MyWindowsPackage -Category Language
    if ($Category -eq 'Language') {
        $GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -ne 'LanguagePack'}
        $GetAllItems = $GetAllItems | Where-Object {($_.PackageName -split ',*~')[3] -ne ''}
    }
    #Get-MyWindowsPackage -Category LanguagePack
    if ($Category -eq 'LanguagePack') {
        $GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -eq 'LanguagePack'}
    }
    #Get-MyWindowsPackage -Category Update
    if ($Category -eq 'Update') {
        $GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -match 'Update'}
    }
    #Get-MyWindowsPackage -Category Other
    if ($Category -eq 'Other') {
        $GetAllItems = $GetAllItems | Where-Object {$_.PackageName -notmatch 'FOD'}
        $GetAllItems = $GetAllItems | Where-Object {($_.PackageName -split ',*~')[3] -eq ''}
        $GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -ne 'LanguagePack'}
        $GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -notmatch 'Update'}
    }
    #=================================================
    #   Culture
    #=================================================
    $FilteredItems = @()
    if ($Culture) {
        foreach ($Item in $Culture) {
            $FilteredItems += $GetAllItems | Where-Object {$_.PackageName -match "$Item"}
        }
    } else {
        $FilteredItems = $GetAllItems
    }
    #=================================================
    #   Dictionary
    #=================================================
    if (Test-Path "$GetModuleBase\Resources\Dictionary\Get-MyWindowsPackage.json") {
        $GetAllItemsDictionary = Get-Content "$GetModuleBase\Resources\Dictionary\Get-MyWindowsPackage.json" | ConvertFrom-Json
    }
    #=================================================
    #   Create Object
    #=================================================
    if ($Detail -eq $true) {
        $Results = foreach ($Item in $FilteredItems) {
            $ItemProductName    = ($Item.PackageName -split ',*~')[0]
            $ItemArchitecture   = ($Item.PackageName -split ',*~')[2]
            $ItemCulture        = ($Item.PackageName -split ',*~')[3]
            $ItemVersion        = ($Item.PackageName -split ',*~')[4]

            $ItemDetails = $null
            $ItemDetails = $GetAllItemsDictionary | `
                Where-Object {($_.ProductName -notmatch 'Package_for_DotNetRollup')} | `
                Where-Object {($_.ProductName -notmatch 'Package_for_RollupFix')} | `
                Where-Object {($_.ProductName -eq $ItemProductName)} | `
                Where-Object {($_.Culture -eq $ItemCulture)} | `
                Select-Object -First 1

            if ($null -eq $ItemDetails) {
                Write-Verbose "$($Item.PackageName) ... gathering details" -Verbose
                if ($PSCmdlet.ParameterSetName -eq 'Online') {
                    $ItemDetails = Get-WindowsPackage -PackageName $Item.PackageName -Online
                }
                if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                    $ItemDetails = Get-WindowsPackage -PackageName $Item.PackageName -Path $Path
                }
            }

            $DisplayName = $ItemDetails.DisplayName
            if ($DisplayName -eq '') {$DisplayName = $ItemProductName}
            if ($ItemProductName -match 'Package_for_DotNetRollup') {$DisplayName = 'DotNet_Cumulative_Update'}
            if ($ItemProductName -match 'Package_for_RollupFix') {$DisplayName = 'Latest_Cumulative_Update'}
            if ($ItemProductName -match 'Package_for_KB') {$DisplayName = ("$ItemProductName" -replace "Package_for_")}

            if ($PSCmdlet.ParameterSetName -eq 'Online') {
                [PSCustomObject] @{
                    DisplayName     = $DisplayName
                    Architecture    = $ItemArchitecture
                    Culture         = $ItemCulture
                    Version         = $ItemVersion
                    ReleaseType     = $Item.ReleaseType
                    PackageState    = $Item.PackageState
                    InstallTime     = $Item.InstallTime
                    CapabilityId    = $ItemDetails.CapabilityId
                    Description     = $ItemDetails.Description
                    PackageName     = $Item.PackageName
                    Online          = $Item.Online
                    ProductName     = $ItemProductName
                }
            }
            if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                [PSCustomObject] @{
                    DisplayName     = $DisplayName
                    Architecture    = $ItemArchitecture
                    Culture         = $ItemCulture
                    Version         = $ItemVersion
                    ReleaseType     = $Item.ReleaseType
                    PackageState    = $Item.PackageState
                    InstallTime     = $Item.InstallTime
                    CapabilityId    = $ItemDetails.CapabilityId
                    Description     = $ItemDetails.Description
                    PackageName     = $Item.PackageName
                    Path            = $Item.Path
                    ProductName     = $ItemProductName
                }
            }
        }
    } else {
        #Build Object
        $Results = foreach ($Item in $FilteredItems) {
            $ItemProductName    = ($Item.PackageName -split ',*~')[0]
            $ItemArchitecture   = ($Item.PackageName -split ',*~')[2]
            $ItemCulture        = ($Item.PackageName -split ',*~')[3]
            $ItemVersion        = ($Item.PackageName -split ',*~')[4]

            if ($PSCmdlet.ParameterSetName -eq 'Online') {
                [PSCustomObject] @{
                    ProductName     = $ItemProductName
                    Architecture    = $ItemArchitecture
                    Culture         = $ItemCulture
                    Version         = $ItemVersion
                    ReleaseType     = $Item.ReleaseType
                    PackageState    = $Item.PackageState
                    InstallTime     = $Item.InstallTime
                    PackageName     = $Item.PackageName
                    Online          = $Item.Online
                }
            }
            if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                [PSCustomObject] @{
                    ProductName     = $ItemProductName
                    Architecture    = $ItemArchitecture
                    Culture         = $ItemCulture
                    Version         = $ItemVersion
                    ReleaseType     = $Item.ReleaseType
                    PackageState    = $Item.PackageState
                    InstallTime     = $Item.InstallTime
                    PackageName     = $Item.PackageName
                    Path            = $Item.Path
                }
            }
        }
    }
    #=================================================
    #   Rebuild Dictionary
    #=================================================
    $Results | `
    Sort-Object ProductName, Culture | `
    Where-Object {$_.Architecture -notmatch 'wow64'} | `
    Where-Object {$_.ProductName -notmatch 'Package_for_DotNetRollup'} | `
    Where-Object {$_.ProductName -notmatch 'Package_for_RollupFix'} | `
    Where-Object {$_.PackageState -ne 'Superseded'} | `
    Select-Object PackageName, ProductName, Architecture, Culture, DisplayName, CapabilityId, Description | `
    ConvertTo-Json | `
    Out-File "$env:TEMP\Get-MyWindowsPackage.json" -Width 2000 -Force
    #=================================================
    #   Return
    #=================================================
    Return $Results
    #=================================================
}
function Mount-MyWindowsImage {
<#
.SYNOPSIS
Mounts MyWindowsImage for servicing.

.DESCRIPTION
Mounts MyWindowsImage and prepares it for offline servicing tasks.

.PARAMETER ImagePath
Specifies the ImagePath to use when running Mount-MyWindowsImage.

.PARAMETER Index
Specifies the Index to use when running Mount-MyWindowsImage.

.PARAMETER ReadOnly
Specifies the ReadOnly to use when running Mount-MyWindowsImage.

.PARAMETER Explorer
Specifies the Explorer to use when running Mount-MyWindowsImage.

.EXAMPLE
Mount-MyWindowsImage -ImagePath <value>
Demonstrates a common way to run Mount-MyWindowsImage.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$ImagePath,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [UInt32]$Index = 1,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [System.Management.Automation.SwitchParameter]$ReadOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [System.Management.Automation.SwitchParameter]$Explorer
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
        foreach ($Input in $ImagePath) {
            Write-Verbose "$Input"
            #=================================================
            #   Get-Item
            #=================================================
            if (Get-Item $Input -ErrorAction SilentlyContinue) {
                $GetItemInput = Get-Item -Path $Input
            } else {
                Write-Warning "Unable to locate WindowsImage at $Input"
                Break
            }
            #=================================================
            #   Directory
            #=================================================
            if ($GetItemInput.PSIsContainer) {
                Write-Verbose "Directory was not expected"

                if (Test-WindowsImageMountPath -Path $GetItemInput.FullName) {
                    Write-Verbose "Windows Image is already mounted in this Directory"
                    Write-Verbose "Returning Mount-WindowsImage Object"
                    Get-WindowsImage -Mounted | Where-Object {($_.Path -eq $GetItemInput.FullName) -and ($_.ImageIndex -eq $Index)}
                    Continue
                } else {
                    Write-Warning "There isn't really anything that I can do with this directory.  Goodbye!"
                    Continue
                }
            }
            #=================================================
            #   Read Only
            #=================================================
            if ($GetItemInput.IsReadOnly) {
                Write-Warning "Cannot Mount this Read Only Image.  Goodbye!"
                Continue
            }
            #=================================================
            #   Already Mounted
            #=================================================
            if (Test-WindowsImageMounted -ImagePath $GetItemInput.FullName -Index $Index) {
                Write-Verbose "Windows Image is already mounted"
                Write-Verbose "Returning Mount-WindowsImage Object"
                Get-WindowsImage -Mounted | Where-Object {($_.ImagePath -eq $GetItemInput.FullName) -and ($_.ImageIndex -eq $Index)}
                Continue
            }
            #=================================================
            #   Not a Windows Image
            #=================================================
            if (-Not (Test-WindowsImage -ImagePath $GetItemInput.FullName)) {
                Write-Warning "Does not appear to be a Windows Image.  Goodbye!"
                Continue
            }
            #=================================================
            #   Set Mount Path
            #=================================================
            $MyWindowsImageMountPath = $env:Temp + '\Mount' + (Get-Random)
            if (-NOT (Test-Path $MyWindowsImageMountPath)) {
                New-Item $MyWindowsImageMountPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
            $Path = (Get-Item $MyWindowsImageMountPath).FullName
            #=================================================
            #   Mount-WindowsImage
            #=================================================
            $Params = @{
                Path        = $Path
                ImagePath   = $GetItemInput.FullName
                Index       = $Index
                ReadOnly    = $ReadOnly
            }
            Mount-WindowsImage @Params | Out-Null
            #=================================================
            #   Explorer
            #=================================================
            if ($Explorer.IsPresent) {explorer $Path}
            #=================================================
            #   Return for PassThru
            #=================================================
            Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $Path}
        }
    }
    end {}
}
function Remove-AppxOnline {
<#
.SYNOPSIS
Removes AppxOnline items.

.DESCRIPTION
Deletes matching AppxOnline items from the current context.

.PARAMETER GridRemoveAppx
Specifies the GridRemoveAppx to use when running Remove-AppxOnline.

.PARAMETER GridRemoveAppxPP
Specifies the GridRemoveAppxPP to use when running Remove-AppxOnline.

.PARAMETER Name
Specifies the Name to use when running Remove-AppxOnline.

.EXAMPLE
Remove-AppxOnline -GridRemoveAppx <value>
Demonstrates a common way to run Remove-AppxOnline.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
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
        $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
        if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
            return
        }
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
function Test-WindowsImage {
<#
.SYNOPSIS
Tests WindowsImage conditions.

.DESCRIPTION
Evaluates WindowsImage state and returns a validation result for scripting decisions.

.PARAMETER ImagePath
Specifies the ImagePath to use when running Test-WindowsImage.

.PARAMETER Index
Specifies the Index to use when running Test-WindowsImage.

.PARAMETER Extension
Specifies the Extension to use when running Test-WindowsImage.

.EXAMPLE
Test-WindowsImage -ImagePath <value>
Demonstrates a common way to run Test-WindowsImage.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('FullName')]
        [string]$ImagePath,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Alias('ImageIndex')]
        [UInt32]$Index = $null,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [ValidateSet('.esd','.wim')]
        [string]$Extension = $null
    )
    #=================================================
    #   Test-Path
    #=================================================
    if (! (Test-Path $ImagePath)) {
        Write-Warning "Test-WindowsImage: Test-Path failed $ImagePath"
        Return $false
    }
    #=================================================
    #   Get-Item
    #=================================================
    try {
        $GetItem = Get-Item -Path $ImagePath -ErrorAction Stop
    }
    catch {
        Write-Warning "Test-WindowsImage: Get-Item failed $ImagePath"
        Return $false
    }
    #=================================================
    #   Get-Item Extension
    #=================================================
    if ($Extension) {
        if (($Extension -eq '.esd') -and ($GetItem.Extension -ne '.esd')) {
            Write-Warning "Test-WindowsImage: Get-Item Extension is not $Extension"
            Return $false
        }
        if (($Extension -eq '.wim') -and ($GetItem.Extension -ne '.wim')) {
            Write-Warning "Test-WindowsImage: Get-Item Extension is not $Extension"
            Return $false
        }
    }
    else {
        if (($GetItem.Extension -ne '.esd') -and ($GetItem.Extension -ne '.wim')) {
            Write-Warning "Test-WindowsImage: Get-Item Extension failed. File must be .esd or .wim"
            Return $false
        }
    }
    #=================================================
    #   Get-WindowsImage
    #=================================================
    if ($Index) {
        try {
            $GetWindowsImage = Get-WindowsImage -ImagePath $GetItem.FullName -Index $Index -ErrorAction Stop | Out-Null
            Return $true
        }
        catch {
            Write-Warning "Test-WindowsImage: Get-WindowsImage failed $ImagePath"
            Return $false
        }
        finally {
            $Error.Clear()
        }
    }
    else {
        try {
            $GetWindowsImage = Get-WindowsImage -ImagePath $GetItem.FullName -ErrorAction Stop | Out-Null
            Return $true
        }
        catch {
            Write-Warning "Test-WindowsImage: Get-WindowsImage failed $ImagePath"
            Return $false
        }
        finally {
            $Error.Clear()
        }
    }
    #=================================================
    #   Something didn't work right if this is run
    #=================================================
    Return $false
    #=================================================
}
function Test-WindowsImageMounted {
<#
.SYNOPSIS
Tests WindowsImageMounted conditions.

.DESCRIPTION
Evaluates WindowsImageMounted state and returns a validation result for scripting decisions.

.PARAMETER ImagePath
Specifies the ImagePath to use when running Test-WindowsImageMounted.

.PARAMETER Index
Specifies the Index to use when running Test-WindowsImageMounted.

.EXAMPLE
Test-WindowsImageMounted -ImagePath <value>
Demonstrates a common way to run Test-WindowsImageMounted.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName
        )]
        [string]$ImagePath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [UInt32]$Index = 1
    )

    if (Get-WindowsImage -Mounted | Where-Object {($_.ImagePath -eq $ImagePath) -and ($_.ImageIndex -eq $Index)}) {
        Return $true
    } else {
        Return $false
    }
}
function Test-WindowsImageMountPath {
<#
.SYNOPSIS
Tests WindowsImageMountPath conditions.

.DESCRIPTION
Evaluates WindowsImageMountPath state and returns a validation result for scripting decisions.

.PARAMETER Path
Specifies the Path to use when running Test-WindowsImageMountPath.

.EXAMPLE
Test-WindowsImageMountPath -P <value>
Demonstrates a common way to run Test-WindowsImageMountPath.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName
        )]
        [string]$Path
    )

    if (Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $Path}) {
        Return $true
    } else {
        Return $false
    }
}
function Test-WindowsPackageCAB {
<#
.SYNOPSIS
Tests WindowsPackageCAB conditions.

.DESCRIPTION
Evaluates WindowsPackageCAB state and returns a validation result for scripting decisions.

.PARAMETER PackagePath
Specifies the PackagePath to use when running Test-WindowsPackageCAB.

.PARAMETER Path
Specifies the Path to use when running Test-WindowsPackageCAB.

.EXAMPLE
Test-WindowsPackageCAB -PackagePath <value>
Demonstrates a common way to run Test-WindowsPackageCAB.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String]
        $PackagePath,

        [Parameter()]
        [System.String]
        $Path
    )

    try {
        $WinPackage = $null
        if ($Path) {
            $WinPackage = Get-WindowsPackage -Path $Path -PackagePath $PackagePath -ErrorAction SilentlyContinue
        }
        else {
            $WinPackage = Get-WindowsPackage -Online -PackagePath $PackagePath -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Verbose -Message $_.Exception.Message
    }

    Write-Verbose -Message $PackagePath
    Write-Verbose -Message $Path

    [string]$returnVal = [string]::Empty

    if ([string]::IsNullOrWhiteSpace($WinPackage.PackageName)) {
        Write-Verbose -Message 'Could not extract PackageName from PackagePath.'
    }
    else {
        switch ($WinPackage.PackageName) {
            { $_ -match 'OnePackage' } { $returnVal = 'CombinedMSU'; Break; }
            { $_ -match 'Multiple_Packages' } { $returnVal = 'CombinedLCU'; Break; }
            { $_ -match 'DotNetRollup' } { $returnVal = 'DotNetCU'; Break; }
            { $_ -match 'ServicingStack' } { $returnVal = 'SSU'; Break; }
            Default { $returnVal = $WinPackage.PackageName; Break; }
        }
        Write-Verbose -Message $returnVal
    }
    Return $returnVal
}
function Update-MyWindowsImage {
<#
.SYNOPSIS
Updates MyWindowsImage content.

.DESCRIPTION
Installs updates into MyWindowsImage according to the supplied parameters.

.PARAMETER Path
Specifies the Path to use when running Update-MyWindowsImage.

.PARAMETER Update
Specifies the Update to use when running Update-MyWindowsImage.

.PARAMETER BitsTransfer
Specifies the BitsTransfer to use when running Update-MyWindowsImage.

.PARAMETER Force
Specifies the Force to use when running Update-MyWindowsImage.

.EXAMPLE
Update-MyWindowsImage -Path <value>
Demonstrates a common way to run Update-MyWindowsImage.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String[]]$Path,

        [ValidateSet('Check','All','AdobeSU','DotNet','DotNetCU','LCU','SSU')]
        [System.String]$Update = 'Check',

        [System.Management.Automation.SwitchParameter]$BitsTransfer,

        [System.Management.Automation.SwitchParameter]$Force
    )

    begin {
        #=================================================
        #   Block
        #=================================================
        $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
        if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
            return
        }
        Block-WindowsVersionNe10
        #=================================================
        #   Get-WindowsImage Mounted
        #=================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
        #=================================================
    }
    process {
        foreach ($Input in $Path) {
            #=================================================
            #   Path
            #=================================================
            $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
            Write-Verbose "Path: $MountPath" -Verbose
            #=================================================
            #   Validate Mount Path
            #=================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Update-MyWindowsImage: Unable to locate Mounted WindowsImage at $Input"
                Break
            }
            #=================================================
            #   Get Registry Information
            #=================================================
            $global:GetRegCurrentVersion = Get-RegCurrentVersion -Path $Input
            #=================================================
            #   Require OSMajorVersion 10
            #=================================================
            if ($global:GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
                Write-Warning "Update-MyWindowsImage: OS MajorVersion 10 is required"
                Break
            }

            Write-Verbose -Verbose $global:GetRegCurrentVersion.ReleaseId
            #=================================================
            #   Get-WSUSXML and Filter Results
            #=================================================
            $global:GetWSUSXML = Get-WSUSXML -Catalog Windows -Silent | Sort-Object UpdateGroup -Descending

            if ($global:GetRegCurrentVersion.ReleaseId -gt 0) {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateBuild -eq $global:GetRegCurrentVersion.DisplayVersion}
            }
            else {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateBuild -eq $global:GetRegCurrentVersion.ReleaseId}
            }

            if ($global:GetRegCurrentVersion.BuildLabEx -match 'amd64') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateArch -eq 'x64'}
            } else {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateArch -eq 'x86'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'WindowsPE') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateOS -eq 'Windows 10'}
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -notmatch 'DotNet'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Core') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Client') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateOS -notmatch 'Server'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Server') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateOS -match 'Server'}
            }

            #Don't install Optional Updates
            $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -ne ''}

            if ($Update -ne 'Check' -and $Update -ne 'All') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -match $Update}
            }
            #=================================================
            #   Get-SessionsXml
            #=================================================
            $global:GetSessionsXml = Get-SessionsXml -Path "$Input" | Where-Object {$_.targetState -eq 'Installed'} | Sort-Object id
            #=================================================
            #   Apply Update
            #=================================================
            foreach ($item in $global:GetWSUSXML) {
                if (! ($Force.IsPresent)) {
                    if ($global:GetSessionsXml | Where-Object {$_.KBNumber -match "$($item.FileKBNumber)"}) {
                        Write-Verbose "Installed: $($item.Title) $($item.FileName)" -Verbose
                        Continue
                    } else {
                        Write-Warning "Not Installed: $($item.Title) $($item.FileName)"
                    }
                }

                if ($Update -eq 'Check') {Continue}

<#                 if ($BitsTransfer.IsPresent) {
                    $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -BitsTransfer -Verbose
                } else {
                    $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -Verbose
                } #>
                $UpdateFile = Save-WebFile -SourceUrl $item.OriginUri
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
            #=================================================
            #   Return for PassThru
            #=================================================
            Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
            #=================================================
        }
    }
    end {}
}
