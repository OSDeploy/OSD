<#
.SYNOPSIS
Performs many tasks on a WinPE.wim file.  Not good for an OS wim

.DESCRIPTION
Performs many tasks on a WinPE.wim file.  Not good for an OS wim

.LINK
https://osd.osdeploy.com/module/functions/winpewim

.NOTES
21.3.12  Initial Release
#>
function Edit-MyWinPE {
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$ImagePath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [UInt32]$Index = 1,

        [ValidateSet('Restricted','AllSigned','RemoteSigned','Unrestricted','Bypass','Undefined')]
        [string]$ExecutionPolicy,

        [String[]]$PSModuleSave,

        [String[]]$PSModuleCopy,

        [switch]$PSGallery,

        [string[]]$DriverPath,

        [switch]$DismountSave
    )

    begin {
        #=======================================================================
        #   Require Admin Rights
        #=======================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #=======================================================================
        #   Get Registry Information
        #=======================================================================
        $GetRegCurrentVersion = Get-RegCurrentVersion
        #=======================================================================
        #   Require OSMajorVersion 10
        #=======================================================================
        if ($GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
            Write-Warning "$($MyInvocation.MyCommand) requires OS MajorVersion 10"
            Break
        }
        #=======================================================================
    }
    process {
        #=======================================================================
        #   Get-WindowsImage Mounted
        #=======================================================================
        if ($null -eq $ImagePath) {
            $ImagePath = (Get-WindowsImage -Mounted | Select-Object -Property ImagePath).ImagePath
        }

        foreach ($Input in $ImagePath) {
            Write-Verbose "Edit-MyWinPE $Input"
            #=======================================================================
            #   Get-Item
            #=======================================================================
            if (Get-Item $Input -ErrorAction SilentlyContinue) {
                $GetItemInput = Get-Item -Path $Input
            } else {
                Write-Warning "Unable to locate WindowsImage at $Input"
                Continue
            }
            #=======================================================================
            #   Mount-MyWindowsImage
            #=======================================================================
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
            #=======================================================================
            #   Make sure WinPE is Major Version 10
            #=======================================================================
            Write-Verbose "Verifying WinPE 10"
            $GetRegCurrentVersion = Get-RegCurrentVersion -Path $MountMyWindowsImage.Path

            if ($GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
                Write-Warning "$($MyInvocation.MyCommand) can only service WinPE with MajorVersion 10"
                
                $MountMyWindowsImage | Dismount-MyWindowsImage -Discard
                Continue
            }
            #=======================================================================
            #   Enable PowerShell Gallery
            #=======================================================================
            if ($PSGallery) {
                $MountMyWindowsImage | Enable-PEWindowsImagePSGallery
            }
            #=======================================================================
            #   Set-WindowsImageExecutionPolicy
            #=======================================================================
            if ($ExecutionPolicy) {
                Set-WindowsImageExecutionPolicy -ExecutionPolicy $ExecutionPolicy -Path $MountMyWindowsImage.Path
            }
            #=======================================================================
            #   PSModuleCopy
            #=======================================================================
            if ($PSModuleCopy) {
                Copy-PSModuleToFolder -Name $PSModuleCopy -Destination "$($MountMyWindowsImage.Path)\Program Files\WindowsPowerShell\Modules" -RemoveOldVersions
            }
            #=======================================================================
            #   PSModuleSave
            #=======================================================================
            if ($PSModuleSave) {
                Save-Module -Name $PSModuleSave -Destination "$($MountMyWindowsImage.Path)\Program Files\WindowsPowerShell\Modules" -RemoveOldVersions
            }
            #=======================================================================
            #   DriverPath
            #=======================================================================
            foreach ($Driver in $DriverPath) {
                Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$Driver" -Recurse -ForceUnsigned
            }
            #=======================================================================
            #   Dismount-MyWindowsImage
            #=======================================================================
            if ($DismountSave) {
                $MountMyWindowsImage | Dismount-MyWindowsImage -Save
            } else {
                $MountMyWindowsImage
            }
            #=======================================================================
        }
    }
    end {}
}