function Set-OSDCloudVMSettings {
    <#
    .SYNOPSIS
    Sets configuration values by using Set-OSDCloudVMSettings.

    .DESCRIPTION
    Provides the implementation for Set-OSDCloudVMSettings.

    .PARAMETER CheckpointVM
    Specifies the value for CheckpointVM.

    .PARAMETER Generation
    Specifies the value for Generation.

    .PARAMETER MemoryStartupGB
    Specifies the value for MemoryStartupGB.

    .PARAMETER NamePrefix
    Specifies the value for NamePrefix.

    .PARAMETER ProcessorCount
    Specifies the value for ProcessorCount.

    .PARAMETER StartVM
    Specifies the value for StartVM.

    .PARAMETER SwitchName
    Specifies the value for SwitchName.

    .PARAMETER VHDSizeGB
    Specifies the value for VHDSizeGB.

    .EXAMPLE
    Set-OSDCloudVMSettings -CheckpointVM <CheckpointVM> -Generation <Generation>
    Runs Set-OSDCloudVMSettings with common parameters.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Updated comment-based help

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
