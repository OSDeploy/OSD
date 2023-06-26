#Requires -Modules @{ ModuleName="OSD"; ModuleVersion="23.5.26.1" }
#Requires -PSEdition Desktop
#Requires -RunAsAdministrator

#Set Hyper-V Configuration
$vmName = "OSDCloud $(Get-Random)"
$vmIso = Join-Path $(Get-OSDCloudWorkspace) 'OSDCloud_NoPrompt.iso'
$vmGeneration = 2
$vmMemory = 16GB
$vmProcessorCount = 2
$vhdSize = 100GB

# Get Hyper-V Defaults
$vmms = Get-WmiObject -Namespace root\virtualization\v2 Msvm_VirtualSystemManagementService
$vmmsSettings = Get-WmiObject -Namespace root\virtualization\v2 Msvm_VirtualSystemManagementServiceSettingData

# Create VHDX VM DVD ISO
$vhdPath = Join-Path $vmmsSettings.DefaultVirtualHardDiskPath "$vmName.vhdx"
$vm = New-VM -Name $vmName -Generation $vmGeneration -MemoryStartupBytes $vmMemory -NewVHDPath $vhdPath -NewVHDSizeBytes $vhdSize -SwitchName 'Default Switch' -Verbose
$vmDvd = $vm | Add-VMDvdDrive -Path $vmIso -Passthru -Verbose
$vm | Set-VMFirmware -FirstBootDevice $vmDvd -Verbose
$vmHardDiskDrive = $vm | Get-VMHardDiskDrive
$vmNetworkAdapter = $vm | Get-VMNetworkAdapter

# Firmware
$vm | Set-VMFirmware -BootOrder $vmDvd, $vmHardDiskDrive, $vmNetworkAdapter -Verbose

# Security
$vm | Set-VMFirmware -EnableSecureBoot On -Verbose
if ((Get-TPM).TpmPresent -eq $true -and (Get-TPM).TpmReady -eq $true) {
    $vm | Set-VMSecurity -VirtualizationBasedSecurityOptOut:$false -Verbose
    $vm | Set-VMKeyProtector -NewLocalKeyProtector -Verbose
    $vm | Enable-VMTPM -Verbose
}

# Memory
$vm | Set-VMMemory -DynamicMemoryEnabled $false -Verbose

# Processor
$vm | Set-VMProcessor -Count $vmProcessorCount -Verbose

# Integration Services
$vm | Get-VMIntegrationService -Name "Guest Service Interface" | Enable-VMIntegrationService -Verbose

# Checkpoints
$vm | Set-VM -AutomaticCheckpointsEnabled $false -Verbose

# Automatic Start Action
$vm | Set-VM -AutomaticStartAction Nothing -AutomaticStartDelay 3 -Verbose

# Automatic Stop Action
$vm | Set-VM -AutomaticStopAction Shutdown -Verbose

# Start VM
$vm | Checkpoint-VM -SnapshotName 'New-VM' -Verbose
vmconnect.exe $env:ComputerName $vmName
Start-Sleep -Seconds 3
$vm | Start-VM -Verbose