<#
.SYNOPSIS
Gets an OSDCloud Workspace

.DESCRIPTION
Gets an OSDCloud Workspace by reading the path stored in $env:ProgramData\OSDCloud\workspace.json

.LINK
https://osdcloud.osdeploy.com
#>
function Get-OSDCloudWorkspace {
    [CmdletBinding()]
    param ()

    if (Test-Path "$env:ProgramData\OSDCloud\workspace.json") {
        $WorkspaceSettings = Get-Content -Path "$env:ProgramData\OSDCloud\workspace.json" | ConvertFrom-Json
        $WorkspacePath = $WorkspaceSettings.WorkspacePath
        $WorkspacePath
    } else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to locate $env:ProgramData\OSDCloud\workspace.json"
    }
}