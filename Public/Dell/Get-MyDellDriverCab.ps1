function Get-MyDellDriverCab {
    [CmdletBinding()]
    param ()

    Write-Verbose "Get-MyDellDriverCab: This function is currently in development"
    Write-Verbose "Get-MyDellDriverCab: Results are for Windows 10 x64 only"

    $ErrorActionPreference = 'SilentlyContinue'

    $GetOSDDriver = Get-OSDDriver -OSDGroup DellModel
    $GetOSDDriver = $GetOSDDriver | `
    Where-Object {$_.Model -eq (Get-MyComputerModel)} | `
    Where-Object {$_.OsVersion -eq '10.0'} | `
    Where-Object {$_.OsArch -eq 'x64'} | `
    Sort-Object LastUpdate -Descending | Select-Object -First 1

    Return $GetOSDDriver
}