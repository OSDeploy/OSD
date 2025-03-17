function Edit-MyWinPE {
    <#
    .SYNOPSIS
    Mounts and edits a WinPE WIM file

    .DESCRIPTION
    Mounts and edits a WinPE WIM file

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding(PositionalBinding = $false)]
    param (
        #Path to the WinPE WIM file. This file must be local and not on a USB or Network Share
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String[]]$ImagePath,

        #Index of the WinPE WIM file to mount. Default is 1
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt32]$Index = 1,

        #WinPE Driver: Download and install in WinPE drivers from Dell,HP,IntelNet,LenovoDock,Nutanix,Surface,USB,VMware,WiFi
        [ValidateSet('*','Dell','HP','IntelNet','LenovoDock','Surface','Nutanix','USB','VMware','WiFi')]
        [System.String[]]$CloudDriver,

        #WinPE Driver: HardwareID of the Driver to add to WinPE
        [Alias('HardwareID')]
        [System.String[]]$DriverHWID,

        #WinPE Driver: Path to additional Drivers you want to add to WinPE
        [System.String[]]$DriverPath,

        #PowerShell: Sets the PowerShell Execution Policy of WinPE.  Bypass is recommended
        [ValidateSet('Restricted','AllSigned','RemoteSigned','Unrestricted','Bypass','Undefined')]
        [System.String]$ExecutionPolicy,

        #PowerShell: Installs named PowerShell Modules from PowerShell Gallery to WinPE
        [Alias('PSModuleSave')]
        [System.String[]]$PSModuleInstall,

        #PowerShell: Copies named PowerShell Modules from the running OS to WinPE
        #This is useful for adding Modules that are customized or not on PowerShell Gallery
        [System.String[]]$PSModuleCopy,

        #PowerShell: Enables PowerShell Gallery functionality in WinPE
        [System.Management.Automation.SwitchParameter]$PSGallery,

        #Sets the specified Wallpaper JPG file as the WinPE Background
        [System.String]$Wallpaper,

        #Dismounts and saves changes to the mounted WinPE WIM
        [System.Management.Automation.SwitchParameter]$DismountSave
    )

    begin {
        #=================================================
        #	Block
        #=================================================
        Block-WinPE
        Block-StandardUser
        Block-WindowsVersionNe10
        Block-PowerShellVersionLt5
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
        #=================================================
        #   Get-WindowsImage Mounted
        #=================================================
        if ($null -eq $ImagePath) {
            $ImagePath = (Get-WindowsImage -Mounted | Select-Object -Property ImagePath).ImagePath
        }

        foreach ($Input in $ImagePath) {
            Write-Verbose "Edit-MyWinPE $Input"
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
                $MountPath = $MountMyWindowsImage.Path
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
            $GetRegCurrentVersion = Get-RegCurrentVersion -Path $MountPath

            if ($GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
                Write-Warning "$($MyInvocation.MyCommand) can only service WinPE with MajorVersion 10"
                
                $MountMyWindowsImage | Dismount-MyWindowsImage -Discard
                Continue
            }
            #=================================================
            #   Enable PowerShell Gallery
            #=================================================
            if ($PSGallery) {
                $MountMyWindowsImage | Enable-PEWindowsImagePSGallery
            }
            #=================================================
            #   Set-WindowsImageExecutionPolicy
            #=================================================
            if ($ExecutionPolicy) {
                Set-WindowsImageExecutionPolicy -ExecutionPolicy $ExecutionPolicy -Path $MountPath
            }
            #=================================================
            #   DriverHWID
            #=================================================
            if ($DriverHWID) {
                $AddWindowsDriverPath = Join-Path $env:TEMP (Get-Random)
                foreach ($Item in $DriverHWID) {
                    Save-MsUpCatDriver -HardwareID $Item -DestinationDirectory $AddWindowsDriverPath
                }
                try {
                    Add-WindowsDriver -Path "$MountPath" -Driver $AddWindowsDriverPath -Recurse -ForceUnsigned -Verbose | Out-Null
                }
                catch {
                    Write-Warning "Unable to find a driver for $Item"
                }
            }
            #=================================================
            #   CloudDriver
            #=================================================
            if ($CloudDriver) {
                foreach ($Driver in $CloudDriver) {
                    $AddWindowsDriverPath = Save-WinPECloudDriver -CloudDriver $Driver -Path (Join-Path $env:TEMP (Get-Random))
                    Add-WindowsDriver -Path "$MountPath" -Driver "$AddWindowsDriverPath" -Recurse -ForceUnsigned -Verbose | Out-Null
                }
                $null = Save-WindowsImage -Path $MountPath
            }
            #=================================================
            #   DriverPath
            #=================================================
            foreach ($AddWindowsDriverPath in $DriverPath) {
                Add-WindowsDriver -Path "$MountPath" -Driver "$AddWindowsDriverPath" -Recurse -ForceUnsigned -Verbose
            }
            #=================================================
            #   Wallpaper
            #=================================================
            if ($Wallpaper) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Wallpaper: $Wallpaper"
                Copy-Item -Path $Wallpaper -Destination "$env:TEMP\winpe.jpg" -Force | Out-Null
                Copy-Item -Path $Wallpaper -Destination "$env:TEMP\winre.jpg" -Force | Out-Null
                robocopy "$env:TEMP" "$MountPath\Windows\System32" winpe.jpg /ndl /njh /njs /b /np /r:0 /w:0
                robocopy "$env:TEMP" "$MountPath\Windows\System32" winre.jpg /ndl /njh /njs /b /np /r:0 /w:0
            }
            #=================================================
            #   PSModuleInstall
            #=================================================
            foreach ($Module in $PSModuleInstall) {
                if ($Module -eq 'DellBiosProvider') {
                    if (Test-Path "$env:SystemRoot\System32\msvcp140.dll") {
                        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $env:SystemRoot\System32\msvcp140.dll to WinPE"
                        Copy-Item -Path "$env:SystemRoot\System32\msvcp140.dll" -Destination "$MountPath\System32" -Force | Out-Null
                    }
                    if (Test-Path "$env:SystemRoot\System32\vcruntime140.dll") {
                        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $env:SystemRoot\System32\vcruntime140.dll to WinPE"
                        Copy-Item -Path "$env:SystemRoot\System32\vcruntime140.dll" -Destination "$MountPath\System32" -Force | Out-Null
                    }
                    if (Test-Path "$env:SystemRoot\System32\msvcp140.dll") {
                        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $env:SystemRoot\System32\vcruntime140_1.dll to WinPE"
                        Copy-Item -Path "$env:SystemRoot\System32\vcruntime140_1.dll" -Destination "$MountPath\System32" -Force | Out-Null
                    }
                }
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving $Module to $MountPath\Program Files\WindowsPowerShell\Modules"
                Save-Module -Name $Module -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
            }
            #=================================================
            #   PSModuleCopy
            #=================================================
            foreach ($Module in $PSModuleCopy) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copy-PSModuleToWindowsImage -Name $Module -Path $MountPath"
                Copy-PSModuleToWindowsImage -Name $Module -Path $MountPath
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
    end {}
}
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
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",APPDATA,0x00000,"%SystemRoot%\System32\Config\SystemProfile\AppData\Roaming"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",HOMEDRIVE,0x00000,"X:"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",HOMEPATH,0x00000,"Windows\System32\Config\SystemProfile"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",LOCALAPPDATA,0x00000,"%SystemRoot%\System32\Config\SystemProfile\AppData\Local"
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
<#
.SYNOPSIS
Sets the PowerShell Execution Policy of a Windows Image .wim file (Mount | Set | Dismount -Save)

