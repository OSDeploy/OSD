<#
.SYNOPSIS
Mount a Windows Image (WIM), enable PowerShell Gallery, and Dismount Save

.DESCRIPTION
Mount a Windows Image (WIM), enable PowerShell Gallery, and Dismount Save

.PARAMETER ImagePath
Mandatory Path to the Windows Image (WIM)

.PARAMETER Index
Index of the Windows Image (WIM) to mount.  Default is 1 (Index 1)

.LINK

.NOTES
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
		#=================================================
		#	Blocks
		#=================================================
		Block-WinPE
		Block-StandardUser
		#=================================================
        $ErrorActionPreference = "Stop"
        #=================================================
    }
    process {
        foreach ($Input in $ImagePath) {
            #=================================================
            $WindowsImageDescription = (Get-WindowsImage -ImagePath $Input).ImageDescription
            Write-Verbose "WindowsImageDescription: $WindowsImageDescription"

            if (($WindowsImageDescription -match 'PE') -or ($WindowsImageDescription -match 'Recovery') -or ($WindowsImageDescription -match 'Setup')) {
                $MountMyWindowsImage = Mount-MyWindowsImage -ImagePath $Input -Index $Index
                $MountMyWindowsImage | Enable-PEWindowsImagePSGallery
                $MountMyWindowsImage | Dismount-MyWindowsImage -Save
            } else {
                Write-Warning "Windows Image does not appear to be WinPE, WinRE, or WinSE"
            }
            #=================================================
        }
    }
    end {}
}
<#
.SYNOPSIS
Enables PowerShell Gallery in a mounted Windows Image

.DESCRIPTION
Enables PowerShell Gallery in a mounted Windows Image

.PARAMETER Path
Path to the mounted Windows Image (WIM). If no path is specified, all mounted Windows Images (WIMs) will be targeted

.LINK

.NOTES
#>
function Enable-PEWindowsImagePSGallery {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$Path
    )

    begin {
		#=================================================
		#	Blocks
		#=================================================
		Block-WinPE
		Block-StandardUser
		#=================================================
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
            #   Driver
            #=================================================
$InfContent = @'
[Version]
Signature   = "$WINDOWS NT$"
Class       = System
ClassGuid   = {4D36E97d-E325-11CE-BFC1-08002BE10318}
Provider    = OSDeploy
DriverVer   = 03/08/2021,2021.03.08.0

[DefaultInstall] 
AddReg      = AddReg 

[AddReg]
;rootkey,[subkey],[value],[flags],[data]
;0x00000    REG_SZ
;0x00001    REG_BINARY
;0x10000    REG_MULTI_SZ
;0x20000    REG_EXPAND_SZ
;0x10001    REG_DWORD
;0x20001    REG_NONE
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",APPDATA,0x00000,"X:\Windows\System32\Config\SystemProfile\AppData\Roaming"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",HOMEDRIVE,0x00000,"X:"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",HOMEPATH,0x00000,"Windows\System32\Config\SystemProfile"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",LOCALAPPDATA,0x00000,"X:\Windows\System32\Config\SystemProfile\AppData\Local"
'@
            #=================================================
            #   Build Driver
            #=================================================
            $InfFile = "$env:Temp\Set-WinPEEnvironment.inf"
            New-Item -Path $InfFile -Force
            Set-Content -Path $InfFile -Value $InfContent -Encoding Unicode -Force
            #=================================================
            #   Add Driver
            #=================================================
            Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned
            #=================================================
            #   Save Modules
            #=================================================
            Write-Verbose "Saving PackageManagement to $MountPath\Program Files\WindowsPowerShell\Modules"
            Save-Module -Name PackageManagement -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force

            Write-Verbose "Saving PowerShellGet to $MountPath\Program Files\WindowsPowerShell\Modules"
            Save-Module -Name PowerShellGet -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
            #=================================================
            #   Return for PassThru
            #=================================================
            Return Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
            #=================================================
        }
    }
    end {}
}