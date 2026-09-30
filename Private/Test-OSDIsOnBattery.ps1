function Test-OSDIsOnBattery {
    <#
    .SYNOPSIS
    Tests whether the computer is running on battery power.

    .DESCRIPTION
    Calls the native Windows GetSystemPowerStatus API and returns true only
    when the AC power status is confirmed as offline. Returns false when the
    computer is connected to AC power, the status is unknown, or the native
    status cannot be determined.

    .EXAMPLE
    Test-OSDIsOnBattery
    Returns true when the computer is running on battery power; otherwise,
    returns false.

    .OUTPUTS
    System.Boolean

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-09-30 - Added native battery power detection
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    try {
        if (-not ([System.Management.Automation.PSTypeName]'OSD.Interop.NativePower').Type) {
            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

namespace OSD.Interop
{
    [StructLayout(LayoutKind.Sequential)]
    public struct SystemPowerStatus
    {
        public byte ACLineStatus;
        public byte BatteryFlag;
        public byte BatteryLifePercent;
        public byte SystemStatusFlag;
        public uint BatteryLifeTime;
        public uint BatteryFullLifeTime;
    }

    public static class NativePower
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool GetSystemPowerStatus(out SystemPowerStatus systemPowerStatus);
    }
}
'@ -ErrorAction Stop
        }

        $SystemPowerStatus = New-Object -TypeName OSD.Interop.SystemPowerStatus
        if (-not [OSD.Interop.NativePower]::GetSystemPowerStatus([ref]$SystemPowerStatus)) {
            return [System.Boolean]$false
        }

        return [System.Boolean]($SystemPowerStatus.ACLineStatus -eq 0)
    }
    catch {
        return [System.Boolean]$false
    }
}
