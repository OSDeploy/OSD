<#
.SYNOPSIS
Creates an .iso file in the OSDCloud Workspace.  ADK is required

.Description
Creates an .iso file in the OSDCloud Workspace.  ADK is required

.PARAMETER WorkspacePath
Directory for the Workspace.  Contains the Media directory

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
        [string]$WorkspacePath,

        #[string]$isoFileName = 'OSDCloud.iso',

        #[ValidateLength(1,16)]
        #[string]$isoLabel = 'OSDCloud',

        [string[]]$DriverPath,

        [ValidateSet('Dell','Nutanix','VMware')]
        [string[]]$CloudDriver
    )
    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $IsoStartTime = Get-Date
    #=======================================================================
    #	Block
    #=======================================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsMajorLt10
    Block-PowerShellVersionLt5
    Block-NonCurl
    #=======================================================================
    #	Set Variables
    #=======================================================================
    $isoFileName = 'OSDCloud.iso'
    $isoLabel = 'OSDCloud'
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
    #   Install OSD Module
    #=======================================================================
    #Write-Verbose "Saving OSD to $MountPath\Program Files\WindowsPowerShell\Modules"
    #Save-Module -Name OSD -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    #=======================================================================
    #   Save WIM
    #=======================================================================
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #=======================================================================
    #   Create ISO
    #=======================================================================
    $NewADKiso = New-ADK.iso -MediaPath "$WorkspacePath\Media" -isoFileName $isoFileName -isoLabel $isoLabel
    #=======================================================================
    #   Restore VerbosePreference
    #=======================================================================
    $VerbosePreference = $CurrentVerbosePreference
    #=======================================================================
    #	Complete
    #=======================================================================
    $IsoEndTime = Get-Date
    $IsoTimeSpan = New-TimeSpan -Start $IsoStartTime -End $IsoEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($IsoTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=======================================================================
    #	Return
    #=======================================================================
    Write-Host -ForegroundColor Cyan        "OSDCloud ISO created at $($NewADKiso.FullName)"
    #Write-Host -ForegroundColor Cyan        "OSDCloud ISO Get-Item is saved in the Global Variable OSDCloudISO"

    explorer $WorkspacePath
    #Return (Get-Item -Path $NewADKiso.FullName | Select-Object -Property *)
    #Return $NewADKiso.FullName
    #=======================================================================
}