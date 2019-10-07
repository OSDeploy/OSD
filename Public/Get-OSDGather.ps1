<#
.SYNOPSIS
Returns common OSD information as an ordered hash table

.DESCRIPTION
Returns common OSD information as an ordered hash table

.EXAMPLE
OSDGather
Get-OSDGather
Returns the Gather Results

.EXAMPLE
$OSDGather = Get-OSDGather
$OSDGather.IsAdmin
$OSDGather.ComputerInfo
Returns the Gather Results saved in a Variable

.LINK
https://osd.osdeploy.com/module/functions/get-osdgather

.NOTES
19.10.4.0   David Segura @SeguraOSD
#>
function Get-OSDGather {
    [CmdletBinding()]
    param (
        #Returns the Name Value
        [Parameter(Position = 0)]
        [ValidateSet(
            'IsAdmin',
            'IsBDE',
            'IsClientOS',
            'IsDesktop',
            'IsLaptop',
            'IsOnBattery',
            'IsSFF',
            'IsServer',
            'IsServerChassis',
            'IsServerCoreOS',
            'IsServerOS',
            'IsTablet',
            'IsUEFI',
            'IsVM',
            'IsWinPE',
            'IsInWinSE'
            )]
        [string]$Property,
        [switch]$Full
    )
    #======================================================================================================
    #   IsAdmin
    #======================================================================================================
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    if ($Property -eq 'IsAdmin') {Return $IsAdmin}
    #======================================================================================================
    #   IsWinPE
    #======================================================================================================
    $IsWinPE = $env:SystemDrive -eq 'X:'
    if ($Property -eq 'IsWinPE') {Return $IsWinPE}
    #======================================================================================================
    #   IsInWinPE
    #======================================================================================================
    $IsInWinSE = ($IsWinPE) -and (Test-Path 'X:\Setup.exe')
    if ($Property -eq 'IsInWinSE') {Return $IsInWinSE}
    #======================================================================================================
    #   IsUEFI
    #======================================================================================================
    if ($IsWinPE) {
        $IsUEFI = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control).PEFirmwareType -eq 2
    } else {
        if ($null -eq (Get-ItemProperty HKLM:\System\CurrentControlSet\Control\SecureBoot\State -ErrorAction SilentlyContinue)) {
            $IsUEFI = $false
        } else {
            $IsUEFI = $true
        }
    }
    if ($Property -eq 'IsUEFI') {Return $IsUEFI}
    #===================================================================================================
    #   IsUEFI
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #===================================================================================================
<#     try {
        Get-SecureBootUEFI -Name SetupMode | Out-Null
        $IsUEFI = $true
    }
    catch {$IsUEFI = $false} #>
    #======================================================================================================
    #   IsBDE
    #   Credit Johan Schrewelius    https://gallery.technet.microsoft.com/PowerShell-script-that-a8a7bdd8
    #======================================================================================================
    $IsBDE = $false
    $BitlockerEncryptionType = $null
    $BitlockerEncryptionMethod = $null

    $EncryptionMethods = @{ 0 = "UNSPECIFIED";
                        1 = 'AES_128_WITH_DIFFUSER';
                        2 = "AES_256_WITH_DIFFUSER";
                        3 = 'AES_128';
                        4 = "AES_256";
                        5 = 'HARDWARE_ENCRYPTION';
                        6 = "AES_256";
                        7 = "XTS_AES_256" }

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
    if ($Property -eq 'IsBDE') {Return $IsBDE}
    #======================================================================================================
    #   Get-CimInstance Win32_ComputerSystem
    #======================================================================================================
    $Win32ComputerSystem = (Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue | Select-Object -Property *)
    #======================================================================================================
    #   IsOS
    #======================================================================================================
    $IsClientOS = $false
    $IsServerOS = $false
    $IsServerCoreOS = $false

    if ($IsWinPE -eq $false) {
        if ($Win32ComputerSystem.Roles -match 'Server_NT' -or $Win32ComputerSystem.Roles -match 'LanmanNT') {
            $IsClientOS = $false
            $IsServerOS = $true
        } else {
            $IsClientOS = $true
            $IsServerOS = $false
        }

        if (!(Test-Path "$env:windir\explorer.exe")) {
            $IsClientOS = $false
            $IsServerOS = $false
            $IsServerCoreOS = $true
        }
    }
    if ($Property -eq 'IsClientOS') {Return $IsClientOS}
    if ($Property -eq 'IsServerOS') {Return $IsServerOS}
    if ($Property -eq 'IsServerCoreOS') {Return $IsServerCoreOS}
    #======================================================================================================
    #   IsVM
    #======================================================================================================
    $IsVM = ($Win32ComputerSystem.Model -match 'Virtual') -or ($Win32ComputerSystem.Model -match 'VMware')
    if ($Property -eq 'IsVM') {Return $IsVM}
    #======================================================================================================
    #   Get-CimInstance Win32_SystemEnclosure
    #======================================================================================================
    $Win32SystemEnclosure = (Get-CimInstance -ClassName Win32_SystemEnclosure -ErrorAction SilentlyContinue | Select-Object -Property *)
    #======================================================================================================
    #   Win32_SystemEnclosure
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #   Credit Johan Schrewelius    https://gallery.technet.microsoft.com/PowerShell-script-that-a8a7bdd8
    #======================================================================================================
    $IsDesktop = $false
    $IsLaptop = $false
    $IsServer = $false
    $IsSFF = $false
    $IsTablet = $false
    $Win32SystemEnclosure | ForEach-Object {
        if ($_.ChassisTypes[0] -in "8", "9", "10", "11", "12", "14", "18", "21") { $IsLaptop = $true }
        if ($_.ChassisTypes[0] -in "3", "4", "5", "6", "7", "15", "16") { $IsDesktop = $true }
        if ($_.ChassisTypes[0] -in "23") {$IsServer = $true}
        if ($_.ChassisTypes[0] -in "34", "35", "36") { $IsSFF = $true }
        if ($_.ChassisTypes[0] -in "13", "31", "32", "30") { $IsTablet = $true } 
    }
    if ($Property -eq 'IsDesktop') {Return $IsDesktop}
    if ($Property -eq 'IsLaptop') {Return $IsLaptop}
    if ($Property -eq 'IsServer' -or $Property -eq 'IsServerChassis') {Return $IsServer}
    if ($Property -eq 'IsSFF') {Return $IsSFF}
    if ($Property -eq 'IsTablet') {Return $IsTablet}
    #======================================================================================================
    #   Get-CimInstance Win32_Battery
    #======================================================================================================
    $Win32Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue | Select-Object -Property *)
    #======================================================================================================
    #   IsOnBattery
    #======================================================================================================
    $IsOnBattery = ($Win32Battery.BatteryStatus -contains 1)
    if ($Property -eq 'IsOnBattery') {Return $IsOnBattery}
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
    $Win32NetworkAdapterConfiguration = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Select-Object -Property *)
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
    #   Get Registry
    #===================================================================================================
    $RegControl = Get-ItemProperty -Path 'HKLM:\SYSTEM\ControlSet001\Control'
    $RegSetup = Get-ItemProperty -Path 'HKLM:\SYSTEM\Setup'
    $RegVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    try {
        $RegVersion.DigitalProductId = $null
        $RegVersion.DigitalProductId4 = $null
    }
    catch {}
    #===================================================================================================
    #   MDT Get CimInstance
    #===================================================================================================
    $Win32BIOS = (Get-CimInstance -ClassName Win32_BIOS | Select-Object -Property *)
    $Win32BaseBoard = (Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property *)
    $Win32ComputerSystemProduct = (Get-CimInstance -ClassName Win32_ComputerSystemProduct | Select-Object -Property *)
    $Win32OperatingSystem = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property *)
    $Win32Processor = (Get-CimInstance -ClassName Win32_Processor | Select-Object -Property *)
    #===================================================================================================
    #   Bitlocker
    #===================================================================================================
    try {$GetBitlockerVolume = Get-BitlockerVolume}
    catch {$GetBitlockerVolume = $null}

    try {$GetPhysicalDisk = Get-PhysicalDisk}
    catch {$GetPhysicalDisk = $null}
    #===================================================================================================
    #   Supports
    #===================================================================================================
    $SupportsNX = $Win32OperatingSystem.DataExecutionPrevention_Available -eq $true
    $Supports32Bit = $Win32Processor.DataWidth -match 32
    $Supports64Bit = $Win32Processor.DataWidth -match 64
    #======================================================================================================
    #   MDT Variables
    #======================================================================================================
    $GetOSDGatherMDT = [ordered]@{
        Architecture = $Architecture
        AssetTag = $Win32SystemEnclosure.SMBIOSAssetTag.Trim()
        #CapableArchitecture = AMD64 X64 X86
        #DEBUG = FALSE
        #DefaultGateway =
        #HalName = acpiapic
        HostName = $Win32ComputerSystem.DNSHostName
        IPAddress = $IPAddress
        #LOGPATH = C:\MININT\SMSOSD\OSDLOGS
        MacAddress = $MacAddress
        Make = $Win32ComputerSystem.Manufacturer
        Memory = [int] ($Win32ComputerSystem.TotalPhysicalMemory / 1024 / 1024)
        Model = $Win32ComputerSystem.Model
        #ORIGINALARCHITECTURE = X64
        #ORIGINALPARTITIONIDENTIFIER = SELECT * FROM Win32_LogicalDisk WHERE Size = '498731053056' and VolumeName = 'OSDisk' and VolumeSerialNumber = '5AC885B9'
        OriginalWindir = $Win32OperatingSystem.WindowsDirectory
        OsCurrentBuild = $Win32OperatingSystem.BuildNumber
        OsCurrentVersion = $Win32OperatingSystem.Version
        #OsSku = Enterprise
        OsVersion = $Win32OperatingSystem.Version
        ProcessorSpeed = $Win32Processor.MaxClockSpeed
        Product = $Win32BaseBoard.Product
        SerialNumber = $Win32BIOS.SerialNumber
        #SupportsHyperVRole = $SupportsNX
        #SupportsSLAT = $Win32Processor.SecondLevelAddressTranslationExtensions
        SupportsX64 = $Supports64Bit
        SupportsX86 = $Supports32Bit
        UUID = $Win32ComputerSystemProduct.UUID
    }
    #======================================================================================================
    #   GetOSDGather
    #======================================================================================================
    $GetOSDGather = [ordered]@{
        #===================================================================================================
        #   Bool
        #===================================================================================================
        IsAdmin = $IsAdmin
        IsBDE = $IsBDE
        IsClientOS = $IsClientOS
        IsDesktop = $IsDesktop
        IsLaptop = $IsLaptop
        IsOnBattery = $IsOnBattery
        IsSFF = $IsSFF
        IsServer = $IsServer
        IsServerChassis = $IsServer
        IsServerCoreOS = $IsServerCoreOS
        IsServerOS = $IsServerOS
        IsTablet = $IsTablet
        IsUEFI = $IsUEFI
        IsVM = $IsVM
        IsWinPE = $IsWinPE
        IsInWinSE = $IsInWinSE
        #===================================================================================================
        #   MDT
        #===================================================================================================
        MDT = $GetOSDGatherMDT
        #===================================================================================================
        #   Registry
        #===================================================================================================
        RegControl = $RegControl
        RegSetup = $RegSetup
        RegVersion = $RegVersion
    }
    #===================================================================================================
    #   Full
    #===================================================================================================
    if ($Full.IsPresent) {
        #===================================================================================================
        #   Get-ComputerInfo
        #===================================================================================================
        #https://docs.microsoft.com/en-us/dotnet/api/microsoft.powershell.commands.computerinfo?view=powershellsdk-1.1.0
        $GetComputerInfo = @{}
        try {
            $GetComputerInfo = Get-ComputerInfo -ErrorAction SilentlyContinue
        }
        catch {}
        #===================================================================================================
        #   Get-CimInstance
        #===================================================================================================
        $Win32DiskPartition = (Get-CimInstance -ClassName Win32_DiskPartition | Select-Object -Property *)
        $Win32DisplayConfiguration = (Get-CimInstance -ClassName Win32_DisplayConfiguration | Select-Object -Property *)
        $Win32Environment = (Get-CimInstance -ClassName Win32_Environment | Select-Object -Property *)
        $Win32LogicalDisk = (Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property *)
        $Win32NetworkAdapter = (Get-CimInstance -ClassName Win32_NetworkAdapter | Select-Object -Property *)
        $Win32PnPEntity = (Get-CimInstance -ClassName Win32_PnPEntity | Select-Object -Property *)
        $Win32SCSIController = (Get-CimInstance -ClassName Win32_SCSIController | Select-Object -Property *)
        $Win32SystemDesktop = (Get-CimInstance -ClassName Win32_SystemDesktop | Select-Object -Property *)
        $Win32UserDesktop = (Get-CimInstance -ClassName Win32_UserDesktop | Select-Object -Property *)
        $Win32VideoController = (Get-CimInstance -ClassName Win32_VideoController | Select-Object -Property *)
        $Win32Volume = (Get-CimInstance -ClassName Win32_Volume | Select-Object -Property *)
        $CimVideoControllerResolution = (Get-CimInstance -ClassName CIM_VideoControllerResolution | Select-Object -Property *)
        #===================================================================================================
        #   Full
        #===================================================================================================
        $GetOSDGather.GetBitlockerVolume = $GetBitlockerVolume
        $GetOSDGather.GetPhysicalDisk = $GetPhysicalDisk
        
        $GetOSDGather.BIOS = $Win32BIOS
        $GetOSDGather.BaseBoard = $Win32BaseBoard
        $GetOSDGather.Battery = $Win32Battery
        $GetOSDGather.ComputerSystem = $Win32ComputerSystem
        $GetOSDGather.ComputerSystemProduct = $Win32ComputerSystemProduct
        $GetOSDGather.DiskPartition = $Win32DiskPartition
        $GetOSDGather.DisplayConfiguration = $Win32DisplayConfiguration
        $GetOSDGather.Environment = $Win32Environment
        $GetOSDGather.LogicalDisk = $Win32LogicalDisk
        $GetOSDGather.NetworkAdapter = $Win32NetworkAdapter
        $GetOSDGather.NetworkAdapterConfiguration = $Win32NetworkAdapterConfiguration
        $GetOSDGather.OperatingSystem = $Win32OperatingSystem
        $GetOSDGather.PnPEntity = $Win32PnPEntity
        $GetOSDGather.Processor = $Win32Processor
        $GetOSDGather.SCSIController = $Win32SCSIController
        $GetOSDGather.SystemDesktop = $Win32SystemDesktop
        $GetOSDGather.SystemEnclosure = $Win32SystemEnclosure
        $GetOSDGather.UserDesktop = $Win32UserDesktop
        $GetOSDGather.VideoController = $Win32VideoController
        $GetOSDGather.VideoControllerResolution = $CIMVideoControllerResolution
        $GetOSDGather.Volume = $Win32Volume
        
        $GetOSDGather.ComputerInfo = $GetComputerInfo
    }
    Return $GetOSDGather
}