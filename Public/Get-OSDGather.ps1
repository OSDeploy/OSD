function Get-OSDGather {
    [CmdletBinding()]
    Param (
        [switch]$Full
    )
    #===================================================================================================
    #	System Setup
    #===================================================================================================
<#     if (Test-Path 'HKLM:\SYSTEM\Setup') {
        $HKLMSystemSetup = Get-ItemProperty -Path 'HKLM:\SYSTEM\Setup'

        [int]$SetupPhase = $HKLMSystemSetup.SetupPhase
        if ($null -eq $SetupPhase) {$SetupPhase = 0}

        [int]$SetupType = $HKLMSystemSetup.SetupType
        if ($null -eq $SetupType) {$SetupType = 0}

        [int]$SystemSetupInProgress = $HKLMSystemSetup.SystemSetupInProgress
        if ($null -eq $SetupPhase) {$SetupPhase = 0}

        [int]$FactoryPreInstallInProgress = $HKLMSystemSetup.FactoryPreInstallInProgress
        if ($null -eq $FactoryPreInstallInProgress) {$FactoryPreInstallInProgress = 0}

        [int]$OOBEInProgress = $HKLMSystemSetup.OOBEInProgress
        if ($null -eq $OOBEInProgress) {$OOBEInProgress = 0}

        #$WorkingDirectory = $HKLMSystemSetup.WorkingDirectory
        #Write-Verbose "Property WorkingDirectory: $WorkingDirectory"

        if ($SystemSetupInProgress -eq 0) {$OSDPhase = 'Windows'}
        if ($FactoryPreInstallInProgress -eq 1) {$OSDPhase = 'WinXE'}
        if ($SetupPhase -eq 4) {$OSDPhase = 'Specialize'}
        if ($OOBEInProgress -eq 1) {$OSDPhase = 'OOBE'}
    } #>
    #===================================================================================================
    #   Get-CimInstance
    #===================================================================================================
    $Win32BIOS = (Get-CimInstance -ClassName Win32_BIOS | Select-Object -Property *)
    $Win32BaseBoard = (Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property *)
    $Win32ComputerSystem = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property *)
    $Win32ComputerSystemProduct = (Get-CimInstance -ClassName Win32_ComputerSystemProduct | Select-Object -Property *)
    $Win32OperatingSystem = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property *)
    $Win32NetworkAdapterConfiguration = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Select-Object -Property *)
    $Win32Processor = (Get-CimInstance -ClassName Win32_Processor | Select-Object -Property *)
    $Win32SystemEnclosure = (Get-CimInstance -ClassName Win32_SystemEnclosure | Select-Object -Property *)
    #===================================================================================================
    #   Architecture
    #===================================================================================================
    if ($env:PROCESSOR_ARCHITEW6432) {
        if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
            $Architecture = "x64"
        } else {
            $Architecture = $env:PROCESSOR_ARCHITEW6432.ToUpper()
        }
    } else {
        if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
            $Architecture = "x64"
        } else {
            $Architecture = $env:PROCESSOR_ARCHITECTURE.ToUpper()
        }
      }
    #===================================================================================================
    #   Win32NetworkAdapterConfiguration
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #===================================================================================================
    $ipList = @()
    $macList = @()
    $gwList = @()
    Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 1" | ForEach-Object {
        $_.IPAddress | ForEach-Object {$ipList += $_ }
        $_.MacAddress | ForEach-Object {$macList += $_ }
        if ($_.DefaultGateway) {$_.DefaultGateway | ForEach-Object {$gwList += $_ }}
    }
    $IPAddress = $ipList
    $MacAddress = $macList
    $DefaultGateway = $gwList
    #===================================================================================================
    #   IsOnBattery
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #===================================================================================================
<#     $bFoundAC = $false
    $bOnBattery = $false
	$bFoundBattery = $false
    foreach($Battery in (Get-WmiObject -Class Win32_Battery))
    {
        $bFoundBattery = $true
        if ($Battery.BatteryStatus -eq "2")
        {
            $bFoundAC = $true
        }
    }
    If ($bFoundBattery -and !$bFoundAC)
    {
        $tsenv.IsOnBattery = $true
    } #>
    #===================================================================================================
    #   IsUEFI
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #===================================================================================================
<#     try
    {
        Get-SecureBootUEFI -Name SetupMode | Out-Null
        $tsenv:IsUEFI = "True"
    }
    catch
    {
        $tsenv:IsUEFI = "False"
    } #>


    if (!($Full.IsPresent)) {
        $OSDGather = [ordered]@{
            IsAdmin = Get-OSDValue -Property IsAdmin

            IsLaptop = Get-OSDValue -Property IsLaptop
            IsDesktop = Get-OSDValue -Property IsDesktop
            IsServer = Get-OSDValue -Property IsServer
            IsSFF = Get-OSDValue -Property IsSFF
            IsTablet = Get-OSDValue -Property IsTablet

            IsUEFI = Get-OSDValue -Property IsUEFI
            #===================================================================================================
            #   Operating System
            #===================================================================================================
            IsWinPE = Get-OSDValue -Property IsWinPE
            IsWinSE = Get-OSDValue -Property IsWinSE
            IsWinOS = Get-OSDValue -Property IsWinOS
            IsServerOS = Get-OSDValue -Property IsServerOS
            IsServerCoreOS = Get-OSDValue -Property IsServerCoreOS

            Architecture = $Architecture
            
            #===================================================================================================
            #   BaseBoard
            #===================================================================================================
            Product = $Win32BaseBoard.Product
            #===================================================================================================
            #   ComputerSystem
            #===================================================================================================
            Make = $Win32ComputerSystem.Manufacturer
            Manufacturer = $Win32ComputerSystem.Manufacturer
            Model = $Win32ComputerSystem.Model
            Memory = [int] ($Win32ComputerSystem.TotalPhysicalMemory / 1024 / 1024)
            #===================================================================================================
            #   ComputerSystemProduct
            #===================================================================================================
            UUID = $Win32ComputerSystemProduct.UUID
            #===================================================================================================
            #   System
            #===================================================================================================
            SerialNumber = $Win32BIOS.SerialNumber.Trim()
            #===================================================================================================
            #   Processor
            #===================================================================================================
            ProcessorSpeed = $Win32Processor.MaxClockSpeed
            SupportsSLAT = $Win32Processor.SecondLevelAddressTranslationExtensions
            #===================================================================================================
            #   Network
            #===================================================================================================
            IPAddress = $IPAddress
            MacAddress = $MacAddress
            DefaultGateway = $DefaultGateway
            #===================================================================================================
            #   SystemSetup
            #===================================================================================================
<#             OSDPhase = $OSDPhase
            SetupPhase = $SetupPhase
            SetupType = $SetupType
            SystemSetupInProgress = $SystemSetupInProgress
            FactoryPreInstallInProgress = $FactoryPreInstallInProgress
            OOBEInProgress = $OOBEInProgress #>
            #===================================================================================================
            #   Win32_OperatingSystem
            #===================================================================================================
            OSCurrentVersion = $Win32OperatingSystem.Version
            OSCurrentBuild = $Win32OperatingSystem.BuildNumber
            #===================================================================================================
            #   Win32_SystemEnclosure
            #===================================================================================================
            AssetTag = $Win32SystemEnclosure.SMBIOSAssetTag.Trim()
            ChassisTypes = $Win32SystemEnclosure.ChassisTypes
            #===================================================================================================
            #   Registry
            #===================================================================================================
            RegCurrentVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
            RegSystemControl = Get-ItemProperty -Path 'HKLM:\SYSTEM\ControlSet001\Control'
            RegSystemSetup = Get-ItemProperty -Path 'HKLM:\SYSTEM\Setup'
        }
    }

    if ($Full.IsPresent) {
        $OSDGather = [ordered]@{
            IsAdmin = Get-OSDValue -Property IsAdmin

            IsLaptop = Get-OSDValue -Property IsLaptop
            IsDesktop = Get-OSDValue -Property IsDesktop
            IsServer = Get-OSDValue -Property IsServer
            IsSFF = Get-OSDValue -Property IsSFF
            IsTablet = Get-OSDValue -Property IsTablet

            IsUEFI = Get-OSDValue -Property IsUEFI

            IsWinPE = Get-OSDValue -Property IsWinPE
            IsWinSE = Get-OSDValue -Property IsWinSE
            IsWinOS = Get-OSDValue -Property IsWinOS
            IsServerOS = Get-OSDValue -Property IsServerOS
            IsServerCoreOS = Get-OSDValue -Property IsServerCoreOS
            #===================================================================================================
            #   SystemSetup
            #===================================================================================================
<#             OSDPhase = $OSDPhase
            SetupPhase = $SetupPhase
            SetupType = $SetupType
            SystemSetupInProgress = $SystemSetupInProgress
            FactoryPreInstallInProgress = $FactoryPreInstallInProgress
            OOBEInProgress = $OOBEInProgress #>
            #===================================================================================================
            #   Win32_ComputerSystem
            #===================================================================================================

            #===================================================================================================
            #   Win32_OperatingSystem
            #===================================================================================================
            OSCurrentVersion = $Win32OperatingSystem.Version
            OSCurrentBuild = $Win32OperatingSystem.BuildNumber
            #===================================================================================================
            #   Win32_SystemEnclosure
            #===================================================================================================
            AssetTag = $Win32SystemEnclosure.SMBIOSAssetTag.Trim()
            ChassisTypes = $Win32SystemEnclosure.ChassisTypes
            #===================================================================================================
            #   Registry
            #===================================================================================================
            RegCurrentVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
            RegSystemControl = Get-ItemProperty -Path 'HKLM:\SYSTEM\ControlSet001\Control'
            RegSystemSetup = Get-ItemProperty -Path 'HKLM:\SYSTEM\Setup'
            #===================================================================================================
            #   CimInstance
            #===================================================================================================
            Win32_Battery = (Get-CimInstance -ClassName Win32_Battery | Select-Object -Property *)
            Win32_BaseBoard = $Win32BaseBoard
            Win32_BIOS = $Win32BIOS
            Win32_BootConfiguration = (Get-CimInstance -ClassName Win32_BootConfiguration | Select-Object -Property *)
            Win32_ComputerSystem = $Win32ComputerSystem
            Win32_ComputerSystemProduct = $Win32ComputerSystemProduct
            Win32_Desktop = (Get-CimInstance -ClassName Win32_Desktop | Select-Object -Property *)
            Win32_DiskPartition = (Get-CimInstance -ClassName Win32_DiskPartition | Select-Object -Property *)
            Win32_DisplayConfiguration = (Get-CimInstance -ClassName Win32_DisplayConfiguration | Select-Object -Property *)
            Win32_Environment = (Get-CimInstance -ClassName Win32_Environment | Select-Object -Property *)
            Win32_LogicalDisk = (Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property *)
            Win32_LogicalDiskRootDirectory = (Get-CimInstance -ClassName Win32_LogicalDiskRootDirectory | Select-Object -Property *)
            Win32_MemoryArray = (Get-CimInstance -ClassName Win32_MemoryArray | Select-Object -Property *)
            Win32_MemoryDevice = (Get-CimInstance -ClassName Win32_MemoryDevice | Select-Object -Property *)
            Win32_NetworkAdapter = (Get-CimInstance -ClassName Win32_NetworkAdapter | Select-Object -Property *)
            Win32_NetworkAdapterConfiguration = $Win32NetworkAdapterConfiguration
            Win32_OperatingSystem = $Win32OperatingSystem
            Win32_OSRecoveryConfiguration = (Get-CimInstance -ClassName Win32_OSRecoveryConfiguration | Select-Object -Property *)
            Win32_PhysicalMedia = (Get-CimInstance -ClassName Win32_PhysicalMedia | Select-Object -Property *)
            Win32_PhysicalMemory = (Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object -Property *)
            Win32_PnpDevice = (Get-CimInstance -ClassName Win32_PnpDevice | Select-Object -Property *)
            Win32_PnPEntity = (Get-CimInstance -ClassName Win32_PnPEntity | Select-Object -Property *)
            Win32_PortableBattery = (Get-CimInstance -ClassName Win32_PortableBattery | Select-Object -Property *)
            Win32_Processor = $Win32Processor
            Win32_SCSIController = (Get-CimInstance -ClassName Win32_SCSIController | Select-Object -Property *)
            Win32_SCSIControllerDevice = (Get-CimInstance -ClassName Win32_SCSIControllerDevice | Select-Object -Property *)
            Win32_SMBIOSMemory = (Get-CimInstance -ClassName Win32_SMBIOSMemory | Select-Object -Property *)
            Win32_SystemBIOS = (Get-CimInstance -ClassName Win32_SystemBIOS | Select-Object -Property *)
            Win32_SystemEnclosure = $Win32SystemEnclosure
            Win32_SystemDesktop = (Get-CimInstance -ClassName Win32_SystemDesktop | Select-Object -Property *)
            Win32_SystemPartitions = (Get-CimInstance -ClassName Win32_SystemPartitions | Select-Object -Property *)
            Win32_UserDesktop = (Get-CimInstance -ClassName Win32_UserDesktop | Select-Object -Property *)
            Win32_VideoController = (Get-CimInstance -ClassName Win32_VideoController | Select-Object -Property *)
            Win32_VideoSettings = (Get-CimInstance -ClassName Win32_VideoSettings | Select-Object -Property *)
            Win32_Volume = (Get-CimInstance -ClassName Win32_Volume | Select-Object -Property *)
        }
    }
