<#
.SYNOPSIS
Sets the PowerShell Execution Policy of a .wim File

.DESCRIPTION
Sets the PowerShell Execution Policy of a .wim File

.LINK
https://osd.osdeploy.com/module/functions/PowerShellGet

.NOTES
21.2.1  Initial Release
#>
function Copy-PSModuleToWim {
    [CmdletBinding()]
    param (
        #Name of the PowerShell Module to Copy
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [SupportsWildcards()]
        [String[]]$Name,

        #Specifies the location of the WIM or VHD file containing the Windows image you want to mount.
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$ImagePath,

        #Index of the WIM to Mount
        #Default is 1
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [UInt32]$Index = 1
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
            #===============================================================================================
            $MountWindowsImageOSD = Mount-MyWindowsImage -ImagePath $Input -Index $Index
            Copy-PSModuleToFolder -Name $Name -Destination "$($MountWindowsImageOSD.Path)\Program Files\WindowsPowerShell\Modules" -RemoveOldVersions
            #$MountWindowsImageOSD | Dismount-MyWindowsImage -Save
            #===============================================================================================
        }
    }
    end {}
}