<#
.SYNOPSIS
Get-Module and copy the ModuleBase to a new Destination\ModuleBase

.DESCRIPTION
Get-Module and copy the ModuleBase to a new Destination\ModuleBase

.PARAMETER Name
Name of the PowerShell Module to Copy

.PARAMETER Destination
Destination PSModule directory
Copied Module is a Child of Destination

.PARAMETER RemoveOldVersions
Removes older Module Versions from the Destination

.LINK
https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletofolder

.NOTES
21.1.30.1   Initial Release
21.1.30.2   Added WinPE Parameter
21.1.30.3   Renamed PSModulePath Parameter to Destination, Added RemoveOldVersions
21.1.31.1   Removed WinPE Parameter
21.2.2.1	Renamed to Copy-ModuleToFolder so I don't mess with PowerShellGet
21.2.9.1	Renamed to Copy-PSModuleToFolder to standardize
#>
function Copy-PSModuleToFolder {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [SupportsWildcards()]
        [String[]]$Name,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Folder')]
        [String]$Destination,

        [switch]$RemoveOldVersions
    )

    begin {
        Write-Verbose "Destination: $Destination"
    }
    process {
        foreach ($Item in $Name) {

            #GetModule
            $GetModule = @()
            $GetModule = Get-Module -ListAvailable -Name $Item | Select-Object Name, Version, ModuleBase
            $GetModule = $GetModule | Sort-Object Name, Version -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}

            if ($null -eq $GetModule) {
                Write-Warning "Unable to find Module in Get-Module -ListAvailable -Name '$Item'"
                Continue
            }
            
            foreach ($Module in $GetModule) {
                Write-Verbose "Module Name: $($Module.Name)"
                Write-Verbose "Module Version: $($Module.Version)"
                Write-Verbose "Module ModuleBase: $($Module.ModuleBase)"

                #Get the Path to the Destination Module
                $DestinationModule = Join-Path -Path $Destination -ChildPath $Module.Name

                #If RemoveOldVersions
                if ($RemoveOldVersions -eq $true) {
                    if (Test-Path $DestinationModule) {
                        Write-Warning "Removing $DestinationModule"
                        Remove-Item -Path $DestinationModule -Recurse -Force -ErrorAction Stop
                    }
                }

                #Remove Module if PSD1 is not in a Version subdirectory
                if (Test-Path "$DestinationModule\*.psd1") {
                    Write-Warning "Destination Module contains a Manifest in '$DestinationModule'.  Content will be replaced"
                    Write-Warning "Removing $DestinationModule"
                    Remove-Item -Path $DestinationModule -Recurse -Force -ErrorAction Stop
                }
                
                #Destination is set to the Windows Format with Version in the Destination
                $DestinationModuleVersion = Join-Path -Path $DestinationModule -ChildPath $Module.Version
                if (Test-Path $DestinationModuleVersion) {
                    Write-Warning "Destination Module exists at '$DestinationModuleVersion'.  Content will be replaced"
                    Write-Warning "Removing $DestinationModuleVersion"
                    Remove-Item -Path $DestinationModuleVersion -Recurse -Force -ErrorAction Stop
                }

                #Copy to the Destination
                Write-Verbose "Copying '$($Module.ModuleBase)' to $DestinationModuleVersion"
                Copy-Item -Path $Module.ModuleBase -Destination $DestinationModuleVersion -Recurse -Force -ErrorAction Stop
                Get-Module -ListAvailable -FullyQualifiedName $DestinationModuleVersion
            }
        }
    }
    end {}
}
<#
.SYNOPSIS
Copies the latest installed named PowerShell Module to a Windows Image .wim file (Mount | Copy | Dismount -Save)

.DESCRIPTION
Copies the latest installed named PowerShell Module to a Windows Image .wim file (Mount | Copy | Dismount -Save)

.PARAMETER ExecutionPolicy
Specifies the new execution policy. The acceptable values for this parameter are:
- Restricted. Does not load configuration files or run scripts. Restricted is the default execution policy.
- AllSigned. Requires that all scripts and configuration files be signed by a trusted publisher, including scripts that you write on the local computer.
- RemoteSigned. Requires that all scripts and configuration files downloaded from the Internet be signed by a trusted publisher.
- Unrestricted. Loads all configuration files and runs all scripts. If you run an unsigned script that was downloaded from the Internet, you are prompted for permission before it runs.
- Bypass. Nothing is blocked and there are no warnings or prompts.
- Undefined. Removes the currently assigned execution policy from the current scope. This parameter will not remove an execution policy that is set in a Group Policy scope.

.PARAMETER ImagePath
Specifies the location of the WIM or VHD file containing the Windows image you want to mount.

.PARAMETER Index
Index of the WIM to Mount
Default is 1

.PARAMETER Name
Name of the PowerShell Module to Copy

.LINK
https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletowim

.NOTES
21.2.9  Initial Release
#>
function Copy-PSModuleToWim {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Restricted','AllSigned','RemoteSigned','Unrestricted','Bypass','Undefined')]
        [string]$ExecutionPolicy,

        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName)]
        [string[]]$ImagePath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [UInt32]$Index = 1,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [SupportsWildcards()]
        [String[]]$Name
    )

    begin {
		#=================================================
		#	Blocks
		#=================================================
		Block-WinPE
		Block-StandardUser
        #=================================================
    }
    process {
        foreach ($Input in $ImagePath) {
            #=================================================
            #   Mount-MyWindowsImage
            #=================================================
            $MountMyWindowsImage = Mount-MyWindowsImage -ImagePath $Input -Index $Index
            #=================================================
            #   Copy-PSModuleToFolder
            #=================================================
            Copy-PSModuleToFolder -Name $Name -Destination "$($MountMyWindowsImage.Path)\Program Files\WindowsPowerShell\Modules" -RemoveOldVersions
            #=================================================
            #   Set-WindowsImageExecutionPolicy
            #=================================================
            if ($ExecutionPolicy) {
                Set-WindowsImageExecutionPolicy -ExecutionPolicy $ExecutionPolicy -Path $MountMyWindowsImage.Path
            }
            #=================================================
            #   Dismount-MyWindowsImage
            #=================================================
            $MountMyWindowsImage | Dismount-MyWindowsImage -Save
            #=================================================
        }
    }
    end {}
}
<#
.SYNOPSIS
Copies the latest installed named PowerShell Module to a mounted Windows Image

.DESCRIPTION
Copies the latest installed named PowerShell Module to a mounted Windows Image

.PARAMETER ExecutionPolicy
Specifies the new execution policy. The acceptable values for this parameter are:
- Restricted. Does not load configuration files or run scripts. Restricted is the default execution policy.
- AllSigned. Requires that all scripts and configuration files be signed by a trusted publisher, including scripts that you write on the local computer.
- RemoteSigned. Requires that all scripts and configuration files downloaded from the Internet be signed by a trusted publisher.
- Unrestricted. Loads all configuration files and runs all scripts. If you run an unsigned script that was downloaded from the Internet, you are prompted for permission before it runs.
- Bypass. Nothing is blocked and there are no warnings or prompts.
- Undefined. Removes the currently assigned execution policy from the current scope. This parameter will not remove an execution policy that is set in a Group Policy scope.

.PARAMETER Path
Specifies the full path to the root directory of the offline Windows image that you will service
If a Path is not specified, all mounted Windows Images will be modified

.LINK
https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletowindowsimage

.NOTES
21.3.8  Resolved issue where Name parameter was missing
21.2.9  Initial Release#>
function Copy-PSModuleToWindowsImage {
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