<#         #===================================================================================================
        #   Win32_OperatingSystem
        #===================================================================================================
        BootDevice = $Win32OperatingSystem.BootDevice
        BuildNumber = $Win32OperatingSystem.BuildNumber
        Caption = $Win32OperatingSystem.Caption
        InstallDate = $Win32OperatingSystem.InstallDate
        Locale = $Win32OperatingSystem.Locale
        OSArchitecture = $Win32OperatingSystem.OSArchitecture
        OperatingSystemSKU = $Win32OperatingSystem.OperatingSystemSKU
        ProductType = $Win32OperatingSystem.ProductType
        SystemDevice = $Win32OperatingSystem.SystemDevice
        SystemDirectory = $Win32OperatingSystem.SystemDirectory
        SystemDrive = $Win32OperatingSystem.SystemDrive
        Version = $Win32OperatingSystem.Version
        WindowsDirectory = $Win32OperatingSystem.WindowsDirectory
        #===================================================================================================
        #   Win32_ComputerSystem
        #===================================================================================================
        ChassisSKUNumber = $Win32ComputerSystem.ChassisSKUNumber
        Name = $Win32ComputerSystem.Name
        Make = $Win32ComputerSystem.Manufacturer
        Manufacturer = $Win32ComputerSystem.Manufacturer
        Model = $Win32ComputerSystem.Model
        SystemFamily = $Win32ComputerSystem.SystemFamily
        SystemSKUNumber = $Win32ComputerSystem.SystemSKUNumber #>
    Return $OSDGather
}