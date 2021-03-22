<#
.SYNOPSIS
Edits the boot.wim in an OSDCloud.workspace

.Description
Edits the boot.wim in an OSDCloud.workspace

.PARAMETER WorkspacePath
Directory for the OSDCloud.workspace which contains Media directory
This is optional as the OSDCloud.workspace is returned by Get-OSDCloud.workspace automatically

.PARAMETER DriverPath
Path to additional Drivers you want to install

.PARAMETER CloudDriver
Download and install in WinPE drivers from Dell,Nutanix,VMware

.LINK
https://osdcloud.osdeploy.com

.NOTES
21.3.16     Initial Release
#>
function Edit-OSDCloud.winpe {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$WorkspacePath,

        [string[]]$DriverPath,

        [ValidateSet('Dell','Nutanix','VMware')]
        [string[]]$CloudDriver
    )
    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $WinpeStartTime = Get-Date
    #=======================================================================
    #	Block
    #=======================================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=======================================================================
    #	Get-OSDCloud.template
    #=======================================================================
    if (-NOT (Get-OSDCloud.template)) {
        Write-Warning "Setting up a new OSDCloud.template"
        New-OSDCloud.template -Verbose
    }

    $OSDCloudTemplate = Get-OSDCloud.template
    if (-NOT ($OSDCloudTemplate)) {
        Write-Warning "Something bad happened.  I have to go"
        Break
    }
    #=======================================================================
    #	Set WorkspacePath
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloud.workspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    $WorkspacePath = Get-OSDCloud.workspace -ErrorAction Stop
    #=======================================================================
    #	Setup Workspace
    #=======================================================================
    if (-NOT ($WorkspacePath)) {
        Write-Warning "You need to provide a path to your Workspace with one of the following examples"
        Write-Warning "New-OSDCloud.iso -WorkspacePath C:\OSDCloud"
        Write-Warning "New-OSDCloud.workspace -WorkspacePath C:\OSDCloud"
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        New-OSDCloud.workspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media")) {
        New-OSDCloud.workspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "Nothing is going well for you today my friend"
        Break
    }
    #=======================================================================
    #   Mount-MyWindowsImage
    #=======================================================================
    $MountMyWindowsImage = Mount-MyWindowsImage -ImagePath "$WorkspacePath\Media\Sources\boot.wim"
    $MountPath = $MountMyWindowsImage.Path
    #=======================================================================
    #   Add AutoPilot Profiles
    #=======================================================================
    robocopy "$WorkspacePath\AutoPilot" "$MountPath\OSDCloud\AutoPilot" *.* /e /ndl /njh /njs /b
    #=======================================================================
    #   DriverPath
    #=======================================================================
    foreach ($Driver in $DriverPath) {
        Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$Driver" -Recurse -ForceUnsigned
    }
    foreach ($Driver in $CloudDriver) {
        if ($Driver -eq 'Dell'){
            Write-Verbose "Adding $Driver CloudDriver"
            if (Test-WebConnection -Uri 'http://downloads.dell.com/FOLDER07062618M/1/WINPE10.0-DRIVERS-A23-PR4K0.CAB') {
                $SaveWebFile = Save-WebFile -SourceUrl 'http://downloads.dell.com/FOLDER07062618M/1/WINPE10.0-DRIVERS-A23-PR4K0.CAB'
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
            
                    if (-NOT (Test-Path $ExpandPath)) {
                        New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                    }
                    Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned
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
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned
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
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned
                }
            }
        }
    }
    #=======================================================================
    #   Startnet
    #=======================================================================
    Write-Verbose "Adding PowerShell.exe to Startnet.cmd"
    $Startnet = Get-Content -Path "$MountPath\Windows\System32\Startnet.cmd"
    if ($Startnet -notmatch "start powershell") {
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start powershell.exe' -Force
    }
    #=======================================================================
    #   Install OSD Module
    #=======================================================================
    Write-Verbose "Saving OSD to $MountPath\Program Files\WindowsPowerShell\Modules"
    Save-Module -Name OSD -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    #=======================================================================
    #   Save WIM
    #=======================================================================
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #=======================================================================
    #	Complete
    #=======================================================================
    $WinpeEndTime = Get-Date
    $WinpeTimeSpan = New-TimeSpan -Start $WinpeStartTime -End $WinpeEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($WinpeTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=======================================================================
}