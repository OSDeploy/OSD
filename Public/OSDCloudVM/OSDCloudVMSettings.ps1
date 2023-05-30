function Get-OSDCloudVMSettings {
    <#
    .SYNOPSIS
    Gets the current OSDCloudVM Settings from the OSD Module, OSDCloud Template, and OSDCloud Workspace

    .DESCRIPTION
    Gets the current OSDCloudVM Settings from the OSD Module, OSDCloud Template, and OSDCloud Workspace

    .EXAMPLE
    Get-OSDCloudVMSettings

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
function Reset-OSDCloudVMSettings {
    <#
    .SYNOPSIS
    Resets OSDCloudVM to its default settings stored in the OSDCloud Template and current Workspace

    .DESCRIPTION
    Resets OSDCloudVM to its default settings stored in the OSDCloud Template and current Workspace

    .EXAMPLE
    Reset-OSDCloudVMSettings

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
function Set-OSDCloudVMSettings {
    <#
    .SYNOPSIS
    Sets OSDCloudVM settings stored in the OSDCloud Template

    .DESCRIPTION
    Sets OSDCloudVM settings stored in the OSDCloud Template

    .EXAMPLE
    Set-OSDCloudVMSettings -ProcessorCount 2 -MemoryStartupGB 8

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param (
        [System.Boolean]
        $CheckpointVM,

        [ValidateSet('1','2')]
        [System.UInt16]
        $Generation,

        [ValidateRange(2, 64)]
        [System.UInt16]
        $MemoryStartupGB,

        [System.String]
        $NamePrefix,

        [ValidateRange(2, 64)]
        [System.UInt16]
        $ProcessorCount,

        [System.Boolean]
        $StartVM,

        [System.String]
        $SwitchName,

        [ValidateRange(8, 128)]
        [System.UInt16]
        $VHDSizeGB
    )

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

    # Update Configuration from Parameters
    if ($PSBoundParameters.ContainsKey('CheckpointVM')) {$OSDCloudVMSettings.CheckpointVM = $CheckpointVM}
    if ($PSBoundParameters.ContainsKey('Generation')) {$OSDCloudVMSettings.Generation = $Generation}
    if ($PSBoundParameters.ContainsKey('MemoryStartupGB')) {$OSDCloudVMSettings.MemoryStartupGB = $MemoryStartupGB}
    if ($PSBoundParameters.ContainsKey('NamePrefix')) {$OSDCloudVMSettings.NamePrefix = $NamePrefix}
    if ($PSBoundParameters.ContainsKey('ProcessorCount')) {$OSDCloudVMSettings.ProcessorCount = $ProcessorCount}
    if ($PSBoundParameters.ContainsKey('StartVM')) {$OSDCloudVMSettings.StartVM = $StartVM}
    if ($PSBoundParameters.ContainsKey('SwitchName')) {$OSDCloudVMSettings.SwitchName = $SwitchName}
    if ($PSBoundParameters.ContainsKey('VHDSizeGB')) {$OSDCloudVMSettings.VHDSizeGB = $VHDSizeGB}

    # Validate SwitchName
    if ($OSDCloudVMSettings.SwitchName) {
        $ValidateSwitch = Get-VMSwitch -Name $OSDCloudVMSettings.SwitchName -ErrorAction SilentlyContinue

        if (-not ($ValidateSwitch)) {
            Write-Warning "SwitchName value '$($OSDCloudVMSettings.SwitchName)' is not valid and will be set to Not connected."
            $OSDCloudVMSettings.SwitchName = $null
        }
    }

    # Export the updated configuration
    Write-Host -ForegroundColor Cyan "Exporting updated configuration to $TemplateConfigurationJson"
    $OSDCloudVMSettings | ConvertTo-Json -Depth 10 | Out-File -FilePath $TemplateConfigurationJson -Force

    # Display the updated settings
    Return $OSDCloudVMSettings
}
Register-ArgumentCompleter -CommandName Set-OSDCloudVMSettings -ParameterName 'SwitchName' -ScriptBlock {Get-VMSwitch | Select-Object -ExpandProperty Name | ForEach-Object {if ($_.Contains(' ')) {"'$_'"} else {$_}}}