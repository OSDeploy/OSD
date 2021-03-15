function Start-ScreenPNGProcess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory,

        [uint32]$Delay = 2,

        [uint32]$Count = 9999
    )

    $StartInfo = new-object System.Diagnostics.ProcessStartInfo
    $StartInfo.FileName = 'powershell.exe'
    $StartInfo.Arguments = "-NoExit -WindowStyle Hidden -Command Get-ScreenPNG -Directory $Directory -Count $Count -Delay $Delay"
    $Global:ScreenPNGPath = $Directory
    $Global:ScreenPNGProcess = ([System.Diagnostics.Process]::Start($StartInfo)).Id
}