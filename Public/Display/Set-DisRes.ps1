<#
.SYNOPSIS
Sets the Primary Display Screen Resolution

.DESCRIPTION
Sets the Primary Display Screen Resolution

.LINK
https://osd.osdeploy.com/module/functions/display/set-disres

.NOTES
21.2.1 Initial Release

#>
function Set-DisRes {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias('Horizontal')]
        [string]$Width,

        [Parameter(Position = 1)]
        [Alias('Vertical')]
        [string]$Height
    )

$Code = @" 
using System; 
using System.Runtime.InteropServices; 
namespace Resolution 
{ 
    [StructLayout(LayoutKind.Sequential)] 
    public struct DEVMODE1 
    { 
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] 
        public string dmDeviceName; 
        public short dmSpecVersion; 
        public short dmDriverVersion; 
        public short dmSize; 
        public short dmDriverExtra; 
        public int dmFields; 
        public short dmOrientation; 
        public short dmPaperSize; 
        public short dmPaperLength; 
        public short dmPaperWidth; 
        public short dmScale; 
        public short dmCopies; 
        public short dmDefaultSource; 
        public short dmPrintQuality; 
        public short dmColor; 
        public short dmDuplex; 
        public short dmYResolution; 
        public short dmTTOption; 
        public short dmCollate; 
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] 
        public string dmFormName; 
        public short dmLogPixels; 
        public short dmBitsPerPel; 
        public int dmPelsWidth; 
        public int dmPelsHeight; 
        public int dmDisplayFlags; 
        public int dmDisplayFrequency; 
        public int dmICMMethod; 
        public int dmICMIntent; 
        public int dmMediaType; 
        public int dmDitherType; 
        public int dmReserved1; 
        public int dmReserved2; 
        public int dmPanningWidth; 
        public int dmPanningHeight; 
    }; 
    class User_32 
    { 
        [DllImport("user32.dll")] 
        public static extern int EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE1 devMode); 
        [DllImport("user32.dll")] 
        public static extern int ChangeDisplaySettings(ref DEVMODE1 devMode, int flags); 
        public const int ENUM_CURRENT_SETTINGS = -1; 
        public const int CDS_UPDATEREGISTRY = 0x01; 
        public const int CDS_TEST = 0x02; 
        public const int DISP_CHANGE_SUCCESSFUL = 0; 
        public const int DISP_CHANGE_RESTART = 1; 
        public const int DISP_CHANGE_FAILED = -1; 
    } 
    public class PrmaryScreenResolution 
    { 
        static public string ChangeResolution(int width, int height) 
        { 
            DEVMODE1 dm = GetDevMode1(); 
            if (0 != User_32.EnumDisplaySettings(null, User_32.ENUM_CURRENT_SETTINGS, ref dm)) 
            { 
                dm.dmPelsWidth = width; 
                dm.dmPelsHeight = height; 
                int iRet = User_32.ChangeDisplaySettings(ref dm, User_32.CDS_TEST); 
                if (iRet == User_32.DISP_CHANGE_FAILED) 
                { 
                    return "Unable To Process Your Request. Sorry For This Inconvenience."; 
                } 
                else 
                { 
                    iRet = User_32.ChangeDisplaySettings(ref dm, User_32.CDS_UPDATEREGISTRY); 
                    switch (iRet) 
                    { 
                        case User_32.DISP_CHANGE_SUCCESSFUL: 
                            { 
                                return "DisRes successfully changed the Display Resolution"; 
                            } 
                        case User_32.DISP_CHANGE_RESTART: 
                            { 
                                return "DisRes needs to restart to change the Display Resolution"; 
                            } 
                        default: 
                            { 
                                return "DisRes failed to change the Display Resolution"; 
                            } 
                    } 
                } 
            } 
            else 
            { 
                return "Failed To Change The Resolution."; 
            } 
        } 
        private static DEVMODE1 GetDevMode1() 
        { 
            DEVMODE1 dm = new DEVMODE1(); 
            dm.dmDeviceName = new String(new char[32]); 
            dm.dmFormName = new String(new char[32]); 
            dm.dmSize = (short)Marshal.SizeOf(dm); 
            return dm; 
        } 
    } 
} 
"@ 
    Add-Type $Code -ErrorAction SilentlyContinue

    #Check if we need to Restore the previous settings
    if ($Width -eq 'Restore')  {
        if ($null -eq $Global:SetDisRes) {
            Write-Warning "Unable to Restore previous Display Settings"
            Break
        } else {
            $Width = $Global:SetDisRes.Width;
            $Height = $Global:SetDisRes.Height;
        }
    } else {
        #Set a Restore only for this PowerShell session
        $Global:SetDisRes = Get-DisplayPrimaryBitmapSize
    }
    
    if ($Width -and $Height) {
        #Do Nothing
    } elseif ($Width) {
        if ($Width -eq '720p')  {[int]$Width = 1280;[int]$Height = 720}
        if ($Width -eq '1080p') {[int]$Width = 1920;$Height = 1080}
        if ($Width -eq '4k')    {[int]$Width = 3840;$Height = 2160}

        if ($Width -eq 1280) {$Height = 600}    #2.13333333333333
        if ($Width -eq 1280) {$Height = 768}    #1.66666666666667
        if ($Width -eq 1280) {$Height = 800}    #1.6
        if ($Width -eq 1280) {$Height = 1024}   #1.25
        if ($Width -eq 1360) {$Height = 768}    #1.77083333333333
        if ($Width -eq 1366) {$Height = 768}    #1.77864583333333
        if ($Width -eq 1440) {$Height = 900}    #1.6
        if ($Width -eq 1680) {$Height = 1050}   #1.6
        if ($Width -eq 1920) {$Height = 1200}   #1.6
        if ($Width -eq 2560) {$Height = 1600}   #1.6
        if ($Width -eq 2560) {$Height = 2048}   #1.25
        if ($Width -eq 5120) {$Height = 1440}   #3.55555555555555

        #4:3
        if ($Width -eq 800)  {$Height = 600}    #4:3
        if ($Width -eq 1024) {$Height = 768}    #4:3
        if ($Width -eq 1152) {$Height = 864}    #4:3
        if ($Width -eq 1280) {$Height = 960}    #4:3
        if ($Width -eq 1400) {$Height = 1050}   #4:3
        if ($Width -eq 1600) {$Height = 1200}   #4:3
        if ($Width -eq 1792) {$Height = 1344}   #4:3
        if ($Width -eq 1856) {$Height = 1392}   #4:3
        if ($Width -eq 1920) {$Height = 1440}   #4:3
        if ($Width -eq 2048) {$Height = 1536}   #4:3
        if ($Width -eq 2560) {$Height = 1920}   #4:3

        #16:9
        if ($Width -eq 1280) {$Height = 720}    #16:9
        if ($Width -eq 1600) {$Height = 900}    #16:9
        if ($Width -eq 1920) {$Height = 1080}   #16:9
        if ($Width -eq 2048) {$Height = 1152}   #16:9
        if ($Width -eq 3840) {$Height = 2160}   #16:9

        Write-Verbose "Height (Vertical Resolution) was automatically set to $Height"
    } elseif ($Height) {
        Write-Warning "Height (Vertical Resolution) was not set"
        Break
    } else {
        #Set Defauts
        [int]$Width = 1920
        [int]$Height = 1080
    }

    [int]$IntWidth = $Width
    [int]$IntHeight = $Height

    Write-Verbose "Width: $IntWidth"
    Write-Verbose "Height: $IntHeight"

    $Result = [Resolution.PrmaryScreenResolution]::ChangeResolution([int]$IntWidth,[int]$IntHeight) 
    
    if ($Result -eq 'DisRes successfully changed the Display Resolution') {
        #Do Nothing
    } else {
        Write-Warning "$Result"
    }
}