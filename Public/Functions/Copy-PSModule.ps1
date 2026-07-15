function Copy-PSModuleToFolder {
    <#
    .SYNOPSIS
    Copies PowerShell modules to a destination module path.

    .DESCRIPTION
    Finds the latest installed version of each requested module and copies it to
    the destination using the standard module\version folder layout.

    .PARAMETER Name
    One or more module names to copy.

    .PARAMETER Destination
    Destination root folder for copied modules.

    .PARAMETER RemoveOldVersions
    Removes existing module content from the destination before copying.

    .EXAMPLE
    Copy-PSModuleToFolder -Name OSD -Destination 'C:\Modules'
    Copies the latest installed OSD module to C:\Modules\OSD\<version>.

    .EXAMPLE
    Copy-PSModuleToFolder -Name OSD,PackageManagement -Destination 'C:\Modules' -RemoveOldVersions
    Removes existing destination module content and copies fresh module versions.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [SupportsWildcards()]
        [String[]]$Name,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Folder')]
        [String]$Destination,

        [System.Management.Automation.SwitchParameter]$RemoveOldVersions
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
                $sourceModuleBase = $Module.ModuleBase
                $exclude = @(".git")
                Write-Verbose "Copying $sourceModuleBase to $DestinationModuleVersion"

                if (-not (Test-Path $DestinationModuleVersion)) {
                    New-Item -Path $DestinationModuleVersion -ItemType Directory -Force | Out-Null
                }

                #Copy-Item -Path "$sourceModuleBase\*" -Destination $DestinationModuleVersion -Exclude $exclude -Recurse -Force -ErrorAction Stop
                Copy-Item -Path (Get-Item -Path "$sourceModuleBase\*" -Exclude $exclude).FullName -Destination $DestinationModuleVersion -Recurse -Force


                Get-Module -ListAvailable -FullyQualifiedName $DestinationModuleVersion
            }
        }
    }
    end {}
}
function Copy-PSModuleToWim {
    <#
    .SYNOPSIS
    Copies PowerShell modules into an offline Windows image.

    .DESCRIPTION
    Mounts one or more WIM images, copies selected modules into the offline
    module path, optionally sets the image execution policy, and saves changes.

    .PARAMETER ExecutionPolicy
    Optional execution policy to set in the mounted image.

    .PARAMETER ImagePath
    One or more WIM image file paths to mount and update.

    .PARAMETER Index
    Image index to mount from each WIM. Default is 1.

    .PARAMETER Name
    One or more module names to copy into the image.

    .EXAMPLE
    Copy-PSModuleToWim -ImagePath 'C:\Media\boot.wim' -Name OSD
    Copies the latest installed OSD module into index 1 of boot.wim.

    .EXAMPLE
    Copy-PSModuleToWim -ImagePath 'C:\Media\boot.wim' -Index 2 -Name OSD -ExecutionPolicy RemoteSigned
    Copies modules to image index 2 and sets execution policy in the mounted image.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
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
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Elevated Administrator rights are required"
        }
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
