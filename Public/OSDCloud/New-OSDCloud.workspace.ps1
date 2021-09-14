function Get-OSDCloud.workspace {
    [CmdletBinding()]
    param ()

    if (Test-Path "$env:ProgramData\OSDCloud\workspace.json") {
        $WorkspaceSettings = Get-Content -Path "$env:ProgramData\OSDCloud\workspace.json" | ConvertFrom-Json
        $WorkspacePath = $WorkspaceSettings.WorkspacePath
        $WorkspacePath
    } else {
        $null
    }
}
<#
.SYNOPSIS
Creates an OSDCloud Workspace

.Description
Creates an OSDCloud Workspace

.PARAMETER WorkspacePath
Directory for the Workspace to contain the Media directory and the .iso file

.LINK
https://osdcloud.osdeploy.com
#>
function New-OSDCloud.workspace {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$WorkspacePath
    )
    #=================================================
    #	Start the Clock
    #=================================================
    $WorkspaceStartTime = Get-Date
    #=================================================
    #   Header
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================"
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)"
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
    #	Get-OSDCloud.template
    #=================================================
    if (!(Get-OSDCloud.template)) {
        Write-Host -ForegroundColor DarkGray "================================================"
        Write-Warning "Setting up a new OSDCloud.template"
        Write-Host -ForegroundColor DarkGray "================================================"
        New-OSDCloud.template
    }

    $OSDCloudTemplate = Get-OSDCloud.template
    if (!($OSDCloudTemplate)) {
        Write-Host -ForegroundColor DarkGray "================================================"
        Write-Warning "Something bad happened.  I have to go"
        Write-Host -ForegroundColor DarkGray "================================================"
        Break
    }
    #=================================================
    #	Remove Old Autopilot Content
    #=================================================
    if (Test-Path "$env:ProgramData\OSDCloud\Autopilot") {
        Write-Warning "Move all your Autopilot Profiles to $env:ProgramData\OSDCloud\Config\AutopilotJSON"
        Write-Warning "You will be unable to create or update an OSDCloud Workspace until $env:ProgramData\OSDCloud\Autopilot is manually removed"
        Break
    }
    if (Test-Path "$WorkspacePath\Autopilot") {
        Write-Warning "Move all your Autopilot Profiles to $WorkspacePath\Config\AutopilotJSON"
        Write-Warning "You will be unable to create or update an OSDCloud Workspace until $WorkspacePath\Autopilot is manually removed"
        Break
    }
    #=================================================
    #	Set WorkspacePath
    #=================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloud.workspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
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
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Workspace Logs at $WorkspaceLogs"

    if (Test-Path $WorkspaceLogs) {
        $null = Remove-Item -Path "$WorkspaceLogs\*" -Recurse -Force -ErrorAction Ignore | Out-Null
    }
    if (-NOT (Test-Path $WorkspaceLogs)) {
        $null = New-Item -Path $WorkspaceLogs -ItemType Directory -Force | Out-Null
    }

    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-New-OSDCloud.workspace.log"
    Start-Transcript -Path (Join-Path $WorkspaceLogs $Transcript) -ErrorAction Ignore
    #=================================================
    #	Copy WorkspacePath
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================"
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Template using Robocopy"
    
    Write-Host -ForegroundColor DarkGray "Source: $OSDCloudTemplate"
    Write-Host -ForegroundColor DarkGray "Destination: $WorkspacePath"

    $null = robocopy "$OSDCloudTemplate" "$WorkspacePath" *.* /e /b /ndl /np /r:0 /w:0 /xj /xf workspace.json /LOG+:$WorkspaceLogs\Robocopy.log
    #=================================================
    #	Mirror Media
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================"
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring OSDCloud Template Media using Robocopy"
    Write-Host -ForegroundColor Yellow 'Mirroring will replace any previous WinPE with a new Template WinPE'
    
    Write-Host -ForegroundColor DarkGray "Source: $OSDCloudTemplate\Media"
    Write-Host -ForegroundColor DarkGray "Destination: $WorkspacePath\Media"

    $null = robocopy "$OSDCloudTemplate\Media" "$WorkspacePath\Media" *.* /mir /b /ndl /np /r:0 /w:0 /xj /LOG+:$WorkspaceLogs\Robocopy.log
    #=================================================
    #	Complete
    #=================================================
    $WorkspaceEndTime = Get-Date
    $WorkspaceTimeSpan = New-TimeSpan -Start $WorkspaceStartTime -End $WorkspaceEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($WorkspaceTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    Write-Host -ForegroundColor Cyan        "OSDCloud Workspace created at $WorkspacePath"
    Write-Host -ForegroundColor DarkGray    "================================================"
    Stop-Transcript
    #=================================================
}
function Set-OSDCloud.workspace {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$WorkspacePath
    )
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-WinPE
    #=================================================
    #	Set-OSDCloud.workspace
    #=================================================
    $WorkspaceSettings = [PSCustomObject]@{
        WorkspacePath = $WorkspacePath
    }

    $WorkspaceSettings | ConvertTo-Json | Out-File "$env:ProgramData\OSDCloud\workspace.json" -Encoding ascii -Width 2000 -Force

    $WorkspacePath
    #=================================================
}