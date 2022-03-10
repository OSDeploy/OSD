<#
.SYNOPSIS
Changes the path to the OSDCloud Workspace

.DESCRIPTION
Changes the path to the OSDCloud Workspace from an OSDCloud Template

.PARAMETER WorkspacePath
Directory for the OSDCloud Workspace to set.  Default is $env:SystemDrive\OSDCloud

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Set-OSDCloudWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [System.String]$WorkspacePath = "$env:SystemDrive\OSDCloud"
    )
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-WinPE
    #=================================================
    #	Set-OSDCloudWorkspace
    #=================================================
    $WorkspaceSettings = [PSCustomObject]@{
        WorkspacePath = $WorkspacePath
    }

    if (-not (Test-Path "$env:ProgramData\OSDCloud")) {
        $null = New-Item -Path "$env:ProgramData\OSDCloud" -ItemType Directory -Force -ErrorAction Stop
    }

    $WorkspaceSettings | ConvertTo-Json | Out-File "$env:ProgramData\OSDCloud\workspace.json" -Encoding ascii -Width 2000 -Force

    $WorkspacePath
    #=================================================
}