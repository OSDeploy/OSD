<#
.SYNOPSIS
Gets many Windows ADK Paths into a hash to easily use in your code

.DESCRIPTION
Gets many Windows ADK Paths into a hash to easily use in your code

.LINK
https://osd.osdeploy.com/module/functions/adk

.NOTES
21.3.15.2   Renamed to make it easier to understand what it does
21.3.10     Initial Release
#>
function Get-AdkPaths {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('amd64','x86')]
        [string]$Arch = $Env:PROCESSOR_ARCHITECTURE
    )
    
    #=================================================
    #   Get-AdkPaths AdkRoot
    #=================================================
    $InstalledRoots32 = 'HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots'
    $InstalledRoots64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots'
    if (Test-Path $InstalledRoots64) {
        $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots64 -Name 'KitsRoot10'
    }
    elseif (Test-Path $InstalledRoots32) {
        $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots64 -Name 'KitsRoot10'
    }
    else {
        Write-Warning "Unable to determine ADK Path"
        Break
    }
    $AdkRoot = Join-Path $KitsRoot10 'Assessment and Deployment Kit'
    #=================================================
    #   WinPERoot
    #=================================================
    $WinPERoot = Join-Path $AdkRoot 'Windows Preinstallation Environment'
    if (-NOT (Test-Path $WinPERoot -PathType Container)) {
        Write-Warning "Cannot find WinPERoot: $WinPERoot"
        $WinPERoot = $null
    }
    #=================================================
    #   PathDeploymentTools
    #=================================================
    $PathDeploymentTools = Join-Path $AdkRoot (Join-Path 'Deployment Tools' $Arch)
    $PathWinPE = Join-Path $WinPERoot $Arch
    #=================================================
    #   Create Object
    #=================================================
    $Results = [PSCustomObject] @{
        #KitsRoot           = $KitsRoot10
        AdkRoot             = $AdkRoot
        PathBCDBoot         = Join-Path $PathDeploymentTools 'BCDBoot'
        PathDeploymentTools = $PathDeploymentTools
        PathDISM            = Join-Path $PathDeploymentTools 'DISM'
        PathOscdimg         = Join-Path $PathDeploymentTools 'Oscdimg'
        PathUsmt            = Join-Path $AdkRoot (Join-Path 'User State Migration Tool' $Arch)
        PathWinPE           = Join-Path $WinPERoot $Arch
        PathWinPEMedia      = Join-Path $PathWinPE 'Media'
        PathWinSetup        = Join-Path $AdkRoot (Join-Path 'Windows Setup' $Arch)
        WinPEOCs            = Join-Path $PathWinPE 'WinPE_OCs'
        WinPERoot           = $WinPERoot
        WimSourcePath       = Join-Path $PathWinPE 'en-us\winpe.wim'

        bcdbootexe          = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bcdboot.exe')
        bcdeditexe          = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bcdedit.exe')
        bootsectexe         = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bootsect.exe')
        dismexe             = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'bootsect.exe')
        efisysbin           = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'efisys.bin')
        efisysnopromptbin   = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'efisys_noprompt.bin')
        etfsbootcom         = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'etfsboot.com')
        imagexexe           = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'imagex.exe')
        oa3toolexe          = Join-Path $PathDeploymentTools (Join-Path 'Licensing\OA30' 'oa3tool.exe')
        oscdimgexe          = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'oscdimg.exe')
        pkgmgrexe           = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'pkgmgr.exe')
    }
    Return $Results
}