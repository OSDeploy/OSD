function Set-OSDCloud.workspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$WorkspacePath
    )
    #=======================================================================
    #	Block
    #=======================================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-WinPE
    #=======================================================================
    #	Set-OSDCloud.workspace
    #=======================================================================
    $WorkspaceSettings = [PSCustomObject]@{
        WorkspacePath = $WorkspacePath
    }

    $WorkspaceSettings | ConvertTo-Json | Out-File "$env:ProgramData\OSDCloud\workspace.json" -Encoding ASCII

    $WorkspacePath
    #=======================================================================
}