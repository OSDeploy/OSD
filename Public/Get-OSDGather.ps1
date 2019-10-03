<#
.SYNOPSIS
Returns common OSD information as an ordered hash table

.DESCRIPTION
Returns common OSD information as an ordered hash table

.EXAMPLE
$OSDGather = Get-OSDGather
$OSDGather.Model

.LINK
https://osd.osdeploy.com/module/functions/get-osdgather

.NOTES
19.10.1     David Segura @SeguraOSD
#>
function Get-OSDGather {
    [CmdletBinding()]
    Param ()
    #===================================================================================================
    #   Get-ComputerInfo
    #===================================================================================================
    #https://docs.microsoft.com/en-us/dotnet/api/microsoft.powershell.commands.computerinfo?view=powershellsdk-1.1.0
    $GetComputerInfo = @{}
    $GetComputerInfo = Get-ComputerInfo
    #===================================================================================================
    #   Get Registry
    #===================================================================================================
    $RegVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    try {
        $RegVersion.DigitalProductId = $null
        $RegVersion.DigitalProductId4 = $null
    }
    catch {}
    $RegControl = Get-ItemProperty -Path 'HKLM:\SYSTEM\ControlSet001\Control'
    $RegSetup = Get-ItemProperty -Path 'HKLM:\SYSTEM\Setup'
    #===================================================================================================
    #   Get CimInstance
    #===================================================================================================
    $Win32BIOS = (Get-CimInstance -ClassName Win32_BIOS | Select-Object -Property *)
    $Win32BaseBoard = (Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property *)
    $Win32Battery = (Get-CimInstance -ClassName Win32_Battery | Select-Object -Property *)
    $Win32ComputerSystem = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property *)
    $Win32ComputerSystemProduct = (Get-CimInstance -ClassName Win32_ComputerSystemProduct | Select-Object -Property *)
    $Win32DiskPartition = (Get-CimInstance -ClassName Win32_DiskPartition | Select-Object -Property *)
    $Win32DisplayConfiguration = (Get-CimInstance -ClassName Win32_DisplayConfiguration | Select-Object -Property *)
    $Win32Environment = (Get-CimInstance -ClassName Win32_Environment | Select-Object -Property *)
    $Win32LogicalDisk = (Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property *)
    $Win32NetworkAdapter = (Get-CimInstance -ClassName Win32_NetworkAdapter | Select-Object -Property *)
    $Win32NetworkAdapterConfiguration = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Select-Object -Property *)
    $Win32OperatingSystem = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property *)
    $Win32PnPEntity = (Get-CimInstance -ClassName Win32_PnPEntity | Select-Object -Property *)
    #$Win32PortableBattery = (Get-CimInstance -ClassName Win32_PortableBattery | Select-Object -Property *)
    $Win32Processor = (Get-CimInstance -ClassName Win32_Processor | Select-Object -Property *)
    $Win32SCSIController = (Get-CimInstance -ClassName Win32_SCSIController | Select-Object -Property *)
    $Win32SystemDesktop = (Get-CimInstance -ClassName Win32_SystemDesktop | Select-Object -Property *)
    $Win32SystemEnclosure = (Get-CimInstance -ClassName Win32_SystemEnclosure | Select-Object -Property *)
    $Win32UserDesktop = (Get-CimInstance -ClassName Win32_UserDesktop | Select-Object -Property *)
    $Win32VideoController = (Get-CimInstance -ClassName Win32_VideoController | Select-Object -Property *)
    $Win32Volume = (Get-CimInstance -ClassName Win32_Volume | Select-Object -Property *)
    $CimVideoControllerResolution = (Get-CimInstance -ClassName CIM_VideoControllerResolution | Select-Object -Property *)
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
    $Win32NetworkAdapterConfiguration | Where-Object {$_.IpEnabled -eq $true} | ForEach-Object {
        $_.IPAddress | ForEach-Object {$ipList += $_ }
        $_.MacAddress | ForEach-Object {$macList += $_ }
        if ($_.DefaultGateway) {$_.DefaultGateway | ForEach-Object {$gwList += $_ }}
    }
    $IPAddress = $ipList
    $MacAddress = $macList
    $DefaultGateway = $gwList
    #===================================================================================================
    #   IsBDE
    #   Credit Johan Schrewelius    https://gallery.technet.microsoft.com/PowerShell-script-that-a8a7bdd8
    #===================================================================================================
    $IsBDE = $false
    $BitlockerEncryptionType = $null
    $BitlockerEncryptionMethod = $null

    $EncVols = Get-WmiObject -Namespace 'ROOT\cimv2\Security\MicrosoftVolumeEncryption' -Query "Select * from Win32_EncryptableVolume" -EA SilentlyContinue
    if ($EncVols) {
        foreach ($EncVol in $EncVols) {
            if($EncVol.ProtectionStatus -ne 0) {
                $EncMethod = [int]$EncVol.GetEncryptionMethod().EncryptionMethod
                if ($EncryptionMethods.ContainsKey($EncMethod)) {$BitlockerEncryptionMethod = $EncryptionMethods[$EncMethod]}
                $Status = $EncVol.GetConversionStatus(0)
                if ($Status.ReturnValue -eq 0) {
                    if ($Status.EncryptionFlags -eq 0x00000001) {$BitlockerEncryptionType = "Used Space Only Encrypted"}
                    else {$BitlockerEncryptionType = "Full Disk Encryption"}
                } else {$BitlockerEncryptionType = "Unknown"}

                $IsBDE = $true
            }
        }
    }
    $BitlockerEncryptionMethod
    $BitlockerEncryptionType
    #===================================================================================================
    #   IsUEFI
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #===================================================================================================
<#     try {
        Get-SecureBootUEFI -Name SetupMode | Out-Null
        $IsUEFI = $true
    }
    catch {$IsUEFI = $false} #>
    #===================================================================================================
    #   HashTable
    #===================================================================================================
    $GetOSDGather = [ordered]@{
        IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
        IsBDE = $IsBDE
        IsClientOS = $GetComputerInfo.WindowsInstallationType -eq 'Client'
        IsDesktop = ($GetComputerInfo.CsPCSystemTypeEx -eq 'Desktop' -or $GetComputerInfo.CsPCSystemTypeEx -eq 'Workstation')
        #IsLaptop = Get-OSDProperty -Property IsLaptop
        IsLaptop = $GetComputerInfo.CsPCSystemTypeEx -eq 'Mobile'
        IsOnBattery = ($Win32Battery.BatteryStatus -eq 1)
        IsSFF = Get-OSDProperty -Property IsSFF
        IsServer = $GetComputerInfo.CsPCSystemTypeEx -match 'Server'
        IsServerCoreOS = $GetComputerInfo.OsServerLevel -eq 'ServerCore'
        IsServerOS = $GetComputerInfo.OsServerLevel -eq 'FullServer'
        IsTablet = $GetComputerInfo.CsPCSystemTypeEx -eq 'Slate'
        IsUEFI = $GetComputerInfo.BiosFirmwareType -eq 'Uefi'
        IsVM = $GetComputerInfo.CsChassisSKUNumber -eq 'Virtual Machine'
        IsWinPE = $env:SystemDrive -eq 'X:'
        IsInWinSE = Get-OSDProperty -Property IsInWinSE
        #===================================================================================================
        #   MDT Variables
        #===================================================================================================
        Architecture = $Architecture
        AssetTag = Get-OSDProperty -Property AssetTag
        #ToDoCapableArchitecture = $null    #AMD64 X64 X86
        #DEBUG = FALSE
        #ToDoDefaultGateway = $null
        #ToDoHalName = $null #acpiapic
        HostName = $GetComputerInfo.CsDNSHostName
        IPAddress = $IPAddress
        #LOGPATH = C:\MININT\SMSOSD\OSDLOGS
        MacAddress = $MacAddress
        Make = $GetComputerInfo.CsManufacturer
        Memory = [int] ($GetComputerInfo.CsTotalPhysicalMemory / 1024 / 1024)
        Model = $GetComputerInfo.CsModel
        #ORIGINALARCHITECTURE = X64
        #ORIGINALPARTITIONIDENTIFIER = SELECT * FROM Win32_LogicalDisk WHERE Size = '498731053056' and VolumeName = 'OSDisk' and VolumeSerialNumber = '5AC885B9'
        #OriginalWindir = $GetComputerInfo.OsWindowsDirectory
        OsCurrentBuild = $GetComputerInfo.OsBuildNumber
        OsCurrentVersion = $GetComputerInfo.OsVersion
        OsSku = $GetComputerInfo.WindowsEditionId
        #OsVersion = $GetComputerInfo.WindowsVersion
        ProcessorSpeed = $Win32Processor.MaxClockSpeed
        Product = $Win32BaseBoard.Product
        SerialNumber = $GetComputerInfo.BiosSeralNumber
        #SupportsHyperVRole = True
        SupportsSLAT = $Win32Processor.SecondLevelAddressTranslationExtensions
        #SupportsX64 = True
        #SupportsX86 = True
        UUID = $Win32ComputerSystemProduct.UUID
        #===================================================================================================
        #   
        #===================================================================================================
        ComputerInfo = ($GetComputerInfo | Sort-Object)
        RegControl = $RegControl
        RegSetup = $RegSetup
        RegVersion = $RegVersion
        #===================================================================================================
        #   CimInstance
        #===================================================================================================
        BIOS = $Win32BIOS
        BaseBoard = $Win32BaseBoard
        Battery = $Win32Battery
        ComputerSystem = $Win32ComputerSystem
        ComputerSystemProduct = $Win32ComputerSystemProduct
        DiskPartition = $Win32DiskPartition
        DisplayConfiguration = $Win32DisplayConfiguration
        Environment = $Win32Environment
        LogicalDisk = $Win32LogicalDisk
        NetworkAdapter = $Win32NetworkAdapter
        NetworkAdapterConfiguration = $Win32NetworkAdapterConfiguration
        OperatingSystem = $Win32OperatingSystem
        PnPEntity = $Win32PnPEntity
        #PortableBattery = $Win32PortableBattery
        Processor = $Win32Processor
        SCSIController = $Win32SCSIController
        SystemDesktop = $Win32SystemDesktop
        SystemEnclosure = $Win32SystemEnclosure
        UserDesktop = $Win32UserDesktop
        VideoController = $Win32VideoController
        VideoControllerResolution = $CIMVideoControllerResolution
        Volume = $Win32Volume
        #===================================================================================================
        #   Other
        #===================================================================================================
<#         OsCaption = $Win32OperatingSystem.Caption
        BitlockerEncryptionMethod = $BitlockerEncryptionMethod
        BitlockerEncryptionType = $BitlockerEncryptionType
        ChassisSKUNumber = $Win32ComputerSystem.ChassisSKUNumber
        ChassisTypes = $Win32SystemEnclosure.ChassisTypes
        ComputerName = $env:COMPUTERNAME
        Manufacturer = $GetComputerInfo.CsManufacturer
        ProductType = $Win32OperatingSystem.ProductType
        SystemDevice = $Win32OperatingSystem.SystemDevice
        SystemDirectory = $Win32OperatingSystem.SystemDirectory
        SystemDrive = $Win32OperatingSystem.SystemDrive
        SystemFamily = $Win32ComputerSystem.SystemFamily
        SystemSKUNumber = $Win32ComputerSystem.SystemSKUNumber #>
    }
    Return $GetOSDGather
    Break
}