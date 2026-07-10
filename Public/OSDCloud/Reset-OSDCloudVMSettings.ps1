function Reset-OSDCloudVMSettings {
    <#
    .SYNOPSIS
    Resets configuration by using Reset-OSDCloudVMSettings.

    .DESCRIPTION
    Provides the implementation for Reset-OSDCloudVMSettings.

    .EXAMPLE
    Reset-OSDCloudVMSettings
    Runs Reset-OSDCloudVMSettings with common parameters.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Updated comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param ()

    $TemplateConfigurationJson = "$env:ProgramData\OSDCloud\Logs\NewOSDCloudVM.json"
    if (Test-Path $TemplateConfigurationJson) {
        Write-Warning "Removing OSDCloudVM Template configuration at $TemplateConfigurationJson"
        Remove-Item -Path $TemplateConfigurationJson -Force -ErrorAction SilentlyContinue | Out-Null
    }

    $WorkspaceConfigurationJson = Join-Path (Get-OSDCloudWorkspace) 'Logs\NewOSDCloudVM.json'
    if (Test-Path $WorkspaceConfigurationJson) {
        Write-Warning "Removing OSDCloudVM Workspace configuration at $WorkspaceConfigurationJson"
        Remove-Item -Path $WorkspaceConfigurationJson -Force -ErrorAction SilentlyContinue | Out-Null
    }

    Get-OSDCloudVMSettings
}
