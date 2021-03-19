function Get-MyDellDriverCab {
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = 'SilentlyContinue'
    #=======================================================================
    #   Require Dell Computer
    #=======================================================================
    if ((Get-MyComputerManufacturer -Brief) -ne 'Dell') {
        Write-Warning "Dell computer is required for this function"
        Return $null
    }

    Write-Verbose "Get-MyDellDriverCab: This function is currently in development"
    Write-Verbose "Get-MyDellDriverCab: Results are for Windows 10 x64 only"
    #=======================================================================
    #   Get-DellCatalogPC
    #=======================================================================
<#     $GetOSDDriver = Get-OSDDriver -OSDGroup DellModel
    $GetOSDDriver = $GetOSDDriver | `
    Where-Object {$_.Model -eq (Get-MyComputerModel)} | `
    Where-Object {$_.OsVersion -eq '10.0'} | `
    Where-Object {$_.OsArch -eq 'x64'} | `
    Sort-Object LastUpdate -Descending | Select-Object -First 1 #>

    $GetMyDellDriverCab = Import-Clixml "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Catalogs\OSD-Dell-DriverPackCatalog.xml"
    $GetMyComputerModel = Get-MyComputerModel
    #=======================================================================
    #   Filter Compatible
    #=======================================================================
    $GetMyDellDriverCab = $GetMyDellDriverCab | `
        Where-Object {$_.Model -eq ($GetMyComputerModel)} | `
        Where-Object {$_.OsArch -eq 'x64'} | `
        Where-Object {$_.OsVersion -eq '10.0'}
    #=======================================================================
    #   Pick and Sort
    #=======================================================================
    $GetMyDellDriverCab = $GetMyDellDriverCab | Sort-Object LastUpdate -Descending | Select-Object -First 1
    #=======================================================================
    #   Return
    #=======================================================================
    Return $GetMyDellDriverCab
}