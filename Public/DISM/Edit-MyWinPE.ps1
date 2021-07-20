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

        [ValidateSet('Dell','HP','Nutanix','VMware')]
        [string[]]$CloudDriver,

        [string[]]$DriverHWID,

        [string[]]$DriverPath,

        [ValidateSet('Restricted','AllSigned','RemoteSigned','Unrestricted','Bypass','Undefined')]
        [string]$ExecutionPolicy,

        [String[]]$PSModuleSave,

        [String[]]$PSModuleCopy,

        [switch]$PSGallery,

        [switch]$DismountSave
    )

    begin {
        #=======================================================================
        #	Block
        #=======================================================================
        Block-WinPE
        Block-StandardUser
        Block-WindowsVersionNe10
        Block-PowerShellVersionLt5
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
            #   DriverHWID
            #=======================================================================
            if ($DriverHWID) {
                $HardwareIDDriverPath = Join-Path $env:TEMP (Get-Random)
                foreach ($Item in $DriverHWID) {
                    Save-MsUpCatDriver -HardwareID $Item -DestinationDirectory $HardwareIDDriverPath
                }
                Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver $HardwareIDDriverPath -Recurse -ForceUnsigned
            }
            #=======================================================================
            #   CloudDriver
            #=======================================================================
            foreach ($Driver in $CloudDriver) {
                if ($Driver -eq 'Dell'){
                    Write-Verbose "Adding $Driver CloudDriver"
                    if (Test-WebConnection -Uri 'http://downloads.dell.com/FOLDER07283025M/1/WinPE10.0-Drivers-A24-45F17.CAB') {
                        $SaveWebFile = Save-WebFile -SourceUrl 'http://downloads.dell.com/FOLDER07283025M/1/WinPE10.0-Drivers-A24-45F17.CAB'
                        if (Test-Path $SaveWebFile.FullName) {
                            $DriverCab = Get-Item -Path $SaveWebFile.FullName
                            $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
                    
                            if (-NOT (Test-Path $ExpandPath)) {
                                New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                            }
                            Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                            Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose
                        }
                    }
                }
                if ($Driver -eq 'HP'){
                    Write-Verbose "Adding $Driver CloudDriver"
                    if (Test-WebConnection -Uri 'https://ftp.hp.com/pub/softpaq/sp110001-110500/sp110326.exe') {
                        $SaveWebFile = Save-WebFile -SourceUrl 'https://ftp.hp.com/pub/softpaq/sp110001-110500/sp110326.exe'
                        if (Test-Path $SaveWebFile.FullName) {
                            $DriverCab = Get-Item -Path $SaveWebFile.FullName
                            $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
        
        
                            Write-Verbose -Verbose "Expanding HP Client Windows PE Driver Pack to $ExpandPath"
                            Start-Process -FilePath $DriverCab -ArgumentList "/s /e /f `"$ExpandPath`"" -Wait
                            Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose
                        }
                    }
                }
                if ($Driver -eq 'Nutanix'){
                    Write-Verbose "Adding $Driver CloudDriver"
                    if (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/Nutanix.cab') {
                        $SaveWebFile = Save-WebFile -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/Nutanix.cab'
                        if (Test-Path $SaveWebFile.FullName) {
                            $DriverCab = Get-Item -Path $SaveWebFile.FullName
                            $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
                    
                            if (-NOT (Test-Path $ExpandPath)) {
                                New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                            }
                            Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                            Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose
                        }
                    }
                }
                if ($Driver -eq 'VMware'){
                    Write-Verbose "Adding $Driver CloudDriver"
                    if (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/VMware.cab') {
                        $SaveWebFile = Save-WebFile -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/VMware.cab'
                        if (Test-Path $SaveWebFile.FullName) {
                            $DriverCab = Get-Item -Path $SaveWebFile.FullName
                            $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
                    
                            if (-NOT (Test-Path $ExpandPath)) {
                                New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                            }
                            Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                            Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose
                        }
                    }
                }
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