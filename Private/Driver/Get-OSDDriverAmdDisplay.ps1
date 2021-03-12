function Get-OSDDriverAmdDisplay {
    [CmdletBinding()]
    param ()

    $ModuleAmdDisplay = @()
    $ModuleAmdDisplay = Get-ChildItem "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\OSDDriver\AmdDisplay" *.drvpack -Recurse | Select-Object FullName

    $AmdDisplay = @()
    $AmdDisplay = foreach ($item in $ModuleAmdDisplay) {
        Get-Content $item.FullName | ConvertFrom-Json
    }
    $AmdDisplay = $AmdDisplay | Sort-Object -Property LastUpdate -Descending
    Return $AmdDisplay
}