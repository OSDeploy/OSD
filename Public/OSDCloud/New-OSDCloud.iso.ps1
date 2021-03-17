<#
.SYNOPSIS
Creates an .iso file from a bootable media directory.  ADK is required

.Description
Creates a .iso file from a bootable media directory.  ADK is required

.PARAMETER WorkspacePath
Directory for the Workspace.  This will contain the Media directory and the .iso file
If not given, one will be created in $env:TEMP\OSDCloud

.PARAMETER isoFileName
File Name of the ISO

.PARAMETER isoLabel
Lable of the ISO.  Limited to 16 characters

.PARAMETER CloudDriver
Download and install in WinPE drivers from Dell,Nutanix,VMware

.LINK
https://osdcloud.osdeploy.com

.NOTES
21.3.16     Initial Release
#>
function New-OSDCloud.iso {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$WorkspacePath = (Join-Path $env:TEMP (Join-Path OSDCloud (Get-Random))),

        #[string]$isoFileName = 'OSDCloud.iso',

        #[ValidateLength(1,16)]
        #[string]$isoLabel = 'OSDCloud',

        [string[]]$DriverPath,

        [ValidateSet('Dell','Nutanix','VMware')]
        [string[]]$CloudDriver
    )
    $isoFileName = 'OSDCloud.iso'
    $isoLabel = 'OSDCloud'
    #===============================================================================================
    #	Start the Clock
    #===============================================================================================
    $IsoStartTime = Get-Date
    #==================================================================================================
    #	Require WinOS
    #==================================================================================================
    if ((Get-OSDGather -Property IsWinPE)) {
        Write-Warning "$($MyInvocation.MyCommand) cannot be run from WinPE"
        Break
    }
    #===============================================================================================
    #   Require Admin Rights
    #===============================================================================================
    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
        Break
    }
    #===============================================================================================
    #   Require cURL
    #===============================================================================================
    if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
        Write-Warning "$($MyInvocation.MyCommand) could not find $env:SystemRoot\System32\curl.exe"
        Write-Warning "Get a newer Windows version!"
        Break
    }
    #===============================================================================================
    #	Set VerbosePreference
    #===============================================================================================
    $CurrentVerbosePreference = $VerbosePreference
    $VerbosePreference = 'Continue'
    #===============================================================================================
    #	Global:OSDCloudWorkspace
    #===============================================================================================
    if (Test-OSDCloud.workspace -WorkspacePath $WorkspacePath) {
        $Global:OSDCloudWorkspace = (Get-Item -Path $WorkspacePath | Select-Object -Property *)
    }
    else {
        New-OSDCloud.workspace -WorkspacePath $WorkspacePath -Verbose
    }
    #===============================================================================================
    #   Mount-MyWindowsImage
    #===============================================================================================
    $MountMyWindowsImage = Mount-MyWindowsImage -ImagePath "$WorkspacePath\Media\Sources\boot.wim"
    $MountPath = $MountMyWindowsImage.Path
    #===============================================================================================
    #   Add AutoPilot Profiles
    #===============================================================================================
    robocopy "$WorkspacePath\AutoPilot" "$MountPath\OSDCloud\AutoPilot" *.* /e /ndl /njh /njs /b
    #===============================================================================================
    #   Enable PowerShell Gallery
    #===============================================================================================
    #Write-Verbose "Saving OSD to $MountPath\Program Files\WindowsPowerShell\Modules"
    #Save-Module -Name OSD -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    #===============================================================================================
    #   DriverPath
    #===============================================================================================
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
    #===============================================================================================
    #   Save WIM
    #===============================================================================================
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #===============================================================================================
    #   Create ISO
    #===============================================================================================
    $NewADKiso = New-ADK.iso -MediaPath "$WorkspacePath\Media" -isoFileName $isoFileName -isoLabel $isoLabel -OpenExplorer
    #===============================================================================================
    #   Restore VerbosePreference
    #===============================================================================================
    $VerbosePreference = $CurrentVerbosePreference
    #===============================================================================================
    #	Complete
    #===============================================================================================
    $IsoEndTime = Get-Date
    $IsoTimeSpan = New-TimeSpan -Start $IsoStartTime -End $IsoEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($IsoTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #===============================================================================================
    #	Return
    #===============================================================================================
    $Global:OSDCLoudISO = (Get-Item -Path $NewADKiso.FullName | Select-Object -Property *)
    Write-Host -ForegroundColor Cyan        "OSDCloud ISO created at $($Global:OSDCLoudISO.FullName)"
    Write-Host -ForegroundColor Cyan        "OSDCloud ISO Get-Item is saved in the Global Variable OSDCLoudISO"

    explorer $WorkspacePath
    Return $Global:OSDCLoudISO
    #===============================================================================================
}