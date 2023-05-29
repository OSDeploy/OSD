function New-OSDCloudVM {
    <#
    .SYNOPSIS
    Creates a Hyper-V VM for use with OSDCloud

    .DESCRIPTION
    Creates a Hyper-V VM for use with OSDCloud

    .EXAMPLE
    New-OSDCloudVM

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

    # Default and Parameter Configuration
    $Global:NewOSDCloudVM = $null
    $Global:NewOSDCloudVM = [ordered]@{
        CheckpointVM    = [System.Boolean]$Global:OSDModuleResource.NewOSDCloudVM.CheckpointVM
        Generation      = [System.Int16]$Global:OSDModuleResource.NewOSDCloudVM.Generation
        MemoryStartupGB = [System.Int64]$Global:OSDModuleResource.NewOSDCloudVM.MemoryStartupGB
        NamePrefix      = [System.String]$Global:OSDModuleResource.NewOSDCloudVM.NamePrefix
        ProcessorCount  = [System.Int64]$Global:OSDModuleResource.NewOSDCloudVM.ProcessorCount
        StartVM         = [System.Boolean]$Global:OSDModuleResource.NewOSDCloudVM.StartVM
        SwitchName      = [System.String]$Global:OSDModuleResource.NewOSDCloudVM.SwitchName
        VHDSizeGB       = [System.Int64]$Global:OSDModuleResource.NewOSDCloudVM.VHDSizeGB
    }

    # Import Template Defaults
    $TemplateLogs = "$env:ProgramData\OSDCloud\Logs"
    if (-NOT (Test-Path $TemplateLogs)) {
        $null = New-Item -Path $TemplateLogs -ItemType Directory -Force | Out-Null
    }
    $TemplateConfigurationJson = "$env:ProgramData\OSDCloud\Logs\NewOSDCloudVM.json"
    if (Test-Path $TemplateConfigurationJson) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Importing default OSDCloud VM Template configuration from $TemplateConfigurationJson"
        $TemplateConfiguration = Get-Content -Path $TemplateConfigurationJson -Raw | ConvertFrom-Json -ErrorAction "Stop" | ConvertTo-Hashtable
        if ($TemplateConfiguration) {
            foreach ($Key in $TemplateConfiguration.Keys) {
                $NewOSDCloudVM.$Key = $TemplateConfiguration.$Key
            }
        }
    }

    # Import Last Workspace Configuration
    $WorkspaceConfigurationJson = Join-Path (Get-OSDCloudWorkspace) 'Logs\NewOSDCloudVM.json'
    if (Test-Path $WorkspaceConfigurationJson) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Importing default OSDCloud VM Workspace configuration from $WorkspaceConfigurationJson"
        $WorkspaceConfiguration = Get-Content -Path $WorkspaceConfigurationJson -Raw | ConvertFrom-Json -ErrorAction "Stop" | ConvertTo-Hashtable
        if ($WorkspaceConfiguration) {
            foreach ($Key in $WorkspaceConfiguration.Keys) {
                $NewOSDCloudVM.$Key = $WorkspaceConfiguration.$Key
            }
        }
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Default OSDCloud VM settings will be saved in $WorkspaceConfigurationJson"
    }

    # Update Configuration from Parameters
    if ($PSBoundParameters.ContainsKey('CheckpointVM')) {$Global:NewOSDCloudVM.CheckpointVM = $CheckpointVM}
    if ($PSBoundParameters.ContainsKey('Generation')) {$Global:NewOSDCloudVM.Generation = $Generation}
    if ($PSBoundParameters.ContainsKey('MemoryStartupGB')) {$Global:NewOSDCloudVM.MemoryStartupGB = $MemoryStartupGB}
    if ($PSBoundParameters.ContainsKey('NamePrefix')) {$Global:NewOSDCloudVM.NamePrefix = $NamePrefix}
    if ($PSBoundParameters.ContainsKey('ProcessorCount')) {$Global:NewOSDCloudVM.ProcessorCount = $ProcessorCount}
    if ($PSBoundParameters.ContainsKey('StartVM')) {$Global:NewOSDCloudVM.StartVM = $StartVM}
    if ($PSBoundParameters.ContainsKey('SwitchName')) {$Global:NewOSDCloudVM.SwitchName = $SwitchName}
    if ($PSBoundParameters.ContainsKey('VHDSizeGB')) {$Global:NewOSDCloudVM.VHDSizeGB = $VHDSizeGB}

    # Validate SwitchName
    if ($Global:NewOSDCloudVM.SwitchName) {
        $ValidateSwitch = Get-VMSwitch -Name $Global:NewOSDCloudVM.SwitchName -ErrorAction SilentlyContinue

        if (-not ($ValidateSwitch)) {
            Write-Warning "SwitchName value '$($Global:NewOSDCloudVM.SwitchName)' is not valid and will be set to Not connected."
            $Global:NewOSDCloudVM.SwitchName = $null
        }
    }

    # Export the updated configuration
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Exporting updated configuration to $WorkspaceConfigurationJson"
    $Global:NewOSDCloudVM | ConvertTo-Json -Depth 10 | Out-File -FilePath $WorkspaceConfigurationJson -Force

    # Get Hyper-V Defaults
    #$VMManagementService = Get-WmiObject -Namespace root\virtualization\v2 Msvm_VirtualSystemManagementService
    $VMManagementServiceSettingData = Get-WmiObject -Namespace root\virtualization\v2 Msvm_VirtualSystemManagementServiceSettingData

    # Set VM Name
    $VmName = "$($NewOSDCloudVM.NamePrefix)$((Get-Date).ToString('yyMMddHHmmss'))"

    # Build Final Configuration
    $Global:OSDCloudVM = $null
    $Global:OSDCloudVM = [ordered]@{
        CheckpointVM                = $NewOSDCloudVM.CheckpointVM
        DvdDrivePath                = Join-Path $(Get-OSDCloudWorkspace) 'OSDCloud_NoPrompt.iso'
        Generation                  = $NewOSDCloudVM.Generation
        MemoryStartupBytes          = ($NewOSDCloudVM.MemoryStartupGB * 1GB)
        MemoryStartupGB             = $NewOSDCloudVM.MemoryStartupGB
        Name                        = $VmName
        NamePrefix                  = $NewOSDCloudVM.NamePrefix
        ProcessorCount              = $NewOSDCloudVM.ProcessorCount
        StartVM                     = $NewOSDCloudVM.StartVM
        SwitchName                  = $NewOSDCloudVM.SwitchName
        VHDPath                     = [System.String](Join-Path $VMManagementServiceSettingData.DefaultVirtualHardDiskPath "$VmName.vhdx")
        VHDSizeBytes                = ($NewOSDCloudVM.VHDSizeGB * 1GB)
        VHDSizeGB                   = [System.Int64]$Global:NewOSDCloudVM.VHDSizeGB
    }

    # Display the current configuration
    Write-Output $Global:OSDCloudVM

    # Create VM VHD
    if ($OSDCloudVM.SwitchName) {
        $vm = New-VM -Name $OSDCloudVM.Name -Generation $OSDCloudVM.Generation -MemoryStartupBytes $OSDCloudVM.MemoryStartupBytes -NewVHDPath $OSDCloudVM.VHDPath -NewVHDSizeBytes $OSDCloudVM.VHDSizeBytes -SwitchName $OSDCloudVM.SwitchName -Verbose -ErrorAction Stop
    }
    else {
        $vm = New-VM -Name $OSDCloudVM.Name -Generation $OSDCloudVM.Generation -MemoryStartupBytes $OSDCloudVM.MemoryStartupBytes -NewVHDPath $OSDCloudVM.VHDPath -NewVHDSizeBytes $OSDCloudVM.VHDSizeBytes -Verbose -ErrorAction Stop
    }
    
    # Create DVD
    $OSDCloudVM.DvdDrive = $vm | Add-VMDvdDrive -Path $OSDCloudVM.DvdDrivePath -Passthru -Verbose
    $OSDCloudVM.HardDiskDrive = $vm | Get-VMHardDiskDrive
    $OSDCloudVM.NetworkAdapter = $vm | Get-VMNetworkAdapter

    if ($OSDCloudVM.Generation -eq 2) {
        # First Boot Device
        $vm | Set-VMFirmware -FirstBootDevice $OSDCloudVM.DvdDrive

        # Firmware
        #$vm | Set-VMFirmware -BootOrder $OSDCloudVM.DvdDrive, $vmHardDiskDrive, $vmNetworkAdapter -Verbose

        # Security
        $vm | Set-VMFirmware -EnableSecureBoot On -Verbose
        if ((Get-TPM).TpmPresent -eq $true -and (Get-TPM).TpmReady -eq $true) {
            $vm | Set-VMSecurity -VirtualizationBasedSecurityOptOut:$false -Verbose
            $vm | Set-VMKeyProtector -NewLocalKeyProtector -Verbose
            $vm | Enable-VMTPM -Verbose
        }
    }

    # Memory
    $vm | Set-VMMemory -DynamicMemoryEnabled $false -Verbose

    # Processor
    $vm | Set-VMProcessor -Count $OSDCloudVM.ProcessorCount -Verbose

    # Integration Services
    # Thanks Andreas Landry
    $IntegrationService = Get-VMIntegrationService -VMName $vm.Name | Where-Object { $_ -match "Microsoft:[0-9A-Fa-f]{8}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{12}\\6C09BB55-D683-4DA0-8931-C9BF705F6480" }
    $vm | Get-VMIntegrationService -Name $IntegrationService.Name | Enable-VMIntegrationService -Verbose

    # Checkpoints Start Stop
    $vm | Set-VM -AutomaticCheckpointsEnabled $false -AutomaticStartAction Nothing -AutomaticStartDelay 3 -AutomaticStopAction Shutdown -Verbose

    #Export Final Configuration
    $Global:OSDCloudVM.VM = $vm
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Exporting current configuration to $env:Temp\OSDCloudVM.json"
    $Global:OSDCloudVM | ConvertTo-Json -Depth 2 | Out-File -FilePath "$env:TEMP\OSDCloudVM.json" -Force

    if ($Global:OSDCloudVM.CheckpointVM -eq $true) {
        $vm | Checkpoint-VM -SnapshotName 'New-VM' -Verbose
    }

    if ($Global:OSDCloudVM.StartVM -eq $true) {
        vmconnect.exe $env:ComputerName $OSDCloudVM.Name
        Start-Sleep -Seconds 3
        $vm | Start-VM -Verbose
    }
}
Register-ArgumentCompleter -CommandName New-OSDCloudVM -ParameterName 'SwitchName' -ScriptBlock {Get-VMSwitch | Select-Object -ExpandProperty Name | ForEach-Object {if ($_.Contains(' ')) {"'$_'"} else {$_}}}