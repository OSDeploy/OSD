function Get-OSDCloudWorkspace {
    <#
    .SYNOPSIS
    Returns the path to the OSDCloud Workspace by reading the path stored in $env:ProgramData\OSDCloud\workspace.json
    
    .DESCRIPTION
    Returns the path to the OSDCloud Workspace by reading the path stored in $env:ProgramData\OSDCloud\workspace.json
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param ()

    if (Test-Path "$env:ProgramData\OSDCloud\workspace.json") {
        $WorkspaceSettings = Get-Content -Path "$env:ProgramData\OSDCloud\workspace.json" | ConvertFrom-Json
        $WorkspacePath = $WorkspaceSettings.WorkspacePath
        $WorkspacePath
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to locate $env:ProgramData\OSDCloud\workspace.json"
    }
}