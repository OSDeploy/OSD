function Get-OSDCloudVMSettings {
    <#
    .SYNOPSIS
    Gets information returned by Get-OSDCloudVMSettings.

    .DESCRIPTION
    Provides the implementation for Get-OSDCloudVMSettings.

    .EXAMPLE
    Get-OSDCloudVMSettings
    Runs Get-OSDCloudVMSettings with common parameters.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Updated comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param ()

    # OSDCloudVM Module Defaults
    $OSDCloudVMSettings = Get-OSDCloudVMDefaults

    # Create Template Logs Directory
    $TemplateLogs = "$env:ProgramData\OSDCloud\Logs"
    if (-NOT (Test-Path $TemplateLogs)) {
        $null = New-Item -Path $TemplateLogs -ItemType Directory -Force | Out-Null
    }

    # Import Template Defaults
    $TemplateConfigurationJson = "$env:ProgramData\OSDCloud\Logs\NewOSDCloudVM.json"
    if (Test-Path $TemplateConfigurationJson) {
        Write-Host -ForegroundColor DarkGray "Importing OSDCloudVM Template settings at $TemplateConfigurationJson"
        $TemplateConfiguration = Get-Content -Path $TemplateConfigurationJson -Raw | ConvertFrom-Json -ErrorAction "Stop" | ConvertTo-Hashtable
        if ($TemplateConfiguration) {
            foreach ($Key in $TemplateConfiguration.Keys) {
                $OSDCloudVMSettings.$Key = $TemplateConfiguration.$Key
            }
        }
    }

    # Import Workspace Defaults
    $WorkspaceConfigurationJson = Join-Path (Get-OSDCloudWorkspace) 'Logs\NewOSDCloudVM.json'
    if (Test-Path $WorkspaceConfigurationJson) {
        Write-Host -ForegroundColor DarkGray "Importing OSDCloudVM Workspace settings at $WorkspaceConfigurationJson"
        $WorkspaceConfiguration = Get-Content -Path $WorkspaceConfigurationJson -Raw | ConvertFrom-Json -ErrorAction "Stop" | ConvertTo-Hashtable
        if ($WorkspaceConfiguration) {
            foreach ($Key in $WorkspaceConfiguration.Keys) {
                $OSDCloudVMSettings.$Key = $WorkspaceConfiguration.$Key
            }
        }
    }

    # Display the updated settings
    Return $OSDCloudVMSettings
}