.DESCRIPTION
Sets the PowerShell Execution Policy of a Windows Image .wim file (Mount | Set | Dismount -Save)

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

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
21.2.1  Initial Release
#>
function Set-WimExecutionPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Restricted','AllSigned','RemoteSigned','Unrestricted','Bypass','Undefined')]
        [string]$ExecutionPolicy,

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
    }
    process {
        foreach ($Input in $ImagePath) {
            #=================================================
            $MountMyWindowsImage = Mount-MyWindowsImage -ImagePath $Input -Index $Index
            $MountMyWindowsImage | Set-WindowsImageExecutionPolicy -ExecutionPolicy $ExecutionPolicy
            $MountMyWindowsImage | Dismount-MyWindowsImage -Save
            #=================================================
        }
    }
    end {}
}
<#
.SYNOPSIS
Sets the PowerShell Execution Policy of a mounted Windows Image

.DESCRIPTION
Sets the PowerShell Execution Policy of a mounted Windows Image

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
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
21.2.1  Initial Release
#>
function Set-WindowsImageExecutionPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Restricted','AllSigned','RemoteSigned','Unrestricted','Bypass','Undefined')]
        [string]$ExecutionPolicy,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$Path
    )

    begin {
		#=================================================
		#	Blocks
		#=================================================
		#Block-WinPE
		Block-StandardUser
        #=================================================
        #   Get-WindowsImage Mounted
        #=================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
        #=================================================
        #   Driver
        #=================================================
$InfHeader = @'
[Version]
Signature   = "$WINDOWS NT$"
Class       = System
ClassGuid   = {4D36E97d-E325-11CE-BFC1-08002BE10318}
Provider    = OSDeploy
DriverVer   = 2/1/2021,2021.2.1.0
'@
$InfMain = @"
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
HKLM,SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell,ExecutionPolicy,0x00000,"$ExecutionPolicy"
"@
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
            #   Build Driver
            #=================================================
            $InfFile = "$env:Temp\Set-ExecutionPolicy.inf"
            New-Item -Path $InfFile -Force
            Set-Content -Path $InfFile -Value $InfHeader -Encoding Unicode -Force
            Add-Content -Path $InfFile -Value $InfMain -Encoding Unicode -Force
            #=================================================
            #   Add Driver
            #=================================================
            Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned
            #=================================================
            #   Return for PassThru
            #=================================================
            Return Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
            #=================================================
        }
    }
    end {}
}
