<#
.SYNOPSIS
Gets an OSDCloud Workspace

.Description
Gets an OSDCloud Workspace by reading the path stored in $env:ProgramData\OSDCloud\workspace.json

.LINK
https://osdcloud.osdeploy.com
#>
function Get-OSDCloud.workspace {
    [CmdletBinding()]
    param ()

    if (Test-Path "$env:ProgramData\OSDCloud\workspace.json") {
        $WorkspaceSettings = Get-Content -Path "$env:ProgramData\OSDCloud\workspace.json" | ConvertFrom-Json
        $WorkspacePath = $WorkspaceSettings.WorkspacePath
        $WorkspacePath
    } else {
        Write-Warning "Unable to locate $env:ProgramData\OSDCloud\workspace.json"
    }
}