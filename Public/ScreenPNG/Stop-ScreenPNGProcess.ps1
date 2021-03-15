function Stop-ScreenPNGProcess {
    [CmdletBinding()]
    param ()

    Stop-Process -Id $Global:ScreenPNGProcess -Force -ErrorAction SilentlyContinue
    $Global:ScreenPNGPath = $null
    $Global:ScreenPNGProcess = $null
}