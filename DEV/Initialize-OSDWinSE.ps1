function Initialize-OSDWinSE {
    [CmdletBinding()]
    Param (
        [switch]$PartitionDisk,
        [switch]$HighPerformance
    )
    Write-Host 'Starting OSDWinSE' -ForegroundColor Green
    #======================================================================================
    #	IsWinPE
    #======================================================================================
    $Global:IsWinPE = $env:SystemDrive -eq 'X:'
    if ($Global:IsWinPE) {
        Write-Host "OSDWinSE IsWinPE: $Global:IsWinPE" -ForegroundColor Cyan
    } else {
        Write-Warning "OSDWinSE: WinPE is required ... Exiting!"
        Break
    }
    #======================================================================================
    #	IsUEFI
    #======================================================================================
    $Global:IsUEFI = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control).PEFirmwareType -eq 2
    Write-Host "OSDWinSE IsUEFI: $Global:IsUEFI" -ForegroundColor Cyan
    #======================================================================================
    #	OSDPhase
    #======================================================================================
    if (Test-Path 'HKLM:\SYSTEM\Setup') {
        $RegistrySystemSetup = Get-ItemProperty -Path 'HKLM:\SYSTEM\Setup'

        # Determine if we are running Windows Setup
        if ($RegistrySystemSetup.SystemSetupInProgress -eq 0) {$Global:OSDPhase = 'Finalize'}
        if ($RegistrySystemSetup.FactoryPreInstallInProgress -eq 1) {$Global:OSDPhase = 'WinSE'}
        if ($RegistrySystemSetup.SetupPhase -eq 4) {$Global:OSDPhase = 'Specialize'}
        if ($RegistrySystemSetup.OOBEInProgress -eq 1) {$Global:OSDPhase = 'OOBE'}
    } else {
        Write-Warning "OSDWinSE: Could not get Setup information from the Registry ... Exiting!"
        Break
    }
    Write-Host "OSDWinSE OSDPhase: $Global:OSDPhase" -ForegroundColor Cyan
    #======================================================================================
    #	Increase the Console Screen Buffer size
    #======================================================================================
    if (!(Test-Path "HKCU:\Console")) {
        Write-Host "Increase Console Screen Buffer" -ForegroundColor Gray
        New-Item -Path "HKCU:\Console" -Force | Out-Null
        New-ItemProperty -Path HKCU:\Console ScreenBufferSize -Value 589889656 -PropertyType DWORD -Force | Out-Null
    }

    #======================================================================================
    #	HighPerformance
    #======================================================================================
    if ($HighPerformance.IsPresent) {
        Write-Host 'OSDWinSE: Enable High Performance Power Plan' -ForegroundColor Cyan
        Write-Verbose 'Set-OSDPower -High'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') -Wait
    }
    #======================================================================================
    #	PartitionDisk Defaults
    #======================================================================================
    $SizeMSR = 128MB

    if ($IsUEFI) {
        if (-not ($SizeSystem)) {$SizeSystem = 200MB}
        if (-not ($SizeRecovery)) {$SizeRecovery = 984MB}
    } else {
        if (-not ($SizeSystem)) {$SizeSystem = 984MB}
    }
    #======================================================================================
    #	PartitionDisk
    #======================================================================================
    if ($PartitionDisk.IsPresent) {
        Write-Host ""
        Write-Host "OSDWinSE will Clean and Partition Disk 0" -ForegroundColor Cyan
        Write-Warning 'All existing Data will be lost!'
        Write-Host ""
        [void](Read-Host 'Press Enter to Continue')
        Write-Host ""

        $PrimaryDisk = Get-Disk | Where-Object {$_.BusType -ne 'USB'} | Sort-Object Number | Select-Object -First 1
        if ($null -eq $PrimaryDisk) {
            Write-Warning "$Title could not find a Local Disk to use"
            Write-Host "Exiting in 5 seconds" -ForegroundColor DarkGray
            Start-Sleep -s 5
            Exit
        }
    
        if ($IsUEFI) {
            Write-Host "Clear-Disk" -ForegroundColor Cyan
            $PrimaryDisk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$true -PassThru
            
            Write-Host "Initialize-Disk" -ForegroundColor Cyan
            Initialize-Disk -Number $PrimaryDisk.Number -PartitionStyle GPT
    
            Write-Host "System Partition: Creating partition of [$SizeSystem]" -ForegroundColor Cyan
            $PartitionSystem = New-Partition -DiskNumber $PrimaryDisk.Number -Size $SizeSystem -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'
        
            Write-Host "System Partition: Formatting FAT32" -ForegroundColor Cyan
            $null = Format-Volume -Partition $PartitionSystem -FileSystem FAT32 -NewFileSystemLabel 'OSDisk' -Force -Confirm:$false
        
            Write-Host "System Partition: Setting system partition as ESP" -ForegroundColor Cyan
            $PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'
        
            Write-Host "MSR Partition: Creating partition of [$SizeMSR]" -ForegroundColor Cyan
            $null = New-Partition -DiskNumber $PrimaryDisk.Number -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}' -Size $SizeMSR 
        
            $PrimaryDisk = Get-Disk | Where-Object {$_.BusType -ne 'USB'} | Sort-Object Number | Select-Object -First 1
        
            Write-Host "OS Partition: Creating partition of [$($PrimaryDisk.LargestFreeExtent - $SizeRecovery)] bytes" -ForegroundColor Cyan
            $PartitionOSDisk = New-Partition -DiskNumber $PrimaryDisk.Number -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -Size ($PrimaryDisk.LargestFreeExtent - $SizeRecovery)
            
            Write-Host "OS Partition: Formatting volume NTFS" -ForegroundColor Cyan
            $null = Format-Volume -Partition $PartitionOSDisk -NewFileSystemLabel 'OSDisk' -FileSystem NTFS -Force -Confirm:$false
    
            Write-Host "Recovery Partition: Creating Partition" -ForegroundColor Cyan
            $PartitionRecovery = New-Partition -DiskNumber $PrimaryDisk.Number -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -UseMaximumSize
    
            Write-Host "Recovery Partition: Formatting volume NTFS" -ForegroundColor Cyan
            $null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel 'Recovery' -FileSystem NTFS -Force -Confirm:$false
        }
    }
}