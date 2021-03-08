<#
.SYNOPSIS
Gets PowerShell Gallery working in WinPE

.DESCRIPTION
Gets PowerShell Gallery working in WinPE

.LINK
https://osd.osdeploy.com/module/functions/winpe/enable-pewimpsgallery

.NOTES
21.3.8     Initial Release
#>
function Enable-PEWimPSGallery {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$ImagePath,

        [Parameter(ValueFromPipelineByPropertyName)]
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
        $ErrorActionPreference = "Stop"
        #===================================================================================================
    }
    process {
        foreach ($Input in $ImagePath) {
            #===============================================================================================
            $MountWindowsImageOSD = Mount-MyWindowsImage -ImagePath $Input -Index $Index
            $MountWindowsImageOSD | Set-WindowsImageWinPEEnvironment

            Write-Verbose "Saving PackageManagement to $($MountWindowsImageOSD.Path)\Program Files\WindowsPowerShell\Modules"
            Save-Module -Name PackageManagement "$($MountWindowsImageOSD.Path)\Program Files\WindowsPowerShell\Modules" -Force

            Write-Verbose "Saving PowerShellGet to $($MountWindowsImageOSD.Path)\Program Files\WindowsPowerShell\Modules"
            Save-Module -Name PowerShellGet "$($MountWindowsImageOSD.Path)\Program Files\WindowsPowerShell\Modules" -Force

            $MountWindowsImageOSD | Dismount-MyWindowsImage -Save
            #===============================================================================================
        }
    }
    end {}
}