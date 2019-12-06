<#
.SYNOPSIS
Edits a mounted Windows Image WIM file

.DESCRIPTION
Edits a mounted Windows Image WIM file

.LINK
https://osd.osdeploy.com/module/functions/edit-osdwindowsimage

.NOTES
19.11.22 David Segura @SeguraOSD
#>
function Edit-OSDWIM {
    [CmdletBinding()]
    Param (
        #Specifies the full path to the root directory of the offline Windows image that you will service.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Path,

        #Download the file using BITS-Transfer
        #Interactive Login required
        [switch]$RemoveAppx
    )

    Begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning 'Edit-OSDWindowsImage: This function requires Admin Rights ELEVATED'
            Break
        }
        #===================================================================================================
        #   Get-WindowsImage Mounted
        #===================================================================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
    }
    Process {
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
                Write-Warning "Edit-OSDWindowsImage: Unable to locate Mounted WindowsImage at $Input"
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
                Write-Warning "Edit-OSDWindowsImage: OS MajorVersion 10 is required"
                Break
            }
            #===================================================================================================
            #   Get Registry Information
            #===================================================================================================
            if ($RemoveAppx.IsPresent) {
                Get-AppxProvisionedPackage -Path $Input | Select-Object DisplayName, PackageName | Out-GridView -PassThru | Remove-AppProvisionedPackage -Path $Input
            }
            #===================================================================================================
            #   Return for PassThru
            #===================================================================================================
            Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
        }
    }
    End {}
}