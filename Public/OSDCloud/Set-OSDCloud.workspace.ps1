function Set-OSDCloud.workspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$WorkspacePath
    )

    $WorkspaceSettings = [PSCustomObject]@{
        WorkspacePath = $WorkspacePath
    }

    $WorkspaceSettings | ConvertTo-Json | Out-File "$env:ProgramData\OSDCloud\workspace.json" -Encoding ASCII

    Return $WorkspacePath
}