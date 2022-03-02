<#
.SYNOPSIS
Creates or updates an OSDCloud Workspace

.DESCRIPTION
Creates or updates an OSDCloud Workspace from an OSDCloud Template

.PARAMETER WorkspacePath
Directory for the OSDCloud Workspace to create or update.  Default is $env:SystemDrive\OSDCloud

.LINK
https://osdcloud.osdeploy.com
#>
function New-xOSDCloudWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [System.String]$WorkspacePath = "$env:SystemDrive\OSDCloud"
    )
    $Global:OSDRobocopyLogs = @()
    #=================================================
    #	Blocks
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #	Get-OSDCloudTemplate
    #=================================================
    if (!(Get-OSDCloudTemplate)) {
        Write-Verbose "========================================================================="
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting up a new OSDCloudTemplate"
        Write-Verbose "========================================================================="
        New-OSDCloudTemplate
    }

    $OSDCloudTemplate = Get-OSDCloudTemplate
    if (!($OSDCloudTemplate)) {
        Write-Verbose "========================================================================="
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something bad happened.  I have to go"
        Write-Verbose "========================================================================="
        Break
    }
    #=================================================
    #	Remove Old Autopilot Content
    #=================================================
    if (Test-Path "$env:ProgramData\OSDCloud\Autopilot") {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Move all your Autopilot Profiles to $env:ProgramData\OSDCloud\Config\AutopilotJSON"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You will be unable to create or update an OSDCloud Workspace until $env:ProgramData\OSDCloud\Autopilot is manually removed"
        Break
    }
    if (Test-Path "$WorkspacePath\Autopilot") {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Move all your Autopilot Profiles to $WorkspacePath\Config\AutopilotJSON"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You will be unable to create or update an OSDCloud Workspace until $WorkspacePath\Autopilot is manually removed"
        Break
    }
    #=================================================
    #	Set WorkspacePath
    #=================================================
    Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    #=================================================
    #	Create WorkspacePath
    #=================================================
    if (!(Test-Path $WorkspacePath)) {
        New-Item -Path $WorkspacePath -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    #   Logs
    #=================================================
    $WorkspaceLogs = "$WorkspacePath\Logs\Workspace"
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Workspace Logs at $WorkspaceLogs"

    if (Test-Path $WorkspaceLogs) {
        $null = Remove-Item -Path "$WorkspaceLogs\*" -Recurse -Force -ErrorAction Ignore | Out-Null
    }
    if (-NOT (Test-Path $WorkspaceLogs)) {
        $null = New-Item -Path $WorkspaceLogs -ItemType Directory -Force | Out-Null
    }

    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-New-OSDCloudWorkspace.log"
    $null = Start-Transcript -Path (Join-Path $WorkspaceLogs $Transcript) -ErrorAction Ignore
    #=================================================
    #	Copy WorkspacePath
    #=================================================
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Source: $OSDCloudTemplate"
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Destination: $WorkspacePath"

    $null = robocopy "$OSDCloudTemplate" "$WorkspacePath" *.* /e /b /ndl /np /r:0 /w:0 /xj /xf workspace.json /LOG+:$WorkspaceLogs\Robocopy.log
    #=================================================
    #	Mirror Media
    #=================================================
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring OSDCloud Template Media using Robocopy"
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring will replace any previous WinPE with a new Template WinPE"
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Source: $OSDCloudTemplate\Media"
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Destination: $WorkspacePath\Media"

    $null = robocopy "$OSDCloudTemplate\Media" "$WorkspacePath\Media" *.* /mir /b /ndl /np /r:0 /w:0 /xj /LOG+:$WorkspaceLogs\Robocopy.log
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace created at $WorkspacePath"
    $null = Stop-Transcript
    #=================================================
}