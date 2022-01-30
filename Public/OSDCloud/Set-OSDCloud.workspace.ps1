<#
.SYNOPSIS
Changes the path to the OSDCloud Workspace

.Description
Changes the path to the OSDCloud Workspace from an OSDCloud Template

.PARAMETER WorkspacePath
Directory for the OSDCloud Workspace to set.  Default is $env:SystemDrive\OSDCloud

.LINK
https://osdcloud.osdeploy.com
#>
function Set-OSDCloud.workspace {
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
    #	Set-OSDCloud.workspace
    #=================================================
    $WorkspaceSettings = [PSCustomObject]@{
        WorkspacePath = $WorkspacePath
    }

    $WorkspaceSettings | ConvertTo-Json | Out-File "$env:ProgramData\OSDCloud\workspace.json" -Encoding ascii -Width 2000 -Force

    $WorkspacePath
    #=================================================
}