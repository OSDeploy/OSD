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
