Function Get-NativeMatchineImage {
    #Code from https://github.com/rweijnen/Posh-Snippets/blob/master/PoshWow64ApiSet
$source = @"
using System;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.ComponentModel;

public static class WinApi
{
    public const ushort IMAGE_FILE_MACHINE_UNKNOWN = 0;
    public const ushort IMAGE_FILE_MACHINE_TARGET_HOST = 0x0001; // Useful for indicating we want to interact with the host and not a WoW guest.
    public const ushort IMAGE_FILE_MACHINE_I386 = 0x014c; // Intel 386.
    public const ushort IMAGE_FILE_MACHINE_R3000 = 0x0162; // MIPS little-endian, = 0x160 big-endian
    public const ushort IMAGE_FILE_MACHINE_R4000 = 0x0166; // MIPS little-endian
    public const ushort IMAGE_FILE_MACHINE_R10000 = 0x0168; // MIPS little-endian
    public const ushort IMAGE_FILE_MACHINE_WCEMIPSV2 = 0x0169; // MIPS little-endian WCE v2
    public const ushort IMAGE_FILE_MACHINE_ALPHA = 0x0184; // Alpha_AXP
    public const ushort IMAGE_FILE_MACHINE_SH3 = 0x01a2; // SH3 little-endian
    public const ushort IMAGE_FILE_MACHINE_SH3DSP = 0x01a3;
    public const ushort IMAGE_FILE_MACHINE_SH3E = 0x01a4; // SH3E little-endian
    public const ushort IMAGE_FILE_MACHINE_SH4 = 0x01a6; // SH4 little-endian
    public const ushort IMAGE_FILE_MACHINE_SH5 = 0x01a8; // SH5
    public const ushort IMAGE_FILE_MACHINE_ARM = 0x01c0; // ARM Little-Endian
    public const ushort IMAGE_FILE_MACHINE_THUMB = 0x01c2; // ARM Thumb/Thumb-2 Little-Endian
    public const ushort IMAGE_FILE_MACHINE_ARMNT = 0x01c4; // ARM Thumb-2 Little-Endian
    public const ushort IMAGE_FILE_MACHINE_AM33 = 0x01d3;
    public const ushort IMAGE_FILE_MACHINE_POWERPC = 0x01F0; // IBM PowerPC Little-Endian
    public const ushort IMAGE_FILE_MACHINE_POWERPCFP = 0x01f1;
    public const ushort IMAGE_FILE_MACHINE_IA64 = 0x0200; // Intel 64
    public const ushort IMAGE_FILE_MACHINE_MIPS16 = 0x0266; // MIPS
    public const ushort IMAGE_FILE_MACHINE_ALPHA64 = 0x0284; // ALPHA64
    public const ushort IMAGE_FILE_MACHINE_MIPSFPU = 0x0366; // MIPS
    public const ushort IMAGE_FILE_MACHINE_MIPSFPU16 = 0x0466; // MIPS
    public const ushort IMAGE_FILE_MACHINE_AXP64 = IMAGE_FILE_MACHINE_ALPHA64;
    public const ushort IMAGE_FILE_MACHINE_TRICORE = 0x0520; // Infineon
    public const ushort IMAGE_FILE_MACHINE_CEF = 0x0CEF;
    public const ushort IMAGE_FILE_MACHINE_EBC = 0x0EBC; // EFI Byte Code
    public const ushort IMAGE_FILE_MACHINE_AMD64 = 0x8664; // AMD64 (K8)
    public const ushort IMAGE_FILE_MACHINE_M32R = 0x9041; // M32R little-endian
    public const ushort IMAGE_FILE_MACHINE_ARM64 = 0xAA64; // ARM64 Little-Endian
    public const ushort IMAGE_FILE_MACHINE_CEE = 0xC0EE;

    public const UInt32 S_OK = 0;

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern UInt32 IsWow64GuestMachineSupported(ushort WowGuestMachine, out bool MachineIsSupported);

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool IsWow64Process2(IntPtr hProcess, out ushort pProcessMachine, out ushort pNativeMachine);

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr GetCurrentProcess();

    public static string MachineTypeToStr(ushort MachineType)
    {
        switch (MachineType)
        {
            case IMAGE_FILE_MACHINE_UNKNOWN:
                return "IMAGE_FILE_MACHINE_UNKNOWN";
            case IMAGE_FILE_MACHINE_TARGET_HOST:
                return "IMAGE_FILE_MACHINE_TARGET_HOST";
            case IMAGE_FILE_MACHINE_I386:
                return "IMAGE_FILE_MACHINE_I386";
            case IMAGE_FILE_MACHINE_R3000:
                return "IMAGE_FILE_MACHINE_R3000";
            case IMAGE_FILE_MACHINE_R4000:
                return "IMAGE_FILE_MACHINE_R4000";
            case IMAGE_FILE_MACHINE_R10000:
                return "IMAGE_FILE_MACHINE_R10000";
            case IMAGE_FILE_MACHINE_WCEMIPSV2:
                return "IMAGE_FILE_MACHINE_WCEMIPSV2";
            case IMAGE_FILE_MACHINE_ALPHA:
                return "IMAGE_FILE_MACHINE_ALPHA";
            case IMAGE_FILE_MACHINE_SH3:
                return "IMAGE_FILE_MACHINE_SH3";
            case IMAGE_FILE_MACHINE_SH3DSP:
                return "IMAGE_FILE_MACHINE_SH3DSP";
            case IMAGE_FILE_MACHINE_SH3E:
                return "IMAGE_FILE_MACHINE_SH3E";
            case IMAGE_FILE_MACHINE_SH4:
                return "IMAGE_FILE_MACHINE_SH4";
            case IMAGE_FILE_MACHINE_SH5:
                return "IMAGE_FILE_MACHINE_SH5";
            case IMAGE_FILE_MACHINE_ARM:
                return "IMAGE_FILE_MACHINE_ARM";
            case IMAGE_FILE_MACHINE_THUMB:
                return "IMAGE_FILE_MACHINE_THUMB";
            case IMAGE_FILE_MACHINE_ARMNT:
                return "IMAGE_FILE_MACHINE_ARMNT";
            case IMAGE_FILE_MACHINE_AM33:
                return "IMAGE_FILE_MACHINE_AM33";
            case IMAGE_FILE_MACHINE_POWERPC:
                return "IMAGE_FILE_MACHINE_POWERPC";
            case IMAGE_FILE_MACHINE_POWERPCFP:
                return "IMAGE_FILE_MACHINE_POWERPCFP";
            case IMAGE_FILE_MACHINE_IA64:
                return "IMAGE_FILE_MACHINE_IA64";
            case IMAGE_FILE_MACHINE_MIPS16:
                return "IMAGE_FILE_MACHINE_MIPS16";
            case IMAGE_FILE_MACHINE_ALPHA64:
                return "IMAGE_FILE_MACHINE_ALPHA64";
            case IMAGE_FILE_MACHINE_MIPSFPU:
                return "IMAGE_FILE_MACHINE_MIPSFPU";
            case IMAGE_FILE_MACHINE_MIPSFPU16:
                return "IMAGE_FILE_MACHINE_MIPSFPU16";
            case IMAGE_FILE_MACHINE_TRICORE:
                return "IMAGE_FILE_MACHINE_TRICORE";
            case IMAGE_FILE_MACHINE_CEF:
                return "IMAGE_FILE_MACHINE_CEF";
            case IMAGE_FILE_MACHINE_EBC:
                return "IMAGE_FILE_MACHINE_EBC";
            case IMAGE_FILE_MACHINE_AMD64:
                return "IMAGE_FILE_MACHINE_AMD64";
            case IMAGE_FILE_MACHINE_M32R:
                return "IMAGE_FILE_MACHINE_M32R";
            case IMAGE_FILE_MACHINE_ARM64:
                return "IMAGE_FILE_MACHINE_ARM64";
            case IMAGE_FILE_MACHINE_CEE:
                return "IMAGE_FILE_MACHINE_CEE";
            default:
                return "Unknown Machine Type";
        }
    }
}
"@
    
    Add-Type $source
    
    $ReturnTable = New-Object -TypeName PSObject
    
    
    [bool]$MachineIsSupported = $false
    $hr = [WinApi]::IsWow64GuestMachineSupported([WinApi]::IMAGE_FILE_MACHINE_I386, [ref]$MachineIsSupported)
    if ($hr -eq [WinApi]::S_OK){
        #$ReturnTable | Add-Member -MemberType NoteProperty -Name "IsWow64GuestMachineSupported IMAGE_FILE_MACHINE_I386" -Value $MachineIsSupported -Force	
    }
    
    [UInt16]$processMachine = 0;
    [UInt16]$nativeMachine = 0;
    $bResult = [WinApi]::IsWow64Process2([WinApi]::GetCurrentProcess(), [ref]$processMachine, [ref]$nativeMachine);
    if ($bResult){
        $Value = $([WinApi]::MachineTypeToStr($nativeMachine))
        $Value = $Value.Split("_") | Select-Object -Last 1
        $ReturnTable | Add-Member -MemberType NoteProperty -Name "NativeMachine" -Value $Value -Force
    
        $Value = $([WinApi]::MachineTypeToStr($processMachine))
        $Value = $Value.Split("_") | Select-Object -Last 1
        $ReturnTable | Add-Member -MemberType NoteProperty -Name "ProcessMachine" -Value $Value -Force
    }
    
    return $ReturnTable
}
    