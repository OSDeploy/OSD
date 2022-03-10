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