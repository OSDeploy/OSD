function Get-OSDGather {
    [CmdletBinding()]
    Param (
        [switch]$Full
    )

    #===================================================================================================
    #   Get-CimInstance
    #===================================================================================================
    $Win32OperatingSystem = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property *)
    $Win32ComputerSystem = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property *)
    $Win32SystemEnclosure = (Get-CimInstance -ClassName Win32_SystemEnclosure | Select-Object -Property *)

    if ($Full.IsPresent) {
        $OSDGather = [ordered]@{
            IsAdmin = Get-OSDValue -Property IsAdmin
    
            IsLaptop = Get-OSDValue -Property IsLaptop
            IsDesktop = Get-OSDValue -Property IsDesktop
            IsServer = Get-OSDValue -Property IsServer
            IsSFF = Get-OSDValue -Property IsSFF
            IsTablet = Get-OSDValue -Property IsTablet
    
            IsWinOS = Get-OSDValue -Property IsWinOS
            IsWinPE = Get-OSDValue -Property IsWinPE
            IsWinSE = ((Get-OSDValue -Property IsWinPE) -and (Test-Path 'X:\Setup.exe'))
            #IsServerCoreOS = "False"
            #IsServerOS = "False"
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
    
            Win32_Battery = (Get-CimInstance -ClassName Win32_Battery | Select-Object -Property *)
            Win32_BaseBoard = (Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property *)
            Win32_BIOS = (Get-CimInstance -ClassName Win32_BIOS | Select-Object -Property *)
            Win32_BootConfiguration = (Get-CimInstance -ClassName Win32_BootConfiguration | Select-Object -Property *)
            Win32_ComputerSystem = $Win32ComputerSystem
            Win32_Desktop = (Get-CimInstance -ClassName Win32_Desktop | Select-Object -Property *)
            Win32_DiskPartition = (Get-CimInstance -ClassName Win32_DiskPartition | Select-Object -Property *)
            Win32_DisplayConfiguration = (Get-CimInstance -ClassName Win32_DisplayConfiguration | Select-Object -Property *)
            Win32_Environment = (Get-CimInstance -ClassName Win32_Environment | Select-Object -Property *)
            Win32_LogicalDisk = (Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property *)
            Win32_LogicalDiskRootDirectory = (Get-CimInstance -ClassName Win32_LogicalDiskRootDirectory | Select-Object -Property *)
            Win32_MemoryArray = (Get-CimInstance -ClassName Win32_MemoryArray | Select-Object -Property *)
            Win32_MemoryDevice = (Get-CimInstance -ClassName Win32_MemoryDevice | Select-Object -Property *)
            Win32_NetworkAdapter = (Get-CimInstance -ClassName Win32_NetworkAdapter | Select-Object -Property *)
            Win32_NetworkAdapterConfiguration = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Select-Object -Property *)
            Win32_OperatingSystem = $Win32OperatingSystem
            Win32_OSRecoveryConfiguration = (Get-CimInstance -ClassName Win32_OSRecoveryConfiguration | Select-Object -Property *)
            Win32_PhysicalMedia = (Get-CimInstance -ClassName Win32_PhysicalMedia | Select-Object -Property *)
            Win32_PhysicalMemory = (Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object -Property *)
            Win32_PnpDevice = (Get-CimInstance -ClassName Win32_PnpDevice | Select-Object -Property *)
            Win32_PnPEntity = (Get-CimInstance -ClassName Win32_PnPEntity | Select-Object -Property *)
            Win32_PortableBattery = (Get-CimInstance -ClassName Win32_PortableBattery | Select-Object -Property *)
            Win32_Processor = (Get-CimInstance -ClassName Win32_Processor | Select-Object -Property *)
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
    } else {
        $OSDGather = [ordered]@{
            IsAdmin = Get-OSDValue -Property IsAdmin
    
            IsLaptop = Get-OSDValue -Property IsLaptop
            IsDesktop = Get-OSDValue -Property IsDesktop
            IsServer = Get-OSDValue -Property IsServer
            IsSFF = Get-OSDValue -Property IsSFF
            IsTablet = Get-OSDValue -Property IsTablet
    
            IsWinOS = Get-OSDValue -Property IsWinOS
            IsWinPE = Get-OSDValue -Property IsWinPE
            IsWinSE = ((Get-OSDValue -Property IsWinPE) -and (Test-Path 'X:\Setup.exe'))
            #IsServerCoreOS = "False"
            #IsServerOS = "False"
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