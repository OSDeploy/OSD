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

    #Requires -RunAsAdministrator

    [CmdletBinding()]
    param (
        [System.Boolean]
        $CheckpointVM = $Global:OSDModuleResource.NewOSDCloudVM.CheckpointVM,

        [ValidateSet('1','2')]
        [System.UInt16]
        $Generation = $Global:OSDModuleResource.NewOSDCloudVM.Generation,

        [ValidateRange(2, 64)]
        [System.UInt16]
        $MemoryStartupGB = $Global:OSDModuleResource.NewOSDCloudVM.MemoryStartupGB,

        [System.String]
        $NamePrefix = $Global:OSDModuleResource.NewOSDCloudVM.NamePrefix,

        [ValidateRange(2, 64)]
        [System.UInt16]
        $ProcessorCount = $Global:OSDModuleResource.NewOSDCloudVM.ProcessorCount,

        [System.String]
        $SwitchName = $Global:OSDModuleResource.NewOSDCloudVM.SwitchName,

        [System.Boolean]
        $StartVM = $Global:OSDModuleResource.NewOSDCloudVM.StartVM,

        [ValidateRange(8, 128)]
        [System.UInt16]
        $VHDSizeGB = $Global:OSDModuleResource.NewOSDCloudVM.VHDSizeGB
    )
    # Get Hyper-V Defaults
    #$VMManagementService = Get-WmiObject -Namespace root\virtualization\v2 Msvm_VirtualSystemManagementService
    $VMManagementServiceSettingData = Get-WmiObject -Namespace root\virtualization\v2 Msvm_VirtualSystemManagementServiceSettingData

    # Validate SwitchName
    if (-not (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue)) {
        if ($SwitchName -eq $Global:OSDModuleResource.NewOSDCloudVM.SwitchName) {
            # Default Switch does not exist.  Autoselect a Switch
            $SwitchName = Get-VMSwitch | Select-Object -ExpandProperty Name -First 1
        }
        else {
            # Specified Switch does not exist.  Autoselect a Switch
            Write-Warning "SwitchName value '$SwitchName' is not valid."
            $SwitchName = Get-VMSwitch | Select-Object -ExpandProperty Name -First 1
            Write-Warning "SwitchName value will be set to '$SwitchName'"
        }
    }

    # Default Configuration
    $Global:NewOSDCloudVM = $null
    $Global:NewOSDCloudVM = [ordered]@{
        CheckpointVM    = [System.Boolean]$CheckpointVM
        NamePrefix      = [System.String]$NamePrefix
        Generation      = [System.Int16]$Generation
        MemoryStartupGB = [System.Int64]$MemoryStartupGB
        ProcessorCount  = [System.Int64]$ProcessorCount
        SwitchName      = [System.String]$SwitchName
        StartVM         = [System.Boolean]$StartVM
        VHDSizeGB       = [System.Int64]$VHDSizeGB
    }

    # Export Default Configuration
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Exporting default configuration to $env:Temp\NewOSDCloudVM.json"
    $Global:NewOSDCloudVM | ConvertTo-Json -Depth 10 | Out-File -FilePath "$env:TEMP\NewOSDCloudVM.json" -Force

    # Import Custom Configuration
    $WorkspaceConfiguration = Join-Path (Get-OSDCloudWorkspace) 'Logs\NewOSDCloudVM.json'
    $WorkspaceConfiguration
    if (Test-Path $WorkspaceConfiguration) {
        Write-Host -ForegroundColor DarkGray "Reading $WorkspaceConfiguration"
        $AutomateConfiguration = Get-Content -Path $WorkspaceConfiguration -Raw | ConvertFrom-Json -ErrorAction "Stop" | ConvertTo-Hashtable
    }
    if ($AutomateConfiguration) {
        foreach ($Key in $AutomateConfiguration.Keys) {
            $NewOSDCloudVM.$Key = $AutomateConfiguration.$Key
        }
    }

    # Validate SwitchName
    if (-not (Get-VMSwitch -Name $Global:NewOSDCloudVM.SwitchName -ErrorAction SilentlyContinue)) {
        Write-Warning "SwitchName value '$($Global:NewOSDCloudVM.SwitchName)' is not valid."
        $Global:NewOSDCloudVM.SwitchName = Get-VMSwitch | Select-Object -ExpandProperty Name -First 1
        Write-Warning "SwitchName value will be set to '$($Global:NewOSDCloudVM.SwitchName)'"
    }

    # Set VM Name
    $VmName = "$($NewOSDCloudVM.NamePrefix)$((Get-Date).ToString('yyMMddHHmmss'))"

    # Build Final Configuration
    $Global:OSDCloudVM = $null
    $Global:OSDCloudVM = [ordered]@{
        CheckpointVM                = $NewOSDCloudVM.CheckpointVM
        DvdDrivePath                = Join-Path $(Get-OSDCloudWorkspace) 'OSDCloud_NoPrompt.iso'
        Name                        = $VmName
        NamePrefix                  = $NewOSDCloudVM.NamePrefix
        Generation                  = $NewOSDCloudVM.Generation
        MemoryStartupBytes          = ($NewOSDCloudVM.MemoryStartupGB * 1GB)
        MemoryStartupGB             = $NewOSDCloudVM.MemoryStartupGB
        ProcessorCount              = $NewOSDCloudVM.ProcessorCount
        SwitchName                  = $NewOSDCloudVM.SwitchName
        StartVM                     = $NewOSDCloudVM.StartVM
        VHDPath                     = [System.String](Join-Path $VMManagementServiceSettingData.DefaultVirtualHardDiskPath "$VmName.vhdx")
        VHDSizeBytes                = ($NewOSDCloudVM.VHDSizeGB * 1GB)
        VHDSizeGB                   = [System.Int64]$Global:NewOSDCloudVM.VHDSizeGB
    }
    $Global:OSDCloudVM

    # Create VM VHD
    $vm = New-VM -Name $OSDCloudVM.Name -Generation $OSDCloudVM.Generation -MemoryStartupBytes $OSDCloudVM.MemoryStartupBytes -NewVHDPath $OSDCloudVM.VHDPath -NewVHDSizeBytes $OSDCloudVM.VHDSizeBytes -SwitchName $OSDCloudVM.SwitchName -Verbose
    
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