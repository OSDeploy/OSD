function Stop-ScreenPNGProcess {
    [CmdletBinding()]
    param ()

    Stop-Process -Id $Global:ScreenPNGProcess -Force -ErrorAction SilentlyContinue
}